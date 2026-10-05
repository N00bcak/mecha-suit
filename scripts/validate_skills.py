#!/usr/bin/env python3
"""Validate portable skill contracts and Codex- and Claude-specific adapters."""

from __future__ import annotations

import argparse
import glob
import re
import sys
from pathlib import Path
from typing import Any

import yaml

MAX_SKILL_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
MAX_COMPATIBILITY_LENGTH = 500
MAX_SKILL_PROMPT_BYTES = 8_000
SKILL_PROMPT_WARNING_BYTES = 7_000
CATALOG_WARNING_CHARACTERS = 6_400
PORTABLE_PROPERTIES = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}
CODEX_PROPERTIES = PORTABLE_PROPERTIES - {"compatibility"}
# Claude adapters are rendered at install time; source skills never carry them.
CLAUDE_PROPERTIES = PORTABLE_PROPERTIES | {"disable-model-invocation"}
EXPLICIT_INVOCATION = "explicit"
CORE_SECTIONS = {
    "Purpose",
    "Do Not Use",
    "Needs",
    "Returns",
    "Done Conditions",
    "Progress",
}
INTERACTION_MARKERS = {
    "Session Overlay Contract",
    "Interactive Loop Contract",
}
RUNTIME_REFERENCE_RE = re.compile(r"`((?:\.{1,2}/|references/)[^`]+\.md)`")


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


def explicit_invocation(frontmatter: dict[str, Any]) -> bool:
    """Return whether the portable metadata declares explicit-only invocation."""
    metadata = frontmatter.get("metadata")
    return isinstance(metadata, dict) and metadata.get("invocation") == EXPLICIT_INVOCATION


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
        elif metadata.get("invocation", EXPLICIT_INVOCATION) != EXPLICIT_INVOCATION:
            failures.append(f"metadata.invocation must be {EXPLICIT_INVOCATION!r} when provided")

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
    frontmatter, body, failures = read_skill(skill_path)
    if failures or frontmatter is None:
        return failures

    headings = markdown_headings(body)
    for section in sorted(CORE_SECTIONS - headings):
        failures.append(f"missing core section {section!r}")
    declared_markers = INTERACTION_MARKERS & headings
    if len(declared_markers) > 1:
        failures.append("skill declares multiple interaction contracts")
    if declared_markers and not explicit_invocation(frontmatter):
        failures.append("interaction skill must declare metadata.invocation: explicit")
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

    prompt_bytes = len((skill_path / "SKILL.md").read_bytes())
    if prompt_bytes > MAX_SKILL_PROMPT_BYTES:
        failures.append(
            f"SKILL.md is {prompt_bytes} UTF-8 bytes; Codex loads at most "
            f"{MAX_SKILL_PROMPT_BYTES} bytes"
        )

    unexpected = set(frontmatter) - CODEX_PROPERTIES
    if unexpected:
        failures.append(f"Codex-incompatible frontmatter keys: {', '.join(sorted(unexpected))}")

    description = frontmatter.get("description")
    if isinstance(description, str) and ("<" in description or ">" in description):
        failures.append("Codex descriptions cannot contain angle brackets")

    name = frontmatter.get("name")
    skill_name = name.strip() if isinstance(name, str) else skill_path.name
    headings = markdown_headings(body)
    explicit = explicit_invocation(frontmatter) or bool(INTERACTION_MARKERS & headings)
    metadata_path = skill_path / "agents" / "openai.yaml"
    if not metadata_path.exists():
        if explicit:
            failures.append("explicit skill is missing agents/openai.yaml")
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
        elif explicit and allow_implicit:
            failures.append("explicit skill must disable implicit invocation")
        elif not explicit and not allow_implicit:
            failures.append("implicit invocation is disabled without metadata.invocation: explicit")
    return failures


def validate_claude_skill(skill_path: Path) -> list[str]:
    """Validate a rendered or linked skill in an installed Claude skill root."""
    frontmatter, _, failures = read_skill(skill_path)
    if frontmatter is None:
        return failures

    unexpected = set(frontmatter) - CLAUDE_PROPERTIES
    if unexpected:
        failures.append(f"Claude-incompatible frontmatter keys: {', '.join(sorted(unexpected))}")
    if frontmatter.get("name") != skill_path.name:
        failures.append(f"folder name does not match declared name {frontmatter.get('name')!r}")

    disabled = frontmatter.get("disable-model-invocation", False)
    if not isinstance(disabled, bool):
        failures.append("disable-model-invocation must be a boolean")
    elif explicit_invocation(frontmatter) != disabled:
        failures.append("disable-model-invocation must match metadata.invocation: explicit")
    return failures + validate_runtime_references(skill_path)


def runtime_references(skill_path: Path) -> list[str]:
    """Return repo-owned Markdown resource paths named by a skill contract."""
    skill_md = skill_path / "SKILL.md"
    if not skill_md.is_file():
        return []
    return sorted(set(RUNTIME_REFERENCE_RE.findall(skill_md.read_text(encoding="utf-8"))))


def validate_runtime_references(skill_path: Path) -> list[str]:
    """Validate paths without pre-resolving an installed skill-directory symlink."""
    failures: list[str] = []
    for raw_target in runtime_references(skill_path):
        candidate = skill_path / raw_target
        matches = [Path(path) for path in glob.glob(str(candidate))]
        if not matches:
            failures.append(f"runtime reference {raw_target!r} does not resolve")
            continue
        non_files = [path for path in matches if not path.is_file()]
        if non_files:
            failures.append(f"runtime reference {raw_target!r} does not resolve to files")
    return failures


