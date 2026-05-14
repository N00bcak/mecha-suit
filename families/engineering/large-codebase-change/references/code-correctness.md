# Code Correctness Checklist

## Correctness by Category

### Boundary Conditions
- Off-by-one: loop bounds, slice indices, range endpoints (inclusive vs exclusive).
- Empty input: zero-length arrays, empty strings, null/nil/None arguments.
- Single element: does the algorithm work when n=1?
- Maximum values: integer overflow at `MAX_INT`, array at capacity, string at max length.
- Negative values: negative indices, negative counts, negative durations.

### Null Safety
- Every dereference of a nullable value has a guard or is provably non-null.
- Optional chaining does not silently swallow errors that should propagate.
- Default values are semantically correct — `0` and `""` are not always safe defaults.

### Concurrency
- Shared mutable state is protected by a lock, atomic, or ownership transfer.
- Lock ordering is consistent (alphabetical, hierarchical, or documented) to prevent deadlock.
- Check-then-act sequences are atomic or guarded (see TOCTOU below).
- Channels/queues: sender and receiver lifecycles match — no writes to closed channels.
- Async: every awaited call can actually be awaited; no fire-and-forget for operations that must complete.

### Resource Management
- Every open gets a close: files, sockets, database connections, locks.
- Close happens in a `finally`/`defer`/`using` block, not in the happy path only.
- Timeouts exist on all blocking operations: network calls, lock acquisition, queue reads.
- Resource pools have bounded size and handle exhaustion explicitly.

### Type Safety
- No implicit coercions that lose data (float to int, long to short, lossy encoding).
- Generic/template types are constrained to what the code actually needs.
- Union/sum types are exhaustively matched — no default/catch-all that hides new variants.
- Serialization round-trips preserve types (JSON numbers, date strings, enums).

### Error Handling
- Errors are handled at the right level — not swallowed at the source, not leaked to the user.
- Partial failure: if step 3 of 5 fails, are steps 1-2 rolled back or is the state consistent?
- Retry logic has backoff and a maximum — no infinite retry loops.
- Error messages include enough context to diagnose (what operation, what input, what failed).
- Panics/exceptions from dependencies are caught at system boundaries.

## Common Bug Patterns

| Pattern | Description | Check |
|---|---|---|
| Off-by-one | Fence-post errors in loops, slicing, pagination | `<` vs `<=`, `length` vs `length - 1`, 0-indexed vs 1-indexed |
| TOCTOU | Time-of-check to time-of-use race | Check and use in same atomic operation, or hold lock across both |
| Double-free / use-after-free | Resource used after release | Nullify references after free; ownership-based lifecycle |
| Integer overflow | Arithmetic exceeds type bounds | Use checked arithmetic, or widen before operating |
| String encoding | Mixing bytes and characters, or UTF-8 and Latin-1 | Explicit encoding at I/O boundaries; internal representation is one encoding |
| Timezone errors | Storing local time, comparing times in different zones | Store UTC; convert at display time; use timezone-aware types |
| Nil map/dict write | Writing to uninitialized map | Initialize before first write; check language semantics |
| Goroutine/thread leak | Spawned work never terminates | Context cancellation, bounded worker pools, tracked goroutines |
| Silent truncation | Data cut off without error (fixed-size buffers, SQL column limits) | Validate length before write; test with max-size input |

## Contract Preservation

When changing a shared interface (function signature, API endpoint, message schema, DB schema):

1. **Find all callers.** Grep, LSP references, or dependency graph. Do not rely on compiler alone — dynamic calls, reflection, and generated code may not trigger errors.
2. **Check both directions.** Callers must handle new return values/errors. Callees must handle new input shapes.
3. **Verify serialized forms.** If the interface crosses a wire or disk (API, queue, file format), old and new versions must coexist during rollout.
4. **Test the boundary.** Unit test the interface itself with edge inputs, not just the implementation behind it.
5. **Update documentation.** Stale docs on shared interfaces cause cascading bugs.

## Input Validation

**Where to validate:** at system boundaries only — API handlers, CLI argument parsing, file/network input, deserialization points.

**What to validate:**

| Layer | Validate | Do Not Validate |
|---|---|---|
| External input (API, CLI, file) | Type, range, length, format, required fields | Business logic (that belongs in domain layer) |
| Internal function calls | Preconditions via asserts in debug builds | Every argument on every call (trust internal callers) |
| Database reads | Schema-guaranteed constraints (no re-check) | Already-validated fields round-tripping from your own writes |

**Validation rules:**
- Reject invalid input early with a clear error. Do not sanitize silently — it hides bugs.
- Validate once, at the boundary. Pass validated types inward (e.g., `UserId` not `string`).
- Allowlist over denylist. Define what is valid, not what is invalid.

## Defensive vs Offensive Programming

| Style | When | Example |
|---|---|---|
| **Defensive** | System boundaries, untrusted input, public APIs | Validate all fields, return error on invalid input |
| **Offensive** | Internal code, trusted callers, invariants | Assert preconditions, crash on violation (fail loud, fail fast) |

Defensive programming inside core logic masks bugs. Offensive programming at API boundaries crashes on valid edge cases. Match the style to the trust level.

## Pre-commit Checklist

Before committing, verify:

- [ ] Every new branch/condition has a test (or an explicit reason it does not).
- [ ] Error paths are tested, not just happy paths.
- [ ] No new warnings from compiler/linter.
- [ ] Shared interfaces: all callers updated, serialization compatibility checked.
- [ ] Resource lifecycle: every acquire has a matching release in a finally/defer.
- [ ] Concurrency: no unguarded shared mutable state introduced.
- [ ] Boundary inputs tested: empty, null, max-size, negative, malformed.
- [ ] No hardcoded secrets, credentials, or environment-specific paths.
- [ ] Changes are reversible or have a rollback plan.
