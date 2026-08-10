#!/usr/bin/env python3
"""Render or run host-neutral interaction evaluations through a host adapter.

Codex does not currently emit a stable implicit-skill invocation event. The
Codex adapter therefore labels observations as heuristic and infers skill use
only from command events that read a candidate SKILL.md.
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CORPUS = ROOT / "evals" / "interaction-boundary.json"
VALID_SPLITS = {"train", "validation"}
VALID_KINDS = {"trigger", "interaction"}


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


def parse_codex_events(stdout: str, candidate_skills: list[str]) -> tuple[set[str], str, bool]:
    observed: set[str] = set()
    final_response = ""
    completed = False
    for line in stdout.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") == "turn.completed":
            completed = True
        item = event.get("item")
        if not isinstance(item, dict):
            continue
        if item.get("type") == "agent_message" and isinstance(item.get("text"), str):
            final_response = item["text"]
        if item.get("type") != "command_execution":
            continue
        serialized = json.dumps(item, sort_keys=True)
        for name in candidate_skills:
            if f"/{name}/SKILL.md" in serialized or f"\\{name}\\SKILL.md" in serialized:
                observed.add(name)
    return observed, final_response, completed


def classify_run(case: dict[str, Any], observed: set[str], completed: bool) -> str:
    if not completed:
        return "inconclusive"
    expected = case["expected"]
    if observed & set(expected["excluded_skills"]):
        return "failed"
    missing = set(expected["loaded_skills"]) - observed
    if not missing:
        return "passed"
    explicitly_invoked = {
        name
        for turn in case["turns"]
        for name in turn["explicit_invocations"]
    }
    if missing <= explicitly_invoked:
        return "inconclusive"
    return "failed"


def run_codex_case(case: dict[str, Any], runs: int, timeout: int) -> dict[str, Any]:
    if len(case["turns"]) != 1:
        return {
            "id": case["id"],
            "status": "manual-review-required",
            "reason": "the Codex exec adapter does not simulate multi-turn state",
            "expected_behaviors": case["expected"]["behaviors"],
        }

    results: list[dict[str, Any]] = []
    observed_counts = {name: 0 for name in case["available_skills"]}
    successful_runs = 0
    for run_number in range(1, runs + 1):
        with tempfile.TemporaryDirectory(prefix="mecha-eval-") as directory:
            workspace = Path(directory)
            link_skills(workspace, case["available_skills"])
            prompt = render_turn(case["turns"][0], "codex")
            command = [
                "codex",
                "exec",
                "--ephemeral",
                "--ignore-user-config",
                "--skip-git-repo-check",
                "--sandbox",
                "read-only",
                "--json",
                "--cd",
                str(workspace),
                prompt,
            ]
            try:
                completed = subprocess.run(
                    command,
                    capture_output=True,
                    text=True,
                    timeout=timeout,
                    check=False,
                )
                observed, response, turn_completed = parse_codex_events(
                    completed.stdout, case["available_skills"]
                )
                run_succeeded = completed.returncode == 0 and turn_completed
                if run_succeeded:
                    successful_runs += 1
                    for name in observed:
                        observed_counts[name] += 1
                classification = (
                    "manual-review"
                    if case["kind"] == "interaction"
                    else classify_run(case, observed, turn_completed)
                )
                results.append(
                    {
                        "run": run_number,
                        "classification": classification,
                        "observed_skill_reads": sorted(observed),
                        "exit_code": completed.returncode,
                        "stderr": completed.stderr.strip(),
                        "final_response": response,
                    }
                )
            except subprocess.TimeoutExpired:
                results.append(
                    {
                        "run": run_number,
                        "classification": "inconclusive",
                        "observed_skill_reads": [],
                        "error": f"timed out after {timeout} seconds",
                    }
                )

    result = {
        "id": case["id"],
        "telemetry": "heuristic-skill-file-read",
        "runs": results,
        "successful_runs": successful_runs,
        "observed_rates": {
            name: observed_counts[name] / successful_runs if successful_runs else 0.0
            for name in sorted(observed_counts)
        },
    }
    if case["kind"] == "interaction":
        result["evaluation"] = "manual-review-required"
        result["expected_behaviors"] = case["expected"]["behaviors"]
    return result


def summarize_case(case: dict[str, Any], result: dict[str, Any], threshold: float) -> None:
    if case["kind"] != "trigger" or "observed_rates" not in result:
        return
    if result.get("successful_runs", 0) == 0:
        result["evaluation"] = "inconclusive-host-failure"
        return
    expected = case["expected"]
    loaded_pass = all(result["observed_rates"][name] > threshold for name in expected["loaded_skills"])
    excluded_pass = all(result["observed_rates"][name] < threshold for name in expected["excluded_skills"])
    explicit = any(turn["explicit_invocations"] for turn in case["turns"])
    if explicit and not loaded_pass:
        result["evaluation"] = "inconclusive-explicit-binding-is-not-observable"
    else:
        result["evaluation"] = "heuristic-pass" if loaded_pass and excluded_pass else "heuristic-fail"


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
            "telemetry": "heuristic; Codex exposes no stable implicit-skill invocation event",
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