def skill_prompt_warning(skill_path: Path) -> str | None:
    prompt_bytes = len((skill_path / "SKILL.md").read_bytes())
    if prompt_bytes >= SKILL_PROMPT_WARNING_BYTES:
        return (
            f"SKILL.md is {prompt_bytes} UTF-8 bytes; "
            f"Codex truncates above {MAX_SKILL_PROMPT_BYTES} bytes"
        )
    return None


def catalog_estimate(skill_files: list[Path], root: Path) -> int:
    """Estimate this repository's model-visible catalog contribution."""
    rendered: list[str] = []
    for skill_file in skill_files:
        frontmatter, _, failures = read_skill(skill_file.parent)
        if failures or frontmatter is None:
            continue
        name = frontmatter.get("name")
        description = frontmatter.get("description")
        if isinstance(name, str) and isinstance(description, str):
            rendered.append(
                f"- {name}: {description.strip()} "
                f"(file: {skill_file.relative_to(root)})\n"
            )
    return len("".join(rendered))


def catalog_warning(estimate: int) -> str | None:
    if estimate >= CATALOG_WARNING_CHARACTERS:
        return (
            f"estimated Codex catalog contribution is {estimate} characters; "
            "review descriptions before it exceeds the host budget"
        )
    return None


def validate_installed_root(installed_root: Path, source_skill_files: list[Path]) -> list[str]:
    failures: list[str] = []
    if not installed_root.is_dir():
        return [f"{installed_root}: installed root is not a directory"]

    for source_skill_file in source_skill_files:
        name = source_skill_file.parent.name
        installed_skill = installed_root / name
        if not (installed_skill / "SKILL.md").is_file():
            failures.append(f"{name}: installed SKILL.md is missing or unreadable")
            continue
        failures.extend(
            f"{name}: {message}"
            for message in validate_runtime_references(installed_skill)
        )
    return failures


def validate_claude_installed_root(installed_root: Path, source_skill_files: list[Path]) -> list[str]:
    if not installed_root.is_dir():
        return [f"{installed_root}: installed root is not a directory"]

    installed = sorted(path.parent for path in installed_root.glob("*/SKILL.md"))
    failures = [
        f"{skill.name}: {message}"
        for skill in installed
        for message in validate_claude_skill(skill)
    ]
    if len(installed) < len(source_skill_files):
        failures.append(
            f"{installed_root}: {len(installed)} skills installed, "
            f"expected {len(source_skill_files)}"
        )
    return failures


def validate_skill(skill_path: Path) -> tuple[bool, str]:
    """Backward-compatible aggregate validation entry point."""
    failures = (
        validate_portable_skill(skill_path)
        + validate_repository_contract(skill_path)
        + validate_codex_skill(skill_path)
        + validate_runtime_references(skill_path)
    )
    return (not failures, "valid" if not failures else "; ".join(failures))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--installed-root",
        type=Path,
        help="also validate runtime references through an installed skill root",
    )
    parser.add_argument(
        "--claude-installed-root",
        type=Path,
        help="also validate rendered Claude adapters under an installed Claude skill root",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(__file__).resolve().parents[1]
    skill_files = sorted((root / "families").glob("*/*/SKILL.md"))
    layers = {
        "portable": validate_portable_skill,
        "interaction": validate_repository_contract,
        "codex": validate_codex_skill,
        "resources": validate_runtime_references,
    }
    failures: list[str] = []

    for skill_file in skill_files:
        relative = skill_file.relative_to(root)
        for layer, validator in layers.items():
            failures.extend(
                f"[{layer}] {relative}: {message}"
                for message in validator(skill_file.parent)
            )

    if args.installed_root is not None:
        failures.extend(
            f"[installed-resources] {message}"
            for message in validate_installed_root(args.installed_root, skill_files)
        )
    if args.claude_installed_root is not None:
        failures.extend(
            f"[claude-installed] {message}"
            for message in validate_claude_installed_root(args.claude_installed_root, skill_files)
        )

    if failures:
        for failure in failures:
            print(f"[fail] {failure}", file=sys.stderr)
        return 1

    for skill_file in skill_files:
        warning = skill_prompt_warning(skill_file.parent)
        if warning:
            print(f"[warn] {skill_file.relative_to(root)}: {warning}", file=sys.stderr)

    estimate = catalog_estimate(skill_files, root)
    print(f"[info] estimated Codex catalog contribution: {estimate} characters")
    warning = catalog_warning(estimate)
    if warning:
        print(f"[warn] {warning}", file=sys.stderr)

    metadata_count = sum(
        (skill_file.parent / "agents" / "openai.yaml").is_file()
        for skill_file in skill_files
    )
    print(f"[ok] Agent Skills portable core for {len(skill_files)} skills")
    print(f"[ok] host-neutral interaction contracts for {len(skill_files)} skills")
    print(f"[ok] Codex adapter metadata for {metadata_count} skills")
    if args.installed_root is not None:
        print(f"[ok] installed runtime references under {args.installed_root}")
    if args.claude_installed_root is not None:
        print(f"[ok] Claude adapters under {args.claude_installed_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
