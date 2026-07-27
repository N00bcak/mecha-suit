# `families/` Spec

## Purpose

`families/` is the core skill library. It groups runtime skills by architectural
role: council synthesis, collaboration, engineering work, CTF work, and AI
work.

## Architecture Tree

```text
families/
    council/
        interdisciplinary-council/
    collaboration/
        interview-me/
        product-co-design/
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
    ai/
        ai-pipeline/
        ai-data-preparation/
        ai-insight-development/
        ai-representation-workbench/
        ai-problem-modeling/
        ai-performance/
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
- Preserve explicit-only invocation for specialist modes that should never be inferred.

## Strengths

- Family boundaries make routing and maintenance cheap.
- `SKILL.md` frontmatter gives hosts compact trigger metadata.
- Stub leaves can define future contracts without pretending to be callable.
- Council-only subagent authority prevents hidden delegation sprawl.

## Architectural Invariants

- Native host behavior owns skill selection and ordinary clarification.
- Only `interdisciplinary-council` may use subagents.
- `interview-me` and `ai-pipeline` are explicit-invocation-only.
- Specialist leaves do one job well.
- Runtime behavior belongs in `SKILL.md`.
- Passive background belongs in `references/`.
- Scripts must improve determinism or reduce repeated procedural work.
- Stub leaves must keep the exact warning: `This is a stub. NEVER CALL THIS SKILL.`

## Common Workflows

- Add a new specialist from `templates/leaf-skill.template.md`.
- Update `README.md` and `shared/examples/skill-selection-examples.md` when the visible
  skill set changes.
- Keep native selection cues in leaf frontmatter descriptions.
- Run `./test.sh` after skill changes.

## Future Work

- Keep the adaptive multi-iteration AI controller outside this skill library
  unless it becomes a separately designed product.
- Add scripts only for repeated, deterministic tasks.
- Keep specialist references concise enough that skills remain loadable.
