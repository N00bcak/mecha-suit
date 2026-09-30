import contextlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from run_interaction_evals import AppServerClient
from run_outcome_evals import (
    CORPUS, ORACLE, ROOT, changes, comparison,
    isolated_environment, load_cases, main, prepare_workspace,
    render_summary, run_arm, run_checks, scope_check, snapshot,
)

FAKE_SERVER = Path(__file__).parent / "fixtures/fake_outcome_server.py"


def fake_factory(mode="normal", calls=None):
    def make(command, *, env, cwd):
        if calls is not None:
            calls.append((command, env, cwd))
        return AppServerClient([sys.executable, str(FAKE_SERVER), *command[3:]],
                               env={**env, "MECHA_FAKE_MODE": mode}, cwd=cwd)
    return make


def trusted_fixture_check(case, workspace, env, timeout):
    # Only deterministic test fixtures run directly; live candidate code uses a sandbox.
    if not case["checks"]:
        return {"status": "not-applicable"}
    result = subprocess.run([sys.executable, "-I", "-B", str(ORACLE), str(workspace),
                             json.dumps(case["checks"])], capture_output=True, text=True, timeout=timeout)
    return {"status": "passed" if result.returncode == 0 else "failed",
            "stdout": result.stdout, "stderr": result.stderr}


