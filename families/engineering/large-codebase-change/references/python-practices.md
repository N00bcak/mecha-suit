# Python Practices

Reference for writing correct, idiomatic, and maintainable Python in large codebases.

---

## Language Philosophy

Python's Zen: "There should be one -- and preferably only one --
obvious way to do it."

- **Explicit over implicit.** No magic. Name things clearly. Pass
  dependencies explicitly rather than relying on global state.
- **EAFP over LBYL.** "Easier to Ask Forgiveness than Permission" —
  use `try`/`except` rather than pre-checking conditions, when the
  exception case is genuinely rare.
- **Duck typing with guardrails.** If it walks like a duck, treat it
  like a duck. Use `Protocol` and `ABC` when the contract matters
  for safety, not for ceremony.
- **Flat over nested.** Shallow module structures. Shallow inheritance.
  If you are nesting more than 3 levels, restructure.
- **Readability counts.** Code is read far more than written. A clear
  10-line function beats a clever 3-line one-liner.

## Type hints

- Annotate all public function signatures. Annotate private functions when the types are non-obvious.
- Run `mypy --strict` when the project supports it. At minimum enable `--warn-return-any` and `--disallow-untyped-defs`.
- Use `X | None` (Python 3.10+) over `Optional[X]`. Use `from __future__ import annotations` on 3.9 to get the same syntax.
- Use `TypeAlias` for complex union types. Use `TypeVar` for generic functions. Use `Protocol` for structural subtyping instead of ABCs when possible.
- `cast()` is a lie to the type checker. Use it only when you have verified the type by other means. Prefer `isinstance` guards.

## Common pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| Mutable default argument | `def f(items=[])` shares one list across all calls | Use `items: list | None = None` and assign inside |
| Late binding closures | `[lambda: i for i in range(3)]` all return 2 | Bind with default arg: `lambda i=i: i` |
| `is` vs `==` | `is` compares identity, not value; CPython interns small ints but this is not guaranteed | Use `==` for value comparison; `is` only for `None`, `True`, `False` |
| Shallow copy | `list(x)`, `x.copy()`, `x[:]` copy top-level only; nested mutables are shared | Use `copy.deepcopy()` when nested structures must be independent |
| Float comparison | `0.1 + 0.2 != 0.3` | Use `math.isclose()` or `decimal.Decimal` for financial math |
| `str.startswith` / `endswith` | Forgetting these accept tuples | `s.startswith(('.py', '.pyi'))` works, no need for `or` chains |

## Correctness traps

- **Bare `except` or `except Exception`**: swallows `KeyboardInterrupt`, `SystemExit`, or real bugs. Catch the narrowest exception you can handle. Log or re-raise everything else.
- **Context managers missing `__exit__`**: if you implement `__enter__` without a correct `__exit__`, resources leak on exceptions. Use `contextlib.contextmanager` for simple cases.
- **Modifying a list while iterating**: `for x in items: items.remove(x)` skips elements. Iterate over a copy or build a new list.
- **Dict ordering**: guaranteed insertion-order from Python 3.7+. If you must support 3.6, use `collections.OrderedDict`.
- **`datetime.now()` without timezone**: returns naive datetime. Use `datetime.now(timezone.utc)` or `datetime.now(tz=ZoneInfo("..."))`.
- **`re.match` vs `re.search`**: `match` anchors at the start of the string only. Use `search` for substring matching.
- **Integer division**: `//` truncates toward negative infinity, not toward zero. `-7 // 2 == -4`, not `-3`.

## Asymptotic gotchas

| Operation | Naive cost | Fix |
|---|---|---|
| `x in list` | O(n) | Use a `set` or `frozenset` for membership checks |
| String concatenation in loop | O(n^2) total from repeated allocation | Collect in list, then `''.join(parts)` |
| `pandas` `.iterrows()` | Row-by-row Python overhead, defeats vectorization | Use vectorized operations, `.apply()` as last resort |
| Repeated `df.append()` | Copies entire DataFrame each time, O(n^2) | Collect rows in a list, then `pd.concat()` once |
| `dict.values()` in comprehension | Creates a view object each time if called repeatedly | Assign to a variable outside the loop |
| Nested `for` with `if x in list` | O(n*m) | Convert the inner collection to a set first |
| `sorted()` inside a loop | O(n log n) per iteration | Sort once outside the loop if the data does not change |

