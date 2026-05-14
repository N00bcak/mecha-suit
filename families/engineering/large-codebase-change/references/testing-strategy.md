# Testing Strategy

Reference for selecting, writing, and prioritizing tests during large codebase changes.

---

## Test types and when to use each

| Type | Purpose | Speed | Use when |
|---|---|---|---|
| Unit | Verify a single function/module in isolation | Fast | Logic-heavy code, pure transformations, edge cases |
| Integration | Verify modules work together correctly | Medium | Database queries, service interactions, middleware chains |
| End-to-end | Verify user-visible behavior through the full stack | Slow | Critical user flows, smoke tests before release |
| Contract | Verify API shape between producer and consumer | Fast | Service boundaries, public APIs, shared schemas |
| Snapshot | Detect unintended output changes | Fast | Serialized output, rendered UI, generated config |
| Property-based | Verify invariants hold across random inputs | Medium | Parsers, serializers, math, encoding/decoding roundtrips |

## Test selection by change type

| Change | Required tests |
|---|---|
| Bug fix | Regression test that fails before the fix, passes after |
| New feature | Happy path + edge cases + at least one error path |
| Refactor | All existing tests must pass unchanged; no new tests needed unless coverage was missing |
| API change | Contract tests for new shape; integration tests for consumers |
| Performance fix | Benchmark before/after; existing correctness tests still pass |
| Dependency upgrade | Existing integration + e2e tests pass; spot-check breaking changelog items |
| Config change | Integration test proving the new config is read and applied |

## Test pyramid

Invest coverage based on risk, not uniformity.

```
        /  E2E  \          Few — critical user flows only
       /----------\
      / Integration \       Moderate — boundaries, I/O, service calls
     /----------------\
    /      Unit        \    Many — logic, transformations, edge cases
   /____________________\
```

**High-risk paths deserve more coverage at every layer:**
- Money handling, billing, payments
- Authentication and authorization
- Data mutation (writes, deletes, migrations)
- User-facing error paths
- Concurrency and shared state

**Low-risk paths need less:**
- Read-only display logic
- Internal admin tooling
- Feature-flagged experimental code

## What NOT to test

- **Implementation details**: don't assert that a private helper was called; assert the output.
- **Trivial getters/setters**: if a function just returns a field, the test adds noise.
- **Framework behavior**: don't test that your ORM generates SQL or your router dispatches routes.
- **Third-party library internals**: trust the library's own tests.
- **Exact error messages**: test error type/category, not string content (unless user-facing).

## When to write tests before vs after

**Write tests first (TDD-style) when:**
- The behavior is well-defined before implementation
- You are fixing a bug (write the failing test, then fix)
- You are implementing a contract or interface
- The code is purely algorithmic

**Write tests after when:**
- You are exploring a design and the interface is unstable
- The implementation is a spike or prototype
- You are working with unfamiliar code and need to understand it first

**In either case:** tests must exist before the change is considered complete.

## Test quality checklist

- [ ] **Independent**: no test depends on another test's state or ordering
- [ ] **Deterministic**: same result every run; no flaky time/network/random dependencies
- [ ] **Fast**: unit tests < 100ms each; slow tests are tagged and can be skipped
- [ ] **Readable**: test name describes the scenario; arrange-act-assert structure
- [ ] **Tests behavior, not implementation**: survives internal refactoring
- [ ] **Single reason to fail**: one logical assertion per test (multiple asserts on the same value are fine)
- [ ] **Cleans up after itself**: no leaked files, ports, processes, database rows

## Mocking guidance

**Mock at boundaries:**
- External HTTP services
- Databases (for unit tests; use a real DB for integration tests)
- File system I/O
- System clock / timers
- Third-party SDK calls

**Do NOT mock:**
- Internal modules in the same package
- Data structures or value objects
- The code under test itself
- Layers you own and can run cheaply

**Mock hygiene:**
- Verify mocks match the real interface (use contract tests or type checking)
- Prefer fakes (in-memory implementations) over stubs for complex behavior
- If you need more than 3 mocks in a test, the design may have too many dependencies

## Coverage priorities

Rank paths by blast radius, not by line count:

1. **Money / billing**: every path that creates, modifies, or deletes financial records
2. **Auth / permissions**: login, token validation, role checks, data access boundaries
3. **Data mutation**: writes, deletes, cascading updates, migration logic
4. **User-facing errors**: what the user sees when things break
5. **Concurrency**: shared state, race conditions, distributed locks
6. **Happy paths**: the main success scenarios for core features
7. **Edge cases**: boundary values, empty inputs, max-length inputs
8. **Configuration**: environment-specific behavior, feature flags
