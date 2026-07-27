---
name: large-codebase-change
description: Implement and verify changes to existing codebases, integrations, migrations, shared contracts, or refactors.
---

# Large Codebase Change

## Purpose

Guide changes in an existing codebase where integration behavior, tests,
shared contracts, or system boundaries matter. Enforces developmental
continuity across sessions, code correctness with appropriate complexity,
and asymptotic sanity.

## Use When

- The task modifies an existing repository.
- The change touches shared behavior, APIs, storage, build systems, or
  migrations.
- The user needs implementation plus verification.
- Work may span multiple sessions and requires state continuity.

## Do Not Use

- Small greenfield prototypes — use `prototype-builder`.
- CTF challenges — use the appropriate CTF specialist.
- ML dataset or modeling work unless the main task is engineering integration.
- Do not spawn, request, or rely on subagents.

## Needs

- User goal and acceptance criteria.
- Repository access or the relevant context.
- Test or validation commands when available.
- Constraints on compatibility, migration, or rollout.

## Returns

- Updated or newly created `SCRATCHPAD.md` when durable planning or handoff state is warranted.
- Scoped implementation with verification evidence.
- Test results or explicit test gaps.
- Risks and follow-up items when material.
- Clear handoff state for the next session.

## Done Conditions

- The intended change is implemented and verified, or the blocker is explicit.
- Tests pass or test gaps are documented with rationale.
- Session state is captured in `SCRATCHPAD.md` when the task warrants durable planning or handoff state.
- Residual risks and deferred items are captured.

## Methodology

### Phase 0: Continuity Check — Resume or Decide

Start by checking for existing progress and deciding whether the task needs durable planning state.

Check for existing progress artifacts:

1. Look for `SCRATCHPAD.md` in the repository root or `.agent/` directory.
2. Check `git log --oneline -20` for recent changes.
3. Look for TODO/FIXME markers left by prior work.

**If a scratchpad exists:**

- Read it completely.
- Verify key claims against current state: do referenced files exist?
  Do described changes appear in the code? Do tests still pass?
- If claims are stale, update the scratchpad before proceeding.
- Resume from the documented next step. Do NOT repeat completed work
  unless verification fails.

**If no scratchpad exists:**

Create `SCRATCHPAD.md` only when the task benefits from durable planning or handoff state:

- Medium-large codebase changes.
- Multi-step or multi-session work.
- Broad change surfaces, migrations, shared contracts, or significant coordination risk.
- User explicitly asks for planning or handoff state.

For small, self-contained edits, do not create a scratchpad. Keep the plan in the response or final summary instead.

When creating `SCRATCHPAD.md`, use this structure:

```
# Scratchpad

## Task
[What we're building/changing and why]

## Status
[active | paused | complete | blocked]

## Change Surface
- [ ] path/to/file — [what changes and why]

## Decisions
- [decision]: [rationale]

## Progress
### [session identifier or date]
- [what was accomplished]
- [files changed]

## Deferred
- [item]: [why deferred]

## Next
[Explicit next action for the next session]
```

When using a scratchpad, update it at every significant decision point:
after orientation, after planning, after each implementation unit, after
verification. See `references/session-continuity.md` for the full
verification and update protocol.

### Phase 1: Orient

Understand the codebase shape before changing it.

1. **Structure**: project layout, language(s), build system, package manager.
2. **Contracts**: APIs, shared types, schemas, configuration surfaces.
3. **Tests**: framework, commands, coverage expectations, existing gaps.
4. **Style**: naming conventions, patterns, file organization.

Read manifests, entrypoints, and the narrowest slice that reveals the
change surface. Do not survey the entire codebase. Record findings in
the scratchpad when using one, otherwise keep them in the response or
final summary.

### Phase 2: Plan the Change Surface

1. Trace from user-facing entry to storage/output.
2. Identify all touch points: direct changes, ripple effects, test updates.
3. Assess risk per touch point: is it shared? tested? complex?
4. Order changes: deepest dependency first, then consumers.

When using a scratchpad, record the plan there with explicit file paths
and expected changes per file. Otherwise keep the plan concise in the
response or final summary.

### Phase 3: Implement

Execute changes in the planned order. For each unit, enforce three
constraints in priority order.

