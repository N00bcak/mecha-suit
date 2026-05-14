# Java/JVM Practices

## Language Philosophy

Java prioritizes readability, stability, and long-term
maintainability.

- **Program to an interface, not an implementation.** Depend on
  `List`, not `ArrayList`. This allows substitution without changing
  callers.
- **Favor composition over inheritance.** Inheritance creates tight
  coupling. Use composition and delegation unless the relationship
  is genuinely "is-a" with shared behavior.
- **Immutability by default.** Make fields `final`, collections
  unmodifiable, and objects immutable unless mutation is required.
  Immutable objects are thread-safe, predictable, and easier to
  reason about.
- **Exceptions for exceptional conditions.** Don't use exceptions for
  control flow. Don't catch `Exception` or `Throwable` broadly.
  Throw specific exceptions with context.
- **Minimize mutability and scope.** Declare variables at the point
  of use. Prefer local over field, `private` over `public`. Reduce
  the surface area others depend on.

## Type Safety

- **Never use raw types.** `List` is a code smell; use `List<String>`.
- **Bounded wildcards:** `<? extends T>` for producers (read-only), `<? super T>` for consumers (write-only). Mnemonic: PECS (Producer Extends, Consumer Super).
- **`Optional` usage:** return type for nullable results. Never use as a field type, method parameter, or in collections.
- **Sealed classes (Java 17+):** use for closed hierarchies where the set of subtypes is known at compile time. Enables exhaustive pattern matching.

```java
// Good: bounded wildcard
public double sum(List<? extends Number> numbers) { ... }

// Good: Optional as return type
public Optional<User> findById(long id) { ... }

// Bad: Optional as parameter
public void process(Optional<String> name) { ... }  // just use @Nullable or overload
```

## Common Pitfalls

| Pitfall | What goes wrong | Fix |
|---|---|---|
| `==` on objects | Compares references, not values | Use `.equals()` for value comparison |
| `equals` without `hashCode` | HashMap/HashSet behavior breaks | Always override both together |
| Autoboxing null | `Integer x = null; int y = x;` throws NPE | Null-check before unboxing |
| Modifying collection during iteration | `ConcurrentModificationException` | Use `Iterator.remove()`, `removeIf()`, or copy |
| `String.format` locale | Uses default locale, numbers format differently | Specify `Locale.US` or `Locale.ROOT` for machine-readable output |
| Mutable date/calendar | `Date` and `Calendar` are mutable, shared references mutate | Use `java.time` API (immutable) |
| `substring` memory | Pre-Java 7u6: substring holds reference to original char[] | Use modern JDK, or `new String(s.substring(...))` |
| Checked exception in lambda | Won't compile in `Function<T,R>` | Wrap in unchecked, or use library functional interfaces |

## Correctness Traps

- **Financial math:** never use `double` or `float`. Use `BigDecimal` with explicit scale and rounding mode.
- **`compareTo` consistency:** if `a.compareTo(b) == 0`, then `a.equals(b)` should be true. `TreeSet` and `TreeMap` rely on this.
- **`DateTimeFormatter` thread safety:** `DateTimeFormatter` is thread-safe (immutable). `SimpleDateFormat` is NOT. Never share `SimpleDateFormat` across threads.
- **`Closeable` resources:** any `Closeable`/`AutoCloseable` must be in a try-with-resources block or explicitly managed.
- **`hashCode` stability:** if a mutable field is used in `hashCode`, putting the object in a `HashSet` then mutating the field makes it unfindable.

```java
// Correct: try-with-resources
try (var conn = dataSource.getConnection();
     var stmt = conn.prepareStatement(sql);
     var rs = stmt.executeQuery()) {
    while (rs.next()) { ... }
}
// All three resources closed in reverse order, even on exception
```

## Resource Management

| Resource | Pattern |
|---|---|
| Streams, connections, readers | try-with-resources |
| Database connections | Connection pool (HikariCP) |
| Thread pools | `ExecutorService` with explicit shutdown |
| Temporary files | `Files.createTempFile` + try-with-resources or delete-on-exit |
| Locks | `try { lock.lock(); ... } finally { lock.unlock(); }` |

**Never rely on finalizers or `Object.finalize()`.** It is deprecated (Java 9+) and unreliable. Use `Cleaner` only as a safety net, not as primary cleanup.

## Concurrency

