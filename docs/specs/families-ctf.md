# `families/ctf/` Spec

## Purpose

`families/ctf/` contains fully authored specialist leaves for common CTF
challenge categories.

## Architecture Tree

```text
families/ctf/
    ctf-triage/
    reverse-ctf/
    pwn-ctf/
    crypto-ctf/
    web-ctf/
    forensics-ctf/
    ai-ctf/
    misc-ctf/
```

Each leaf follows the normal skill shape:

```text
<ctf-skill>/
    SKILL.md
    references/
    scripts/
    agents/
```

## Main Responsibilities

- Triage unknown challenges into the right specialist category.
- Provide category-specific solve workflows and pivot rules.
- Maintain references for repeated techniques without overloading the main
  skill document.
- Keep CTF work artifact-native and evidence-first.

## Strengths

- Coverage spans reverse, pwn, crypto, web, forensics, AI security, and misc.
- `ctf-triage` prevents premature commitment to the wrong specialist.
- Pivot rules let one specialist hand off when recovered evidence changes the
  task type.

## Architectural Invariants

- CTF leaves do not use subagents.
- Unknown category starts at `ctf-triage`.
- Category leaves should not absorb unrelated CTF domains.
- References support execution but do not replace the `SKILL.md` workflow.
- Tool-specific scripts must be deterministic and portable.

## Common Workflows

- Add or refine category references when a repeated technique is missing.
- Update `ctf-triage` only when category boundaries or first-pass triage change.
- Keep new CTF leaves narrow; prefer improving existing leaves unless a distinct
  domain boundary exists.

## Future Work

- Add optional tool-specific references only where they prevent repeated agent
  failure.
- Avoid importing full CTF workstation provisioning into global skills.
