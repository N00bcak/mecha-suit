#!/usr/bin/env python3
"""Render or run host-neutral interaction evaluations through a host adapter.

The Codex adapter uses structured inputs for explicit skills and labels
implicit skill-file-read observations as heuristic.
"""

from __future__ import annotations

import argparse
import json
import queue
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CORPUS = ROOT / "evals" / "interaction-boundary.json"
VALID_SPLITS = {"train", "validation"}
VALID_KINDS = {"trigger", "interaction"}


class AppServerError(RuntimeError):
    """Raised when the Codex app-server protocol cannot complete a request."""


class AppServerClient:
    """Small synchronous JSON-RPC client for Codex's stdio app server."""

    def __init__(
        self, command: list[str] | None = None, *,
        env: dict[str, str] | None = None, cwd: Path | None = None,
    ) -> None:
        self.process = subprocess.Popen(
            command or ["codex", "app-server", "--stdio"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            env=env,
            cwd=cwd,
        )
        self.messages: queue.Queue[dict[str, Any] | None] = queue.Queue()
        self.backlog: list[dict[str, Any]] = []
        self.stderr_lines: list[str] = []
        self.next_request_id = 1
        self.stdout_thread = threading.Thread(target=self._read_stdout, daemon=True)
        self.stderr_thread = threading.Thread(target=self._read_stderr, daemon=True)
        self.stdout_thread.start()
        self.stderr_thread.start()

    def _read_stdout(self) -> None:
        assert self.process.stdout is not None
        for line in self.process.stdout:
            try:
                self.messages.put(json.loads(line))
            except json.JSONDecodeError:
                self.messages.put({"_malformed": line.rstrip("\n")})
        self.messages.put(None)

    def _read_stderr(self) -> None:
        assert self.process.stderr is not None
        self.stderr_lines.extend(self.process.stderr)

    def _send(self, message: dict[str, Any]) -> None:
        if self.process.stdin is None or self.process.poll() is not None:
            raise AppServerError("Codex app server is not running")
        self.process.stdin.write(json.dumps(message, separators=(",", ":")) + "\n")
        self.process.stdin.flush()

    def _next_message(self, deadline: float) -> dict[str, Any]:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError("timed out waiting for Codex app server")
        try:
            message = self.messages.get(timeout=remaining)
        except queue.Empty as error:
            raise TimeoutError("timed out waiting for Codex app server") from error
        if message is None:
            stderr = "".join(self.stderr_lines).strip()
            detail = f": {stderr}" if stderr else ""
            raise AppServerError(f"Codex app server exited unexpectedly{detail}")
        if "_malformed" in message:
            raise AppServerError(f"invalid JSON from Codex app server: {message['_malformed']}")
        return message

    def request(self, method: str, params: dict[str, Any], timeout: int) -> Any:
        request_id = self.next_request_id
        self.next_request_id += 1
        self._send({"id": request_id, "method": method, "params": params})
        deadline = time.monotonic() + timeout
        while True:
            message = self._next_message(deadline)
            if message.get("id") == request_id and "method" not in message:
                if "error" in message:
                    raise AppServerError(f"{method} failed: {message['error']}")
                return message.get("result")
            if "id" in message and "method" in message:
                raise AppServerError(
                    f"unsupported app-server request during {method}: {message['method']}"
                )
            self.backlog.append(message)

    def notify(self, method: str) -> None:
        self._send({"method": method})

    def next_notification(self, timeout: int) -> dict[str, Any]:
        if self.backlog:
            return self.backlog.pop(0)
        message = self._next_message(time.monotonic() + timeout)
        if "id" in message and "method" in message:
            raise AppServerError(f"unsupported app-server request: {message['method']}")
        return message

    def initialize(self, timeout: int) -> None:
        self.request(
            "initialize",
            {
                "clientInfo": {"name": "mecha-suit-evals", "version": "1"},
                "capabilities": {"experimentalApi": True},
            },
            timeout,
        )
        self.notify("initialized")

    @property
    def stderr(self) -> str:
        return "".join(self.stderr_lines).strip()

    def close(self) -> None:
        if self.process.stdin is not None and not self.process.stdin.closed:
            try:
                self.process.stdin.close()
            except BrokenPipeError:
                pass
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=5)
        self.stdout_thread.join(timeout=1)
        self.stderr_thread.join(timeout=1)
        if self.process.stdout is not None and not self.process.stdout.closed:
            self.process.stdout.close()
        if self.process.stderr is not None and not self.process.stderr.closed:
            self.process.stderr.close()

    def __enter__(self) -> AppServerClient:
        return self

    def __exit__(self, *_: object) -> None:
        self.close()


