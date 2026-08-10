#!/usr/bin/env python3
"""Validate portable skill contracts and Codex-specific metadata."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

import yaml

MAX_SKILL_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
MAX_COMPATIBILITY_LENGTH = 500
PORTABLE_PROPERTIES = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}
CODEX_PROPERTIES = PORTABLE_PROPERTIES - {"compatibility"}
CORE_SECTIONS = {
    "Purpose",
    "Use When",
    "Do Not Use",
    "Needs",
    "Returns",
    "Done Conditions",
    "Persistence And Yield",
}
INTERACTION_MARKERS = {
    "Session Overlay Contract",
    "Interactive Loop Contract",
}


def read_skill(skill_path: Path) -> tuple[dict[str, Any] | None, str, list[str]]:
    """Parse a SKILL.md file and return frontmatter, body, and diagnostics."""
    skill_md = skill_path / "SKILL.md"
    if not skill_md.is_file():
        return None, "", ["SKILL.md not found"]

    content = skill_md.read_text(encoding="utf-8")
    match = re.match(r"^---\r?\n(.*?)\r?\n---(?:\r?\n|$)(.*)$", content, re.DOTALL)
    if not match:
        return None, "", ["invalid YAML frontmatter delimiters"]

    try:
        frontmatter = yaml.safe_load(match.group(1))
    except yaml.YAMLError as error:
        return None, match.group(2).strip(), [f"invalid YAML: {error}"]

    if not isinstance(frontmatter, dict):
        return None, match.group(2).strip(), ["frontmatter must be a YAML dictionary"]
    return frontmatter, match.group(2).strip(), []


def validate_portable_skill(skill_path: Path) -> list[str]:
    """Validate the host-neutral Agent Skills contract."""
    frontmatter, body, failures = read_skill(skill_path)
    if frontmatter is None:
        return failures

    unexpected = set(frontmatter) - PORTABLE_PROPERTIES
    if unexpected:
        failures.append(f"unexpected frontmatter keys: {', '.join(sorted(unexpected))}")

    name = frontmatter.get("name")
    description = frontmatter.get("description")
    if not isinstance(name, str) or not name.strip():
        failures.append("name must be a non-empty string")
    else:
        name = name.strip()
        if not re.fullmatch(r"[a-z0-9-]+", name):
            failures.append("name must use lowercase letters, digits, and hyphens only")
        if name.startswith("-") or name.endswith("-") or "--" in name:
            failures.append("name cannot start/end with a hyphen or contain consecutive hyphens")
        if len(name) > MAX_SKILL_NAME_LENGTH:
            failures.append(f"name exceeds {MAX_SKILL_NAME_LENGTH} characters")
        if skill_path.name != name:
            failures.append(f"folder name does not match declared name {name!r}")

    if not isinstance(description, str) or not description.strip():
        failures.append("description must be a non-empty string")
    elif len(description.strip()) > MAX_DESCRIPTION_LENGTH:
        failures.append(f"description exceeds {MAX_DESCRIPTION_LENGTH} characters")

    license_value = frontmatter.get("license")
    if license_value is not None and (not isinstance(license_value, str) or not license_value.strip()):
        failures.append("license must be a non-empty string when provided")

    compatibility = frontmatter.get("compatibility")
    if compatibility is not None:
        if not isinstance(compatibility, str) or not compatibility.strip():
            failures.append("compatibility must be a non-empty string when provided")
        elif len(compatibility.strip()) > MAX_COMPATIBILITY_LENGTH:
            failures.append(f"compatibility exceeds {MAX_COMPATIBILITY_LENGTH} characters")

    metadata = frontmatter.get("metadata")
    if metadata is not None:
        if not isinstance(metadata, dict):
            failures.append("metadata must be a mapping")
        elif any(not isinstance(key, str) or not isinstance(value, str) for key, value in metadata.items()):
            failures.append("metadata keys and values must be strings")

    allowed_tools = frontmatter.get("allowed-tools")
    if allowed_tools is not None and (not isinstance(allowed_tools, str) or not allowed_tools.strip()):
        failures.append("allowed-tools must be a non-empty string when provided")

    if not body:
        failures.append("SKILL.md body must be non-empty")
    return failures


def markdown_headings(body: str) -> set[str]:
    return {
        match.group(1).strip()
        for line in body.splitlines()
        if (match := re.fullmatch(r"##\s+(.+?)\s*", line))
    }


def validate_repository_contract(skill_path: Path) -> list[str]:
    """Validate Mecha Suit's host-neutral interaction contract."""
    _, body, failures = read_skill(skill_path)
    if failures:
        return failures

    headings = markdown_headings(body)
    for section in sorted(CORE_SECTIONS - headings):
        failures.append(f"missing core section {section!r}")
    declared_markers = INTERACTION_MARKERS & headings
    if len(declared_markers) > 1:
        failures.append("skill declares multiple interaction contracts")
    return failures


