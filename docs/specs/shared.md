# `shared/` Spec

## Purpose

`shared/` holds cross-skill examples and rubrics that multiple skills or docs
can reference without duplicating language.

## Architecture Tree

```text
shared/
    examples/
        routing-examples.md
    rubrics/
        persistence-yield-rubric.md
        skill-boundary-rubric.md
```

## Main Responsibilities

- Provide common examples for routing and skill invocation.
- Define shared rubrics for persistence, yielding, and skill boundaries.
- Keep repeated policy language consistent across skills.

## Strengths

- Reduces duplication in primary skill files.
- Gives maintainers stable language for recurring concepts.
- Helps tests and docs point to one shared interpretation.

## Architectural Invariants

- Shared files are passive support material.
- Do not hide active runtime steps here when they belong in `SKILL.md`.
- Keep rubrics concise and reusable.
- Update shared examples when visible routing behavior changes.

## Common Workflows

- Add routing examples after adding or changing a visible skill boundary.
- Update rubrics when a repeated policy concept needs shared wording.
- Reference shared material from skills only when it saves meaningful context.

## Future Work

- Add more examples only when they catch real routing ambiguity.
- Avoid turning `shared/` into a registry or taxonomy layer.