def skill_names(root: Path = ROOT) -> set[str]:
    return {
        skill_file.parent.name
        for skill_file in (root / "families").glob("*/*/SKILL.md")
    }


def load_corpus(path: Path = DEFAULT_CORPUS) -> dict[str, Any]:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read evaluation corpus: {error}") from error
    failures = validate_corpus(document)
    if failures:
        raise ValueError("invalid evaluation corpus:\n- " + "\n- ".join(failures))
    return document


def validate_corpus(document: Any, known_skills: set[str] | None = None) -> list[str]:
    failures: list[str] = []
    if not isinstance(document, dict):
        return ["document must be an object"]
    if document.get("schema_version") != 1:
        failures.append("schema_version must be 1")
    if not isinstance(document.get("default_runs"), int) or document["default_runs"] < 1:
        failures.append("default_runs must be a positive integer")
    threshold = document.get("trigger_threshold")
    if not isinstance(threshold, (int, float)) or not 0 < threshold < 1:
        failures.append("trigger_threshold must be between 0 and 1")

    cases = document.get("cases")
    if not isinstance(cases, list) or not cases:
        return failures + ["cases must be a non-empty list"]

    known_skills = known_skills if known_skills is not None else skill_names()
    seen_ids: set[str] = set()
    for index, case in enumerate(cases):
        prefix = f"cases[{index}]"
        if not isinstance(case, dict):
            failures.append(f"{prefix} must be an object")
            continue
        case_id = case.get("id")
        if not isinstance(case_id, str) or not case_id:
            failures.append(f"{prefix}.id must be a non-empty string")
            case_id = prefix
        elif case_id in seen_ids:
            failures.append(f"duplicate case id {case_id!r}")
        seen_ids.add(case_id)
        prefix = case_id

        if case.get("split") not in VALID_SPLITS:
            failures.append(f"{prefix}: split must be train or validation")
        kind = case.get("kind")
        if kind not in VALID_KINDS:
            failures.append(f"{prefix}: kind must be trigger or interaction")

        available = case.get("available_skills")
        if not isinstance(available, list) or not available or not all(
            isinstance(value, str) for value in available
        ):
            failures.append(f"{prefix}: available_skills must be a non-empty string list")
            available_set: set[str] = set()
        else:
            available_set = set(available)
            unknown = available_set - known_skills
            if unknown:
                failures.append(f"{prefix}: unknown skills: {', '.join(sorted(unknown))}")

        turns = case.get("turns")
        if not isinstance(turns, list) or not turns:
            failures.append(f"{prefix}: turns must be a non-empty list")
            turns = []
        if kind == "trigger" and len(turns) != 1:
            failures.append(f"{prefix}: trigger cases must contain exactly one turn")
        for turn_index, turn in enumerate(turns):
            turn_prefix = f"{prefix}.turns[{turn_index}]"
            if not isinstance(turn, dict):
                failures.append(f"{turn_prefix} must be an object")
                continue
            if not isinstance(turn.get("prompt"), str) or not turn["prompt"].strip():
                failures.append(f"{turn_prefix}.prompt must be a non-empty string")
            invocations = turn.get("explicit_invocations")
            if not isinstance(invocations, list) or not all(
                isinstance(value, str) for value in invocations
            ):
                failures.append(f"{turn_prefix}.explicit_invocations must be a string list")
            elif not set(invocations) <= available_set:
                failures.append(f"{turn_prefix}: explicit invocation is not available")

        expected = case.get("expected")
        if not isinstance(expected, dict):
            failures.append(f"{prefix}: expected must be an object")
            continue
        loaded = expected.get("loaded_skills")
        excluded = expected.get("excluded_skills")
        behaviors = expected.get("behaviors")
        for field, value in (("loaded_skills", loaded), ("excluded_skills", excluded)):
            if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
                failures.append(f"{prefix}: expected.{field} must be a string list")
        if isinstance(loaded, list) and isinstance(excluded, list):
            if set(loaded) & set(excluded):
                failures.append(f"{prefix}: loaded and excluded skills overlap")
            if not (set(loaded) | set(excluded)) <= available_set:
                failures.append(f"{prefix}: expected skill is not available")
        if not isinstance(behaviors, list) or not all(isinstance(item, str) for item in behaviors):
            failures.append(f"{prefix}: expected.behaviors must be a string list")
        elif kind == "interaction" and not behaviors:
            failures.append(f"{prefix}: interaction cases require observable behaviors")
    return failures


