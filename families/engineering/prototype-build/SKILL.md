---
name: prototype-build
description: Build and verify isolated greenfield prototypes, demos, tools, or apps around one core outcome.
---

# Prototype Build

## Purpose

Build an isolated greenfield artifact that demonstrates one core outcome
end-to-end, without introducing production architecture.

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

- A runnable vertical slice with conventional run instructions.
- Verification of the primary path and a material failure path.
- Visible shortcuts, scope deferrals, and promotion signals.

## Done Conditions

- The core outcome is observable end-to-end.
- The realistic primary path and one material failure path are verified.
- Run instructions live in the repository's conventional location.
- Required, optional, and deferred scope is clear.

## Methodology

### Phase 0: Continuity Check

Inspect partial implementation and verify claims against current files before
resuming. Keep useful orientation in the session-local working note.

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

Choose from explicit preference, available runtime, hypothesis-critical
libraries, delivery target, then maintainer familiarity. Do not shop for
frameworks without a constraint. Use `references/stack-selection.md` when the
choice is material and load only the relevant `../references/*-practices.md`.

### Phase 3: Build One Vertical Slice

Implement the smallest path from realistic input to observable output. Make it
run before adding secondary behavior.

Then add only:

- error handling for inputs the demonstration will encounter;
- behavior required to observe the core outcome;
- optional scope that is genuinely cheap and does not create architecture.

Follow `../../../shared/rubrics/change-discipline.md`. Keep local duplication
when extraction would cost more to understand or change.

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

Real users, sensitive or durable data, consequential failures, production
integration, or compatibility obligations are promotion signals. When one
appears, identify the hardening work. Hand off to
`large-codebase-change` only if the resulting existing repository also meets
the large-codebase heuristic; otherwise continue with native Codex.

## Progress

Progress is a working slice, validated stack, clearer scope, or discovered
constraint. Try one bounded simplification before yielding.

## Pivot Rules

- If work moves into an existing repository, route by repository size:
  `large-codebase-change` for clearly large repositories, native Codex
  otherwise.
- If the task becomes domain analysis rather than prototype construction, use
  the appropriate specialist or native Codex.
- If the user changes the core outcome, update the scope budget before
  continuing.

## Language References

Load only the relevant primer: `../references/python-practices.md`,
`../references/typescript-practices.md`, `../references/go-practices.md`,
`../references/rust-practices.md`, `../references/systems-c-cpp-practices.md`,
or `../references/java-jvm-practices.md`.
