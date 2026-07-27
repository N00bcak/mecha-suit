# Global AGENTS Example

Use this file as a compact global instruction layer when this toolbox is installed.

## Skill Routing

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Use `$interview-me` only when the user explicitly invokes it.
- Use `$product-co-design` when a product concept needs shaping, constructive critique, validation planning, or a specialist-ready brief.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Use `$interdisciplinary-council` only for genuine cross-domain work where the relevant non-council specialists are fully authored.

## Subagent Policy

- Specialist leaves never spawn, request, or rely on subagents.
- Only `$interdisciplinary-council` may use subagents, and only by inheriting from fully authored non-council specialist leaves.

## Repo-local Context

Keep global skills reusable. Put repository commands, paths, conventions, and project-specific architecture in a repo-local adapter skill or local `AGENTS.md`.
