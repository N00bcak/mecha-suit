"""Offline JSON-RPC peer for outcome-runner tests; never calls a model."""
import json
import os
from pathlib import Path
import sys
import time
import tomllib

config = {}
args = sys.argv[1:]
for index, arg in enumerate(args):
    if arg == "-c":
        entry = tomllib.loads(args[index + 1])
        def merge(left, right):
            for key, value in right.items():
                if isinstance(value, dict):
                    merge(left.setdefault(key, {}), value)
                else:
                    left[key] = value
        merge(config, entry)

home = Path(os.environ["HOME"])
workspace = Path.cwd()
mode = os.environ.get("MECHA_FAKE_MODE", "normal")
turn_number = 0


def send(value):
    print(json.dumps(value), flush=True)


for line in sys.stdin:
    request = json.loads(line)
    method = request["method"]
    params = request.get("params", {})
    if "id" not in request:
        continue
    result = {}
    if method == "skills/list":
        paths = list((home / ".agents/skills").glob("*/SKILL.md"))
        paths.append(home / "bundled/skill-creator/SKILL.md")
        if mode == "extra-skill" and "skills" in config:
            paths.append(home / "unexpected/SKILL.md")
        disabled = {x["path"] for x in config.get("skills", {}).get("config", [])}
        skills = [{"name": p.parent.name, "path": str(p), "enabled": str(p) not in disabled,
                   "scope": "user", "description": "Fixture skill"} for p in paths]
        result = {"data": [{"skills": skills, "errors": []}]}
    elif method == "config/read":
        result = {"config": config, "layers": [{"name": {"type": "sessionFlags"}, "config": config}]}
        if mode == "ambient-config":
            result["layers"].append({"name": {"type": "system", "file": "/etc/codex/config.toml"}, "config": {"notify": ["external"]}})
    elif method == "thread/start":
        sources = [str(workspace / "AGENTS.md")]
        if (home / ".codex/AGENTS.md").exists():
            sources.append(str(home / ".codex/AGENTS.md"))
        if mode == "extra-instructions":
            sources.append("/unexpected/AGENTS.md")
        result = {"thread": {"id": "fixture-thread"}, "cwd": str(workspace),
                  "model": "wrong" if mode == "wrong-model" else config["model"],
                  "reasoningEffort": config["model_reasoning_effort"], "approvalPolicy": "never",
                  "instructionSources": sources, "sandbox": {"type": "workspaceWrite", "networkAccess": False,
                  "writableRoots": [], "excludeSlashTmp": True, "excludeTmpdirEnvVar": True}}
    elif method == "turn/start":
        assert params["model"] == config["model"]
        assert params["effort"] == config["model_reasoning_effort"]
        assert all(item["type"] == "text" for item in params["input"])
        turn_number += 1
        turn_id = str(turn_number)
        send({"id": request["id"], "result": {"turn": {"id": turn_id}}})
        if (workspace / "limits.py").exists():
            (workspace / "limits.py").write_text("def clamp(value, low, high):\n    if low > high: raise ValueError()\n    return min(high, max(low, value))\n")
        if (workspace / "labels.py").exists():
            (workspace / "labels.py").write_text("def normalize_label(value):\n    return value.strip().lower()\n")
        if mode == "scope-violation":
            (workspace / ".mecha").mkdir(exist_ok=True)
            (workspace / ".mecha/index.md").write_text("Unrequested state")
        send({"method": "item/completed", "params": {"threadId": "fixture-thread", "turnId": turn_id,
              "item": {"type": "commandExecution", "command": "python3 -B check.py", "aggregatedOutput": "retained evidence"}}})
        if mode == "timeout":
            time.sleep(30)
            continue
        send({"method": "item/completed", "params": {"threadId": "fixture-thread", "turnId": turn_id,
              "item": {"type": "agentMessage", "text": "Fixture response"}}})
        if mode == "usage":
            send({"method": "thread/tokenUsage/updated", "params": {"threadId": "fixture-thread", "tokenUsage": {"total": {"totalTokens": 123}}}})
        send({"method": "turn/completed", "params": {"threadId": "fixture-thread",
              "turn": {"id": turn_id, "status": "failed" if mode == "failed-turn" else "completed"}}})
        continue
    send({"id": request["id"], "result": result})