**Correctness first.** Does it do what it claims? Does it preserve
existing invariants? Does it handle the real input domain?

Common correctness traps:

- Off-by-one and boundary conditions.
- Null/undefined in nullable contexts.
- Race conditions in concurrent code.
- Resource leaks: connections, file handles, locks, cursors.
- Broken contracts: changing a return type, field name, or error shape
  that callers depend on.
- Silent data corruption: truncation, lossy casts, timezone mangling.

When unsure whether behavior is correct, write a test for it before
moving forward.

**Appropriate complexity.** Use the simplest structure that correctly
solves the problem. Three similar lines beat a premature abstraction.
A direct implementation beats a clever one. Introduce a new abstraction
only when it eliminates a real, repeated source of bugs or
inconsistency — not when it merely looks cleaner.

Signs of inappropriate complexity:

- A wrapper that adds no safety or clarity.
- A generic solution to a problem that only exists once.
- An inheritance hierarchy for two concrete types.
- A configuration system for values that never change.

**Asymptotic sanity.** No O(n²) where O(n) is straightforward. No
full-collection scans where index lookups exist. No repeated
computation where memoization is trivial. No unbounded memory growth
where streaming is possible.

Do NOT microoptimize. Constant factors do not matter until profiling
says they do. Prefer clarity over marginal speedups. But if you are
nesting a loop inside a loop over the same collection and you do not
need to, fix it.

Consult language-specific references when working in a language with
specific idiom or safety requirements.

### Phase 4: Verify

1. **Type checking / linting**: run if the project has it configured.
2. **Existing tests**: must pass. A failure from your change means the
   change is likely wrong, not the tests — unless the test is genuinely
   stale and you can demonstrate why.
3. **New tests**: write for new behavior, fixed bugs, or uncovered
   critical paths.
4. **Manual verification**: when automated coverage is insufficient,
   document exactly what you checked and why.

If tests do not exist or are broken pre-change, document this in the
scratchpad when using one, otherwise in the final summary. Narrow the
verification scope rather than skipping it.

### Phase 5: Session Close

Before ending any session that uses `SCRATCHPAD.md`, update it with:

- What was accomplished this session.
- Current test/build state.
- Deferred items with rationale.
- Explicit next step for the next session.
- Files modified this session.
- Open questions or risks.

If the task is complete, set status to `complete` and preserve the
scratchpad for reference. If no scratchpad is in use, include the same
state in the final summary.

## Persistence And Yield

Useful progress means working code, passing tests, narrowed change
surface, discovered constraints, or verified assumptions.

Before yielding:

- Try the primary implementation path.
- Try one distinct bounded alternative when the primary path fails.
- Check whether missing information is discoverable from available context.
- Confirm the next action would repeat prior work, require unsafe guessing,
  or leave this skill's boundary.

Do not yield merely because the codebase is large, the task is hard,
or tests are slow.

When yielding, update the scratchpad if one is in use and return:
attempts made, useful progress found, specific blocker, why more work
would repeat, and the next recovery step.

## Pivot Rules

- If the change is actually a greenfield prototype, hand off to
  `prototype-builder` with current context.
- If the change requires ML model work, hand off to the appropriate ML
  skill or `task-clarifier` if ML skills are stubs.
- If the task requires genuine multi-specialist judgment across families,
  hand off to `interdisciplinary-council`.

## Reference

- `references/session-continuity.md` — scratchpad protocol and verification
- `references/code-correctness.md` — correctness checklist and common bugs
- `references/complexity-and-optimality.md` — complexity principles and asymptotic sanity
- `references/testing-strategy.md` — test selection and coverage priorities
- `references/software-principles.md` — SOLID, KISS, Law of Demeter, and other governing principles
- `references/refactoring-patterns.md` — safe refactoring techniques
- `references/migration-and-rollout.md` — migration safety and rollout strategies
- `references/python-practices.md` — Python idioms, typing, common pitfalls
- `references/typescript-practices.md` — TypeScript strict mode, async, type safety
- `references/go-practices.md` — Go error handling, concurrency, interfaces
- `references/rust-practices.md` — ownership, lifetimes, error handling
- `references/systems-c-cpp-practices.md` — memory safety, RAII, undefined behavior
- `references/java-jvm-practices.md` — collections, concurrency, resource management
