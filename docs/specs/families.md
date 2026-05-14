# `families/` Spec

## Purpose

`families/` is the core skill library. It groups runtime skills by architectural
role: routing, council synthesis, engineering work, CTF work, and ML stubs.

## Architecture Tree

```text
families/
    routing/
        task-router/
        task-clarifier/
    council/
        interdisciplinary-council/
    engineering/
        large-codebase-change/
        prototype-builder/
    ctf/
        ctf-triage/
        reverse-ctf/
        pwn-ctf/
        crypto-ctf/
        web-ctf/
        forensics-ctf/
        ai-ctf/
        misc-ctf/
    ml/
        dataset-triage/
        classical-ml-baseline/
        deep-learning-experiment/
```

Each skill folder may contain:

```text
<skill>/
    SKILL.md       active runtime behavior
    references/    passive supporting material
    scripts/       deterministic helpers, when justified
    agents/        host metadata, only when materially useful
```

## Main Responsibilities

- Provide reusable runtime instructions for broad classes of work.
- Keep skill boundaries explicit enough for cheap routing.
- Separate active execution behavior from passive references.
- Keep specialist leaves narrow and composable.

## Strengths

- Family boundaries make routing and maintenance cheap.
- `SKILL.md` frontmatter gives hosts compact trigger metadata.
- Stub leaves can define future contracts without pretending to be callable.
- Council-only subagent authority prevents hidden delegation sprawl.

## Architectural Invariants

- Top layer is `routing/`, not orchestration.
- Only `interdisciplinary-council` may use subagents.
- Specialist leaves do one job well.
- Runtime behavior belongs in `SKILL.md`.
- Passive background belongs in `references/`.
- Scripts must improve determinism or reduce repeated procedural work.
- Stub leaves must keep the exact warning: `This is a stub. NEVER CALL THIS SKILL.`

## Common Workflows

- Add a new specialist from `templates/leaf-skill.template.md`.
- Update `README.md` and `shared/examples/routing-examples.md` when the visible
  skill set changes.
- Update `task-router` only when top-level routing behavior changes.
- Run `./test.sh` after skill changes.

## Future Work

- Fully author ML leaves only when their repeated workflow is clear.
- Add scripts only for repeated, deterministic tasks.
- Keep CTF references concise enough that skills remain loadable.
