# Go Practices

Reference for writing correct, idiomatic, and maintainable Go in large codebases.

---

## Language Philosophy

Go optimizes for simplicity, readability, and maintainability over
expressiveness.

- **Errors are values.** Handle them explicitly. Every `err` must be
  checked or intentionally discarded with a comment explaining why.
- **Accept interfaces, return structs.** Functions should depend on
  behavior (interfaces), not implementation. But return concrete
  types so callers get full functionality.
- **Share memory by communicating.** Prefer channels over mutexes
  when coordinating goroutines. Use mutexes only for simple state
  guarding.
- **A little copying is better than a little dependency.** Don't
  import a library for one function. Write the 10 lines yourself.
- **Clear is better than clever.** Go intentionally lacks many power
  features. Explicit loops over functional chains, explicit error
  handling over exception magic.

## Error handling

- **Always check errors.** Never discard with `_` unless the function genuinely cannot fail in your context and you document why.
- Wrap errors with context: `fmt.Errorf("loading config %s: %w", path, err)`. The `%w` verb enables unwrapping.
- Use `errors.Is(err, target)` to check for specific sentinel errors. Use `errors.As(err, &target)` to extract typed errors.
- Define sentinel errors (`var ErrNotFound = errors.New("not found")`) for conditions callers are expected to handle.
- Define custom error types (implementing `Error() string`) when callers need structured information (e.g., status codes, retry-after).
- Do not log and return the same error. Pick one: handle it (log, retry, recover) or propagate it (wrap and return).
- `defer` cleanup should use named returns or check its own errors: `defer func() { err = f.Close() }()`.

## Concurrency

| Pattern | Use when | Key rule |
|---|---|---|
| `sync.Mutex` | Guarding shared mutable state | Lock, defer unlock, keep critical section small |
| Channels | Signaling between goroutines, pipeline stages | Creator closes the channel; receivers range over it |
| `sync.WaitGroup` | Waiting for a known set of goroutines to finish | `Add` before `go`, `Done` in the goroutine, `Wait` in the caller |
| `context.Context` | Cancellation, timeouts, request-scoped values | Pass as first parameter; check `ctx.Done()` in long loops |
| `errgroup.Group` | Fan-out with error collection and cancellation | Returns first error; cancels remaining work via context |
| `sync.Once` | One-time initialization | Prefer over `init()` for lazy setup |

- **Goroutine leaks**: every goroutine must have a guaranteed exit path. Use `context.Context` cancellation or done channels.
- **Channel ownership**: the goroutine that creates/writes a channel should close it. Receivers should never close a channel.
- **Never start a goroutine without knowing how it will stop.** Ask: what signal will cause this goroutine to return?
- Use `select` with a `ctx.Done()` case in any goroutine that loops or blocks on a channel.

## Common pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| Loop variable capture (pre-1.22) | Goroutine captures loop variable by reference; all see final value | `v := v` inside the loop, or upgrade to Go 1.22+ which fixes this |
| Nil interface vs nil pointer | An interface holding a nil pointer is not `== nil` | Check the concrete value, or avoid storing nil pointers in interfaces |
| Slice append aliasing | `append` may return a new slice or mutate the underlying array | Never assume `append` returns an independent slice; copy if needed |
| Map concurrent write | Concurrent writes to a map panic at runtime | Use `sync.Mutex`, `sync.RWMutex`, or `sync.Map` |
| Defer in loops | `defer` runs at function exit, not loop iteration end | Wrap the loop body in a closure: `func() { f := open(); defer f.Close(); ... }()` |
| Struct zero values | Zero value of a struct may be an invalid state | Use constructor functions; document whether zero value is usable |
| String immutability | String operations allocate new strings | Use `strings.Builder` for construction; `[]byte` for mutation |

## Interface design

- **Accept interfaces, return structs.** Callers define the interface they need; implementations return concrete types.
- Keep interfaces small: 1-2 methods is ideal. `io.Reader`, `io.Writer`, `fmt.Stringer` are canonical examples.
- Do not define interfaces preemptively. Define them when you have at least two implementations or need to mock for testing.
- Interfaces belong in the **consumer** package, not the implementer package.
- Use `interface{}` / `any` sparingly. Generics (Go 1.18+) are usually clearer for type-safe polymorphism.

## Correctness traps

