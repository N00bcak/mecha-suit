# C and C++ Practices

Follow the build system, language standard, compiler flags, ownership style,
and nearby code before this primer. Do not import modern C++ patterns into C or
into a repository that intentionally targets an older standard.

## Idiomatic Defaults

- In C, make ownership and cleanup paths explicit. In C++, prefer RAII and
  value semantics consistent with the codebase.
- Preserve the local error model: status codes, result types, exceptions, or
  error objects.
- Pair every acquisition with an obvious release on every path.
- Use established synchronization primitives and document shared-state
  ownership.
- Prefer the narrowest type that expresses the API contract without clever
  template machinery or unsafe casts.

## Codex Bloat Traps

- C++ class hierarchies for one implementation.
- Template generalization used at one call site.
- Smart-pointer conversion without understanding existing ownership.
- New threading for work that is naturally sequential.
- Compatibility macros or build options for unsupported hypothetical targets.

## Avoid / Prefer

```cpp
// Avoid: owning raw allocation with manual exit paths.
Widget* widget = new Widget(config);
use(*widget);
delete widget;

// Prefer when consistent with the project:
Widget widget(config);
use(widget);
```

```c
resource = acquire();
if (resource == NULL) {
    return ERROR;
}
/* Keep cleanup visible on every exit path. */
release(resource);
```

## Native Checks

Use the repository's CMake, Meson, Make, Bazel, or project scripts and pinned
compiler flags. Run its formatter, static analyzer, sanitizers, and tests when
configured; do not invent a parallel toolchain.
