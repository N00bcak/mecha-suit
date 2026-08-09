# `families/collaboration/` Spec

## Purpose

`families/collaboration/` contains conversation-first leaves for eliciting
intent, developing product and domain evidence, preserving shared language,
mapping decisions, communicating clearly, and transferring verified context.

## Architecture Tree

```text
families/collaboration/
    interview-me/
    low-friction-collaboration/
    product-co-design/
    product-research/
    domain-modeling/
    decision-mapping/
    portable-handoff/
    parallel-subagents/
    second-opinion/
```

## Main Responsibilities

- Conduct an explicitly requested one-question-at-a-time interview.
- Make complex exchanges easy to follow without reducing reasoning depth.
- Shape product concepts and develop evidence about users, workflows, domains,
  alternatives, and assumptions.
- Sharpen domain language and preserve authorized durable decisions.
- Map long-horizon decision dependencies before implementation planning.
- Package verified state for another session, machine, agent, or collaborator.
- Provide bounded parallel delegation and independent second opinions.

## Architectural Invariants

- `interview-me` and `product-co-design` are explicit-invocation-only
  interactive loops and cannot govern simultaneously.
- `low-friction-collaboration` is an explicit-invocation-only session overlay
  that may compose with the active task or loop.
- Other collaboration leaves rely on native frontmatter selection.
- Only `parallel-subagents` and `second-opinion` authorize subagent use.
- Product research develops evidence; product co-design owns product judgment.
- Decision mapping produces decisions, not implementation deliverables.
- Portable handoff crosses context boundaries; each phase owns routine
  transition updates.
- Collaboration leaves participate in a matching work record without
  creating a router or silently changing accepted intent.

## Common Workflows

- Use `product-research` to investigate product or domain evidence, then
  explicitly invoke `product-co-design` to make the product judgment.
- Use `domain-modeling` when terminology, invariants, or durable decisions need
  active clarification.
- Use `decision-mapping` when the path to a specification exceeds one credible
  planning session.
- Use `portable-handoff` when verified work state must cross a context boundary.
- Add another collaboration leaf only after a distinct repeated workflow shows
  that no existing leaf owns it cleanly.