def load_yaml_mapping(path: Path) -> tuple[dict[str, Any] | None, list[str]]:
    try:
        value = yaml.safe_load(path.read_text(encoding="utf-8"))
    except yaml.YAMLError as error:
        return None, [f"invalid YAML: {error}"]
    if not isinstance(value, dict):
        return None, ["document must be a YAML dictionary"]
    return value, []


def validate_codex_skill(skill_path: Path) -> list[str]:
    """Validate the Codex-compatible frontmatter and optional openai.yaml adapter."""
    frontmatter, body, failures = read_skill(skill_path)
    if frontmatter is None:
        return failures

    unexpected = set(frontmatter) - CODEX_PROPERTIES
    if unexpected:
        failures.append(f"Codex-incompatible frontmatter keys: {', '.join(sorted(unexpected))}")

    description = frontmatter.get("description")
    if isinstance(description, str) and ("<" in description or ">" in description):
        failures.append("Codex descriptions cannot contain angle brackets")

    name = frontmatter.get("name")
    skill_name = name.strip() if isinstance(name, str) else skill_path.name
    headings = markdown_headings(body)
    explicit_interaction = bool(INTERACTION_MARKERS & headings)
    metadata_path = skill_path / "agents" / "openai.yaml"
    if not metadata_path.exists():
        if explicit_interaction:
            failures.append("explicit interaction skill is missing agents/openai.yaml")
        return failures

    document, metadata_failures = load_yaml_mapping(metadata_path)
    failures.extend(f"agents/openai.yaml: {failure}" for failure in metadata_failures)
    if document is None:
        return failures

    interface = document.get("interface")
    if not isinstance(interface, dict):
        failures.append("agents/openai.yaml: interface must be a mapping")
    else:
        display_name = interface.get("display_name")
        short_description = interface.get("short_description")
        default_prompt = interface.get("default_prompt")
        if not isinstance(display_name, str) or not display_name.strip():
            failures.append("agents/openai.yaml: display_name must be a non-empty string")
        if not isinstance(short_description, str) or not 25 <= len(short_description.strip()) <= 64:
            failures.append("agents/openai.yaml: short_description must contain 25-64 characters")
        if not isinstance(default_prompt, str) or f"${skill_name}" not in default_prompt:
            failures.append(f"agents/openai.yaml: default_prompt must mention ${skill_name}")

    policy = document.get("policy", {})
    if not isinstance(policy, dict):
        failures.append("agents/openai.yaml: policy must be a mapping")
    else:
        allow_implicit = policy.get("allow_implicit_invocation", True)
        if not isinstance(allow_implicit, bool):
            failures.append("agents/openai.yaml: allow_implicit_invocation must be a boolean")
        elif explicit_interaction and allow_implicit:
            failures.append("explicit interaction skill must disable implicit invocation")
    return failures


def validate_skill(skill_path: Path) -> tuple[bool, str]:
    """Backward-compatible aggregate validation entry point."""
    failures = (
        validate_portable_skill(skill_path)
        + validate_repository_contract(skill_path)
        + validate_codex_skill(skill_path)
    )
    return (not failures, "valid" if not failures else "; ".join(failures))


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    skill_files = sorted((root / "families").glob("*/*/SKILL.md"))
    layers = {
        "portable": validate_portable_skill,
        "interaction": validate_repository_contract,
        "codex": validate_codex_skill,
    }
    failures: list[str] = []

    for skill_file in skill_files:
        relative = skill_file.relative_to(root)
        for layer, validator in layers.items():
            failures.extend(
                f"[{layer}] {relative}: {message}"
                for message in validator(skill_file.parent)
            )

    if failures:
        for failure in failures:
            print(f"[fail] {failure}", file=sys.stderr)
        return 1

    metadata_count = sum(
        (skill_file.parent / "agents" / "openai.yaml").is_file()
        for skill_file in skill_files
    )
    print(f"[ok] Agent Skills portable core for {len(skill_files)} skills")
    print(f"[ok] host-neutral interaction contracts for {len(skill_files)} skills")
    print(f"[ok] Codex adapter metadata for {metadata_count} skills")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
