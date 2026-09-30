#!/usr/bin/env python3
"""Compare fixture outcomes with project instructions alone and the full Mecha stack.

Live runs are opt-in, require an explicit model/effort, and never grade prose.
"""

from __future__ import annotations

import argparse
import base64
import difflib
import fnmatch
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import tempfile
import time
from typing import Any

from run_interaction_evals import (
    AppServerClient, AppServerError, collect_turn, listed_skills_for_workspace,
)

ROOT = Path(__file__).resolve().parents[1]
CORPUS = ROOT / "evals/outcomes/cases.json"
ORACLE = ROOT / "evals/outcomes/check_functions.py"
PROJECT_INSTRUCTIONS = """# Fixture project
Use Python's standard library; no dependency installation is needed.
Run relevant checks with python3 -B. Preserve existing public interfaces.
Keep changes within the requested task and report the evidence you obtained.
"""


def fingerprint(value: Any) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def relative_path(value: str) -> bool:
    path = PurePosixPath(value)
    return bool(value) and not path.is_absolute() and ".." not in path.parts and "\\" not in value


def load_cases(path: Path = CORPUS) -> list[dict[str, Any]]:
    document = json.loads(path.read_text())
    if document.get("schema_version") != 1:
        raise ValueError("outcome schema_version must be 1")
    cases = document.get("cases", [])
    if not cases:
        raise ValueError("outcome corpus must contain cases")
    seen = set()
    for case in cases:
        name = case.get("id", "")
        if not re.fullmatch(r"[a-z0-9-]+", name) or name in seen:
            raise ValueError("outcome case IDs must be unique lowercase slugs")
        seen.add(name)
        for field in ("files", "base_files"):
            files = case.get(field, {})
            if not isinstance(files, dict) or any(
                not relative_path(p) or p.split("/")[0] in {".git", ".codex", ".agents"}
                or p == "AGENTS.md" or not isinstance(content, str)
                for p, content in files.items()
            ):
                raise ValueError(f"{name}: invalid {field}")
        for field in ("turns", "manual_review"):
            if not case.get(field) or not all(isinstance(v, str) and v.strip() for v in case[field]):
                raise ValueError(f"{name}: {field} must contain text")
        if not isinstance(case.get("allowed_changes"), list) or any(
            not isinstance(p, str) or not relative_path(p) for p in case["allowed_changes"]
        ):
            raise ValueError(f"{name}: invalid allowed_changes")
        if not isinstance(case.get("checks"), list):
            raise ValueError(f"{name}: checks must be a list")
        for check in case["checks"]:
            if check.get("file") not in case["files"] or not re.fullmatch(
                r"[A-Za-z_]\w*", check.get("function", "")
            ) or not check.get("vectors"):
                raise ValueError(f"{name}: invalid function check")
            for vector in check["vectors"]:
                if not isinstance(vector.get("args"), list) or (
                    ("equals" in vector) == ("raises" in vector)
                ):
                    raise ValueError(f"{name}: vector needs arguments and exactly one expectation")
    return cases


def write_files(workspace: Path, files: dict[str, str]) -> None:
    for name, content in files.items():
        path = workspace / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)


def prepare_workspace(workspace: Path, case: dict[str, Any]) -> None:
    workspace.mkdir()
    write_files(workspace, {"AGENTS.md": PROJECT_INSTRUCTIONS, **case["files"], **case.get("base_files", {})})
    # Suppress developer-global git hooks/configuration and make the review base local.
    git_env = {"PATH": os.environ.get("PATH", ""), "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
               "GIT_AUTHOR_DATE": "2000-01-01T00:00:00Z", "GIT_COMMITTER_DATE": "2000-01-01T00:00:00Z"}
    git = ["git", "-c", "core.hooksPath=" + os.devnull, "-c", "commit.gpgSign=false",
           "-c", "user.name=Outcome Fixture", "-c", "user.email=fixture@example.invalid"]
    for args in (["init", "-q"], ["add", "."], ["commit", "-qm", "Fixture baseline"]):
        subprocess.run(git + args, cwd=workspace, env=git_env, check=True, capture_output=True)
    write_files(workspace, case["files"])


