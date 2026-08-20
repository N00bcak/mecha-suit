# Repo AGENTS Template

Use this repo-local file to connect project facts to the global skill toolbox.

## Global Skills

- Inspect local context before asking about discoverable facts.
- State safe assumptions and ask one focused question only when ambiguity
  materially changes the work.
- Require explicit invocation for session overlays and interactive loops; keep
  at most one interactive loop active.
- Do not authorize subagent use outside the global `parallel-subagents` and
  `second-opinion` skill contracts.
- Only `$multi-step-governance` creates or updates `.mecha/work/` state.
  Specialist skills return bounded artifacts and evidence for the governor.
- Treat resume candidates as advisory context. Use Codex `$skill-name` syntax
  to offer reactivation, and never activate one from the record alone.

## Local Commands

- Install dependencies: `<command>`
- Run tests: `<command>`
- Run lint: `<command>`
- Start app: `<command>`

## Local Boundaries

- Source root: `<path>`
- Test root: `<path>`
- Generated files: `<path or rule>`
- Do not edit: `<path or rule>`

## Local Notes

Keep this section factual and concise. Put reusable methods in global skills, not here.
