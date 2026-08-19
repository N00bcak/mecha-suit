---
name: large-codebase-change
description: Implement PR-ready changes to established code above roughly 5kLoC with idiomatic, anti-bloat, and verification discipline.
---

# Large Codebase Change

## Purpose

Implement the smallest idiomatic, verified change that is ready for review in a
clearly large existing repository.

## Do Not Use

- Existing repositories clearly below the boundary — continue with native
  Codex.
- Isolated greenfield prototypes — use `prototype-builder`.
- Uncertain-cause bugs whose primary work is reproduction and diagnosis — use
  `diagnosing-bugs` first, then apply this skill's implementation discipline
  after the cause or repair is supported.
- CTF or ML-specific work unless the primary task is engineering integration.
- Do not spawn, request, or rely on subagents.

## Needs

- User goal and acceptance criteria.
- Repository access and applicable local instructions.
- Available build, format, lint, and test commands.
- Compatibility, migration, rollout, or publication constraints.

## Returns

- A minimal, idiomatic, PR-ready diff.
- Verification evidence and explicit test gaps.
- Compatibility or rollout risks, deferred work, and suggested review focus.

PR-ready does not mean published. Work on the current branch and preserve user
changes. Do not create or switch branches, commit, push, or open a pull request
unless the user explicitly asks.

## Done Conditions

- The requested behavior is implemented across every affected boundary.
- The diff contains no speculative or redundant structure.
- Relevant formatting, static checks, and tests pass, or gaps are explained.
- The handoff identifies outcome, scope, evidence, risks, deferrals, and review
  focus.

## Methodology

### Phase 0: Continuity Check

Inspect Git state, relevant TODOs, partial work, and any matching work record.
Verify recorded claims before resuming and preserve accepted intent when
correcting stale implementation state. Use
`../references/session-continuity.md` only for durable work; keep small changes
in the response. When a matching record requires
`../../../shared/rubrics/lifecycle-contract.md`, read it only if its current
contents are not already available in context. Reconcile legacy scratchpads
without moving or deleting them unless authorized.

### Phase 1: Orient Narrowly

1. Read applicable instructions, manifests, and repository-native commands.
2. Inspect nearby implementation and test style.
3. Identify the narrowest relevant change surface.
4. Preserve unrelated working-tree changes.
5. Load `../../../shared/rubrics/change-discipline.md` and only the relevant
   `../references/*-practices.md` primers.

Do not survey the whole repository. Count maintained source lines only if the
routing boundary remains unclear after inspecting its structure.

### Phase 2: Map the Change

Trace the requested behavior through affected:

- callers and entry points;
- public or shared contracts;
- persistence and migrations;
- configuration and deployment surfaces;
- tests and fixtures;
- backward-compatibility or rollout boundaries.

Record explicit file paths and risks. Read
`references/migration-and-rollout.md` only for data, API, message, or staged
rollout changes. Read `references/testing-strategy.md` when test selection is
not obvious.

In lifecycle mode, map the change surface and verification to the accepted
`AC-*` criteria. Surface implementation evidence that contradicts locked intent
instead of silently revising the contract.

### Phase 3: Implement Surgically

Match local conventions before applying general language guidance. Make the
deepest necessary change first, then update consumers and tests.

Apply these abstraction gates:

- No single-use helper unless it names a real domain operation or isolates a
  meaningful boundary.
- No pass-through wrapper.
- No speculative interface, factory, parameter, configuration, or extension
  point.
- Preserve sequential logic when splitting it would increase navigation cost.
- Treat SOLID as diagnostic guidance, not a quota for types or functions.
- Add dependencies only when the requested behavior cannot reasonably use the
  existing toolchain.

Handle errors, resources, concurrency, and types in the repository's idiom.
Remove only artifacts made obsolete by this change.

Read `../references/behavior-first-development.md` when the user requests
test-first work, a regression needs a durable guard, or a meaningful automated
check can observe the new behavior before implementation. Read
`../references/design-decision-discipline.md` when introducing or moving a
consequential interface, seam, persistence contract, or compatibility boundary.

### Phase 4: Verify by Risk

1. Run the repository-native formatter and static checks for changed files.
2. Run focused tests that exercise the changed behavior.
3. Run broader tests when shared contracts or blast radius justify them.
4. Test a material failure path for new behavior.
5. Use manual verification when automation cannot observe the relevant path,
   and record exactly what was checked.

Select verification by failure consequence and change surface, not a fixed
quota. A pre-existing failure must be demonstrated and reported, not silently
attributed.

### Phase 5: Mandatory Compression Review

Review every new function, type, file, wrapper, option, dependency, and
configuration value.

For each one, ask:

- What concrete complexity, duplication, or risk does it reduce?
- Would inlining or using an existing local pattern be clearer?
- Is it required by current behavior rather than a hypothetical future?

Remove anything that does not earn its maintenance and navigation cost. Re-run
affected verification after compression.

### Phase 6: Close

Update any active work record with verification, risks, files, and one next
step. Set it complete only when no required work remains.

In lifecycle mode, implementation completion is not lifecycle completion.
Record the review baseline and head, diff scope, criterion evidence, known
verification gaps, and review-ready state, then name three-axis review as the
next task shape. For remediation, answer every open `RF-*` blocker as fixed
with evidence, rebutted with counter-evidence, or conflicting with accepted
intent. Keep lifecycle state in-progress until `code-review` passes or the user
records an explicit waiver.

Return the outcome, diff scope, verification, risks, deferrals, and reviewer
focus. Do not publish Git state unless explicitly requested.

## Persistence And Yield

Progress is working code, passing tests, a narrower change surface, or a
verified constraint. Try one distinct bounded alternative before yielding and
update any active work record.

## Pivot Rules

- If the work is an isolated greenfield outcome, use `prototype-builder`.
- If the repository is clearly below the large-codebase heuristic, continue
  with native Codex.
- Use an appropriate domain specialist when engineering integration is not the
  primary task.

## Language References

Load only the relevant primer: `../references/python-practices.md`,
`../references/typescript-practices.md`, `../references/go-practices.md`,
`../references/rust-practices.md`, `../references/systems-c-cpp-practices.md`,
or `../references/java-jvm-practices.md`.
