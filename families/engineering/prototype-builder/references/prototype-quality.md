# Prototype Quality

Reference for calibrating what a prototype needs, what it doesn't, and when to harden.

---

## What a prototype MUST have

These are non-negotiable. A prototype without these is a broken experiment, not a prototype.

- [ ] **Working core behavior**: the main thing it demonstrates actually works
- [ ] **Run instructions**: someone else can start it in under 2 minutes (README, `--help`, or top-of-file comment)
- [ ] **Clear scope of what's deferred**: explicit list of known gaps and shortcuts (inline comments, a `TODO` section, or a "Limitations" heading)

## What a prototype SHOULD have

These make the prototype usable rather than merely runnable.

- [ ] **Basic error handling for common inputs**: bad file path, missing argument, malformed input get a human-readable message instead of a stack trace
- [ ] **Reasonable defaults**: runs without a config file; sensible values for optional parameters
- [ ] **Clean entry point**: one obvious way to start it (`main.py`, `cli.sh`, `npm start`)
- [ ] **Minimal dependency list**: only what is actually used; no "might need this later" packages

## What a prototype should NOT have

Adding these to a prototype wastes time and creates false confidence about production-readiness.

| Don't add | Why |
|---|---|
| Auth/login system | Unless auth IS the prototype's core behavior |
| Logging framework | `print` / `console.log` with a prefix is fine |
| Config management system | Environment variables or CLI args are enough |
| CI/CD pipeline | You are the CI; run it yourself |
| Comprehensive test suite | One or two smoke tests at most |
| Database migrations | Use a simple schema setup script or in-memory store |
| Deployment scripts | It runs on your machine; that's the point |
| Abstraction layers | No interfaces "for future flexibility" |
| Monitoring / alerting | You are the monitor |
| API documentation | The code is small enough to read |

## Quality bar by prototype type

### CLI tool

- [ ] Runs from command line with a single command
- [ ] `--help` flag prints usage
- [ ] Bad input produces a readable error message, not a traceback
- [ ] Exit code 0 on success, non-zero on failure
- [ ] Works with relative and absolute file paths (if file-based)

```bash
# Minimum viable --help
Usage: toolname [options] <input>

Options:
  --output, -o    Output file (default: stdout)
  --verbose, -v   Print debug info
  --help, -h      Show this message
```

### Web app

- [ ] `npm start` / `python app.py` / equivalent starts the server
- [ ] Core page loads and works in a browser
- [ ] Form submissions and button clicks do the core thing
- [ ] Server errors return a message, not a blank page or hung request
- [ ] Port is configurable or prints the URL on startup

### Data pipeline

- [ ] Reads input from a file or stdin
- [ ] Transforms and writes output to a file or stdout
- [ ] Fails visibly on malformed input with a message identifying the problem
- [ ] Handles empty input without crashing
- [ ] Prints a summary on completion (rows processed, errors skipped)

### Library / SDK

- [ ] Importable without side effects
- [ ] Core function works as documented
- [ ] Has one usage example (in README, docstring, or `examples/` file)
- [ ] Type hints or signatures are present for public functions
- [ ] Raises clear exceptions on invalid input (not `KeyError` on an internal dict)

## When to harden

A prototype becomes production code when any of these happen:

- Other people start depending on it
- It handles real user data
- Downtime or bugs have consequences beyond "try again"
- You are adding features faster than you are adding safety

**When that happens:** hand off to `large-codebase-change` patterns. Specifically:

1. Add tests for existing behavior (characterization tests)
2. Add error handling for edge cases
3. Replace in-memory stores with persistent storage
4. Add input validation
5. Set up CI
6. Remove or resolve every `TODO` and `HACK` comment

**Do not** try to harden incrementally inside the prototype mindset. Switch modes explicitly.

## Intentional technical debt

Every shortcut must be visible. The rule is: **document it, don't hide it.**

### Acceptable

```python
# TODO: This uses an in-memory dict. Data is lost on restart.
store = {}

# HACK: Hardcoded to localhost. Pass via env var for real use.
API_URL = "http://localhost:8080"

# NOTE: No pagination. Will break above ~1000 items.
results = fetch_all(query)
```

### Not acceptable

```python
# Silently drops records that fail validation
for record in records:
    try:
        process(record)
    except Exception:
        pass  # Silent data loss

# Returns stale data without indicating it
def get_price(item):
    if item in cache:
        return cache[item]  # Could be hours old, caller has no idea
    ...
```

**The test:** if someone unfamiliar with the code runs the prototype and gets wrong results, will they know why? If the answer is no, the shortcut is hidden, not intentional.

## Prototype lifecycle decision tree

```
Is the core idea validated?
├── No  → Keep iterating on the prototype
└── Yes
    ├── Is anyone depending on it?
    │   ├── Yes → Harden immediately (you're already late)
    │   └── No
    │       ├── Will it be used again? → Plan hardening before next use
    │       └── One-time exploration? → Archive it with a note and move on
    └── Did the idea fail?
        → Delete the prototype. Dead prototypes that linger become zombie dependencies.
```
