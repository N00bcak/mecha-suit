import copy
import json
import sys
import tempfile
import textwrap
import unittest
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from run_interaction_evals import (  # noqa: E402
    AppServerClient,
    DEFAULT_CORPUS,
    classify_run,
    collect_turn,
    load_corpus,
    observe_skill_reads,
    render_turn,
    run_classification,
    skill_filter_config,
    summarize_case,
    turn_input,
    validate_corpus,
)

ROOT = Path(__file__).resolve().parents[1]
ENGINEERING_CORPUS = ROOT / "evals" / "engineering-routing.json"
REVIEW_CONVERGENCE_CORPUS = ROOT / "evals" / "review-convergence.json"
WEB_DESIGN_CORPUS = ROOT / "evals" / "web-design-routing.json"


class InteractionEvaluationTests(unittest.TestCase):
    def test_every_committed_corpus_is_valid(self) -> None:
        for path in sorted((ROOT / "evals").glob("*.json")):
            with self.subTest(path=path.name):
                load_corpus(path)

    def test_committed_corpus_has_planned_shape(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        kinds = Counter(case["kind"] for case in corpus["cases"])
        splits = Counter(case["split"] for case in corpus["cases"])
        trigger_cases = [case for case in corpus["cases"] if case["kind"] == "trigger"]

        self.assertEqual(set(kinds), {"trigger", "interaction"})
        self.assertEqual(set(splits), {"train", "validation"})
        self.assertEqual(
            sum(bool(case["expected"]["loaded_skills"]) for case in trigger_cases),
            10,
        )

    def test_contract_regressions_have_observable_cases(self) -> None:
        cases = {
            case["id"]: case
            for path in (DEFAULT_CORPUS, ENGINEERING_CORPUS, REVIEW_CONVERGENCE_CORPUS)
            for case in load_corpus(path)["cases"]
        }
        for name in ("adhoc-plan-execution", "contributor-spec-and-slices", "explicit-governance-record",
                     "review-empty-diff", "engineering-snapshot-audit"):
            self.assertIn(name, cases)
        self.assertIn("multi-step-governance", cases["adhoc-plan-execution"]["expected"]["excluded_skills"])
        self.assertEqual(cases["explicit-governance-record"]["turns"][0]["explicit_invocations"], ["multi-step-governance"])
        self.assertIn("code-review", cases["engineering-snapshot-audit"]["expected"]["excluded_skills"])
        self.assertIn("does-not-issue-passing-disposition", cases["review-empty-diff"]["expected"]["behaviors"])

    def test_corpus_rejects_unknown_skill(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        changed = copy.deepcopy(corpus)
        changed["cases"][0]["available_skills"].append("unknown-skill")
        failures = validate_corpus(changed)
        self.assertTrue(any("unknown skills" in failure for failure in failures))

    def test_engineering_corpus_covers_positive_and_native_boundaries(self) -> None:
        corpus = load_corpus(ENGINEERING_CORPUS)
        cases = corpus["cases"]
        self.assertEqual({case["split"] for case in cases}, {"train", "validation"})
        loaded = {
            skill
            for case in cases
            for skill in case["expected"]["loaded_skills"]
        }
        self.assertTrue(
            {"prototype-builder", "large-codebase-change", "diagnosing-bugs"}
            <= loaded
        )
        self.assertTrue(any(not case["expected"]["loaded_skills"] for case in cases))

        by_id = {case["id"]: case for case in cases}
        mid_sized = by_id["engineering-mid-sized-existing-native"]
        self.assertEqual(mid_sized["expected"]["loaded_skills"], [])
        self.assertEqual(
            set(mid_sized["expected"]["excluded_skills"]),
            {"prototype-builder", "large-codebase-change"},
        )

        compatibility = by_id["engineering-small-diff-large-repo"]
        self.assertTrue(
            {
                "changes-authoritative-boundary",
                "maps-versioned-consumers",
                "verifies-old-and-new-clients",
                "reports-compatibility-risk",
                "does-not-self-authorize-required-deferrals",
                "returns-unresolved-required-obligations-as-blocked",
            }
            <= set(compatibility["expected"]["behaviors"])
        )

    def test_review_convergence_corpus_covers_material_boundaries(self) -> None:
        corpus = load_corpus(REVIEW_CONVERGENCE_CORPUS)
        cases = corpus["cases"]
        behaviors = {
            behavior
            for case in cases
            for behavior in case["expected"]["behaviors"]
        }
        self.assertTrue(
            {
                "blocks-evidenced-regression",
                "rejects-unsupported-claim",
                "preserves-implementer-choice",
                "defers-safe-preexisting-defect",
                "requests-decisive-check",
                "accepts-counter-evidence",
                "preserves-finding-identity",
                "routes-stalemate-to-adjudication",
                "blocks-unsafe-preexisting-defect",
                "routes-intent-change-to-user",
                "passes-with-only-non-blocking-items",
            }
            <= behaviors
        )

    def test_web_design_corpus_covers_artifacts_and_boundaries(self) -> None:
        corpus = load_corpus(WEB_DESIGN_CORPUS)
        cases = corpus["cases"]
        self.assertEqual(len(cases), 8)
        self.assertEqual(
            Counter(case["split"] for case in cases),
            {"train": 4, "validation": 4},
        )

        by_id = {case["id"]: case for case in cases}
        for case_id in {
            "web-design-astro-content-experience",
            "web-design-standalone-infographic",
            "web-design-operational-application",
        }:
            self.assertEqual(
                by_id[case_id]["expected"]["loaded_skills"],
                ["web-design"],
            )

        for case_id in {
            "web-design-not-inline-visualization",
            "web-design-not-small-css-fix",
        }:
            self.assertEqual(by_id[case_id]["expected"]["loaded_skills"], [])

        self.assertEqual(
            by_id["web-design-after-product-direction"]["expected"]["loaded_skills"],
            ["product-co-design"],
        )
        self.assertEqual(
            by_id["web-design-not-full-stack-change"]["expected"]["loaded_skills"],
            ["large-codebase-change"],
        )

        interaction = by_id["web-design-concepts-before-implementation"]
        self.assertTrue(
            {
                "researches-context-before-design",
                "renders-exactly-three-materially-different-comps",
                "keeps-comps-outside-production-path",
                "waits-for-direction-selection",
                "implements-only-selected-direction",
                "discloses-fixture-boundary",
                "covers-material-interface-states",
                "verifies-responsive-behavior",
                "checks-wcag-2-2-aa",
            }
            <= set(interaction["expected"]["behaviors"])
        )

    def test_codex_rendering_adds_host_syntax_outside_corpus_prompt(self) -> None:
        turn = {
            "prompt": "Discuss the concept with me.",
            "explicit_invocations": ["product-co-design", "low-friction-collaboration"],
        }
        self.assertEqual(
            render_turn(turn, "codex"),
            "$product-co-design $low-friction-collaboration Discuss the concept with me.",
        )

    def test_codex_turn_input_adds_structured_explicit_skills(self) -> None:
        turn = {
            "prompt": "Discuss the concept with me.",
            "explicit_invocations": ["product-co-design"],
        }
        workspace = Path("workspace").resolve()
        inputs = turn_input(turn, workspace)
        self.assertEqual(
            inputs,
            [
                {
                    "type": "text",
                    "text": "$product-co-design Discuss the concept with me.",
                },
                {
                    "type": "skill",
                    "name": "product-co-design",
                    "path": str(
                        workspace
                        / ".agents/skills/product-co-design/SKILL.md"
                    ),
                },
            ],
        )

    def test_codex_parser_labels_skill_file_reads_as_heuristic(self) -> None:
        item = {
            "type": "commandExecution",
            "command": "sed -n 1,80p /tmp/.agents/skills/product-research/SKILL.md",
            "commandActions": [],
        }
        self.assertEqual(
            observe_skill_reads(item, ["product-research", "product-co-design"]),
            {"product-research"},
        )

    def test_skill_filter_disables_non_candidate_catalog_entries(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            workspace = Path(directory)
            candidate = workspace / ".agents/skills/product-research/SKILL.md"
            candidate.parent.mkdir(parents=True)
            candidate.write_text("---\nname: product-research\n---\n", encoding="utf-8")
            listed = [
                {"name": "product-research", "path": str(candidate)},
                {"name": "other", "path": "/tmp/global/other/SKILL.md"},
            ]
            self.assertEqual(
                skill_filter_config(listed, workspace, ["product-research"]),
                {
                    "user_instructions": "",
                    "skills": {
                        "config": [
                            {
                                "path": "/tmp/global/other/SKILL.md",
                                "enabled": False,
                            }
                        ]
                    }
                },
            )

    def test_app_server_protocol_reuses_one_thread_across_turns(self) -> None:
        server_source = textwrap.dedent(
            """
            import json
            import sys

            turn_number = 0

            def send(message):
                print(json.dumps(message), flush=True)

            for line in sys.stdin:
                message = json.loads(line)
                method = message.get("method")
                if method == "initialize":
                    send({"id": message["id"], "result": {}})
                elif method == "initialized":
                    continue
                elif method == "turn/start":
                    if message["params"]["threadId"] != "thread-1":
                        send({"id": message["id"], "error": {"message": "wrong thread"}})
                        continue
                    turn_number += 1
                    turn_id = f"turn-{turn_number}"
                    send({"id": message["id"], "result": {"turn": {"id": turn_id}}})
                    send({
                        "method": "item/completed",
                        "params": {
                            "threadId": "thread-1",
                            "turnId": turn_id,
                            "item": {
                                "type": "agentMessage",
                                "text": f"response {turn_number}",
                            },
                        },
                    })
                    send({
                        "method": "turn/completed",
                        "params": {
                            "threadId": "thread-1",
                            "turn": {
                                "id": turn_id,
                                "status": "completed",
                                "items": [],
                            },
                        },
                    })
            """
        )
        with tempfile.TemporaryDirectory() as directory:
            server = Path(directory) / "fake_app_server.py"
            server.write_text(server_source, encoding="utf-8")
            client = AppServerClient([sys.executable, str(server)])
            try:
                client.initialize(2)
                responses: list[str] = []
                for number in (1, 2):
                    started = client.request(
                        "turn/start",
                        {"threadId": "thread-1", "input": []},
                        2,
                    )
                    result = collect_turn(
                        client,
                        "thread-1",
                        started["turn"]["id"],
                        [],
                        2,
                    )
                    self.assertEqual(result["status"], "completed")
                    responses.append(result["final_response"])
                    self.assertEqual(result["turn_id"], f"turn-{number}")
                self.assertEqual(responses, ["response 1", "response 2"])
            finally:
                client.close()

    def test_structured_explicit_binding_is_loaded_evidence(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(
            case
            for case in corpus["cases"]
            if case["id"] == "trigger-explicit-product-co-design"
        )
        self.assertEqual(
            classify_run(case, set(), {"product-co-design"}, True),
            "passed",
        )

    def test_skill_warning_makes_run_inconclusive(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(
            case
            for case in corpus["cases"]
            if case["id"] == "trigger-explicit-product-co-design"
        )
        self.assertEqual(
            classify_run(
                case,
                set(),
                {"product-co-design"},
                True,
                ["Skill instructions could not be loaded"],
            ),
            "inconclusive",
        )

    def test_incomplete_interaction_run_is_not_sent_to_manual_review(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(case for case in corpus["cases"] if case["kind"] == "interaction")
        self.assertEqual(
            run_classification(case, set(), set(), False, []),
            "inconclusive",
        )

    def test_host_failure_cannot_pass_a_negative_case(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(
            case
            for case in corpus["cases"]
            if case["id"] == "trigger-clearer-writing-without-explicit-overlay"
        )
        result = {
            "loaded_rates": {name: 0.0 for name in case["available_skills"]},
            "successful_runs": 0,
        }
        summarize_case(case, result, corpus["trigger_threshold"])
        self.assertEqual(result["evaluation"], "inconclusive-host-failure")


if __name__ == "__main__":
    unittest.main()
