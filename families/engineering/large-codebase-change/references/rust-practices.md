# Rust Practices

## Language Philosophy

Rust enforces correctness through its type system and ownership model.
Work with the compiler, not against it.

- **Make illegal states unrepresentable.** Use enums, newtypes, and
  the type system to make invalid data impossible to construct. A
  `NonZeroU32` is better than a `u32` with a comment saying "must
  not be zero."
- **Ownership is a design tool.** When the borrow checker rejects
  your code, it often reveals a real design issue — unclear ownership,
  conflicting lifetimes, or shared mutable state. Restructure rather
  than reaching for `Rc`/`Arc`/`unsafe`.
- **If it compiles, it probably works.** Lean into the type system
  and borrow checker to encode invariants. Tests verify logic;
  the compiler verifies structure.
- **Zero-cost abstractions.** Abstractions should not have runtime
  overhead. If you are adding a wrapper, it should compile away.
- **Unsafe is a contract.** `unsafe` blocks must document the safety
  invariants they rely on. Minimize scope. Prefer safe abstractions
  that encapsulate the unsafety.

## Ownership and Borrowing

| Situation | Use | Why |
|---|---|---|
| Read-only access | `&T` | No ownership transfer, no allocation |
| Mutation needed | `&mut T` | Exclusive access, compiler-enforced |
| Caller keeps using data after call | `&T` or `&mut T` | Avoids unnecessary clone |
| Need owned data in a struct field | `T` (owned) | Structs own their data |
| Expensive clone on hot path | `Rc<T>` (single-thread) or `Arc<T>` (multi-thread) | Shared ownership, reference-counted |
| Optional shared mutation | `Rc<RefCell<T>>` / `Arc<Mutex<T>>` | Interior mutability pattern |
| Genuinely need a copy | `.clone()` | Explicit is better than implicit |

**Rule of thumb:** start with borrowing. Only add `Clone`, `Rc`, or `Arc` when the borrow checker rejects code and the rejection is structurally correct (not a design mistake).

## Error Handling

- Use `Result<T, E>` for all fallible functions. Reserve `panic!` for unrecoverable invariant violations.
- `?` operator for propagation. Chain with `.map_err()` or `.context()` when the error needs wrapping.
- Library crates: define error enums with `thiserror`. Each variant maps to a distinct failure mode.
- Application crates: use `anyhow::Result` for convenient error chaining and backtraces.
- **Never `unwrap()` in production code.** Use `expect("reason")` only when the invariant is truly guaranteed and documented.

```rust
// Library error (thiserror)
#[derive(Debug, thiserror::Error)]
pub enum ParseError {
    #[error("invalid header at byte {0}")]
    InvalidHeader(usize),
    #[error("unexpected EOF")]
    UnexpectedEof,
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

// Application error (anyhow)
use anyhow::{Context, Result};
fn load_config(path: &Path) -> Result<Config> {
    let raw = std::fs::read_to_string(path)
        .context("failed to read config file")?;
    toml::from_str(&raw).context("failed to parse config")
}
```

## Common Pitfalls

| Pitfall | What happens | Fix |
|---|---|---|
| Accepting `String` instead of `&str` in fn args | Forces caller to allocate | Accept `&str`, return `String` |
| Accepting `Vec<T>` instead of `&[T]` in fn args | Forces caller to own a Vec | Accept `&[T]` for read-only access |
| Lifetime elision hiding borrows | Struct borrows outlive source | Make lifetimes explicit when struct holds references |
| `to_string()` on `&str` in hot loop | Allocates every iteration | Keep as `&str` where possible |
| `Deref` coercion confusion | `&String` auto-coerces to `&str` | Know the chain: `String -> &str`, `Vec<T> -> &[T]`, `Box<T> -> &T` |
| Returning references to local variables | Borrow checker error | Return owned types or use lifetime parameters |

## Correctness Traps