## Error handling

- Exceptions are for exceptional conditions. Do not use `try/except` for normal control flow (e.g., checking dict keys — use `.get()` or `in`).
- `EAFP` (try/except) vs `LBYL` (check first): prefer EAFP when the check itself is expensive or racy (e.g., file existence). Prefer LBYL when failure is common and the check is cheap.
- Define custom exception classes when callers need to distinguish error types. Inherit from a project-level base exception.
- Always include context in error messages: what operation failed, on what input, why.
- Use `raise ... from err` to preserve the original traceback in exception chaining.

## Testing

- Use `pytest` over `unittest`. Prefer plain `assert` statements over `self.assertEqual`.
- Use `@pytest.fixture` for setup/teardown. Use `conftest.py` for shared fixtures. Keep fixtures close to the tests that use them.
- Use `@pytest.mark.parametrize` for combinatorial input testing. Keep parameter lists readable.
- Mock at boundaries: external HTTP, databases, file I/O, system clock. Do not mock internal modules.
- Use `unittest.mock.patch` to replace dependencies at the point of import in the module under test, not where they are defined.
- Use `tmp_path` fixture for file system tests. Use `monkeypatch` for environment variables.
- Mark slow tests with `@pytest.mark.slow` and exclude them from fast feedback loops.

## Concurrency

| Model | Use when | Watch out for |
|---|---|---|
| `asyncio` | I/O-bound work with many concurrent connections | Cannot use blocking calls in coroutines; use `run_in_executor` for blocking I/O |
| `threading` | I/O-bound work in sync codebases, legacy code | GIL prevents true parallelism for CPU work; beware shared mutable state |
| `multiprocessing` | CPU-bound work needing true parallelism | Serialization cost for passing data; no shared memory by default |
| `concurrent.futures` | Simple fan-out for either I/O or CPU tasks | Use `ThreadPoolExecutor` for I/O, `ProcessPoolExecutor` for CPU |

- GIL: only one thread executes Python bytecode at a time. Threads still help for I/O because the GIL is released during blocking system calls.
- Always use `asyncio.run()` as the top-level entry point. Do not nest event loops.
- Use `asyncio.TaskGroup` (3.11+) or `asyncio.gather()` with `return_exceptions=True` to avoid lost exceptions.
- Never share mutable state between threads without a lock. `queue.Queue` is thread-safe and preferred for producer-consumer patterns.
- `multiprocessing` data must be picklable. Prefer `multiprocessing.Queue` or `shared_memory` over `Manager` for performance.

## Packaging

- Use `pyproject.toml` as the single source of project metadata. Avoid `setup.py` / `setup.cfg` for new projects.
- Pin exact dependency versions in lock files (`pip-compile`, `poetry.lock`, `uv.lock`). Use ranges only in library `pyproject.toml`.
- Always use virtual environments. Never install project dependencies into the system Python.
- Prefer `uv` or `pip-compile` for reproducible installs.
- Use `__all__` in `__init__.py` to define the public API of a package.
- Keep `src/` layout for applications (`src/mypackage/`). Flat layout is acceptable for small libraries.

## Dangerous patterns

| Pattern | Risk | Alternative |
|---|---|---|
| `eval()` / `exec()` | Arbitrary code execution | `ast.literal_eval()` for data; structured parsing for logic |
| `pickle` with untrusted data | Arbitrary code execution on deserialization | `json`, `msgpack`, or protobuf with explicit schemas |
| `os.system()` | Shell injection, no error capture | `subprocess.run([...], check=True)` with list args |
| `yaml.load()` without `Loader` | Arbitrary code execution | `yaml.safe_load()` always |
| `__del__` for cleanup | Non-deterministic; may not run | Context managers or `atexit` |
| Global mutable state | Hidden coupling, test pollution | Pass state explicitly; use dependency injection |
| `from module import *` | Namespace pollution, name collisions | Import specific names or use qualified access |