def snapshot(workspace: Path) -> dict[str, dict[str, str]]:
    files = {}
    for path in sorted(workspace.rglob("*")):
        name = path.relative_to(workspace).as_posix()
        if name.split("/")[0] == ".git":
            continue
        if path.is_symlink():
            files[name] = {"symlink": os.readlink(path)}
        elif path.is_file():
            data = path.read_bytes()
            try:
                files[name] = {"text": data.decode("utf-8")}
            except UnicodeDecodeError:
                files[name] = {"base64": base64.b64encode(data).decode()}
    return files


def changes(before: dict, after: dict) -> dict[str, Any]:
    changed = {}
    for name in sorted(before.keys() | after.keys()):
        if before.get(name) != after.get(name):
            old, new = before.get(name), after.get(name)
            changed[name] = {"before": old, "after": new}
            if (old is None or "text" in old) and (new is None or "text" in new):
                changed[name]["diff"] = "".join(difflib.unified_diff(
                    (old or {}).get("text", "").splitlines(True),
                    (new or {}).get("text", "").splitlines(True),
                    fromfile="before/" + name, tofile="after/" + name,
                ))
    return changed


def scope_check(changed: dict, allowed: list[str]) -> dict[str, Any]:
    unexpected = [name for name in changed if not any(fnmatch.fnmatchcase(name, p) for p in allowed)]
    return {"status": "failed" if unexpected else "passed", "unexpected_paths": unexpected}


def isolated_environment(home: Path, auth_source: Path | None) -> dict[str, str]:
    """Only authentication is imported; never copy the developer's config or skills."""
    codex_home = home / ".codex"
    codex_home.mkdir(parents=True)
    if auth_source is not None and auth_source.is_file():
        shutil.copyfile(auth_source, codex_home / "auth.json")
        (codex_home / "auth.json").chmod(0o600)
    env = {key: os.environ[key] for key in ("PATH", "LANG", "SSL_CERT_FILE", "SSL_CERT_DIR", "OPENAI_API_KEY") if key in os.environ}
    env.update(HOME=str(home), CODEX_HOME=str(codex_home), PYTHONDONTWRITEBYTECODE="1")
    return env


def install_treatment(home: Path) -> dict[str, str]:
    toolbox = home / "toolbox"
    for name in ("families", "shared"):
        shutil.copytree(ROOT / name, toolbox / name)
    skills = home / ".agents/skills"
    skills.mkdir(parents=True)
    expected = {}
    for source in sorted((toolbox / "families").glob("*/*/SKILL.md")):
        (skills / source.parent.name).symlink_to(source.parent, target_is_directory=True)
        expected[source.parent.name] = str(source.resolve())
    shutil.copyfile(ROOT / "templates/global-AGENTS.template.md", home / ".codex/AGENTS.md")
    return expected


def config_for(model: str, effort: str, home: Path) -> dict[str, Any]:
    return {
        "model": model, "model_reasoning_effort": effort,
        "approval_policy": "never", "sandbox_mode": "workspace-write",
        "sandbox_workspace_write": {"network_access": False, "writable_roots": [],
                                    "exclude_tmpdir_env_var": True, "exclude_slash_tmp": True},
        "web_search": "disabled", "mcp_servers": {}, "allow_login_shell": False,
        "features": {"apps": False, "plugins": False, "multi_agent": False},
        "shell_environment_policy": {"inherit": "none", "set": {"PATH": os.environ.get("PATH", ""), "HOME": str(home), "ZDOTDIR": str(home), "PYTHONDONTWRITEBYTECODE": "1"}},
    }


def server_command(config: dict[str, Any]) -> list[str]:
    # JSON scalars/arrays/strings also have TOML-compatible syntax; tables are flattened.
    command = ["codex", "app-server", "--stdio"]
    def add(prefix: str, value: Any) -> None:
        if isinstance(value, dict):
            if not value:
                command.extend(["-c", prefix + "={}"])
            for key, child in value.items():
                add(prefix + "." + key if prefix else key, child)
        elif isinstance(value, list) and value and isinstance(value[0], dict):
            rows = ["{ " + ", ".join(k + " = " + json.dumps(v) for k, v in row.items()) + " }" for row in value]
            command.extend(["-c", prefix + "=[" + ", ".join(rows) + "]"])
        else:
            command.extend(["-c", prefix + "=" + json.dumps(value)])
    for key, value in config.items():
        add(key, value)
    return command


