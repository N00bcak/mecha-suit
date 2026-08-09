# `templates/` Spec

## Purpose

`templates/` contains repeatable starting points for skills, repo-local
instructions and adapters.

## Architecture Tree

```text
templates/
    task-skill.template.md
    session-overlay.template.md
    interactive-loop.template.md
    work-index.template.md
    repo-AGENTS.template.md
    repo-CLAUDE.template.md
    repo-adapter-skill.template.md
```

## Main Responsibilities

- Preserve the task, session-overlay, and interactive-loop authoring contracts.
- Preserve the fallback two-mode work-index shape used across lifecycle-aware
  leaves.
- Provide repo-local instruction scaffolds for downstream projects.
- Provide adapter scaffolds that connect local context to global skills.

## Strengths

- Makes new skills easier to author consistently.
- Keeps repo-local facts separate from global reusable behavior.
- Prevents contract drift when adding specialist leaves.

## Architectural Invariants

- Each skill uses exactly one interaction-lifetime template. Task is the
  default; overlays and loops self-declare through standardized headings.
- Overlays and loops require explicit-invocation host metadata and remain
  session-local; templates do not create a routing registry.
- Skill templates produce fully authored callable contracts, not placeholders.
- If a skill contract shape changes, update the applicable template and all
  docs and tests that describe it.
- If lifecycle state changes, update `work-index.template.md`, the lifecycle
  rubric, participating leaves, and focused tests together.
- Templates should not include private paths or organization-specific facts.
- Adapter templates add local context; they do not fork global skill behavior.

## Common Workflows

- Start bounded outcomes from `task-skill.template.md`.
- Start composable session behavior from `session-overlay.template.md`.
- Start multi-turn conversational control from
  `interactive-loop.template.md`.
- Copy repo templates into downstream repos and fill in local commands.
- Use adapter templates when a project needs local context around a global skill.

## Future Work

- Add examples to templates only when they reduce repeated authoring mistakes.
- Keep template complexity lower than authored skills.
