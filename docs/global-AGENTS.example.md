# Global AGENTS Example

Use this file as a compact global instruction layer when this toolbox is installed.

## Skill Routing

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Use `$interview-me` only when the user explicitly invokes it.
- Use `$product-co-design` when a product concept needs shaping, constructive critique, validation planning, or a specialist-ready brief.
- Use `$low-friction-collaboration` when a dense technical exchange needs
  direct wording, visible state, and low recall burden without shallower
  reasoning.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Do not authorize subagent use through global instructions.

## Subagent Policy

- Installed skills never spawn, request, or rely on subagents.

## Repo-local Context

Keep global skills reusable. Put repository commands, paths, conventions, and project-specific architecture in a repo-local adapter skill or local `AGENTS.md`.
