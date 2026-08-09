# `shared/` Spec

## Purpose

`shared/` holds cross-skill examples and rubrics that multiple skills or docs
can reference without duplicating language.

## Architecture Tree

```text
shared/
    examples/
        skill-selection-examples.md
    rubrics/
        change-discipline.md
        lifecycle-contract.md
        persistence-yield-rubric.md
        research-integrity.md
        skill-boundary-rubric.md
```

## Main Responsibilities

- Provide common examples for native skill selection and invocation.
- Define shared rubrics for lifecycle state, research integrity, change
  discipline, persistence, yielding, and skill boundaries.
- Keep repeated policy language consistent across skills.

## Strengths

- Reduces duplication in primary skill files.
- Gives maintainers stable language for recurring concepts.
- Helps tests and docs point to one shared interpretation.

## Architectural Invariants

- Shared files are passive support material.
- Do not hide active runtime steps here when they belong in `SKILL.md`.
- `lifecycle-contract.md` defines common state and authority; each participating
  leaf still owns and states its active transition behavior.
- Keep rubrics concise and reusable.
- Update shared examples when visible selection behavior changes.

## Common Workflows

- Add selection examples after adding or changing a visible skill boundary.
- Update rubrics when a repeated policy concept needs shared wording.
- Reference shared material from skills only when it saves meaningful context.

## Future Work

- Add more examples only when they catch a real selection ambiguity.
- Avoid turning `shared/` into a registry or taxonomy layer.
