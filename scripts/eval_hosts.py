#!/usr/bin/env python3
"""Claude Code host adapter for Mecha Suit evaluations.

Mirrors the Codex runners' isolation: each run gets a temporary home whose
CLAUDE_CONFIG_DIR holds only what the comparison arm installs. Authentication
comes from a `claude setup-token` subscription token, never from the
developer's own configuration, skills, or memory.
"""

from __future__ import annotations

import json
import os
import queue
import shlex
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parents[1]
TOKEN_VARIABLE = "CLAUDE_CODE_OAUTH_TOKEN"
# Only these variables pass through; credentials such as ANTHROPIC_API_KEY or
# provider switches would otherwise outrank the token or leak the host setup.
INHERITED_VARIABLES = ("PATH", "LANG", "SSL_CERT_FILE", "SSL_CERT_DIR")
INSTRUCTION_LOG = "instructions-loaded.jsonl"
STREAM_COMMAND = [
    "claude", "-p",
    "--input-format", "stream-json",
    "--output-format", "stream-json",
    "--verbose",
    "--no-session-persistence",
    "--strict-mcp-config",
]
# Read-only parity with the Codex interaction runner's read-only sandbox.
READ_ONLY_DENIED_TOOLS = ["Bash", "Edit", "Write", "NotebookEdit", "WebFetch", "WebSearch"]
# Outcome arms may edit and run checks, but never reach the network.
OUTCOME_DENIED_TOOLS = ["WebFetch", "WebSearch"]


class ClaudeHostError(RuntimeError):
    """Raised when a Claude run cannot be isolated, started, or verified."""


def mecha_skill_names(root: Path = ROOT) -> set[str]:
    return {path.parent.name for path in (root / "families").glob("*/*/SKILL.md")}


def isolated_environment(home: Path, token: str | None) -> dict[str, str]:
    """Build an allowlisted environment rooted at a temporary home."""
    if not token:
        raise ClaudeHostError(
            f"{TOKEN_VARIABLE} is required for Claude runs; create one with `claude setup-token`"
        )
    config = home / ".claude"
    config.mkdir(parents=True, exist_ok=True)
    env = {key: os.environ[key] for key in INHERITED_VARIABLES if key in os.environ}
    env.update(
        HOME=str(home),
        CLAUDE_CONFIG_DIR=str(config),
        CODEX_HOME=str(home / ".codex"),
        MECHA_SKILL_ROOT=str(home / ".agents" / "skills"),
        PYTHONDONTWRITEBYTECODE="1",
    )
    env[TOKEN_VARIABLE] = token
    return env


def install(env: dict[str, str], names: Iterable[str], *, global_instructions: bool) -> list[str]:
    """Install skills with the real installer so Claude adapters are exercised."""
    names = sorted(names)
    install_env = {key: value for key, value in env.items() if key != TOKEN_VARIABLE}
    completed = subprocess.run(
        [str(ROOT / "install.sh"), *names],
        env=install_env, capture_output=True, text=True,
    )
    if completed.returncode != 0:
        raise ClaudeHostError(f"install.sh failed: {completed.stderr.strip() or completed.stdout.strip()}")
    instructions = Path(env["CLAUDE_CONFIG_DIR"]) / "CLAUDE.md"
    if not global_instructions and (instructions.exists() or instructions.is_symlink()):
        instructions.unlink()
    return names


def write_settings(env: dict[str, str], *, sandbox: bool, effort: str | None = None) -> Path:
    """Record loaded instruction files and, for edit-capable arms, sandbox Bash."""
    config = Path(env["CLAUDE_CONFIG_DIR"])
    log = config / INSTRUCTION_LOG
    recorder = (
        f"{shlex.quote(sys.executable)} -c "
        + shlex.quote("import json,sys; print(json.dumps(json.load(sys.stdin)))")
        + f" >> {shlex.quote(str(log))}"
    )
    settings: dict[str, Any] = {
        "hooks": {"InstructionsLoaded": [{"hooks": [{"type": "command", "command": recorder}]}]},
    }
    if sandbox:
        settings["sandbox"] = {"enabled": True, "network": {"allowedDomains": []}}
    if effort:
        settings["effortLevel"] = effort
    path = config / "settings.json"
    path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
    return path


def loaded_instruction_files(env: dict[str, str]) -> list[str]:
    log = Path(env["CLAUDE_CONFIG_DIR"]) / INSTRUCTION_LOG
    if not log.is_file():
        return []
    paths = []
    for line in log.read_text(encoding="utf-8").splitlines():
        try:
            record = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(record.get("file_path"), str):
            paths.append(record["file_path"])
    return sorted(set(paths))


def stream_command(
    *, model: str | None, permission_mode: str, denied_tools: list[str],
    allowed_tools: Iterable[str] = (), add_dirs: Iterable[Path] = (),
) -> list[str]:
    command = [*STREAM_COMMAND, "--permission-mode", permission_mode,
               "--disallowed-tools", ",".join(denied_tools)]
    if allowed_tools:
        command += ["--allowed-tools", ",".join(allowed_tools)]
    if model:
        command += ["--model", model]
    for directory in add_dirs:
        command += ["--add-dir", str(directory)]
    return command


def user_message(text: str) -> str:
    return json.dumps({"type": "user", "message": {"role": "user", "content": text}})


