# `families/routing/` Spec

## Purpose

`families/routing/` contains the cheap selection layer. It decides which skill
should own a task or repairs ambiguity before specialist work begins.

## Architecture Tree

```text
families/routing/
    task-router/
        SKILL.md
        references/routing-checklist.md
    task-clarifier/
        SKILL.md
        references/ambiguity-checklist.md
```

## Main Responsibilities

- Classify tasks by shape and minimum required inputs.
- Select a next skill when fit is clear.
- Route unclear or missing-input tasks to `task-clarifier`.
- Route product concept development and critique to `product-co-design`.
- Never select the explicit-invocation-only `interview-me` skill.
- Keep handoffs compact and context-efficient.

## Strengths

- The router is intentionally narrow and cheap.
- The clarifier separates ambiguity repair from specialist execution.
- Stub ML leaves are guarded by routing to clarification instead of execution.

## Architectural Invariants

- Router does not solve domain tasks.
- Router does not gather broad context.
- Router does not use subagents.
- Router does not inspect specialist internals unless names/descriptions are
  insufficient.
- Clarifier asks for missing information or reframes the task; it does not
  become a hidden generalist solver.

## Common Workflows

- Edit `task-router/SKILL.md` when a top-level routing choice changes.
- Edit `task-clarifier/SKILL.md` when ambiguity-handling output changes.
- Add examples to `shared/examples/routing-examples.md` when routing behavior is
  visible to users.
- Use references only for edge cases that would bloat primary skill text.

## Future Work

- Add focused routing examples as new families become callable.
- Consider lightweight routing regression checks only if routing drift becomes a
  repeated maintenance problem.