def select_cases(
    corpus: dict[str, Any], split: str, requested_ids: list[str]
) -> list[dict[str, Any]]:
    cases = [
        case
        for case in corpus["cases"]
        if split == "all" or case["split"] == split
    ]
    if requested_ids:
        requested = set(requested_ids)
        available = {case["id"] for case in cases}
        missing = requested - available
        if missing:
            raise ValueError(f"unknown or excluded case ids: {', '.join(sorted(missing))}")
        cases = [case for case in cases if case["id"] in requested]
    return cases


def render_turn(turn: dict[str, Any], host: str) -> str:
    if host != "codex":
        raise ValueError(f"unsupported host: {host}")
    invocations = " ".join(f"${name}" for name in turn["explicit_invocations"])
    return f"{invocations} {turn['prompt']}".strip()


def dry_run(cases: list[dict[str, Any]], host: str) -> dict[str, Any]:
    return {
        "host": host,
        "mode": "dry-run",
        "cases": [
            {
                "id": case["id"],
                "kind": case["kind"],
                "turns": [render_turn(turn, host) for turn in case["turns"]],
                "expected": case["expected"],
            }
            for case in cases
        ],
    }


def link_skills(workspace: Path, names: list[str]) -> None:
    target = workspace / ".agents" / "skills"
    target.mkdir(parents=True)
    by_name = {
        skill_file.parent.name: skill_file.parent
        for skill_file in (ROOT / "families").glob("*/*/SKILL.md")
    }
    for name in names:
        (target / name).symlink_to(by_name[name], target_is_directory=True)


def skill_path(workspace: Path, name: str) -> Path:
    return workspace / ".agents" / "skills" / name / "SKILL.md"


def turn_input(turn: dict[str, Any], workspace: Path) -> list[dict[str, str]]:
    inputs = [{"type": "text", "text": render_turn(turn, "codex")}]
    inputs.extend(
        {"type": "skill", "name": name, "path": str(skill_path(workspace, name))}
        for name in turn["explicit_invocations"]
    )
    return inputs


def skill_filter_config(
    listed_skills: list[dict[str, Any]], workspace: Path, available_skills: list[str]
) -> dict[str, Any]:
    candidate_paths = {
        skill_path(workspace, name).resolve()
        for name in available_skills
    }
    disabled: list[dict[str, Any]] = []
    for skill in listed_skills:
        path = skill.get("path")
        if not isinstance(path, str):
            continue
        try:
            resolved = Path(path).resolve()
        except OSError:
            resolved = Path(path)
        if resolved not in candidate_paths:
            disabled.append({"path": path, "enabled": False})
    config: dict[str, Any] = {"user_instructions": ""}
    if disabled:
        config["skills"] = {"config": disabled}
    return config


def observe_skill_reads(item: dict[str, Any], candidates: list[str]) -> set[str]:
    if item.get("type") != "commandExecution":
        return set()
    serialized = json.dumps(item, sort_keys=True)
    return {
        name
        for name in candidates
        if f"/{name}/SKILL.md" in serialized or f"\\{name}\\SKILL.md" in serialized
    }


def collect_turn(
    client: AppServerClient,
    thread_id: str,
    turn_id: str,
    candidates: list[str],
    timeout: int,
    on_event: Callable[[dict[str, Any]], None] | None = None,
) -> dict[str, Any]:
    messages: list[str] = []
    warnings: list[str] = []
    observed: set[str] = set()
    deadline = time.monotonic() + timeout
    status = "inProgress"
    error: Any = None

    while status == "inProgress":
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError(f"turn {turn_id} timed out after {timeout} seconds")
        notification = client.next_notification(max(1, int(remaining + 0.999)))
        method = notification.get("method")
        params = notification.get("params")
        if not isinstance(params, dict):
            continue
        notification_thread = params.get("threadId")
        if notification_thread is not None and notification_thread != thread_id:
            continue

        if on_event is not None:
            on_event(notification)

        if method == "warning" and isinstance(params.get("message"), str):
            warnings.append(params["message"])
            continue
        if method == "item/completed" and params.get("turnId") == turn_id:
            item = params.get("item")
            if not isinstance(item, dict):
                continue
            if item.get("type") == "agentMessage" and isinstance(item.get("text"), str):
                messages.append(item["text"])
            observed.update(observe_skill_reads(item, candidates))
            continue
        if method == "turn/completed":
            turn = params.get("turn")
            if not isinstance(turn, dict) or turn.get("id") != turn_id:
                continue
            status = str(turn.get("status", "failed"))
            error = turn.get("error")

    return {
        "turn_id": turn_id,
        "status": status,
        "agent_messages": messages,
        "final_response": messages[-1] if messages else "",
        "warnings": warnings,
        "observed_skill_reads": sorted(observed),
        "error": error,
    }


