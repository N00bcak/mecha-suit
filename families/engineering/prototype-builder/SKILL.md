---
name: prototype-builder
description: Build and verify isolated greenfield prototypes, demos, tools, or apps around one core outcome.
---

# Prototype Builder

## Purpose

Build an isolated greenfield artifact that demonstrates one core outcome
end-to-end, without introducing production architecture.

## Use When

- The work starts from little or no existing implementation.
- The artifact is isolated and organized around one demonstrable outcome.
- The user wants a prototype, demo, tool, app, or experiment.

There is no line-count limit. Greenfield posture and a single core outcome are
the routing cues.

## Do Not Use

- Changes inside an existing repository that are not an isolated greenfield
  artifact.
- Production integration, migration, or compatibility work.
- CTF or ML-specific analysis unless the primary task is building the
  prototype.
- Do not spawn, request, or rely on subagents.

Use `large-codebase-change` for an existing repository only when it also meets
that skill's large-codebase boundary. Otherwise continue with native Codex.

## Needs

- Intended user and observable demonstration.
- Core hypothesis or outcome.
- Preferred platform, runtime, libraries, or deployment target when specified.
- Required inputs, outputs, and constraints.

## Returns

- Updated or newly created `SCRATCHPAD.md` when durable continuity is
  warranted.
- A runnable vertical slice with conventional run instructions.
- Verification of the primary path and a material failure path.
- Visible shortcuts, scope deferrals, and promotion signals.

## Done Conditions

- The core outcome is observable end-to-end.
- The realistic primary path and one material failure path are verified.
- Run instructions live in the repository's conventional location.
- Required, optional, and deferred scope is clear.
- Scratchpad state is current when a scratchpad is in use.

## Methodology

### Phase 0: Continuity Check

Look for `SCRATCHPAD.md`, partial implementation, relevant TODO markers, and
recent Git history when a repository exists.

If a scratchpad exists, read it completely, verify its claims against current
files and runnable state, and resume from its next step.

Create one only for multi-session work, multiple dependencies, significant
coordination risk, or an explicit user request. Small prototypes keep state in
the response.

Use this structure:

```markdown
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

Update it after stack selection, the first working core loop, each feature
unit, verification, and before yielding. Follow
`../references/session-continuity.md`.

### Phase 1: Frame the Demonstration

Before selecting a stack, state:

- the user;
- the core hypothesis or outcome;
- the input-to-output interaction that demonstrates it;
- what an observer will see when it works.

Maintain a scope budget:

- **Required now:** necessary for the demonstration.
- **Optional if cheap:** improves observation without changing architecture.
- **Intentionally deferred:** unrelated hardening or secondary behavior.

### Phase 2: Choose the Stack

Choose from, in order:

1. explicit user preference;
2. available runtime and repository context;
3. libraries critical to the hypothesis;
4. deployment or distribution target;
5. likely maintainer familiarity.

Do not shop for frameworks without a constraint. Record the choice and a short
rationale. Use `references/stack-selection.md`, then load only the shared
language primers relevant to the chosen stack.

### Phase 3: Build One Vertical Slice

Implement the smallest path from realistic input to observable output. Make it
run before adding secondary behavior.

Then add only:

- error handling for inputs the demonstration will encounter;
- behavior required to observe the core outcome;
- optional scope that is genuinely cheap and does not create architecture.

Follow `../../../shared/rubrics/change-discipline.md`. Local duplication is acceptable
when extracting an abstraction would cost more to understand or change.

### Phase 4: Calibrate Quality

Use `references/prototype-quality.md` to decide whether tests, CI, migrations,
deployment, documentation, authentication, or persistence are material.
Require them only when the prototype's use, data, or core hypothesis depends on
them. Make every shortcut visible.

Apply repository and language idioms for composition, errors, resources,
concurrency, and types without building production layers.

### Phase 5: Verify and Document

1. Run the complete primary path with realistic input.
2. Exercise at least one failure that would materially undermine the
   demonstration.
3. Run repository-native formatting, linting, and tests that exist or are
   material to the hypothesis.
4. Put install and run instructions in the conventional README, help output,
   example, or equivalent location.
5. List visible shortcuts and intentionally deferred scope.

### Phase 6: Close and Assess Promotion

Promotion signals include:

- real users depend on it;
- it handles sensitive or durable data;
- downtime or incorrect output has consequences;
- it integrates into production systems;
- it acquires compatibility obligations.

When a signal appears, identify the hardening work. Hand off to
`large-codebase-change` only if the resulting existing repository also meets
the large-codebase heuristic; otherwise continue with native Codex.

If using a scratchpad, update runnable state, verification, files changed,
deferrals, promotion signals, and the next step.

## Persistence And Yield

Useful progress means a working slice, validated stack choice, clearer scope,
or discovered constraints.

Before yielding, try the primary path and one bounded simplification such as a
smaller scope, simpler stack, or fewer features. Check whether missing
information is discoverable and update the scratchpad when one is in use.

## Pivot Rules

- If work moves into an existing repository, route by repository size:
  `large-codebase-change` for clearly large repositories, native Codex
  otherwise.
- If the task becomes domain analysis rather than prototype construction, use
  the appropriate specialist or native Codex.
- If the user changes the core outcome, update the scope budget before
  continuing.

## References

- `../../../shared/rubrics/change-discipline.md` — anti-bloat and surgical-change gates
- `../references/session-continuity.md` — shared scratchpad protocol
- `../references/python-practices.md` — Python idioms
- `../references/typescript-practices.md` — TypeScript idioms
- `../references/go-practices.md` — Go idioms
- `../references/rust-practices.md` — Rust idioms
- `../references/systems-c-cpp-practices.md` — C and C++ idioms
- `../references/java-jvm-practices.md` — Java and JVM idioms
- `references/stack-selection.md` — constraint-led stack selection
- `references/prototype-quality.md` — risk-calibrated prototype quality