class OutcomeTests(unittest.TestCase):
    def setUp(self):
        self.cases = load_cases()

    def arm(self, case=None, arm="baseline", mode="normal", calls=None):
        return run_arm(case or self.cases[0], arm, "fixture-model", "low", 1, None,
                       client_factory=fake_factory(mode, calls), checker=trusted_fixture_check)

    def test_corpus_validates_and_rejects_escape_paths(self):
        self.assertEqual({c["id"] for c in self.cases}, {
            "accepted-plan", "spec-and-slices", "small-fix", "snapshot-audit", "diff-review"})
        for path in ("../escape.py", "/outside.py", ".git/config", ".codex/config.toml"):
            doc = json.loads(CORPUS.read_text())
            doc["cases"][0]["files"][path] = "invalid"
            with tempfile.TemporaryDirectory() as d:
                p = Path(d) / "cases.json"
                p.write_text(json.dumps(doc))
                with self.assertRaises(ValueError):
                    load_cases(p)

    def test_function_oracles_discriminate_broken_and_corrected_artifacts(self):
        corrections = {
            "accepted-plan": ("limits.py", "def clamp(value, low, high):\n    if low > high: raise ValueError()\n    return min(high, max(low, value))\n"),
            "small-fix": ("labels.py", "def normalize_label(value):\n    return value.strip().lower()\n"),
        }
        for case in self.cases:
            with tempfile.TemporaryDirectory() as d:
                workspace = Path(d) / "workspace"
                prepare_workspace(workspace, case)
                if case["checks"]:
                    self.assertEqual(trusted_fixture_check(case, workspace, {}, 5)["status"], "failed")
                    path, text = corrections[case["id"]]
                    (workspace / path).write_text(text)
                    self.assertEqual(trusted_fixture_check(case, workspace, {}, 5)["status"], "passed")
                else:
                    self.assertEqual(trusted_fixture_check(case, workspace, {}, 5)["status"], "not-applicable")

    def test_review_fixture_contains_real_diff_and_regression(self):
        case = next(c for c in self.cases if c["id"] == "diff-review")
        with tempfile.TemporaryDirectory() as d:
            workspace = Path(d) / "workspace"
            prepare_workspace(workspace, case)
            diff = subprocess.run(["git", "diff", "HEAD"], cwd=workspace, capture_output=True, text=True, check=True).stdout
            self.assertIn("// 100", diff)
            self.assertIn("result += price", diff)
            check = {**case, "checks": [{"file": "billing.py", "function": "discounted", "vectors": [{"args": [10, 15], "equals": 8.5}]}]}
            self.assertEqual(trusted_fixture_check(check, workspace, {}, 5)["status"], "failed")
            (workspace / "billing.py").write_text(case["base_files"]["billing.py"])
            self.assertEqual(trusted_fixture_check(check, workspace, {}, 5)["status"], "passed")

    def test_pair_uses_full_catalog_identical_files_and_explicit_model_effort(self):
        calls = []
        baseline = self.arm(calls=calls)
        mecha = self.arm(arm="mecha", calls=calls)
        for result in (baseline, mecha):
            self.assertEqual(result["status"], "completed", result.get("error"))
            self.assertEqual(result["checks"]["status"], "passed")
            self.assertEqual(result["scope"]["status"], "passed")
            self.assertEqual(result["verified_model"], "fixture-model")
            self.assertEqual(result["verified_effort"], "low")
            self.assertIsNone(result["usage"])
        self.assertEqual(baseline["initial_files"], mecha["initial_files"])
        self.assertEqual(baseline["expected_catalog"], [])
        self.assertEqual(set(mecha["expected_catalog"]), {p.parent.name for p in ROOT.glob("families/*/*/SKILL.md")})
        self.assertNotEqual(calls[0][2], calls[2][2])
        self.assertTrue(all(not cwd.exists() for _, _, cwd in calls))
        self.assertTrue(any(e["params"].get("item", {}).get("aggregatedOutput") == "retained evidence" for e in mecha["events"]))

    def test_isolation_failures_are_inconclusive_before_turns(self):
        for mode in ("wrong-model", "extra-instructions", "ambient-config", "extra-skill"):
            with self.subTest(mode=mode):
                result = self.arm(mode=mode)
                self.assertEqual(result["status"], "inconclusive")
                self.assertEqual(result["turns"], [])
                self.assertEqual(result["checks"]["status"], "inconclusive")

    def test_timeout_and_failed_turn_keep_partial_evidence(self):
        for mode in ("timeout", "failed-turn"):
            result = self.arm(mode=mode)
            self.assertEqual(result["status"], "inconclusive")
            self.assertTrue(result["events"])
            self.assertIn("limits.py", result["changes"])
            self.assertIn("return min", result["changes"]["limits.py"]["after"]["text"])

    def test_scope_failure_is_separate_from_successful_execution(self):
        result = self.arm(mode="scope-violation")
        self.assertEqual(result["status"], "completed")
        self.assertEqual(result["checks"]["status"], "passed")
        self.assertEqual(result["scope"]["status"], "failed")
        self.assertIn(".mecha/index.md", result["scope"]["unexpected_paths"])

    def test_usage_is_captured_only_when_available(self):
        self.assertEqual(self.arm(mode="usage")["usage"]["total"]["totalTokens"], 123)

    def test_planning_and_audits_remain_manually_graded(self):
        for case in self.cases:
            if not case["checks"]:
                result = self.arm(case)
                self.assertEqual(result["checks"]["status"], "not-applicable")
                self.assertTrue(all(c["verdict"] is None for c in result["manual_review"]))
                self.assertEqual(len(result["turns"]), len(case["turns"]))

    def test_comparison_alternates_order_and_retains_both_arms(self):
        order = []
        def runner(case, arm, *args):
            order.append(arm)
            return {"status": "completed", "initial_fingerprint": "same", "checks": {"status": "passed"},
                    "scope": {"status": "passed"}, "elapsed_seconds": 1,
                    "manual_review": [{"criterion": "Review evidence", "verdict": None}]}
        report = comparison(self.cases[:1], 2, "fixture-model", "low", 1, None, runner)
        self.assertEqual(order, ["baseline", "mecha", "mecha", "baseline"])
        self.assertTrue(all(p["status"] == "comparable" for p in report["pairs"]))
        summary = render_summary(report)
        self.assertIn("baseline", summary)
        self.assertIn("mecha", summary)
        self.assertIn("- [ ] Review evidence", summary)

    def test_evaluator_uses_read_only_network_disabled_command_api(self):
        from unittest.mock import MagicMock
        client = MagicMock()
        client.request.return_value = {"exitCode": 0, "stdout": "passed", "stderr": ""}
        manager = MagicMock()
        manager.__enter__.return_value = client
        with patch("run_outcome_evals.AppServerClient", return_value=manager) as factory:
            result = run_checks(self.cases[0], Path("/fixture"), {"OPENAI_API_KEY": "secret"}, 1)
        self.assertEqual(result["status"], "passed")
        method, params, timeout = client.request.call_args.args
        self.assertEqual(method, "command/exec")
        self.assertEqual(params["sandboxPolicy"], {"type": "readOnly", "networkAccess": False})
        self.assertIn(str(ORACLE), params["command"])
        self.assertNotIn("OPENAI_API_KEY", factory.call_args.kwargs["env"])

    def test_inconclusive_checker_prevents_comparison_claim(self):
        def runner(case, arm, *args):
            return {"status": "completed", "initial_fingerprint": "same", "checks": {"status": "inconclusive"}}
        report = comparison(self.cases[:1], 1, "fixture-model", "low", 1, None, runner)
        self.assertEqual(report["pairs"][0]["status"], "inconclusive")

    def test_json_and_markdown_reports_retain_evidence(self):
        arms = {arm: self.arm(arm=arm) for arm in ("baseline", "mecha")}
        report = {"pairs": [{"case": "accepted-plan", "repetition": 1, "status": "comparable", "arms": arms}]}
        with tempfile.TemporaryDirectory() as d:
            output = Path(d) / "results.json"
            with patch("run_outcome_evals.comparison", return_value=report), \
                 patch("run_outcome_evals.shutil.which", return_value="codex"), \
                 patch("run_outcome_evals.subprocess.run") as version:
                version.return_value.stdout = "codex-fixture"
                self.assertEqual(main(["--model", "fixture-model", "--effort", "low", "--output", str(output)]), 0)
            saved = json.loads(output.read_text())
            self.assertIn("limits.py", saved["pairs"][0]["arms"]["mecha"]["changes"])
            self.assertTrue(output.with_suffix(".md").exists())
            self.assertIn("Manual review", output.with_suffix(".md").read_text())

    def test_environment_imports_auth_only_and_does_not_report_it(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            auth = root / "auth.json"
            auth.write_text('{"fixture": "secret"}')
            with patch.dict(os.environ, {"UNRELATED_SECRET": "secret", "PYTHONPATH": "/ambient"}):
                env = isolated_environment(root / "home", auth)
            self.assertNotIn("UNRELATED_SECRET", env)
            self.assertNotIn("PYTHONPATH", env)
            self.assertEqual((root / "home/.codex/auth.json").read_text(), auth.read_text())
            self.assertFalse((root / "home/.codex/config.toml").exists())

    def test_scope_detects_deletions_and_symlinks_without_following_them(self):
        with tempfile.TemporaryDirectory() as d:
            workspace = Path(d) / "workspace"
            prepare_workspace(workspace, self.cases[0])
            before = snapshot(workspace)
            (workspace / "PLAN.md").unlink()
            (workspace / "outside").symlink_to(Path(d))
            changed = changes(before, snapshot(workspace))
            self.assertIn("symlink", changed["outside"]["after"])
            self.assertEqual(set(scope_check(changed, ["limits.py"])["unexpected_paths"]), {"PLAN.md", "outside"})

    def test_cli_dry_run_is_offline_and_live_requires_settings(self):
        with patch("run_outcome_evals.AppServerClient", side_effect=AssertionError("must not run")):
            with contextlib.redirect_stdout(io.StringIO()) as output:
                self.assertEqual(main(["--dry-run", "--case", "small-fix"]), 0)
            self.assertEqual(len(json.loads(output.getvalue())["cases"]), 1)
            with contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(main([]), 2)
                self.assertEqual(main(["--dry-run", "--case", "missing"]), 2)
                self.assertEqual(main(["--dry-run", "--runs", "0"]), 2)


if __name__ == "__main__":
    unittest.main()
