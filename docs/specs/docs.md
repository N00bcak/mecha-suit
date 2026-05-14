# `docs/` Spec

## Purpose

`docs/` holds human-facing maintenance and platform documentation. It explains
how to evolve the toolbox, adapt it to hosts, and understand architecture that
is broader than one runtime skill.

## Architecture Tree

```text
docs/
    global-AGENTS.example.md
    global-CLAUDE.example.md
    maintenance-playbook.md
    platform-notes.md
    specs/
        README.md
        *.md
```

## Main Responsibilities

- Document maintenance workflows and architectural policy.
- Provide host-specific starting points that users can copy into global config.
- Track platform notes without embedding host quirks into every skill.
- Hold subsystem specs for future maintainers.

## Strengths

- Keeps maintenance guidance out of runtime `SKILL.md` files.
- Makes Codex and Claude adaptation explicit without forcing one host model.
- Provides a place for policy and architecture that should not inflate prompts.

## Architectural Invariants

- Do not move active runtime behavior from `SKILL.md` into `docs/`.
- Keep docs portable; avoid private infrastructure and local-only assumptions.
- Keep examples clearly labeled as examples, not required repo state.
- Update docs when a public workflow, skill contract, or installation contract
  changes.

## Common Workflows

- Add maintenance guidance to `maintenance-playbook.md`.
- Add host-specific notes to `platform-notes.md`.
- Add subsystem architecture notes under `docs/specs/`.
- Update global examples only when the recommended global setup changes.

## Future Work

- Add a short release checklist if this repository starts shipping tagged
  releases.
- Add an architecture-decision log only if repeated architectural decisions need
  traceability beyond the specs.
