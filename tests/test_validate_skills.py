import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

from validate_skills import (  # noqa: E402
    CATALOG_WARNING_CHARACTERS,
    MAX_SKILL_PROMPT_BYTES,
    catalog_estimate,
    catalog_warning,
    skill_prompt_warning,
    validate_claude_skill,
    validate_codex_skill,
    validate_portable_skill,
    validate_repository_contract,
    validate_installed_root,
    validate_runtime_references,
)


CORE_BODY = """# Example

## Purpose
Do one job.

## Do Not Use
- Another job is requested.

## Needs
- An input.

## Returns
- An output.

## Done Conditions
- The output exists.

## Progress
Return the current state.
"""

EXPLICIT_METADATA = "metadata:\n    invocation: explicit\n"


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
            skill = self.make_skill(
                Path(directory),
                name="another-overlay",
                extra_frontmatter=EXPLICIT_METADATA,
                body=body,
            )
            self.write_openai_metadata(skill)
            self.assertEqual(validate_repository_contract(skill), [])
            self.assertEqual(validate_codex_skill(skill), [])

    def test_interaction_contract_requires_explicit_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = CORE_BODY + "\n## Session Overlay Contract\nCompose with the task.\n"
            skill = self.make_skill(Path(directory), body=body)
            self.assertIn(
                "interaction skill must declare metadata.invocation: explicit",
                validate_repository_contract(skill),
            )

    def test_explicit_declaration_must_be_visible_to_installer(self) -> None:
        accepted = (
            "metadata:\n    invocation: \"explicit\"\n",
            "metadata:\n    invocation: 'explicit'\n",
            "metadata:\n    invocation: explicit  # manual only\n",
        )
        for index, frontmatter in enumerate(accepted):
            with self.subTest(frontmatter=frontmatter), tempfile.TemporaryDirectory() as directory:
                skill = self.make_skill(Path(directory), name=f"block-{index}", extra_frontmatter=frontmatter)
                self.assertEqual(validate_repository_contract(skill), [])
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(Path(directory), extra_frontmatter="metadata: {invocation: explicit}\n")
            self.assertIn(
                "declare metadata.invocation: explicit in block style so install.sh can enforce it",
                validate_repository_contract(skill),
            )

    def test_portable_skill_rejects_unknown_invocation_policy(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(
                Path(directory),
                extra_frontmatter="metadata:\n    invocation: manual\n",
            )
            self.assertIn(
                "metadata.invocation must be 'explicit' when provided",
                validate_portable_skill(skill),
            )

    def test_codex_policy_must_match_explicit_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            undeclared = self.make_skill(root, name="undeclared")
            self.write_openai_metadata(undeclared)
            self.assertIn(
                "implicit invocation is disabled without metadata.invocation: explicit",
                validate_codex_skill(undeclared),
            )
            declared = self.make_skill(root, name="declared", extra_frontmatter=EXPLICIT_METADATA)
            self.assertIn("explicit skill is missing agents/openai.yaml", validate_codex_skill(declared))
            self.write_openai_metadata(declared, allow_implicit="true")
            self.assertIn("explicit skill must disable implicit invocation", validate_codex_skill(declared))

    def test_claude_skill_requires_rendered_invocation_adapter(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = self.make_skill(root, extra_frontmatter=EXPLICIT_METADATA)
            self.assertIn(
                "disable-model-invocation must match metadata.invocation: explicit",
                validate_claude_skill(source),
            )
            rendered = self.make_skill(
                root / "claude",
                extra_frontmatter=EXPLICIT_METADATA + "disable-model-invocation: true\n",
            )
            self.assertEqual(validate_claude_skill(rendered), [])
            self.assertTrue(
                any("Codex-incompatible" in failure for failure in validate_codex_skill(rendered))
            )

    def test_explicit_interaction_requires_codex_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            body = CORE_BODY + "\n## Interactive Loop Contract\nOwn the exchange.\n"
            skill = self.make_skill(Path(directory), body=body)
            self.assertIn(
                "explicit skill is missing agents/openai.yaml",
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

    def test_codex_prompt_budget_uses_utf8_bytes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(Path(directory))
            skill_md = skill / "SKILL.md"
            content = skill_md.read_text(encoding="utf-8")
            exact = content + "x" * (MAX_SKILL_PROMPT_BYTES - len(content.encode("utf-8")))
            skill_md.write_text(exact, encoding="utf-8")
            self.assertFalse(any("UTF-8 bytes" in value for value in validate_codex_skill(skill)))

            skill_md.write_text(exact + "x", encoding="utf-8")
            self.assertTrue(any("8001 UTF-8 bytes" in value for value in validate_codex_skill(skill)))
            skill_md.write_text(exact + "é", encoding="utf-8")
            self.assertTrue(any("8002 UTF-8 bytes" in value for value in validate_codex_skill(skill)))

    def test_codex_prompt_warning_starts_at_7000_bytes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill = self.make_skill(Path(directory))
            skill_md = skill / "SKILL.md"
            content = skill_md.read_text(encoding="utf-8")
            skill_md.write_text(
                content + "x" * (6_999 - len(content.encode("utf-8"))),
                encoding="utf-8",
            )
            self.assertIsNone(skill_prompt_warning(skill))
            skill_md.write_text(skill_md.read_text(encoding="utf-8") + "x", encoding="utf-8")
            self.assertIn("7000 UTF-8 bytes", skill_prompt_warning(skill) or "")

    def test_runtime_references_validate_source_and_installed_alias(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            family = root / "families" / "example"
            skill = self.make_skill(family, body=CORE_BODY + "\nRead `../references/guide.md`.\n")
            references = family / "references"
            references.mkdir()
            (references / "guide.md").write_text("Guide.\n", encoding="utf-8")
            installed = root / "installed" / skill.name
            installed.parent.mkdir()
            installed.symlink_to(skill, target_is_directory=True)

            self.assertEqual(validate_runtime_references(skill), [])
            self.assertEqual(validate_runtime_references(installed), [])
            (references / "guide.md").unlink()
            self.assertIn(
                "runtime reference '../references/guide.md' does not resolve",
                validate_runtime_references(installed),
            )

    def test_runtime_reference_glob_requires_a_match(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            skill = self.make_skill(
                root,
                body=CORE_BODY + "\nRead `../references/*-practices.md`.\n",
            )
            self.assertTrue(any("does not resolve" in value for value in validate_runtime_references(skill)))

    def test_installed_root_requires_every_source_skill(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = self.make_skill(root / "source")
            installed_root = root / "installed"
            installed_root.mkdir()
            self.assertEqual(
                validate_installed_root(installed_root, [source / "SKILL.md"]),
                ["example-skill: installed SKILL.md is missing or unreadable"],
            )

    def test_catalog_estimate_includes_rendered_metadata_and_locator(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            skill = self.make_skill(root / "families" / "example")
            estimate = catalog_estimate([skill / "SKILL.md"], root)
            self.assertGreater(estimate, len("example-skill"))
            self.assertLess(estimate, CATALOG_WARNING_CHARACTERS)

    def test_catalog_warning_starts_at_6400_characters(self) -> None:
        self.assertIsNone(catalog_warning(CATALOG_WARNING_CHARACTERS - 1))
        self.assertIn(
            "6400 characters",
            catalog_warning(CATALOG_WARNING_CHARACTERS) or "",
        )


if __name__ == "__main__":
    unittest.main()
