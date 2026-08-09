# Repo CLAUDE Template

Use this repo-local file to adapt the global toolbox for Claude Code.

## Skill Intent

- Inspect local context before asking about discoverable facts.
- State safe assumptions and ask one focused question only when ambiguity
  materially changes the work.
- Keep ordinary implementation in the relevant specialist leaf.
- Require explicit invocation for session overlays and interactive loops; keep
  at most one interactive loop active.
- Do not authorize subagent use outside the global `parallel-subagents` and
  `second-opinion` skill contracts.
- When a collaboration or engineering skill declares lifecycle participation,
  treat a matching `.mecha/work/<slug>/index.md` as optional host-neutral
  continuity. Resume candidates require fresh explicit invocation; do not
  assume automatic planning-mode support.

## Project Commands

- Setup: `<command>`
- Test: `<command>`
- Lint: `<command>`
- Run: `<command>`

## Project Facts

- Main source: `<path>`
- Tests: `<path>`
- Important config: `<path>`
- Generated output: `<path or rule>`

## Guardrails

Do not copy these local facts into the global toolbox.