def run_turns(
    command: list[str], env: dict[str, str], cwd: Path, prompts: list[str], timeout: int
) -> tuple[list[dict[str, Any]], str]:
    """Send each turn only after the previous turn's result event.

    Claude merges user messages that arrive while a turn is running, so writing
    every turn up front would collapse a multi-turn case into one turn.
    """
    process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        env=env, cwd=cwd, text=True, bufsize=1,
    )
    lines: queue.Queue[str | None] = queue.Queue()
    stderr_lines: list[str] = []

    def read_stdout() -> None:
        assert process.stdout is not None
        for line in process.stdout:
            lines.put(line)
        lines.put(None)

    def read_stderr() -> None:
        assert process.stderr is not None
        stderr_lines.extend(process.stderr)

    readers = [threading.Thread(target=read_stdout, daemon=True),
               threading.Thread(target=read_stderr, daemon=True)]
    for reader in readers:
        reader.start()
    events: list[dict[str, Any]] = []
    try:
        assert process.stdin is not None
        for prompt in prompts:
            process.stdin.write(user_message(prompt) + "\n")
            process.stdin.flush()
            deadline = time.monotonic() + timeout
            while True:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise ClaudeHostError(f"Claude turn timed out after {timeout} seconds")
                try:
                    line = lines.get(timeout=remaining)
                except queue.Empty as error:
                    raise ClaudeHostError(f"Claude turn timed out after {timeout} seconds") from error
                if line is None:
                    raise ClaudeHostError("Claude exited before the turn finished: "
                                          + redact("".join(stderr_lines).strip()[-500:], env))
                events.extend(parse_events([line]))
                if events and events[-1].get("type") == "result":
                    break
        process.stdin.close()
        process.wait(timeout=30)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise ClaudeHostError(f"Claude process failed: {error}") from error
    finally:
        if process.poll() is None:
            process.kill()
            process.wait(timeout=5)
        for reader in readers:
            reader.join(timeout=1)
    return events, redact("".join(stderr_lines), env)


def parse_events(lines: Iterable[str]) -> list[dict[str, Any]]:
    events = []
    for line in lines:
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError as error:
            raise ClaudeHostError(f"invalid stream-json line: {line[:200]}") from error
        if isinstance(event, dict):
            events.append(event)
    return events


def redact(text: str, env: dict[str, str]) -> str:
    token = env.get(TOKEN_VARIABLE)
    return text.replace(token, "<redacted>") if token else text


def init_events(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [e for e in events if e.get("type") == "system" and e.get("subtype") == "init"]


def tool_uses(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    uses = []
    for event in events:
        if event.get("type") != "assistant":
            continue
        content = event.get("message", {}).get("content", [])
        uses.extend(block for block in content if isinstance(block, dict) and block.get("type") == "tool_use")
    return uses


def observe_skills(events: list[dict[str, Any]], candidates: Iterable[str]) -> set[str]:
    """Skill tool calls are direct evidence; SKILL.md reads match the Codex heuristic."""
    candidates = set(candidates)
    observed = set()
    for use in tool_uses(events):
        tool_input = use.get("input", {})
        if use.get("name") == "Skill" and tool_input.get("skill") in candidates:
            observed.add(tool_input["skill"])
        elif use.get("name") == "Read":
            path = str(tool_input.get("file_path", ""))
            observed.update(name for name in candidates if path.endswith(f"/{name}/SKILL.md"))
    return observed


def turn_results(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    results = []
    for event in events:
        if event.get("type") != "result":
            continue
        completed = event.get("subtype") == "success" and not event.get("is_error")
        results.append({
            "status": "completed" if completed else "failed",
            "final_response": event.get("result") if isinstance(event.get("result"), str) else "",
            "num_turns": event.get("num_turns"),
            "usage": event.get("usage"),
            "cost_usd": event.get("total_cost_usd"),
        })
    return results


def verify_session(
    events: list[dict[str, Any]], *, workspace: Path, expected_skills: Iterable[str],
    model: str | None, denied_tools: list[str],
) -> dict[str, Any]:
    """Abort instead of reporting a run whose environment was not the requested one."""
    inits = init_events(events)
    if not inits:
        raise ClaudeHostError("Claude emitted no init event")
    init = inits[0]
    if Path(init.get("cwd", "")).resolve() != workspace.resolve():
        raise ClaudeHostError("Claude session started outside the evaluation workspace")
    if model and model not in str(init.get("model", "")):
        raise ClaudeHostError(f"model {init.get('model')!r} does not match request {model!r}")
    if init.get("mcp_servers"):
        raise ClaudeHostError("MCP servers leaked into the isolated session")
    if any(plugin.get("path") != "builtin" for plugin in init.get("plugins", [])):
        raise ClaudeHostError("non-builtin plugins leaked into the isolated session")
    listed = set(init.get("skills", [])) & mecha_skill_names()
    if listed != set(expected_skills):
        raise ClaudeHostError(
            f"Mecha skill catalog {sorted(listed)} does not match {sorted(expected_skills)}"
        )
    leaked_tools = set(init.get("tools", [])) & set(denied_tools)
    if leaked_tools:
        raise ClaudeHostError(f"denied tools remain available: {sorted(leaked_tools)}")
    return {"model": init.get("model"), "version": init.get("claude_code_version"),
            "permission_mode": init.get("permissionMode")}
