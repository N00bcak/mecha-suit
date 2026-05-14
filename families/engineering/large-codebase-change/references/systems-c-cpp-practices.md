# C/C++ Systems Practices

## Language Philosophy

C and C++ give you full control and full responsibility.

- **RAII (C++).** Resource Acquisition Is Initialization. Every
  resource (memory, files, locks, sockets) is owned by a stack
  object whose destructor releases it. No manual cleanup in `finally`
  or `goto cleanup`.
- **Const correctness.** Mark everything `const` that does not need
  to mutate. This is documentation the compiler enforces. Apply to
  parameters, return values, member functions, and local variables.
- **Rule of Zero (C++).** If your class does not manage a resource
  directly, don't write a destructor, copy constructor, or move
  constructor. If you must manage a resource, follow the Rule of
  Five.
- **Zero-overhead principle.** You don't pay for what you don't use.
  Abstractions should compile to the same code you would write by
  hand.
- **Undefined behavior is the enemy.** Signed overflow, null deref,
  out-of-bounds access, strict aliasing violations — these don't
  just crash. They make your program do anything. Treat UB as a
  correctness bug, not a performance concern.

## Memory Safety Priority List

These are the highest-severity bugs in C/C++ codebases. Every change must be evaluated against them.

| Bug class | Typical cause | Detection |
|---|---|---|
| Buffer overflow | `strcpy`, manual index math, off-by-one | ASan, bounds-checking, `strncpy`/`snprintf` |
| Use-after-free | Pointer retained after `free`/`delete` | ASan, nullify pointers after free |
| Double-free | Multiple `free` on same pointer | ASan, ownership discipline |
| Dangling pointer | Stack address returned, iterator invalidated | Compiler warnings, code review |
| Uninitialized read | Variable used before assignment | MSan, `-Wuninitialized`, zero-init |
| Memory leak | Missing `free`/`delete`, early return skips cleanup | LSan, Valgrind, RAII (C++) |

## C-Specific Patterns

### Allocation discipline

```c
// Always pair malloc/free. Check return value.
char *buf = malloc(size);
if (!buf) { return -ENOMEM; }
// ... use buf ...
free(buf);
buf = NULL;  // prevent use-after-free
```

### Common traps

| Trap | Wrong | Right |
|---|---|---|
| `sizeof` on pointer vs array | `sizeof(ptr)` (gives pointer size) | `sizeof(arr)` or pass length explicitly |
| `strncpy` null termination | `strncpy(dst, src, n)` may not null-terminate | `dst[n-1] = '\0'` after strncpy |
| Format string attack | `printf(user_input)` | `printf("%s", user_input)` |
| Signed/unsigned comparison | `if (len < -1)` always false for `size_t` | Use consistent types, enable `-Wsign-compare` |
| `realloc` and old pointer | `ptr = realloc(ptr, new_size)` leaks on failure | Use temp: `tmp = realloc(ptr, new_size)` |
| Integer truncation | Assigning `size_t` to `int` | Use matching types, cast explicitly with comment |

### Format specifiers

| Type | Specifier | Notes |
|---|---|---|
| `int` | `%d` | |
| `unsigned` | `%u` | |
| `long` | `%ld` | |
| `size_t` | `%zu` | Portable across platforms |
| `int64_t` | `PRId64` | From `<inttypes.h>` |
| `void *` | `%p` | |

## C++-Specific Patterns

### RAII and Smart Pointers

| Pointer type | Ownership | Use when |
|---|---|---|
| `std::unique_ptr<T>` | Exclusive | Single owner, default choice |
| `std::shared_ptr<T>` | Shared, ref-counted | Genuine shared ownership (rare) |
| `std::weak_ptr<T>` | Non-owning observer | Breaking cycles, caches |
| Raw pointer `T*` | Non-owning | Observing only, never managing lifetime |

```cpp
// Factory returns unique_ptr — caller owns the object
auto widget = std::make_unique<Widget>(args...);

// Transfer ownership
auto pool = std::make_unique<ConnectionPool>();
server.set_pool(std::move(pool));  // explicit transfer
```

### Rule of Five / Rule of Zero

- **Rule of Zero (preferred):** if all members are RAII types (smart pointers, std containers), define no special members.
- **Rule of Five:** if you define any of destructor, copy constructor, copy assignment, move constructor, move assignment -- define all five.
- **Suppress what you don't need:** `ClassName(const ClassName&) = delete;`

