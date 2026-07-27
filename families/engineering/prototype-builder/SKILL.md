---
name: prototype-builder
description: Build and verify small greenfield prototypes, demos, tools, or apps under about 1kLoC.
---

# Prototype Builder

## Purpose

Create small, working first versions of greenfield tools, demos, apps, or
experiments. Enforces developmental continuity across sessions, correctness
from the start, and minimal viable complexity.

## Use When

- The task starts from little or no existing code.
- The likely implementation is under about 1kLoC.
- The user values a working first pass over deep architecture.
- The user wants a prototype, demo, tool, or experiment.

## Do Not Use

- Large existing codebases — use `large-codebase-change`.
- Production migration or complex integration work — use `large-codebase-change`.
- CTF or ML-specific analysis — use the appropriate specialist.
- Do not spawn, request, or rely on subagents.

## Needs

- Desired user-facing behavior.
- Preferred platform or runtime if specified.
- Required inputs, outputs, and constraints.
- Any assets or external dependencies explicitly required.

## Returns

- Updated or newly created `SCRATCHPAD.md` when durable planning or handoff state is warranted.
- Working prototype with clear run instructions.
- Basic verification evidence.
- Notes on intentionally deferred hardening.
- Session handoff state for continuity.

## Done Conditions

- The prototype runs and demonstrates the core behavior.
- Run instructions are documented in the scratchpad or a README.
- Intentionally deferred items are listed.
- Session state is captured in `SCRATCHPAD.md` when the task warrants durable planning or handoff state.

## Methodology

### Phase 0: Continuity Check — Resume or Decide

Start by checking for existing progress and deciding whether the task needs durable planning state.

Check for existing progress:

1. Look for `SCRATCHPAD.md` in the project root.
2. Check for partial implementations or TODO markers.
3. Check `git log --oneline -10` if the project has a repo.

**If a scratchpad exists:**

- Read it completely.
- Verify claims: does the prototype still run? Are referenced files present?
- Resume from the documented next step.

**If no scratchpad exists:**

Create `SCRATCHPAD.md` only when the prototype benefits from durable planning or handoff state:

- Medium-large prototype work.
- Multi-step or multi-session work.
- Many features, external dependencies, or significant coordination risk.
- User explicitly asks for planning or handoff state.

For small, self-contained prototypes, do not create a scratchpad. Keep the plan and run notes in the response or final summary instead.

When creating `SCRATCHPAD.md`, use this structure:

```
# Scratchpad

## Task
[What we're building and for whom]

## Status
[active | paused | complete | blocked]

## Stack
[Language/framework and why]

## Features
- [x] [completed feature]
- [ ] [planned feature]

## Progress
### [session identifier or date]
- [what was built]

## Deferred
- [item]: [why deferred, when to revisit]

## Next
[Explicit next action]
```

When using a scratchpad, update it at key decision points: after stack
selection, after the core loop works, after each feature unit.

### Phase 1: Stack Selection

Choose the simplest viable stack.

1. Use what the user specified if they specified something.
2. Otherwise, choose by constraint fit: runtime availability, library
   ecosystem for the task, deployment target.
3. Prefer boring technology. The prototype proves the idea, not the stack.
4. Decide in under a minute and move on. The user can redirect.

Record the choice and one-sentence rationale in the scratchpad when
using one, otherwise keep it in the response or final summary. See
`references/stack-selection.md` for decision heuristics.

### Phase 2: Core Loop First

Build the primary user-facing behavior before anything else.

1. Define the core interaction: what does the user do, what happens?
2. Implement the minimal path from input to output.
3. Get it running. Verify it works for the happy path.
4. Do NOT build supporting infrastructure (auth, config systems,
   logging frameworks) until the core loop works.

A prototype that runs one thing correctly is more useful than a
prototype that has good architecture but does nothing.

### Phase 3: Build Out

Add secondary features in priority order.

1. **Error handling for real inputs**: what actually goes wrong? Handle
   those cases. Not every theoretical error — the ones users will hit.
2. **Missing core features**: what does the user expect that is not there?
3. **Polish**: better error messages, edge cases, UI refinement — only
   if time and scope permit.

For each addition:

- **Correctness first.** It must work for real inputs.
- **Simplest correct implementation.** No premature abstraction.
  Three routes in a flat file beat an over-engineered router
  framework for a demo.
- **Asymptotic sanity.** If the prototype reads a file, do not load
  the entire file into memory if streaming line-by-line works. If it
  searches a list, do not scan the whole list when a set lookup works.
  But do not optimize beyond what the expected data size requires.

### Phase 4: Verify and Document

1. Run the prototype end-to-end with realistic inputs.
2. Test the golden path and at least one error path.
3. Document how to run it: dependencies, install steps, run command.
4. List what was intentionally deferred and why.

### Phase 5: Session Close

Before ending any session that uses `SCRATCHPAD.md`, update it with:

- What was built this session.
- Current runnable state (does it run? what works?).
- Deferred items.
- Explicit next step.
- Files created or modified.

If the prototype is complete, set status to `complete`. If no scratchpad
is in use, include the same state in the final summary.

## Persistence And Yield

Useful progress means working code, runnable state, validated stack
choice, discovered constraints, or clearer scope.

Before yielding:

- Try the primary implementation path.
- Try one distinct bounded simplification: smaller scope, simpler stack,
  fewer features.
- Check whether missing information is discoverable.
- Confirm the next action would repeat prior work, require unsafe
  guessing, or leave this skill's boundary.

Do not yield merely because the task is ambitious or the stack is
unfamiliar.

When yielding, update the scratchpad if one is in use and return:
attempts made, useful progress found, specific blocker, why more work
would repeat, and the next recovery step.

## Pivot Rules

- If the prototype grows past ~1kLoC and needs integration or
  migration work, hand off to `large-codebase-change`.
- If the prototype needs ML model training, hand off to the
  appropriate ML skill or `task-clarifier` if ML skills are stubs.
- If the user redirects to a different stack or scope, update the
  scratchpad if one is in use and continue.

## Reference

- `references/session-continuity.md` — scratchpad protocol and verification
- `references/stack-selection.md` — stack choice heuristics by task type
- `references/prototype-quality.md` — quality bar for prototypes, what to defer
