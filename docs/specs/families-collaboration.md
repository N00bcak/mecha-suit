# `families/collaboration/` Spec

## Purpose

`families/collaboration/` contains conversation-first specialist leaves for
eliciting user-owned context, reducing communication effort, and co-designing
product concepts.

## Architecture Tree

```text
families/collaboration/
    interview-me/
    low-friction-collaboration/
    product-co-design/
```

## Main Responsibilities

- Conduct an explicitly requested, one-question-at-a-time interview.
- Make complex technical exchanges easy to follow, resume, and act on without
  reducing their reasoning depth.
- Shape and scrutinize product concepts through collaborative conversation.
- Preserve facts, assumptions, preferences, tensions, and decisions in compact
  working syntheses.
- Produce a structured interview synthesis or product brief at a useful
  stopping point.

## Architectural Invariants

- `interview-me` is explicit-invocation-only and is never selected implicitly.
- `interview-me` enforces explicit invocation with
  `agents/openai.yaml` and `allow_implicit_invocation: false`.
- `product-co-design` is routable and council-eligible.
- `low-friction-collaboration` is routable, may shape another leaf's response,
  and is not council-eligible.
- All three leaves remain non-subagentic.
- Collaboration skills are conversation-first but do not omit structured
  synthesis when it improves continuity or handoff.
- Implementation, dedicated research, and visual execution remain with their
  respective specialists.

## Common Workflows

- Invoke `interview-me` by name with a topic and desired outcome.
- Use `low-friction-collaboration` for direct, low-load communication in dense
  or multi-step technical exchanges.
- Use `product-co-design` for product framing, concept alternatives,
  constructive critique, validation planning, and specialist handoff.
- Add a new collaboration leaf only after a distinct repeated workflow has
  demonstrated that neither existing leaf owns it cleanly.
