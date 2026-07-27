# Change Discipline

Use local instructions and nearby code as the primary standard. These gates
prevent Codex from turning a focused outcome into a framework.

## Before Editing

- State the requested outcome and narrowest change surface.
- Inspect repository state and preserve unrelated user changes.
- Trace only the callers, contracts, state, configuration, tests, and
  compatibility edges the change can affect.
- Prefer an existing local pattern when it fits.

## Abstraction Gates

Add a function, type, file, wrapper, option, or dependency only when it reduces
a concrete source of complexity or risk.

- A single-use helper must name a real domain operation or isolate a meaningful
  boundary.
- A wrapper must add policy, an invariant, translation, or safety.
- Add an interface only for existing substitutability, a real external
  boundary, or a demonstrated testing need.
- Do not add speculative factories, parameters, configuration, hooks, or
  extension points.
- Keep sequential logic together when splitting it would increase navigation
  without clarifying the operation.
- Treat design principles as diagnostic guidance, not quotas for types or
  functions.

## Surgical Implementation

- Match existing names, error models, resource ownership, and test style.
- Touch only lines that serve the requested outcome.
- Do not reformat, rename, or clean up adjacent code.
- Remove artifacts made obsolete by the change.
- Tolerate small local duplication when extraction would cost more than it
  saves.
- Optimize for an observed constraint or an avoidable poor algorithm on the
  expected input, not hypothetical scale.

## Compression Review

Before handoff, inventory every added function, type, file, wrapper, option,
dependency, and configuration value. For each:

1. Name the current complexity, duplication, or risk it removes.
2. Compare it with inlining or an existing local pattern.
3. Remove it if its value depends on hypothetical future use.

Inspect the complete diff for drive-by edits and re-run affected checks.

## Handoff

Report the outcome, concise change scope, verification evidence, compatibility
or rollout risk, intentional deferrals, and the area a reviewer should inspect
most closely. Review-ready work does not authorize branch creation, commits,
pushes, or pull requests.
