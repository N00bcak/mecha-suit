# `templates/` Spec

## Purpose

`templates/` contains repeatable starting points for skills, repo-local
instructions, adapters, and council subagent outputs.

## Architecture Tree

```text
templates/
    leaf-skill.template.md
    council-subagent.template.md
    repo-AGENTS.template.md
    repo-CLAUDE.template.md
    repo-adapter-skill.template.md
```

## Main Responsibilities

- Preserve the expected shape of new specialist leaves.
- Provide repo-local instruction scaffolds for downstream projects.
- Provide adapter scaffolds that connect local context to global skills.
- Keep council subagent output shape consistent.

## Strengths

- Makes new skills easier to author consistently.
- Keeps repo-local facts separate from global reusable behavior.
- Prevents contract drift when adding specialist leaves.

## Architectural Invariants

- If specialist leaf contract shape changes, update the template and all docs
  that describe the contract.
- Templates should not include private paths or organization-specific facts.
- Adapter templates add local context; they do not fork global skill behavior.
- Council subagent templates must preserve narrow inherited-leaf outputs.

## Common Workflows

- Start new specialist leaves from `leaf-skill.template.md`.
- Copy repo templates into downstream repos and fill in local commands.
- Use adapter templates when a project needs local context around a global skill.

## Future Work

- Add examples to templates only when they reduce repeated authoring mistakes.
- Keep template complexity lower than authored skills.
