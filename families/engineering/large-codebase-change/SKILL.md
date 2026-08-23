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

- A minimal diff, verification evidence, explicit gaps, risks, authorized
  deferrals, blockers, and reviewer focus.

PR-ready does not authorize publishing, commits, branches, pushes, or pull
requests.

## Done Conditions

- The requested behavior satisfies its acceptance criteria across the mapped
  modules, consumers, and deployables.
- Compatibility, migration, and rollout obligations are completed, explicitly
  deferred by a user decision, or returned as blocked.
- Verification selected for the affected blast radius passes, or the exact gaps
  and resulting uncertainty are reported.
- The shared change-discipline gates are satisfied.

## Workflow

1. **Orient:** read `../../../shared/rubrics/change-discipline.md` and verify
    resumed claims against current evidence. If the large-codebase boundary
    remains unclear after inspecting repository structure, count only maintained
    source lines.
2. **Map:** locate the authoritative layer for the requested behavior. Identify
    independently deployed or version-skewed producers and consumers, and map
    acceptance criteria across their contracts, persistence, configuration, and
    rollout boundaries. Surface contradictions rather than rewriting intent.
3. **Implement:** change the authoritative layer, then update affected consumers
    and tests. Use the conditional migration, behavior-first, design-decision,
    and language references when their loading cues apply.
4. **Verify:** select focused and broader evidence by blast radius and
    compatibility risk. Demonstrate mixed-version behavior when versions can
    overlap, exercise a material failure path, and report proven pre-existing
    failures separately.
5. **Close:** apply the shared rubric's Compression Review and Handoff.

## Progress

Progress is working code, passing evidence, a narrower surface, or a verified
constraint. Yield when the next step requires a user decision or another
specialist outcome.

## References

- Read `references/testing-strategy.md` when test selection is unclear, the
  change crosses a shared boundary, or a consequential failure path needs
  stronger evidence.
- Read `references/migration-and-rollout.md` for data, API, message,
  configuration, or staged-rollout changes.
- Read `../references/behavior-first-development.md` when the user requests
  test-first work, a regression needs a durable guard, or new behavior can be
  observed meaningfully before implementation.
- Read `../references/design-decision-discipline.md` when introducing or moving
  a consequential interface, seam, persistence contract, or compatibility
  boundary.
- After local conventions are clear, load only the applicable language primers
  for languages actually changed:
  `../references/python-practices.md`,
  `../references/typescript-practices.md`, `../references/go-practices.md`,
  `../references/rust-practices.md`,
  `../references/systems-c-cpp-practices.md`, or
  `../references/java-jvm-practices.md`.
