# Design Decision Discipline

Load this reference only when work creates or moves a consequential interface,
module seam, persistence contract, or compatibility boundary.

## Interface Contract

Treat an interface as everything a caller must know: operations, types,
invariants, ordering, errors, configuration, resource ownership, concurrency,
and relevant performance behavior.

Prefer a small interface that hides real complexity and matches repository
language. Tests and callers should observe behavior through the same interface.

## Abstraction Checks

- **Deletion test:** imagine deleting the abstraction. If its policy or
  complexity spreads into callers, it may earn its place. If complexity simply
  disappears, keep the direct form.
- Add substitutability for actual variation, a real external boundary, or a
  demonstrated testing need.
- Avoid pass-through wrappers, speculative adapters, and interfaces introduced
  solely to satisfy a design slogan.
- Keep related policy and invariants local even when the implementation uses
  private internal helpers.

## Consequential Choices

For a hard-to-reverse interface decision, compare the primary design with one
materially different design. Judge them against caller burden, hidden
complexity, locality of change, testability, compatibility, and current need.
Record the chosen design and why the rejected alternative lost. Do not run this
exercise for routine local structure.
