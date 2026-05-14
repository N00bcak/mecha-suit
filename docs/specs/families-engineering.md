# `families/engineering/` Spec

## Purpose

`families/engineering/` contains general software engineering specialist leaves:
one for existing codebase changes and one for small greenfield prototypes.

## Architecture Tree

```text
families/engineering/
    large-codebase-change/
        SKILL.md
        references/
            code-correctness.md
            testing-strategy.md
            session-continuity.md
            ...
    prototype-builder/
        SKILL.md
        references/
            prototype-quality.md
            session-continuity.md
            stack-selection.md
```

## Main Responsibilities

- Guide scoped changes in existing repositories.
- Guide small prototype and demo builds.
- Preserve verification discipline and session continuity.
- Keep implementation complexity appropriate to the task.

## Strengths

- Separates integration-heavy codebase work from greenfield prototype work.
- Encodes persistence/yield behavior for long-running engineering tasks.
- Holds language and testing references without forcing them into every run.

## Architectural Invariants

- Engineering leaves do not use subagents.
- `large-codebase-change` owns existing codebases, shared contracts, migrations,
  refactors, and test-verified integration work.
- `prototype-builder` owns small greenfield tools or demos.
- Repo-specific facts belong in local `AGENTS.md` or adapter skills, not global
  engineering leaves.

## Common Workflows

- Use `large-codebase-change` for non-trivial edits in this repository.
- Use `prototype-builder` for small new tools under roughly 1kLoC.
- Add references only when they improve repeated execution across many repos.
- Use scratchpads only when durable handoff state is useful.

## Future Work

- Add additional language references only when repeated tasks justify them.
- Keep engineering leaves from turning into a broad project-management layer.
