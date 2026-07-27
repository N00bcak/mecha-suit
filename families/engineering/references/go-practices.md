# Go Practices

Follow `go.mod`, repository scripts, package boundaries, and nearby code before
this primer.

## Idiomatic Defaults

- Keep packages cohesive and APIs concrete. Accept interfaces at real
  boundaries; do not create them preemptively.
- Return errors with useful operation context and preserve causes with `%w`.
- Acquire resources near `defer` cleanup and check close errors when they can
  affect correctness.
- Use goroutines only with clear ownership, termination, and error propagation.
- Prefer concrete types; use generics only when repeated type-safe logic earns
  them.

## Codex Bloat Traps

- One-method interfaces created beside their only implementation.
- `Manager`, `Service`, or `Factory` layers that forward calls.
- A goroutine and channel for sequential work.
- Option functions for values that never vary.
- Package fragmentation that creates import navigation without ownership.

## Avoid / Prefer

```go
// Avoid: pass-through abstraction.
func (s *UserService) Find(id string) (User, error) {
    return s.repo.Find(id)
}

// Prefer: call the repository directly unless service policy exists.
user, err := repo.Find(id)
```

```go
f, err := os.Open(name)
if err != nil {
    return fmt.Errorf("open input: %w", err)
}
defer f.Close()
```

## Native Checks

Use repository scripts when present. Otherwise the standard baseline is
`gofmt` on changed files, `go vet ./...`, and `go test ./...`; honor workspace,
build-tag, and generated-code conventions.
