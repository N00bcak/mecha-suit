# Java and JVM Practices

Follow the Gradle or Maven configuration, target JVM, framework conventions,
and nearby code before this primer.

## Idiomatic Defaults

- Prefer existing framework composition and plain objects; add interfaces at
  real module or substitution boundaries.
- Preserve checked/unchecked exception and result conventions. Translate
  exceptions only when adding useful domain context.
- Use try-with-resources for closeable resources and established transaction
  scopes.
- Use the repository's executor, coroutine, reactive, or structured concurrency
  model; do not mix models casually.
- Reuse records, sealed types, nullability annotations, and collection
  conventions supported by the pinned toolchain.

## Codex Bloat Traps

- Interface/implementation pairs with one implementation and no boundary.
- Builder and factory layers for simple construction.
- DTO duplication that merely renames identical fields.
- New executor pools without lifecycle ownership.
- Framework or language features unsupported by the configured target.

## Avoid / Prefer

```java
// Avoid: wrapper adds no policy.
User findUser(String id) {
    return repository.findUser(id);
}

// Prefer: call the established boundary directly.
User user = repository.findUser(id);
```

```java
try (InputStream input = Files.newInputStream(path)) {
    return parser.parse(input);
}
```

## Native Checks

Use the repository wrapper and configured tasks, commonly `./gradlew check` or
`./mvnw test`, plus narrower formatter, static-analysis, and test tasks where
available. Do not use a system Gradle or Maven when a wrapper is committed.