### Move Semantics

- `std::move` is a cast, not a move. The actual move happens in the move constructor/assignment.
- Moved-from objects are in a valid but unspecified state. Only safe operations: destroy or reassign.
- Pass sink parameters by value, then `std::move` into storage.

## Undefined Behavior Checklist

Every item below is UB in both C and C++. Compilers may "optimize" UB away silently.

- [ ] Signed integer overflow (use unsigned or check before arithmetic)
- [ ] Null pointer dereference
- [ ] Out-of-bounds array/pointer access
- [ ] Strict aliasing violation (casting between unrelated pointer types)
- [ ] Misaligned pointer access
- [ ] Data race (concurrent unsynchronized access, at least one write)
- [ ] Use of uninitialized values
- [ ] Shifting by negative or >= bit-width amount
- [ ] Modifying a `const` object through a cast

## Build System and Tooling

### Compiler flags (minimum for any serious project)

```bash
# GCC / Clang
-Wall -Wextra -Werror -Wpedantic
-fsanitize=address,undefined    # debug/test builds
-fstack-protector-strong        # production builds
-D_FORTIFY_SOURCE=2             # glibc hardening
```

### Sanitizers

| Sanitizer | Detects | Flag |
|---|---|---|
| AddressSanitizer (ASan) | Buffer overflow, use-after-free, leaks | `-fsanitize=address` |
| UndefinedBehaviorSanitizer (UBSan) | Signed overflow, null deref, misalignment | `-fsanitize=undefined` |
| MemorySanitizer (MSan) | Uninitialized reads (Clang only) | `-fsanitize=memory` |
| ThreadSanitizer (TSan) | Data races | `-fsanitize=thread` |

ASan and TSan cannot be combined. Run them as separate CI jobs.

### Static analysis

- `clang-tidy` with `modernize-*`, `bugprone-*`, `cppcoreguidelines-*` checks.
- `cppcheck` for supplementary analysis.
- `scan-build` (Clang static analyzer) for path-sensitive bugs.

## Concurrency

### C++ (prefer `<mutex>` and `<thread>`)

```cpp
std::mutex mtx;
{
    std::lock_guard<std::mutex> lock(mtx);  // RAII unlock
    shared_data.update();
}
// lock released here
```

### C (pthreads)

```c
pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_lock(&mtx);
// critical section
pthread_mutex_unlock(&mtx);
```

| Rule | Detail |
|---|---|
| Data races are UB | Even "benign" races. Use atomics or locks. |
| `volatile` is not synchronization | It prevents compiler reordering only, not CPU reordering. |
| Lock ordering | Always acquire multiple locks in the same global order. |
| `std::atomic` for lock-free | Use `memory_order_seq_cst` unless you can prove a weaker order is correct. |
| Condition variables | Always use in a while-loop (spurious wakeups). |

## Asymptotic and Performance Notes

| Factor | Guidance |
|---|---|
| Cache locality | `std::vector` beats `std::list` for almost all sizes due to contiguous memory. |
| `std::unordered_map` vs `std::map` | Unordered: O(1) avg lookup. Ordered: O(log n). Prefer unordered unless order matters. |
| Virtual dispatch | Measurable cost in tight loops. Consider CRTP or `std::variant` for closed hierarchies. |
| `std::string` SSO | Small strings (typically <= 22 bytes) avoid heap allocation. Don't prematurely optimize string handling. |
| Branch prediction | Predictable branches are nearly free. Use `[[likely]]`/`[[unlikely]]` (C++20) sparingly. |
| Allocation | `malloc` in hot loops is expensive. Pool or arena allocate. |

## Testing

### C++

- **Google Test:** `TEST(SuiteName, TestName)`, `EXPECT_EQ`, `ASSERT_EQ`.
- **Google Mock:** mock interfaces for dependency injection.
- **Catch2:** alternative with simpler setup, `SECTION` for BDD-style.

### C

- Minimal custom harness or CUnit/Check.
- `assert()` in debug builds for internal invariants.

### Memory checking (both languages)

```bash
# Valgrind (slower but thorough)
valgrind --leak-check=full --error-exitcode=1 ./test_binary

# ASan (faster, compile-time instrumentation)
gcc -fsanitize=address -g -o test_binary test.c && ./test_binary
```

Run tests under ASan in CI. Use Valgrind for deeper analysis when ASan misses something (e.g., custom allocators).
