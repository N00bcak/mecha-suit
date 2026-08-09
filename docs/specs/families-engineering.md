# `families/engineering/` Spec

## Purpose

`families/engineering/` contains narrow leaves for technical research,
specification, slicing, implementation, prototyping, diagnosis, and review.

## Architecture Tree

```text
families/engineering/
    technical-research/
    implementation-spec/
    work-slicing/
    large-codebase-change/
    prototype-builder/
    diagnosing-bugs/
    code-review/
    references/
        session-continuity.md
        behavior-first-development.md
        design-decision-discipline.md
        <language primers>
```

## Main Responsibilities

- Resolve software and architecture questions through primary evidence.
- Preserve accepted intent separately from engineering decomposition.
- Create verifiable vertical slices and genuine dependency edges.
- Implement PR-ready changes in clearly large repositories.
- Build isolated greenfield prototypes around one demonstrable outcome.
- Diagnose difficult bugs through reproducible, falsifiable evidence.
- Review changes independently for intent, correctness, and maintainability.

## Architectural Invariants

- Engineering leaves do not authorize subagents.
- `implementation-spec` owns accepted intent; `work-slicing` may not change it.
- Behavior-first development is conditional shared guidance, not a separate
  routing destination.
- `code-review` is read-only unless the user separately requests fixes.
- Lifecycle code work closes through three-axis review or explicit user waiver.
- `large-codebase-change` retains its roughly 5k maintained-line routing cue;
  smaller existing repositories remain native Codex work.
- `prototype-builder` retains greenfield posture as its routing cue.
- Ad-hoc behavior remains available without lifecycle artifacts.

## Common Workflows

- Use `technical-research` before planning when an external technical fact or
  feasibility decision is unresolved.
- Use `implementation-spec` for settled intent, then `work-slicing` when the
  accepted change needs more than one implementation unit.
- Use `diagnosing-bugs` for hard bugs and regressions; use native diagnosis for
  an obvious routine failure.
- Use `code-review` for a bounded diff or lifecycle completion gate.
- Load behavior-first or design-decision references only when their conditions
  apply.
