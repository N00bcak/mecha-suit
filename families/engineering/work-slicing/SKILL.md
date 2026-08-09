---
name: work-slicing
description: Decompose an accepted implementation contract into verifiable vertical slices with explicit dependency edges.
---

# Work Slicing

## Purpose

Turn accepted intent into executable engineering slices while preserving every
acceptance criterion, constraint, and non-goal.

## Use When

- Accepted work exceeds one simple implementation unit.
- A specification or plan needs dependency-aware vertical decomposition.
- Multi-session work needs independently verifiable progress units.

## Do Not Use

- Do not invent, reinterpret, or accept product intent.
- Do not split by technical layer when an end-to-end slice can remain green.
- Do not publish tickets, assign owners, or implement the slices.
- Do not spawn, request, or rely on subagents.

## Needs

- An accepted implementation contract or user-approved equivalent.
- Relevant repository architecture, tests, delivery constraints, and baseline.
- Required slice size or session boundary when specified.

## Returns

- Ordered vertical slices with acceptance mapping and dependency edges.
- Per-slice observable outcome, verification, risks, and completion condition.
- Explicit expand-migrate-contract sequencing for unavoidable wide changes.
- Updated lifecycle artifact pointers and next executable slice.

## Done Conditions

- Every acceptance criterion maps to at least one slice and no slice violates a
  non-goal or constraint.
- Each ordinary slice is independently verifiable and leaves the repository in
  a coherent state.
- Dependencies are genuine blockers rather than preferred ordering.
- An implementer can start the frontier without making a missing planning choice.

## Workflow

1. Read `../../../shared/rubrics/lifecycle-contract.md` and the accepted intent
   revision.
2. Inspect the narrow repository surfaces needed to understand viable seams,
   tests, compatibility, and rollout.
3. Draft the smallest end-to-end slices that produce observable behavior or
   independently useful risk reduction.
4. Map `AC-*` identifiers, constraints, tests, and failure paths to each slice.
5. Add an edge only when a slice cannot start or finish coherently first.
6. Check coverage, frontier size, rollback or compatibility needs, and session
   fit before finalizing.

Use expand-migrate-contract for a wide mechanical change that cannot land green
as vertical slices: add the compatible new form, migrate bounded caller groups,
then remove the old form after every migration completes.

Prefer an existing seam. When a new or moved interface is consequential, read
`../references/design-decision-discipline.md` before fixing the slice shape.

## Lifecycle Participation

Store the plan at `.mecha/work/<slug>/slices.md` or the established project
location. Link it from the index, record the next unblocked slice, and preserve
the accepted intent revision verbatim. If implementation evidence challenges
intent, stop and surface the required user-authorized revision.

## Persistence And Yield

Useful progress means covered acceptance criteria, a smaller coherent slice,
corrected dependency, or explicit migration sequence.

Before yielding, test the primary decomposition against one alternate grouping
and verify criterion coverage. Return slices, frontier, unresolved planning
blocker, and next action.
