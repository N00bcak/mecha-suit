import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import eval_hosts  # noqa: E402
from run_interaction_evals import cases_for_host, render_turn, validate_corpus  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures" / "claude"


def load_fixture(name: str, workspace: Path) -> list[dict]:
    text = (FIXTURES / name).read_text(encoding="utf-8").replace("/WORKSPACE", str(workspace))
    return eval_hosts.parse_events(text.splitlines())


class ClaudeHostTests(unittest.TestCase):
    def test_skill_calls_and_skill_reads_are_observed(self) -> None:
        events = load_fixture("skill-call.jsonl", Path("/tmp/workspace"))
        observed = eval_hosts.observe_skills(events, ["second-opinion", "change-review", "web-design"])
        self.assertEqual(observed, {"second-opinion", "change-review"})

    def test_turn_results_report_completion_and_failure(self) -> None:
        success = eval_hosts.turn_results(load_fixture("skill-call.jsonl", Path("/tmp/w")))
        failure = eval_hosts.turn_results(load_fixture("failed-turn.jsonl", Path("/tmp/w")))
        self.assertEqual([turn["status"] for turn in success], ["completed"])
        self.assertEqual(success[0]["final_response"], "Critique follows.")
        self.assertEqual([turn["status"] for turn in failure], ["failed"])

    def test_session_verification_accepts_matching_catalog(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            session = eval_hosts.verify_session(
                load_fixture("skill-call.jsonl", workspace), workspace=workspace,
                expected_skills=["change-review", "second-opinion"], model="haiku",
                denied_tools=eval_hosts.READ_ONLY_DENIED_TOOLS,
            )
            self.assertEqual(session["model"], "claude-haiku-4-5-20251001")

    def test_session_verification_rejects_contaminated_runs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            clean = load_fixture("skill-call.jsonl", workspace)
            leaked = load_fixture("failed-turn.jsonl", workspace)
            cases = [
                (clean, {"expected_skills": ["change-review"]}, "catalog"),
                (clean, {"model": "opus"}, "model"),
                (leaked, {}, "MCP"),
            ]
            for events, overrides, message in cases:
                arguments = {"workspace": workspace, "expected_skills": ["change-review", "second-opinion"],
                             "model": None, "denied_tools": eval_hosts.READ_ONLY_DENIED_TOOLS, **overrides}
                with self.subTest(message), self.assertRaisesRegex(eval_hosts.ClaudeHostError, message):
                    eval_hosts.verify_session(events, **arguments)
            with self.assertRaisesRegex(eval_hosts.ClaudeHostError, "outside"):
                eval_hosts.verify_session(clean, workspace=workspace / "other", expected_skills=[],
                                          model=None, denied_tools=[])

    def test_isolated_environment_drops_host_credentials(self) -> None:
        polluted = {"PATH": "/bin", "ANTHROPIC_API_KEY": "sk-host", "ANTHROPIC_PROFILE": "work",
                    "CLAUDE_CODE_USE_BEDROCK": "1", "CLAUDE_CONFIG_DIR": "/Users/me/.claude"}
        with tempfile.TemporaryDirectory() as directory, mock.patch.dict(os.environ, polluted, clear=True):
            home = Path(directory) / "home"
            env = eval_hosts.isolated_environment(home, "oauth-secret")
        self.assertEqual(env["CLAUDE_CONFIG_DIR"], str(home / ".claude"))
        self.assertEqual(env["HOME"], str(home))
        self.assertEqual(env[eval_hosts.TOKEN_VARIABLE], "oauth-secret")
        self.assertFalse({"ANTHROPIC_API_KEY", "ANTHROPIC_PROFILE", "CLAUDE_CODE_USE_BEDROCK"} & set(env))

    def test_missing_token_is_reported_before_any_run(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(eval_hosts.ClaudeHostError, "setup-token"):
                eval_hosts.isolated_environment(Path(directory), None)

    def test_token_is_redacted_from_captured_output(self) -> None:
        env = {eval_hosts.TOKEN_VARIABLE: "oauth-secret"}
        self.assertEqual(eval_hosts.redact("auth oauth-secret failed", env), "auth <redacted> failed")

    def test_instruction_log_and_settings_round_trip(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            env = eval_hosts.isolated_environment(Path(directory), "token")
            settings = json.loads(eval_hosts.write_settings(env, sandbox=True, effort="low").read_text())
            self.assertIn("InstructionsLoaded", settings["hooks"])
            self.assertEqual(settings["sandbox"]["network"]["allowedDomains"], [])
            self.assertEqual(settings["effortLevel"], "low")
            log = Path(env["CLAUDE_CONFIG_DIR"]) / eval_hosts.INSTRUCTION_LOG
            log.write_text('{"file_path": "/w/CLAUDE.md"}\nnot json\n{"file_path": "/w/AGENTS.md"}\n')
            self.assertEqual(eval_hosts.loaded_instruction_files(env), ["/w/AGENTS.md", "/w/CLAUDE.md"])

    def test_stream_command_pins_isolation_flags(self) -> None:
        command = eval_hosts.stream_command(
            model="haiku", permission_mode="default",
            denied_tools=["Bash", "Edit"], add_dirs=[Path("/repo")],
        )
        for flag in ("--strict-mcp-config", "--no-session-persistence", "--add-dir"):
            self.assertIn(flag, command)
        self.assertEqual(command[command.index("--disallowed-tools") + 1], "Bash,Edit")
        self.assertNotIn("--bare", command)

    def test_explicit_invocations_render_per_host(self) -> None:
        turn = {"prompt": "Interview me.", "explicit_invocations": ["user-interview"]}
        self.assertEqual(render_turn(turn, "codex"), "$user-interview Interview me.")
        self.assertEqual(render_turn(turn, "claude"), "/user-interview Interview me.")
        with self.assertRaisesRegex(ValueError, "one explicit skill"):
            render_turn({"prompt": "x", "explicit_invocations": ["a", "b"]}, "claude")

    def test_host_restricted_cases_are_filtered(self) -> None:
        cases = [{"id": "shared"}, {"id": "codex-only", "hosts": ["codex"]}]
        self.assertEqual([c["id"] for c in cases_for_host(cases, "claude")], ["shared"])
        self.assertEqual([c["id"] for c in cases_for_host(cases, "codex")], ["shared", "codex-only"])

    def test_host_restriction_requires_a_reason(self) -> None:
        corpus = {"schema_version": 1, "default_runs": 1, "trigger_threshold": 0.5, "cases": [{
            "id": "c", "split": "train", "kind": "trigger", "hosts": ["codex"],
            "available_skills": ["change-review"],
            "turns": [{"prompt": "Review.", "explicit_invocations": []}],
            "expected": {"loaded_skills": ["change-review"], "excluded_skills": [], "behaviors": []},
        }]}
        self.assertIn("c: hosts requires a hosts_reason", validate_corpus(corpus))
        corpus["cases"][0]["hosts"] = ["cursor"]
        corpus["cases"][0]["hosts_reason"] = "x"
        self.assertTrue(any("non-empty subset" in f for f in validate_corpus(corpus)))

    def test_turns_are_sent_only_after_the_previous_result(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            command = [sys.executable, str(FIXTURES / "fake_claude.py")]
            events, _ = eval_hosts.run_turns(
                command, {"PATH": os.environ.get("PATH", "")}, Path(directory), ["one", "two", "three"], 10
            )
        turns = eval_hosts.turn_results(events)
        self.assertEqual([t["final_response"] for t in turns], ["0:one", "1:two", "2:three"])
        self.assertEqual([t["status"] for t in turns], ["completed"] * 3)


if __name__ == "__main__":
    unittest.main()