| Trap | Details |
|---|---|
| `range` over maps is non-deterministic | Iteration order varies between runs. Sort keys first if order matters |
| `string(intValue)` | Converts int to a Unicode code point, not a digit string. Use `strconv.Itoa()` or `fmt.Sprintf` |
| `time.After` in select | Leaks a timer each iteration until it fires. Use `time.NewTimer` and `timer.Stop()` / `timer.Reset()` |
| Struct field alignment | Field ordering affects struct size due to padding. Run `fieldalignment` linter for hot-path structs |
| `json.Unmarshal` into interface{} | Numbers become `float64`. Use `json.Number` or decode into typed structs |
| Nil slices vs empty slices | `var s []int` is nil; `s := []int{}` is empty. Both have length 0, but `json.Marshal` gives `null` vs `[]` |
| `iota` in const blocks | Resets to 0 in each `const` block. Adding a value in the middle shifts subsequent values |

## Asymptotic gotchas

| Operation | Cost | Fix |
|---|---|---|
| `append` | Amortized O(1) but copies entire backing array when growing | Pre-allocate with `make([]T, 0, expectedCap)` if size is known |
| Map lookup | O(1) average but high constant factor for small n | For < 10 elements, a sorted slice with binary search may be faster |
| String concatenation in loop | O(n^2) from repeated allocation | Use `strings.Builder` or `bytes.Buffer` |
| `json.Marshal` / `Unmarshal` | Reflection-heavy; costly in hot paths | Use code-generated marshalers (`easyjson`, `go-json`) or reuse `json.Encoder` / `json.Decoder` |
| Repeated `regexp.Compile` | Compiles the regex each call | Compile once at package level with `regexp.MustCompile` |
| `reflect` in hot paths | 10-100x slower than direct access | Use generics or code generation |
| `fmt.Sprintf` for simple conversions | Allocates and parses format string | Use `strconv.Itoa`, `strconv.FormatFloat`, etc. |

## Testing

- **Table-driven tests**: define cases as a slice of structs, loop with `t.Run(name, ...)`. Standard Go idiom.

```go
tests := []struct {
    name   string
    input  int
    expect int
}{
    {"positive", 5, 25},
    {"zero", 0, 0},
    {"negative", -3, 9},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got := Square(tt.input)
        if got != tt.expect {
            t.Errorf("Square(%d) = %d, want %d", tt.input, got, tt.expect)
        }
    })
}
```

- Use `testify/assert` and `testify/require` for concise assertions. `require` stops the test on failure; `assert` continues.
- Use `httptest.NewServer` and `httptest.NewRecorder` for HTTP handler tests.
- Run tests with `-race` to detect data races: `go test -race ./...`. Do this in CI always.
- Use `t.Helper()` in test helper functions so that failure messages point to the caller, not the helper.
- Use `t.Parallel()` to run independent tests concurrently. Ensure tests do not share mutable state.
- Use `t.Cleanup()` over `defer` for test teardown — it runs after subtests complete.

## Packaging

- Keep `main` packages thin. Put business logic in importable packages.
- Use `internal/` packages to prevent external imports of implementation details.
- Avoid global mutable state. Pass dependencies as function parameters or struct fields.
- Use `wire`, manual constructor functions, or `fx` for dependency injection. Avoid service locators.
- Module names should match the repository path: `github.com/org/repo`.
- Run `go mod tidy` before committing. Check for `go.sum` changes in code review.

## Performance

- **Profile before optimizing.** Use `pprof` for CPU, memory, goroutine, and block profiles. `go tool pprof` for analysis.
- **Escape analysis**: values that escape to the heap cost allocation + GC pressure. Run `go build -gcflags='-m'` to see escape decisions. Keep hot-path allocations on the stack.
- **`sync.Pool`**: reuse expensive temporary objects (buffers, decoders). Objects may be collected at any GC. Do not store state that must persist.
- **Avoid premature `interface{}`**: interfaces cause heap allocations for small values due to boxing. Use concrete types in hot paths.
- Prefer `[]byte` over `string` when data will be modified or passed to I/O functions.
- Use `bufio.Scanner` / `bufio.Reader` for line-by-line or chunked I/O instead of reading entire files into memory.
- Benchmark with `testing.B`: `func BenchmarkX(b *testing.B) { for i := 0; i < b.N; i++ { ... } }`. Compare with `benchstat`.