def verify_config(response: dict, config: dict, home: Path) -> None:
    effective = response.get("config", {})
    for key in ("model", "model_reasoning_effort", "approval_policy", "sandbox_mode", "sandbox_workspace_write", "web_search", "mcp_servers", "allow_login_shell"):
        if effective.get(key) != config[key]:
            raise AppServerError(f"unverified effective configuration: {key}")
    if any(effective.get(k) for k in ("instructions", "developer_instructions", "user_instructions", "model_instructions_file", "compact_prompt")):
        raise AppServerError("unexpected instruction override")
    for key, value in config["features"].items():
        if effective.get("features", {}).get(key) != value:
            raise AppServerError(f"unverified feature isolation: {key}")
    policy = effective.get("shell_environment_policy", {})
    if any(policy.get(k) != v for k, v in config["shell_environment_policy"].items()) or any(
        v is not None for k, v in policy.items() if k not in config["shell_environment_policy"]
    ):
        raise AppServerError("unverified tool environment")
    layers = response.get("layers")
    if not isinstance(layers, list):
        raise AppServerError("configuration layer telemetry unavailable")
    for layer in layers:
        if layer.get("disabledReason") or not layer.get("config"):
            continue
        source = layer.get("name", {})
        if source.get("type") == "sessionFlags":
            continue
        file = source.get("file")
        if not file or not Path(file).resolve().is_relative_to(home.resolve()):
            raise AppServerError("configuration inherited from outside isolated home")


def verify_catalog(skills: list[dict], expected: dict[str, str]) -> None:
    enabled = [s for s in skills if s.get("enabled") is True]
    actual = {s["name"]: str(Path(s["path"]).resolve()) for s in enabled}
    if len(enabled) != len(actual) or actual != expected:
        raise AppServerError("enabled skill catalog does not match the comparison arm")


def verify_thread(response: dict, workspace: Path, home: Path, treatment: bool, model: str, effort: str) -> None:
    if response.get("model") != model or response.get("reasoningEffort") != effort:
        raise AppServerError("model or effort does not match request")
    if response.get("approvalPolicy") != "never" or Path(response.get("cwd", "")).resolve() != workspace.resolve():
        raise AppServerError("thread permissions or workspace mismatch")
    policy = response.get("sandbox", {})
    if policy.get("type") != "workspaceWrite" or policy.get("networkAccess") is not False or not policy.get("excludeSlashTmp") or not policy.get("excludeTmpdirEnvVar"):
        raise AppServerError("workspace-only, network-disabled sandbox was not established")
    if any(Path(p).resolve() != workspace.resolve() for p in policy.get("writableRoots", [])):
        raise AppServerError("sandbox grants additional writable roots")
    expected = {str((workspace / "AGENTS.md").resolve())}
    if treatment:
        expected.add(str((home / ".codex/AGENTS.md").resolve()))
    sources = response.get("instructionSources")
    if not isinstance(sources, list) or {str(Path(p).resolve()) for p in sources} != expected:
        raise AppServerError("instruction sources do not match the comparison arm")


def run_checks(case: dict, workspace: Path, env: dict, timeout: int) -> dict:
    if not case["checks"]:
        return {"status": "not-applicable", "reason": "Outcome requires manual trace review"}
    command = [sys.executable, "-I", "-B", str(ORACLE), str(workspace), json.dumps(case["checks"])]
    config = {"sandbox_mode": "read-only", "approval_policy": "never", "mcp_servers": {},
              "features": {"apps": False, "plugins": False},
              "shell_environment_policy": {"inherit": "none"}}
    # The evaluator reads candidate code but cannot modify the workspace or access the network.
    clean_env = {k: v for k, v in env.items() if k != "OPENAI_API_KEY"}
    with AppServerClient(server_command(config), env=clean_env, cwd=workspace) as client:
        client.initialize(timeout)
        response = client.request("command/exec", {
            "command": command, "cwd": str(workspace), "timeoutMs": timeout * 1000,
            "sandboxPolicy": {"type": "readOnly", "networkAccess": False},
        }, timeout + 5)
    if not isinstance(response, dict) or not isinstance(response.get("exitCode"), int) or any(
        not isinstance(response.get(k), str) for k in ("stdout", "stderr")
    ):
        raise AppServerError("evaluator command returned invalid telemetry")
    return {"status": "passed" if response["exitCode"] == 0 else "failed", "command": command,
            "exit_code": response["exitCode"], "stdout": response["stdout"], "stderr": response["stderr"]}


