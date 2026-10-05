# Repo CLAUDE Template

Use this repo-local file to adapt the global toolbox for Claude Code.

## Skill Intent

- Inspect local context before asking about discoverable facts.
- State safe assumptions and ask one focused question only when ambiguity
  materially changes the work.
- Keep ordinary implementation in the relevant specialist leaf.
- Require explicit invocation for session overlays and interactive loops; keep
  at most one interactive loop active.
- Among Mecha Suit skills, only `parallel-subagents` and `second-opinion` may
  use subagents; host-native workflows keep their own subagent rules.
- Only `/multi-step-governance` creates or updates `.mecha/work/` state.
  Contributors return bounded artifacts and evidence.
- Treat resume candidates as advisory context. Offer reactivation with Claude
  `/skill-name` syntax, and never activate one from the record alone.

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