| Need | Use | Avoid |
|---|---|---|
| Thread-safe map | `ConcurrentHashMap` | `Collections.synchronizedMap` (coarse locking) |
| Atomic counter | `AtomicLong`, `LongAdder` (high contention) | `synchronized` block around `long++` |
| Async composition | `CompletableFuture` | Raw `Thread` + shared mutable state |
| Lightweight concurrency (Java 21+) | Virtual threads (`Thread.ofVirtual()`) | Platform threads for I/O-bound work |
| Visibility without atomicity | `volatile` | Nothing (bare field access across threads is a race) |
| Publish immutable object | `volatile` or `final` field | Non-volatile, non-final field (may see partial construction) |

```java
// CompletableFuture composition
CompletableFuture<Order> order = fetchOrder(id);
CompletableFuture<User> user = fetchUser(userId);

order.thenCombine(user, (o, u) -> enrichOrder(o, u))
     .thenAccept(this::save)
     .exceptionally(ex -> { log.error("failed", ex); return null; });
```

**Critical rules:**
- Never synchronize on a public object, a `String` literal, or a boxed primitive.
- `ConcurrentHashMap.putIfAbsent` is atomic; `get`-then-`put` is not.
- `volatile` guarantees visibility, not atomicity. `count++` on a volatile field is still a race.

## Asymptotic Considerations

| Operation | Cost | Alternative |
|---|---|---|
| `ArrayList.add(0, x)` | O(n) shift | `ArrayDeque` for queue behavior |
| `LinkedList` random access | O(n) | `ArrayList` (cache-friendly, O(1) indexed access) |
| `HashMap` vs `TreeMap` | O(1) vs O(log n) lookup | Use `HashMap` unless sorted order is needed |
| String concat in loop with `+` | O(n^2) total (creates new String each iteration) | `StringBuilder` |
| `Stream` operations | Lazy until terminal op | Don't create a stream just to call `.count()` on a collection |
| `List.contains` | O(n) | `Set.contains` O(1) for frequent membership checks |

## Error Handling

### Exception hierarchy

| Type | When to use | Example |
|---|---|---|
| Unchecked (`RuntimeException`) | Programming errors, unrecoverable | `IllegalArgumentException`, `NullPointerException` |
| Checked (`Exception`) | Recoverable conditions the caller must handle | `IOException`, custom business exceptions |
| `Error` | JVM-level failures | Never catch `Error` or `Throwable` in application code |

### Rules

- **Throw early, catch late.** Validate inputs at entry points. Handle exceptions at the level that can actually recover.
- **Never swallow exceptions.** `catch (Exception e) { }` hides bugs. At minimum, log.
- **Don't use exceptions for flow control.** Exceptions are for exceptional conditions, not expected branching.
- **Catch the narrowest type.** `catch (IOException e)` not `catch (Exception e)`.
- **Wrap, don't discard cause.** `throw new ServiceException("msg", cause)` preserves the stack trace.

## Testing

### JUnit 5 conventions

```java
@Test
void shouldRejectNegativeAmount() {
    assertThrows(IllegalArgumentException.class,
        () -> account.withdraw(-100));
}

@ParameterizedTest
@CsvSource({"1,1,2", "0,0,0", "-1,1,0"})
void shouldAdd(int a, int b, int expected) {
    assertEquals(expected, calculator.add(a, b));
}
```

| Practice | Detail |
|---|---|
| Test naming | `shouldDoXWhenY` or `givenX_whenY_thenZ` |
| Mockito | Mock external dependencies, not the class under test |
| Don't mock types you don't own | Wrap third-party APIs behind your own interface, mock that |
| Testcontainers | Real database/Redis/Kafka in integration tests via Docker |
| Assertions | Use AssertJ for fluent, readable assertions |
| Coverage | Measure, but don't chase 100%. Focus on business logic and edge cases. |

## Build and Dependency Management

### Maven / Gradle

| Concern | Guidance |
|---|---|
| Dependency convergence | Enforce with Maven enforcer plugin or Gradle `failOnVersionConflict()` |
| Transitive conflicts | Use `dependencyManagement` (Maven) or platform/BOM (Gradle) |
| Fat jars | Use `maven-shade-plugin` or `shadowJar` carefully. Relocate packages to avoid classpath conflicts. |
| Reproducible builds | Pin all dependency versions. Avoid `LATEST`/`RELEASE`/`+` ranges. |
| Multi-module | Declare shared dependency versions in parent POM or Gradle `libs.versions.toml`. |

### Key build checks for CI

```bash
# Maven
mvn verify -B -Dmaven.test.failure.ignore=false

# Gradle
./gradlew check --no-daemon
```

- Run `spotbugs`/`errorprone` in CI for static analysis.
- Run `dependency-check` for known CVEs in dependencies.
