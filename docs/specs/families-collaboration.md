# `families/collaboration/` Spec

## Purpose

`families/collaboration/` contains conversation-first specialist leaves for
eliciting user-owned context and co-designing product concepts.

## Architecture Tree

```text
families/collaboration/
    interview-me/
    product-co-design/
```

## Main Responsibilities

- Conduct an explicitly requested, one-question-at-a-time interview.
- Shape and scrutinize product concepts through collaborative conversation.
- Preserve facts, assumptions, preferences, tensions, and decisions in compact
  working syntheses.
- Produce a structured interview synthesis or product brief at a useful
  stopping point.

## Architectural Invariants

- `interview-me` is explicit-invocation-only and is never selected by the router.
- `product-co-design` is routable and council-eligible.
- Both leaves remain non-subagentic.
- Collaboration skills are conversation-first but do not omit structured
  synthesis when it improves continuity or handoff.
- Implementation, dedicated research, and visual execution remain with their
  respective specialists.

## Common Workflows

- Invoke `interview-me` by name with a topic and desired outcome.
- Use `product-co-design` for product framing, concept alternatives,
  constructive critique, validation planning, and specialist handoff.
- Add a new collaboration leaf only after a distinct repeated workflow has
  demonstrated that neither existing leaf owns it cleanly.
