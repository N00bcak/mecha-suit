import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
IGNORED_PARTS = {".git", ".mecha", ".venv", "matt-pocock-excursion"}
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
RESOURCE_RE = re.compile(r"`([^`]+\.md)`")


def repository_markdown() -> list[Path]:
    return [
        path
        for path in ROOT.rglob("*.md")
        if not IGNORED_PARTS.intersection(path.relative_to(ROOT).parts)
    ]


class DocumentationTests(unittest.TestCase):
    def test_local_markdown_links_resolve(self) -> None:
        broken: list[str] = []
        for source in repository_markdown():
            for raw_target in LINK_RE.findall(source.read_text()):
                target = raw_target.split("#", 1)[0].strip().strip("<>")
                if not target or "://" in target or target.startswith("mailto:"):
                    continue
                resolved = (source.parent / target).resolve()
                if not resolved.exists():
                    broken.append(f"{source.relative_to(ROOT)} -> {raw_target}")
        self.assertEqual(broken, [])

    def test_handbook_is_consolidated(self) -> None:
        required = {
            "README.md",
            "AGENTS.md",
            "CLAUDE.md",
            "docs/architecture.md",
            "docs/maintenance-playbook.md",
            "docs/platform-notes.md",
            "docs/skills.md",
            "templates/global-AGENTS.template.md",
            "templates/global-CLAUDE.template.md",
        }
        removed = {
            "CODESTYLE.md",
            "SUBAGENTS_PLAN.md",
            "docs/global-AGENTS.example.md",
            "docs/global-CLAUDE.example.md",
            "shared/examples/skill-selection-examples.md",
            "shared/rubrics/persistence-yield-rubric.md",
            "shared/rubrics/skill-boundary-rubric.md",
        }
        self.assertTrue(all((ROOT / path).exists() for path in required))
        self.assertTrue(all(not (ROOT / path).exists() for path in removed))

        legacy_tokens = (
            "CODESTYLE.md",
            "SUBAGENTS_PLAN.md",
            "docs/specs/",
            "docs/global-AGENTS.example.md",
            "docs/global-CLAUDE.example.md",
            "shared/examples/skill-selection-examples.md",
            "shared/rubrics/persistence-yield-rubric.md",
            "shared/rubrics/skill-boundary-rubric.md",
        )
        stale = [
            f"{path.relative_to(ROOT)} -> {token}"
            for path in repository_markdown()
            for token in legacy_tokens
            if token in path.read_text()
        ]
        self.assertEqual(stale, [])

    def test_runtime_references_have_direct_skill_consumers(self) -> None:
        references = set(ROOT.glob("families/**/references/*.md"))
        references.update((ROOT / "shared/rubrics").glob("*.md"))
        consumed: set[Path] = set()

        for skill in ROOT.glob("families/*/*/SKILL.md"):
            for raw_target in RESOURCE_RE.findall(skill.read_text()):
                resolved = (skill.parent / raw_target).resolve()
                if resolved in references:
                    consumed.add(resolved)

        orphaned = sorted(str(path.relative_to(ROOT)) for path in references - consumed)
        self.assertEqual(orphaned, [])

    def test_every_skill_has_positive_routing_coverage(self) -> None:
        skills = {
            skill.parent.name for skill in ROOT.glob("families/*/*/SKILL.md")
        }
        covered: set[str] = set()
        for corpus_path in (ROOT / "evals").glob("*.json"):
            corpus = json.loads(corpus_path.read_text())
            for case in corpus["cases"]:
                covered.update(case["expected"]["loaded_skills"])

        self.assertEqual(skills - covered, set())
        self.assertEqual(covered - skills, set())


if __name__ == "__main__":
    unittest.main()
