# Rust Practices

Follow `Cargo.toml`, the pinned toolchain, feature conventions, and nearby code
before this primer.

## Idiomatic Defaults

- Prefer enums and pattern matching for closed state; introduce traits for real
  shared behavior or boundaries.
- Propagate errors with `?` and add context at subsystem boundaries using the
  repository's error approach.
- Let ownership and RAII express resource lifetime; avoid cloning to escape a
  design question without checking local patterns.
- Use async only in an async subsystem and avoid holding locks across `.await`.
- Make invalid states unrepresentable when it simplifies current behavior, not
  by building a type hierarchy for every value.

## Codex Bloat Traps

- A trait with one implementation and no boundary.
- Newtype layers with no invariant or domain meaning.
- Excessive `Arc<Mutex<_>>` instead of clear ownership.
- Cloning entire values to satisfy the borrow checker.
- Feature flags and generic parameters for hypothetical consumers.

## Avoid / Prefer

```rust
// Avoid: clone only to sidestep borrowing.
let name = user.name.clone();
render(&name);

// Prefer:
render(&user.name);
```

```rust
// Prefer contextual propagation at a boundary.
let config = load(path).context("load application config")?;
```

## Native Checks

Use repository tasks and the pinned toolchain. Common checks are
`cargo fmt --check`, `cargo clippy --all-targets`, and `cargo test`; apply the
workspace features and targets the repository uses.