def listed_skills_for_workspace(
    client: AppServerClient, workspace: Path, timeout: int
) -> list[dict[str, Any]]:
    response = client.request(
        "skills/list",
        {"cwds": [str(workspace)], "forceReload": True},
        timeout,
    )
    data = response.get("data") if isinstance(response, dict) else None
    if not isinstance(data, list) or not data:
        raise AppServerError("skills/list returned no workspace entry")
    entry = data[0]
    if not isinstance(entry, dict):
        raise AppServerError("skills/list returned an invalid workspace entry")
    errors = entry.get("errors")
    if isinstance(errors, list) and errors:
        raise AppServerError(f"skills/list reported errors: {errors}")
    skills = entry.get("skills")
    if not isinstance(skills, list):
        raise AppServerError("skills/list returned no skill metadata")
    return [skill for skill in skills if isinstance(skill, dict)]


def classify_run(
    case: dict[str, Any],
    observed: set[str],
    explicit_bindings: set[str],
    completed: bool,
    skill_warnings: list[str] | None = None,
) -> str:
    if not completed:
        return "inconclusive"
    if skill_warnings:
        return "inconclusive"
    expected = case["expected"]
    loaded_evidence = observed | explicit_bindings
    if loaded_evidence & set(expected["excluded_skills"]):
        return "failed"
    missing = set(expected["loaded_skills"]) - loaded_evidence
    if not missing:
        return "passed"
    return "failed"


def run_classification(
    case: dict[str, Any],
    observed: set[str],
    explicit_bindings: set[str],
    completed: bool,
    skill_warnings: list[str],
) -> str:
    if not completed or skill_warnings:
        return "inconclusive"
    if case["kind"] == "interaction":
        return "manual-review"
    return classify_run(
        case,
        observed,
        explicit_bindings,
        completed,
        skill_warnings,
    )


