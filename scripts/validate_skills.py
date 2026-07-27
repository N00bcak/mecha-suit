#!/usr/bin/env python3
"""Validate all skill frontmatter using Codex skill-creator-compatible rules."""

import re
import sys
from pathlib import Path

import yaml

MAX_SKILL_NAME_LENGTH = 64
ALLOWED_PROPERTIES = {
    "name",
    "description",
    "license",
    "allowed-tools",
    "metadata",
}


def validate_skill(skill_path: Path) -> tuple[bool, str]:
    skill_md = skill_path / "SKILL.md"
    content = skill_md.read_text()
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, "invalid YAML frontmatter delimiters"

    try:
        frontmatter = yaml.safe_load(match.group(1))
    except yaml.YAMLError as error:
        return False, f"invalid YAML: {error}"

    if not isinstance(frontmatter, dict):
        return False, "frontmatter must be a YAML dictionary"

    unexpected = set(frontmatter) - ALLOWED_PROPERTIES
    if unexpected:
        return False, f"unexpected frontmatter keys: {', '.join(sorted(unexpected))}"

    name = frontmatter.get("name")
    description = frontmatter.get("description")
    if not isinstance(name, str) or not name.strip():
        return False, "name must be a non-empty string"
    if not isinstance(description, str) or not description.strip():
        return False, "description must be a non-empty string"

    name = name.strip()
    description = description.strip()
    if not re.fullmatch(r"[a-z0-9-]+", name):
        return False, "name must use lowercase letters, digits, and hyphens only"
    if name.startswith("-") or name.endswith("-") or "--" in name:
        return False, "name cannot start/end with a hyphen or contain consecutive hyphens"
    if len(name) > MAX_SKILL_NAME_LENGTH:
        return False, f"name exceeds {MAX_SKILL_NAME_LENGTH} characters"
    if "<" in description or ">" in description:
        return False, "description cannot contain angle brackets"
    if len(description) > 1024:
        return False, "description exceeds 1024 characters"
    if skill_path.name != name:
        return False, f"folder name does not match declared name {name!r}"

    return True, "valid"


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    skill_files = sorted((root / "families").glob("*/*/SKILL.md"))
    failures = []

    for skill_file in skill_files:
        valid, message = validate_skill(skill_file.parent)
        if not valid:
            failures.append(f"{skill_file.relative_to(root)}: {message}")

    if failures:
        for failure in failures:
            print(f"[fail] {failure}", file=sys.stderr)
        return 1

    print(f"[ok] Codex-compatible frontmatter for {len(skill_files)} skills")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
