# Python Practices

Follow `pyproject.toml`, configured tools, supported Python versions, and nearby
code before this primer.

## Idiomatic Defaults

- Compose small functions and plain data structures; introduce classes for
  stateful behavior or established domain models.
- Preserve the repository's exception model. Raise specific exceptions and
  chain translated errors with `from`.
- Use context managers for files, locks, transactions, and temporary resources.
- Match the existing async model; do not mix blocking I/O into an event loop.
- Add type annotations at public boundaries and where they clarify non-obvious
  shapes. Reuse project aliases and models.

## Codex Bloat Traps

- A class with one stateless method.
- A generic repository, factory, or protocol with one implementation.
- A configuration object for fixed local values.
- Catching `Exception` to manufacture fallback behavior.
- Splitting a short linear operation across many private methods.

## Avoid / Prefer

```python
# Avoid: a wrapper with no policy.
def get_user(client, user_id):
    return client.get_user(user_id)

# Prefer: call the established API directly.
user = client.get_user(user_id)
```

```python
# Avoid: manual cleanup.
handle = path.open()
data = handle.read()
handle.close()

# Prefer: explicit resource lifetime.
with path.open() as handle:
    data = handle.read()
```

## Native Checks

Use commands configured by the repository, commonly through `uv`, `tox`,
`nox`, or project scripts. Typical tools are `ruff format`, `ruff check`,
`mypy` or `pyright`, and `pytest`; do not introduce them when absent.
