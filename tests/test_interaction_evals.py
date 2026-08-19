import copy
import json
import sys
import unittest
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from run_interaction_evals import (  # noqa: E402
    DEFAULT_CORPUS,
    classify_run,
    load_corpus,
    parse_codex_events,
    render_turn,
    summarize_case,
    validate_corpus,
)

ROOT = Path(__file__).resolve().parents[1]
ENGINEERING_CORPUS = ROOT / "evals" / "engineering-routing.json"
REVIEW_CONVERGENCE_CORPUS = ROOT / "evals" / "review-convergence.json"


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

        self.assertEqual(kinds, {"trigger": 20, "interaction": 12})
        self.assertEqual(splits, {"train": 18, "validation": 14})
        self.assertEqual(
            sum(bool(case["expected"]["loaded_skills"]) for case in trigger_cases),
            10,
        )

    def test_corpus_rejects_unknown_skill(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        changed = copy.deepcopy(corpus)
        changed["cases"][0]["available_skills"].append("unknown-skill")
        failures = validate_corpus(changed)
        self.assertTrue(any("unknown skills" in failure for failure in failures))

    def test_engineering_corpus_covers_positive_and_native_boundaries(self) -> None:
        corpus = load_corpus(ENGINEERING_CORPUS)
        cases = corpus["cases"]
        self.assertEqual(len(cases), 8)
        self.assertEqual(
            Counter(case["split"] for case in cases),
            {"train": 4, "validation": 4},
        )
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

    def test_review_convergence_corpus_covers_material_boundaries(self) -> None:
        corpus = load_corpus(REVIEW_CONVERGENCE_CORPUS)
        cases = corpus["cases"]
        self.assertEqual(len(cases), 11)
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

    def test_codex_rendering_adds_host_syntax_outside_corpus_prompt(self) -> None:
        turn = {
            "prompt": "Discuss the concept with me.",
            "explicit_invocations": ["product-co-design", "low-friction-collaboration"],
        }
        self.assertEqual(
            render_turn(turn, "codex"),
            "$product-co-design $low-friction-collaboration Discuss the concept with me.",
        )

    def test_codex_parser_labels_skill_file_reads_as_heuristic(self) -> None:
        events = "\n".join(
            [
                json.dumps(
                    {
                        "type": "item.completed",
                        "item": {
                            "type": "command_execution",
                            "command": "sed -n 1,80p /tmp/.agents/skills/product-research/SKILL.md",
                        },
                    }
                ),
                json.dumps(
                    {
                        "type": "item.completed",
                        "item": {"type": "agent_message", "text": "Result"},
                    }
                ),
                json.dumps({"type": "turn.completed"}),
            ]
        )
        observed, response, completed = parse_codex_events(
            events, ["product-research", "product-co-design"]
        )
        self.assertEqual(observed, {"product-research"})
        self.assertEqual(response, "Result")
        self.assertTrue(completed)

    def test_unobserved_explicit_binding_is_inconclusive(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(
            case
            for case in corpus["cases"]
            if case["id"] == "trigger-explicit-product-co-design"
        )
        self.assertEqual(classify_run(case, set(), True), "inconclusive")

    def test_host_failure_cannot_pass_a_negative_case(self) -> None:
        corpus = load_corpus(DEFAULT_CORPUS)
        case = next(
            case
            for case in corpus["cases"]
            if case["id"] == "trigger-clearer-writing-without-explicit-overlay"
        )
        result = {
            "observed_rates": {name: 0.0 for name in case["available_skills"]},
            "successful_runs": 0,
        }
        summarize_case(case, result, corpus["trigger_threshold"])
        self.assertEqual(result["evaluation"], "inconclusive-host-failure")


if __name__ == "__main__":
    unittest.main()