def run_arm(case: dict, arm: str, model: str, effort: str, timeout: int,
            auth_source: Path | None, client_factory=AppServerClient, checker=run_checks) -> dict:
    result: dict[str, Any] = {"arm": arm, "status": "inconclusive", "turns": [], "events": [],
                              "usage": None, "manual_review": [{"criterion": c, "verdict": None} for c in case["manual_review"]]}
    result["user_turns"] = case["turns"]
    started = time.monotonic()
    with tempfile.TemporaryDirectory(prefix="mecha-outcome-") as temporary:
        root = Path(temporary).resolve()
        home, workspace = root / "home", root / "workspace"
        env = isolated_environment(home, auth_source)
        prepare_workspace(workspace, case)
        expected = install_treatment(home) if arm == "mecha" else {}
        before = snapshot(workspace)
        config = config_for(model, effort, home)
        result["initial_files"] = before
        result["initial_fingerprint"] = fingerprint(before)
        result["expected_catalog"] = sorted(expected)
        client = None
        thread_id = None
        active_turn_id = None
        try:
            # Discover bundled skills once, then restart with them disabled in both arms.
            client = client_factory(server_command(config), env=env, cwd=workspace)
            client.initialize(timeout)
            listed = listed_skills_for_workspace(client, workspace, timeout)
            disabled = [{"path": s["path"], "enabled": False} for s in listed
                        if str(Path(s["path"]).resolve()) not in expected.values()]
            client.close()
            client = None
            config["skills"] = {"config": disabled}
            client = client_factory(server_command(config), env=env, cwd=workspace)
            client.initialize(timeout)
            resolved = client.request("config/read", {"cwd": str(workspace), "includeLayers": True}, timeout)
            verify_config(resolved, config, home)
            verify_catalog(listed_skills_for_workspace(client, workspace, timeout), expected)
            normalized_config = json.loads(json.dumps(config).replace(str(root), "<isolated-root>"))
            result["config_fingerprint"] = fingerprint(normalized_config)
            response = client.request("thread/start", {
                "cwd": str(workspace), "ephemeral": True, "model": model,
                "approvalPolicy": "never", "sandbox": "workspace-write",
            }, timeout)
            verify_thread(response, workspace, home, arm == "mecha", model, effort)
            result["verified_model"] = response["model"]
            result["verified_effort"] = response["reasoningEffort"]
            thread_id = response["thread"]["id"]
            for prompt in case["turns"]:
                turn = client.request("turn/start", {"threadId": thread_id, "model": model,
                    "effort": effort, "input": [{"type": "text", "text": prompt}]}, timeout)
                active_turn_id = turn["turn"]["id"]
                collected = collect_turn(client, thread_id, active_turn_id, list(expected), timeout,
                                         on_event=result["events"].append)
                active_turn_id = None
                result["turns"].append(collected)
                if collected["status"] != "completed" or collected["warnings"]:
                    raise AppServerError("turn failed or emitted warnings; inspect retained trace")
            result["status"] = "completed"
        except (AppServerError, OSError, TimeoutError, KeyError, TypeError, ValueError) as error:
            result["error"] = str(error)
        finally:
            if client is not None:
                if thread_id is not None:
                    try:
                        if active_turn_id is not None:
                            client.request("turn/interrupt", {"threadId": thread_id, "turnId": active_turn_id}, min(timeout, 5))
                        client.request("thread/backgroundTerminals/clean", {"threadId": thread_id}, min(timeout, 5))
                    except (AppServerError, OSError, TimeoutError) as error:
                        result["cleanup_error"] = str(error)
                        result["status"] = "inconclusive"
                client.close()
                result["server_stderr"] = client.stderr
            # Keep partial events and artifacts even after a timeout or protocol failure.
            after = snapshot(workspace)
            result["changes"] = changes(before, after)
            result["scope"] = scope_check(result["changes"], case["allowed_changes"])
            result["checks"] = {"status": "inconclusive"}
            if result["status"] == "completed":
                try:
                    result["checks"] = checker(case, workspace, env, timeout)
                except (AppServerError, OSError, TimeoutError, subprocess.TimeoutExpired) as error:
                    result["checks"] = {"status": "inconclusive", "error": str(error)}
            for event in result["events"]:
                if event.get("method") == "thread/tokenUsage/updated":
                    result["usage"] = event.get("params", {}).get("tokenUsage")
            result["elapsed_seconds"] = round(time.monotonic() - started, 3)
    return result


