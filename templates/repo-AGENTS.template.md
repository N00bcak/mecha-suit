# Repo AGENTS Template

Use this repo-local file to connect project facts to the global skill toolbox.

## Global Skills

- Inspect local context before asking about discoverable facts.
- State safe assumptions and ask one focused question only when ambiguity
  materially changes the work.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Do not authorize subagent use outside the global `parallel-subagents` and
  `second-opinion` skill contracts.

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
