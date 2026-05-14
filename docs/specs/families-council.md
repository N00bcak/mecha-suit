# `families/council/` Spec

## Purpose

`families/council/` contains the controlled cross-domain synthesis layer. It is
reserved for tasks where one specialist perspective is insufficient and
competing interpretations need reconciliation.

## Architecture Tree

```text
families/council/
    interdisciplinary-council/
        SKILL.md
        references/
            council-escalation-checklist.md
            subagent-use-checklist.md
```

## Main Responsibilities

- Decide whether council mode is justified.
- Select the fewest relevant fully authored specialist perspectives.
- Frame narrow specialist questions.
- Synthesize agreements, conflicts, risks, and a recommendation.

## Strengths

- Subagent permission is centralized in exactly one skill.
- Council outputs require explicit verification status and uncertainty.
- The workflow discounts specialist output that exceeds its inherited boundary.

## Architectural Invariants

- This is the only family allowed to use subagents.
- Council is not a fallback for ambiguity; use `task-clarifier` first.
- Council subagents must inherit from fully authored non-council leaves.
- Stub leaves, router, and clarifier cannot be inherited as council subagents.
- The council layer synthesizes; subagents do not synthesize each other.

## Common Workflows

- Update the eligible inherited leaf list when a new fully authored specialist
  should be council-eligible.
- Use the escalation checklist before broadening a task into council work.
- Keep second-pass specialist questions narrow and evidence-producing.

## Future Work

- Add council examples only when they clarify genuine cross-domain conflicts.
- Revisit subagent policy only as an explicit architecture change.
