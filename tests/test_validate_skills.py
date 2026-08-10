import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from validate_skills import (  # noqa: E402
    validate_codex_skill,
    validate_portable_skill,
    validate_repository_contract,
)


CORE_BODY = """# Example

## Purpose
Do one job.

## Use When
- The job is requested.

## Do Not Use
- Another job is requested.

## Needs
- An input.

## Returns
- An output.

## Done Conditions
- The output exists.

## Persistence And Yield
Return the current state.
"""


class SkillValidationTests(unittest.TestCase):
    def make_skill(
        self,
        root: Path,
        name: str = "example-skill",
        extra_frontmatter: str = "",
        body: str = CORE_BODY,
    ) -> Path:
        skill = root / name
        skill.mkdir(parents=True)
        (skill / "SKILL.md").write_text(
            "---\n"
            f"name: {name}\n"
            "description: Perform an example workflow when the user requests the example task.\n"
            f"{extra_frontmatter}"
            "---\n\n"
            f"{body}",
            encoding="utf-8",
        )
        return skill

    def write_openai_metadata(
        self,
        skill: Path,
        *,
        allow_implicit: str = "false",
        prompt_name: str | None = None,
    ) -> None:
        prompt_name = prompt_name or skill.name
        agents = skill / "agents"
        agents.mkdir()
        (agents / "openai.yaml").write_text(
            "interface:\n"
            '    display_name: "Example Skill"\n'
            '    short_description: "Perform the example workflow"\n'
            f'    default_prompt: "Use ${prompt_name} to perform the example workflow."\n'
            "policy:\n"
            f"    allow_implicit_invocation: {allow_implicit}\n",
            encoding="utf-8",
        )

    def test_portable_skill_accepts_standard_compatibility(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(
                Path(directory),
                extra_frontmatter="compatibility: Requires network access.\n",
            )
            self.assertEqual(validate_portable_skill(skill), [])
            self.assertTrue(
                any("Codex-incompatible" in failure for failure in validate_codex_skill(skill))
            )

    def test_portable_skill_rejects_non_string_metadata_values(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(
                Path(directory),
                extra_frontmatter="metadata:\n    version: 1\n",
            )
            self.assertIn(
                "metadata keys and values must be strings",
                validate_portable_skill(skill),
            )

    def test_portable_skill_rejects_folder_name_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(Path(directory))
            text = (skill / "SKILL.md").read_text(encoding="utf-8")
            (skill / "SKILL.md").write_text(
                text.replace("name: example-skill", "name: different-name"),
                encoding="utf-8",
            )
            self.assertTrue(
                any("folder name" in failure for failure in validate_portable_skill(skill))
            )

    def test_repository_contract_rejects_multiple_interaction_markers(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = (
                CORE_BODY
                + "\n## Session Overlay Contract\nCompose.\n"
                + "\n## Interactive Loop Contract\nOwn the exchange.\n"
            )
            skill = self.make_skill(Path(directory), body=body)
            self.assertIn(
                "skill declares multiple interaction contracts",
                validate_repository_contract(skill),
            )

    def test_generic_contract_accepts_another_overlay(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = CORE_BODY + "\n## Session Overlay Contract\nCompose with the task.\n"
            skill = self.make_skill(Path(directory), name="another-overlay", body=body)
            self.write_openai_metadata(skill)
            self.assertEqual(validate_repository_contract(skill), [])
            self.assertEqual(validate_codex_skill(skill), [])

    def test_explicit_interaction_requires_codex_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = CORE_BODY + "\n## Interactive Loop Contract\nOwn the exchange.\n"
            skill = self.make_skill(Path(directory), body=body)
            self.assertIn(
                "explicit interaction skill is missing agents/openai.yaml",
                validate_codex_skill(skill),
            )

    def test_codex_metadata_requires_boolean_policy_and_matching_prompt(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = CORE_BODY + "\n## Interactive Loop Contract\nOwn the exchange.\n"
            skill = self.make_skill(Path(directory), body=body)
            self.write_openai_metadata(
                skill,
                allow_implicit='"false"',
                prompt_name="wrong-name",
            )
            failures = validate_codex_skill(skill)
            self.assertTrue(any("must be a boolean" in failure for failure in failures))
            self.assertTrue(any("must mention $example-skill" in failure for failure in failures))


if __name__ == "__main__":
    unittest.main()
