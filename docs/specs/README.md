# Repository Specs

## Purpose

This directory documents the maintained architecture of Mecha Suit by subsystem.
It is for future editors who need to understand what each folder owns, what it
must preserve, and where future work should fit.

Runtime behavior still belongs in each skill's `SKILL.md`. Repo-wide
development rules still belong in `AGENTS.md`.

## Architecture Tree

```text
mecha-suit/
    docs/          human-facing maintenance and platform documentation
    evals/         host-neutral behavioral evaluation cases
    families/      skill families and specialist leaves
    scripts/       deterministic validators and opt-in evaluation adapters
    shared/        cross-skill examples and rubrics
    templates/     repeatable authoring templates
    tests/         deterministic validator and corpus tests
```

Generated, vendor, ignored work-state, and cache folders are intentionally
excluded from this spec set, including `.git/`, `.mecha/`, and local
development environments.

## Navigation

| Spec | Covers |
| --- | --- |
| `docs.md` | `docs/` maintenance and platform documentation |
| `families.md` | global skill-family architecture |
| `families-collaboration.md` | interviewing, communication, product research and design, domain decisions, handoff, and bounded delegation |
| `families-engineering.md` | engineering specialist leaves |
| `families-ai.md` | AI pipeline manual and execution leaves |
| `families-writing.md` | long-form prose and site-specific blog writing leaves |
| `shared.md` | shared examples and rubrics |
| `templates.md` | templates for repo and skill authoring |

## Architectural Invariants

- Specs describe architecture; they do not override `AGENTS.md`.
- Specs summarize skills; they do not duplicate full skill playbooks.
- Runtime behavior belongs in `SKILL.md`.
- Passive aids belong in `references/`.
- Deterministic helpers belong in `scripts/`.
- Evaluation cases remain host-neutral; invocation syntax belongs in adapters.
- Live model evaluation stays outside the deterministic test suite.
- Generated and dependency directories should not gain hand-authored specs.

## Common Workflow

1. Read the subsystem spec before making a structural change.
2. Read the relevant `SKILL.md` or source files for execution details.
3. Update the spec only when ownership, invariants, or future work changes.
4. Run `./test.sh` after changing repo architecture, skills, templates, or
   install behavior.

## Future Work

- Add a lightweight link checker if specs start referencing many files.
- Add a spec review step to `docs/maintenance-playbook.md` if specs become part
  of the normal release/change checklist.
