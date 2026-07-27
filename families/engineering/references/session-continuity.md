# Session Continuity Protocol

## SCRATCHPAD.md Format

The scratchpad is the single source of truth for multi-session work. It lives at the repository root (or a designated project subdirectory) and follows this structure:

```markdown
# Scratchpad — <short task name>

## Goal
<1-2 sentence statement of the end state>

## Status
<one of: NOT STARTED | IN PROGRESS | BLOCKED | DONE>

## Completed
- <concrete outcome, not intent — e.g. "added retry logic to api/client.go" not "worked on retry">
- <each entry references a file path or commit when possible>

## Current State
- <what exists right now — files changed, branches, test results>
- <any partial work: half-written functions, skipped tests, temp hacks>

## Next Step
<the single most important action to take next — specific enough to start immediately>

## Open Questions
- <genuine unknowns that affect the plan>
- <decisions deferred with rationale>

## Context
- <branch name, relevant PRs, upstream dependencies>
- <commands to reproduce current state: build, test, run>
```

Every section is mandatory. Empty sections get `None` — never omit the heading.

## When to Create vs Resume

| Situation | Action |
|---|---|
| No SCRATCHPAD.md exists | Create one only when the task warrants durable planning or handoff state |
| SCRATCHPAD.md exists, same task | Resume: verify state first (see below) |
| SCRATCHPAD.md exists, different task | Archive old one (`SCRATCHPAD-<date>.md`), create new |
| SCRATCHPAD.md exists, task is DONE | Archive, create new if starting fresh work |

## Verification Protocol

On every session start, before trusting the scratchpad:

1. **Files exist.** Check that files listed under Completed and Current State actually exist at the stated paths.
2. **Git state matches.** Run `git status`, `git log --oneline -5`, `git branch`. Confirm branch, recent commits, and working tree match the scratchpad.
3. **Tests pass.** Run the test command listed under Context. If it fails, the scratchpad is stale — update Current State before proceeding.
4. **No conflicting changes.** Check `git diff` for uncommitted work not mentioned in the scratchpad.

If any check fails, update the scratchpad to reflect reality before doing new work.

```bash
# Minimal verification sequence
test -f SCRATCHPAD.md && echo "scratchpad exists" || echo "no scratchpad"
git status --short
git log --oneline -5
git branch --show-current
# then run project-specific test command from Context section
```

## Update Cadence

Update the scratchpad:

- **Before first change** — verify and correct stale entries.
- **After completing a logical unit** — a function, a passing test, a refactor step. Not after every line.
- **Before any commit** — ensure Completed and Current State reflect what you are about to commit.
- **Before ending a session** — mandatory (see Session Handoff below).
- **When the plan changes** — if Next Step changes, update immediately so it is never wrong.

Do not update the scratchpad continuously. Batch updates at natural breakpoints.

## Session Handoff

Before ending a session, the scratchpad must contain:

1. **Completed** — everything done this session, with file paths.
2. **Current State** — accurate description of where things stand, including any failing tests or partial work.
3. **Next Step** — concrete and actionable. A new session should be able to start executing within 1-2 minutes of reading it.
4. **Open Questions** — anything discovered but not resolved.
5. **Context** — updated commands if they changed (new env vars, new test flags, etc.).

The handoff test: could a different agent, with no memory of this session, read the scratchpad and continue effectively? If not, add detail.

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Stale scratchpad | Claims files or state that no longer exist | Always verify on resume |
| No next step | Session ends with "continue work" or blank Next Step | Write a specific action: "add error handling to `parse()` in `src/parser.rs`" |
| Intent without state | "Working on auth refactor" — says what you planned, not what exists | Describe concrete artifacts: "split `auth.py` into `auth/login.py` and `auth/token.py`, login.py compiles, token.py has stub `refresh()`" |
| Completed list with no paths | "Fixed the bug" — no way to verify | Always include file paths or commit hashes |
| Scratchpad in .gitignore | Lost on branch switch or clone | Keep it tracked, or store in a location that persists across branches |
| Overlong scratchpad | More than ~80 lines, buries the signal | Archive completed milestones, keep only active work |

## Example

```markdown
# Scratchpad — migrate user service to async

## Goal
Convert user-service from sync Flask to async Quart, maintaining API compatibility.

## Status
IN PROGRESS

## Completed
- Converted `src/routes/users.py` to async handlers (commit a1b2c3d)
- Updated `src/db/connection.py` to use async connection pool
- Added `pytest-asyncio` to requirements-dev.txt

## Current State
- `src/routes/admin.py` still uses sync handlers — will fail at runtime
- All tests in `tests/test_users.py` pass (12/12)
- `tests/test_admin.py` skipped with TODO marker — needs async rewrite
- Branch: `async-migration`, 3 commits ahead of main

## Next Step
Convert `src/routes/admin.py` handlers to async, then unskip and fix `tests/test_admin.py`.

## Open Questions
- Background task in `admin.py:cleanup_sessions()` uses threading — need to decide between asyncio.create_task or keeping thread.

## Context
- Branch: async-migration
- Test: `pytest tests/ -x -q`
- Run: `quart run --reload`
```

## Scratchpad vs Actual State Conflicts

When the scratchpad disagrees with the filesystem or git:

1. **Filesystem wins.** The scratchpad is a record, not a source of truth for code. If a file was deleted or changed outside the scratchpad workflow, update the scratchpad.
2. **Investigate before overwriting.** If Completed says X was done but the file is missing, check `git log` — someone may have reverted it. Record what happened.
3. **Never silently ignore conflicts.** Add a line to Open Questions explaining the discrepancy and how you resolved it.
4. **Re-run verification.** After resolving any conflict, re-run the full verification sequence before proceeding with new work.
