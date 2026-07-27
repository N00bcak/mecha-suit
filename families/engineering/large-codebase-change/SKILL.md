---
name: large-codebase-change
description: Implement PR-ready changes in codebases above roughly 5kLoC with idiomatic, anti-bloat, and verification discipline.
---

# Large Codebase Change

## Purpose

Implement the smallest idiomatic, verified change that is ready for review in a
clearly large existing repository.

## Use When

- The task changes an existing repository with roughly more than 5k lines of
  maintained source code.
- The requested edit is small or large; repository scale is the routing cue.
- The work may affect integrations, shared contracts, persistence,
  configuration, migrations, or compatibility boundaries.

Treat 5kLoC as a heuristic. Exclude generated, vendored, dependency, and build
output. Count only when repository size is genuinely unclear.

## Do Not Use

- Existing repositories clearly below the boundary — continue with native
  Codex.
- Isolated greenfield prototypes — use `prototype-builder`.
- CTF or ML-specific work unless the primary task is engineering integration.
- Do not spawn, request, or rely on subagents.

## Needs

- User goal and acceptance criteria.
- Repository access and applicable local instructions.
- Available build, format, lint, and test commands.
- Compatibility, migration, rollout, or publication constraints.

## Returns

- Updated or newly created `SCRATCHPAD.md` when durable continuity is
  warranted.
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
- Scratchpad state is current when a scratchpad is in use.
- The handoff identifies outcome, scope, evidence, risks, deferrals, and review
  focus.

## Methodology

### Phase 0: Continuity Check

1. Look for `SCRATCHPAD.md` at the repository root or in `.agent/`.
2. Inspect current Git status and recent history without changing the branch.
3. Read TODO or FIXME markers only on the relevant change surface.

If a scratchpad exists, read it completely and verify its claims against files,
Git state, and available tests before resuming. If it is stale, update it
first.

If none exists, create one only for multi-session work, broad change surfaces,
migrations, significant coordination risk, or an explicit user request. Small,
self-contained changes keep state in the response.

Use this structure:

```markdown
# Scratchpad

## Task
[What we're changing and why]

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

Update it after orientation, planning, each implementation unit, verification,
and before yielding. Follow `../references/session-continuity.md`.

### Phase 1: Orient Narrowly

1. Read applicable instructions, manifests, and repository-native commands.
2. Inspect nearby implementation and test style.
3. Identify the narrowest relevant change surface.
4. Preserve unrelated working-tree changes.
5. Load `../references/change-discipline.md`.
6. Load only the shared language primers for files likely to change.

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
Avoid drive-by cleanup; remove only artifacts made obsolete by this change.

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

If using a scratchpad, update completed work, current verification state,
deferrals, risks, modified files, and one explicit next step. Set status to
`complete` only when no required work remains.

Return a PR-ready handoff:

- outcome;
- concise diff scope;
- verification evidence;
- compatibility or rollout risks;
- intentionally deferred work;
- suggested reviewer focus.

Do not publish Git state unless explicitly requested.

## Persistence And Yield

Useful progress means working code, passing tests, narrowed change surface,
discovered constraints, or verified assumptions.

Before yielding, try the primary path and one distinct bounded alternative,
check whether missing information is locally discoverable, and confirm further
work would repeat or require a user-owned decision. Update the scratchpad when
one is in use.

## Pivot Rules

- If the work is an isolated greenfield outcome, use `prototype-builder`.
- If the repository is clearly below the large-codebase heuristic, continue
  with native Codex.
- Use an appropriate domain specialist when engineering integration is not the
  primary task.

## References

- `../references/change-discipline.md` — anti-bloat and surgical-change gates
- `../references/session-continuity.md` — shared scratchpad protocol
- `../references/python-practices.md` — Python idioms
- `../references/typescript-practices.md` — TypeScript idioms
- `../references/go-practices.md` — Go idioms
- `../references/rust-practices.md` — Rust idioms
- `../references/systems-c-cpp-practices.md` — C and C++ idioms
- `../references/java-jvm-practices.md` — Java and JVM idioms
- `references/testing-strategy.md` — risk-calibrated test selection
- `references/migration-and-rollout.md` — migration and rollout decisions
