# Software Engineering Principles

General principles that govern implementation decisions. When
principles conflict, higher-priority principles win.

---

## Priority Order

1. **Correctness** — the code does what it claims.
2. **Simplicity** — the simplest correct solution is the best one.
3. **Readability** — code is read far more than written.
4. **Maintainability** — the next person can change it safely.
5. **Performance** — only after the above are satisfied.

## KISS — Keep It Simple

Every line of code is a liability. The simplest solution that
correctly solves the problem is the best solution.

**Applies when:**
- Choosing between two correct approaches — pick the shorter one.
- Designing an API — fewer parameters, fewer options.
- Structuring code — flat beats nested, concrete beats abstract.

**Does NOT mean:**
- Skip error handling. Simple code still handles real failure modes.
- Avoid all abstraction. Abstraction that removes a real source of
  bugs or confusion is simplification, not complexity.

## SOLID

### Single Responsibility Principle (SRP)

A module should have one reason to change. If a class handles both
HTTP parsing and business logic, a change to the wire format forces
a change to the business layer.

**Test:** can you describe what the module does without using "and"?

### Open/Closed Principle (OCP)

Modules should be open for extension, closed for modification. Add
new behavior by adding new code (a new implementation, a new case),
not by editing existing working code.

**Applies when:** the extension point is real and expected (plugin
systems, strategy patterns). Does NOT mean every function needs an
extension hook — that is speculative abstraction.

### Liskov Substitution Principle (LSP)

Subtypes must be substitutable for their base types without breaking
correctness. A `Square` that inherits from `Rectangle` but breaks
when you set width independently violates LSP.

**Test:** does every method in the subtype honor the contracts
(preconditions, postconditions, invariants) of the base type?

### Interface Segregation Principle (ISP)

Clients should not depend on methods they do not use. A large
interface forces implementers to provide stubs for unused methods.

**Fix:** split large interfaces into small, focused ones. Prefer
several 1-2 method interfaces over one 10-method interface.

### Dependency Inversion Principle (DIP)

High-level modules should not depend on low-level modules. Both
should depend on abstractions.

**In practice:** a service depends on a repository interface, not
on a specific database client. The database client implements the
interface. Swapping databases changes one file, not twenty.

**Over-application:** don't invert dependencies that will never
change. A CLI tool that only ever reads files does not need a
`FileSystem` interface.

## DRY — Don't Repeat Yourself

Every piece of knowledge should have a single authoritative
representation.

**Rule of Three:** tolerate duplication until you see it three
times. The first two occurrences might not actually be the same
concept — they just look similar now. By the third, the pattern
is real.

**DRY applies to knowledge, not code.** Two functions that happen
to have similar structure but represent different domain concepts
are not duplication. Forcing them into a shared abstraction couples
unrelated concerns.

**When repetition is better:**
- The "duplicated" code serves different domains that change
  independently.
- The shared abstraction would be more complex than the repetition.
- Removing duplication requires adding parameters, flags, or mode
  switches that make the code harder to follow.

## YAGNI — You Aren't Gonna Need It

Do not build for requirements that do not exist yet.

- No plugin systems without plugins.
- No configuration for values that never change.
- No generic solutions to problems that exist once.
- No "what if we need to support X later" — when X arrives, the
  context will be clearer and the solution will be better.

**The cost of YAGNI violations:** unused code still needs to be
read, tested, maintained, and navigated. It increases cognitive
load for every future reader.

## Law of Demeter

A method should only call methods on:
- `this` / `self`
- its parameters
- objects it creates
- its direct component objects

**Violation:** `order.getCustomer().getAddress().getCity()` — this
chains through three objects, coupling the caller to the internal
structure of `Order`, `Customer`, and `Address`.

**Fix:** `order.getShippingCity()` — the `Order` knows how to get
the city. Callers don't know or care about the internal structure.

**Pragmatic exception:** data transfer objects, configuration
objects, and builder patterns often deliberately expose chained
access. The Law of Demeter applies to behavior, not to data
containers.

## Separation of Concerns

Each module handles one concern. Mixing concerns means a change in
one area forces changes in unrelated areas.

**Common violations:**
- Business logic in HTTP handlers.
- SQL queries in UI rendering code.
- Logging interleaved with core algorithm.
- Validation mixed with transformation.

**Fix:** separate by responsibility boundary, not by technical
layer. A "services" directory full of 2000-line files is not
separation of concerns.

## Composition over Inheritance

Prefer composing objects from smaller parts over building deep
inheritance hierarchies.

**Inheritance problems:**
- Tight coupling between parent and child.
- Fragile base class: changing the parent breaks children.
- Combinatorial explosion when multiple axes of variation exist.

**Composition advantages:**
- Swap behavior at runtime.
- Combine behaviors without combinatorial explosion.
- Test components independently.

**When inheritance is appropriate:** true "is-a" relationships with
shared behavior, and only when the hierarchy is shallow (1-2 levels).

## Fail Fast

Detect and report errors at the earliest possible point.

- Validate inputs at system boundaries.
- Throw/return errors immediately when invariants are violated.
- Don't return default values that hide failures.
- Don't silently continue with corrupted state.

**Corollary:** fail loudly. A silent failure that corrupts data is
worse than a crash that preserves data.

## Principle of Least Surprise

Code should behave the way a competent reader would expect from
reading the name and signature.

**Violations:**
- A function called `getUser()` that modifies the database.
- A method called `validate()` that also transforms the input.
- A boolean parameter that inverts the function's behavior.
- A constructor with side effects.

**Fix:** names must match behavior. If a function does two things,
either split it or name it honestly.

## Command-Query Separation (CQS)

A method should either change state (command) or return a value
(query), not both.

**Commands:** `user.setName("Alice")` — changes state, returns void.
**Queries:** `user.getName()` — returns data, changes nothing.

**Pragmatic exceptions:** `stack.pop()` (returns and removes) is
acceptable when the combined operation is atomic and the alternative
is error-prone. Builder patterns also commonly violate CQS for
fluency.

## Applying Principles

Principles are heuristics, not laws. They conflict. When they do:

| Conflict | Resolution |
|---|---|
| DRY vs KISS | If the abstraction is more complex than the duplication, keep the duplication |
| SOLID vs YAGNI | Don't create interfaces for hypothetical future implementations |
| OCP vs simplicity | Don't add extension points until an extension exists |
| DIP vs pragmatism | Don't invert dependencies that will never change |
| DRY vs separation of concerns | Don't couple unrelated domains to eliminate superficial duplication |

The goal is working, maintainable software — not principle compliance.