def comparison(cases: list[dict], runs: int, model: str, effort: str, timeout: int,
               auth_source: Path | None, runner=run_arm) -> dict:
    report = {"schema_version": 1, "model": model, "effort": effort,
              "corpus_fingerprint": fingerprint(cases), "pairs": []}
    for case in cases:
        for repetition in range(1, runs + 1):
            order = ["baseline", "mecha"] if repetition % 2 else ["mecha", "baseline"]
            arms = {arm: runner(case, arm, model, effort, timeout, auth_source) for arm in order}
            comparable = (
                all(a["status"] == "completed" and a["checks"]["status"] != "inconclusive" for a in arms.values())
                and len({a["initial_fingerprint"] for a in arms.values()}) == 1
            )
            report["pairs"].append({"case": case["id"], "repetition": repetition, "order": order,
                                    "status": "comparable" if comparable else "inconclusive", "arms": arms})
    return report


def render_summary(report: dict) -> str:
    lines = [
        "# Paired outcome evaluation", "",
        "Objective checks do not grade the response. Review traces before drawing conclusions.", "",
        "| Case / run | Arm | Execution | Checks | Scope | Seconds |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for pair in report.get("pairs", []):
        for arm in ("baseline", "mecha"):
            result = pair["arms"][arm]
            lines.append(
                f"| {pair['case']} / {pair['repetition']} ({pair['status']}) | {arm} | "
                f"{result['status']} | {result['checks']['status']} | "
                f"{result['scope']['status']} | {result['elapsed_seconds']} |"
            )
    for pair in report.get("pairs", []):
        lines.extend(["", f"Manual review: {pair['case']} / {pair['repetition']}", ""])
        for check in pair["arms"]["mecha"]["manual_review"]:
            lines.append(f"- [ ] {check['criterion']} Compare both arms and cite trace/artifact evidence.")
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", action="append", default=[])
    parser.add_argument("--runs", type=int, default=1)
    parser.add_argument("--model")
    parser.add_argument("--effort")
    parser.add_argument("--timeout", type=int, default=180)
    parser.add_argument("--output", type=Path, help="JSON report; a Markdown companion is also written")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    try:
        cases = load_cases()
        unknown = set(args.case) - {case["id"] for case in cases}
        if unknown or args.runs < 1 or args.timeout < 1:
            raise ValueError("unknown case or non-positive runs/timeout")
        if args.case:
            cases = [case for case in cases if case["id"] in args.case]
        if args.output and args.output.suffix != ".json":
            raise ValueError("--output must end in .json (the companion report uses .md)")
        if args.dry_run:
            report = {"mode": "dry-run", "cases": cases, "arms": ["baseline", "mecha"],
                      "runs": args.runs, "catalog": sorted(p.parent.name for p in ROOT.glob("families/*/*/SKILL.md"))}
        else:
            if not args.model or not args.effort:
                raise ValueError("live comparisons require --model and --effort")
            if shutil.which("codex") is None:
                raise ValueError("Codex CLI is not available")
            auth_source = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))) / "auth.json"
            version = subprocess.run(["codex", "--version"], capture_output=True, text=True, check=True).stdout.strip()
            report = comparison(cases, args.runs, args.model, args.effort, args.timeout, auth_source)
            report["codex_version"] = version
            report["mecha_fingerprint"] = fingerprint({str(p.relative_to(ROOT)): p.read_text()
                for parent in ("families", "shared", "templates")
                for p in sorted((ROOT / parent).rglob("*")) if p.suffix in {".md", ".yaml"}})
            report["oracle_fingerprint"] = fingerprint(ORACLE.read_text())
        rendered = json.dumps(report, indent=2, sort_keys=True) + "\n"
        if args.output:
            args.output.write_text(rendered)
            if not args.dry_run:
                args.output.with_suffix(".md").write_text(render_summary(report))
        else:
            print(rendered, end="")
            if not args.dry_run:
                print(render_summary(report), file=sys.stderr)
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"[fail] {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
