---
name: large-codebase-change
description: Implement PR-ready changes to established code above roughly 10kLoC with idiomatic, anti-bloat, and verification discipline.
---

# Large Codebase Change

## Purpose

Implement the smallest idiomatic, verified, review-ready change in an established
large repository.

## Do Not Use

- Repositories clearly below the size/complexity boundary.
- Isolated greenfield work; use `prototype-builder`.
- Uncertain-cause bugs; diagnose first.
- Work whose primary outcome is AI or CTF analysis.
- Do not use, spawn, request, or rely on subagents.

## Needs

- Requested outcome, acceptance criteria, repository access, local instructions,
  commands, and material compatibility or rollout constraints.

## Returns

- A minimal diff, verification evidence, explicit gaps, risks, deferrals, and
  reviewer focus.

PR-ready does not authorize publishing, commits, branches, pushes, or pull
requests.

## Workflow

1. **Orient:** inspect relevant instructions, Git state, partial work, nearby
    code/tests, and the narrowest change surface. Verify resumed claims against
    current files and tests.
2. **Map:** trace affected callers, contracts, persistence/migration,
    configuration, tests, and compatibility boundaries. Map supplied criteria to
    change and verification; surface contradictions rather than rewriting intent.
3. **Implement:** make the deepest necessary change, then consumers and tests.
    Apply `../../../shared/rubrics/change-discipline.md`. Load a language primer
    only when relevant; load migration, test-first, or design-decision references
    only when their named condition applies.
4. **Verify:** choose formatter, static checks, focused tests, broader checks,
    and a material failure path by consequence and blast radius. Report proven
    pre-existing failures separately.
5. **Compress:** use the shared change-discipline compression review; remove
    anything that does not earn current complexity or risk.
6. **Handoff:** return outcome, diff scope, verification, gaps, risks,
    deferrals, and review focus.

## Progress

Progress is working code, passing evidence, a narrower surface, or a verified
constraint. Yield when the next step requires a user decision or another
specialist outcome.