- **Integer overflow:** debug builds panic, release builds wrap silently. Use `checked_add`, `saturating_add`, or `wrapping_add` for explicit behavior.
- **`unsafe` blocks:** every `unsafe` block needs a `// SAFETY:` comment documenting which invariants the caller guarantees.
- **`Send`/`Sync` bounds:** if a type holds raw pointers or interior mutability, it is not automatically `Send`/`Sync`. Implementing these manually is unsafe and requires proof.
- **`Drop` ordering:** struct fields drop in declaration order. If drop order matters (e.g., file handle before temp dir), declare fields in the correct order.
- **`mem::forget` is safe:** do not rely on `Drop` for safety invariants. `ManuallyDrop` and `mem::forget` can skip destructors.

## Concurrency

```rust
// Shared mutable state
let shared = Arc::new(Mutex::new(HashMap::new()));
let handle = {
    let shared = Arc::clone(&shared);
    tokio::spawn(async move {
        let mut map = shared.lock().await;  // tokio::sync::Mutex
        map.insert("key", "value");
    })
};
```

| Pattern | When |
|---|---|
| `Arc<Mutex<T>>` | Shared mutable state across threads |
| `mpsc` channel | Producer-consumer, message passing |
| `broadcast` channel | Fan-out to multiple consumers |
| `watch` channel | Single latest-value broadcast |
| `RwLock<T>` | Many readers, rare writers |
| `tokio::spawn` | CPU-light async work |
| `tokio::spawn_blocking` | Blocking/CPU-heavy work inside async context |

**Critical:** never hold a `std::sync::Mutex` lock across an `.await` point. Use `tokio::sync::Mutex` or restructure to drop the guard before awaiting.

## Asymptotic Considerations

| Operation | Cost | Alternative |
|---|---|---|
| `Vec::contains` | O(n) | `HashSet::contains` O(1) amortized |
| `String` concat with `+` | Clones left operand | `format!()` or `String::push_str` |
| `collect()` into `HashMap` | One pass | Prefer over manual loop with repeated lookups |
| `Vec::insert(0, _)` | O(n) shift | `VecDeque::push_front` O(1) |
| `Vec::remove(0)` | O(n) shift | `VecDeque::pop_front` O(1) |
| Nested `Vec::contains` in loop | O(n*m) | Build a `HashSet` first |

## Testing

- Place unit tests in `#[cfg(test)] mod tests` at the bottom of each module.
- Use `assert_eq!` (requires `Debug` + `PartialEq`). Derive both on types used in tests.
- `#[should_panic(expected = "message")]` for expected panics.
- `proptest` or `quickcheck` for property-based testing on parsers, serializers, numeric code.
- **Test in both profiles:** `cargo test` (debug, overflow panics) and `cargo test --release` (overflow wraps). Behavior can differ.
- Integration tests live in `tests/` directory at crate root.

## Unsafe Code Checklist

- [ ] Is the unsafe block truly necessary? No safe alternative?
- [ ] `// SAFETY:` comment documents all invariants.
- [ ] Unsafe scope is minimized (only the necessary lines).
- [ ] Safe abstraction wraps the unsafe code with a safe public API.
- [ ] Run `cargo miri test` to detect undefined behavior.
- [ ] No aliased `&mut` references.
- [ ] Raw pointer dereferences have valid provenance and alignment.

## Cargo Patterns

- **Workspaces:** use `[workspace]` in root `Cargo.toml` for multi-crate projects. Share dependency versions with `workspace = true`.
- **Feature flags:** gate optional dependencies behind features. Default features should be minimal.
- **Clippy:** run `cargo clippy -- -D warnings` in CI. Key lints: `clippy::unwrap_used`, `clippy::pedantic`.
- **Formatting:** `cargo fmt --check` in CI. Configure `rustfmt.toml` for project-wide style.
- **Dependency audit:** `cargo audit` for known vulnerabilities. `cargo deny` for license and duplicate checks.