def run_codex_case(case: dict[str, Any], runs: int, timeout: int) -> dict[str, Any]:
    results: list[dict[str, Any]] = []
    loaded_counts = {name: 0 for name in case["available_skills"]}
    read_counts = {name: 0 for name in case["available_skills"]}
    successful_runs = 0
    for run_number in range(1, runs + 1):
        with tempfile.TemporaryDirectory(prefix="mecha-eval-") as directory:
            workspace = Path(directory)
            link_skills(workspace, case["available_skills"])
            client: AppServerClient | None = None
            try:
                client = AppServerClient()
                client.initialize(timeout)
                listed_skills = listed_skills_for_workspace(client, workspace, timeout)
                config = skill_filter_config(
                    listed_skills, workspace, case["available_skills"]
                )
                thread_response = client.request(
                    "thread/start",
                    {
                        "cwd": str(workspace),
                        "ephemeral": True,
                        "approvalPolicy": "never",
                        "sandbox": "read-only",
                        "config": config,
                    },
                    timeout,
                )
                if not isinstance(thread_response, dict):
                    raise AppServerError("thread/start returned an invalid response")
                thread = thread_response.get("thread")
                if not isinstance(thread, dict) or not isinstance(thread.get("id"), str):
                    raise AppServerError("thread/start returned no thread id")
                thread_id = thread["id"]

                turns: list[dict[str, Any]] = []
                explicit_bindings: set[str] = set()
                observed: set[str] = set()
                skill_warnings: list[str] = []
                for turn_number, turn in enumerate(case["turns"], start=1):
                    explicit_bindings.update(turn["explicit_invocations"])
                    turn_response = client.request(
                        "turn/start",
                        {
                            "threadId": thread_id,
                            "input": turn_input(turn, workspace),
                        },
                        timeout,
                    )
                    if not isinstance(turn_response, dict):
                        raise AppServerError("turn/start returned an invalid response")
                    started_turn = turn_response.get("turn")
                    if not isinstance(started_turn, dict) or not isinstance(
                        started_turn.get("id"), str
                    ):
                        raise AppServerError("turn/start returned no turn id")
                    turn_result = collect_turn(
                        client,
                        thread_id,
                        started_turn["id"],
                        case["available_skills"],
                        timeout,
                    )
                    turn_result["turn"] = turn_number
                    turn_result["explicit_bindings"] = sorted(turn["explicit_invocations"])
                    turns.append(turn_result)
                    observed.update(turn_result["observed_skill_reads"])
                    skill_warnings.extend(
                        warning
                        for warning in turn_result["warnings"]
                        if "skill" in warning.casefold()
                    )
                    if turn_result["status"] != "completed":
                        break

                run_succeeded = (
                    len(turns) == len(case["turns"])
                    and all(turn["status"] == "completed" for turn in turns)
                    and not skill_warnings
                )
                if run_succeeded:
                    successful_runs += 1
                    for name in observed | explicit_bindings:
                        loaded_counts[name] += 1
                    for name in observed:
                        read_counts[name] += 1
                classification = run_classification(
                    case,
                    observed,
                    explicit_bindings,
                    run_succeeded,
                    skill_warnings,
                )
                results.append(
                    {
                        "run": run_number,
                        "classification": classification,
                        "explicit_bindings": sorted(explicit_bindings),
                        "observed_skill_reads": sorted(observed),
                        "turns": turns,
                        "skill_warnings": skill_warnings,
                        "app_server_stderr": client.stderr,
                    }
                )
            except (AppServerError, OSError, TimeoutError) as error:
                results.append(
                    {
                        "run": run_number,
                        "classification": "inconclusive",
                        "explicit_bindings": [],
                        "observed_skill_reads": [],
                        "turns": [],
                        "error": str(error),
                        "app_server_stderr": client.stderr if client else "",
                    }
                )
            finally:
                if client is not None:
                    client.close()

    result = {
        "id": case["id"],
        "telemetry": {
            "explicit": "structured-skill-input",
            "implicit": "heuristic-skill-file-read",
        },
        "runs": results,
        "successful_runs": successful_runs,
        "loaded_rates": {
            name: loaded_counts[name] / successful_runs if successful_runs else 0.0
            for name in sorted(loaded_counts)
        },
        "observed_read_rates": {
            name: read_counts[name] / successful_runs if successful_runs else 0.0
            for name in sorted(read_counts)
        },
    }
    if case["kind"] == "interaction":
        result["evaluation"] = "manual-review-required"
        result["expected_behaviors"] = case["expected"]["behaviors"]
    return result


def summarize_case(case: dict[str, Any], result: dict[str, Any], threshold: float) -> None:
    if case["kind"] != "trigger" or "loaded_rates" not in result:
        return
    if result.get("successful_runs", 0) == 0:
        result["evaluation"] = "inconclusive-host-failure"
        return
    expected = case["expected"]
    loaded_pass = all(
        result["loaded_rates"][name] > threshold
        for name in expected["loaded_skills"]
    )
    excluded_pass = all(
        result["loaded_rates"][name] < threshold
        for name in expected["excluded_skills"]
    )
    result["evaluation"] = "evidence-pass" if loaded_pass and excluded_pass else "evidence-fail"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", choices=("codex",), default="codex")
    parser.add_argument("--corpus", type=Path, default=DEFAULT_CORPUS)
    parser.add_argument("--split", choices=("train", "validation", "all"), default="validation")
    parser.add_argument("--case", action="append", default=[], dest="case_ids")
    parser.add_argument("--runs", type=int)
    parser.add_argument("--timeout", type=int, default=180)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        corpus = load_corpus(args.corpus)
        cases = select_cases(corpus, args.split, args.case_ids)
    except ValueError as error:
        print(f"[fail] {error}", file=sys.stderr)
        return 2

    if args.dry_run:
        report = dry_run(cases, args.host)
    else:
        if shutil.which("codex") is None:
            print("[fail] Codex CLI is not available", file=sys.stderr)
            return 2
        runs = args.runs or corpus["default_runs"]
        if runs < 1:
            print("[fail] --runs must be positive", file=sys.stderr)
            return 2
        results = [run_codex_case(case, runs, args.timeout) for case in cases]
        by_id = {case["id"]: case for case in cases}
        for result in results:
            summarize_case(by_id[result["id"]], result, corpus["trigger_threshold"])
        report = {
            "host": args.host,
            "telemetry": {
                "explicit": "structured skill input",
                "implicit": "heuristic; Codex exposes no stable implicit-skill invocation event",
            },
            "runs_per_trigger_case": runs,
            "trigger_threshold": corpus["trigger_threshold"],
            "results": results,
        }

    rendered = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
