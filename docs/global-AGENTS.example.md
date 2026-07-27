# Global AGENTS Example

Use this file as a compact global instruction layer when this toolbox is installed.

## Skill Routing

- Use `$task-router` when the user asks for skill selection or when the next skill is not obvious.
- Use `$task-clarifier` when the request is ambiguous, mixed, underspecified, or novel.
- Use `$interview-me` only when the user explicitly invokes it.
- Use `$product-co-design` when a product concept needs shaping, constructive critique, validation planning, or a specialist-ready brief.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Use `$interdisciplinary-council` only for genuine cross-domain work where the relevant non-council specialists are fully authored.

## Subagent Policy

- `task-router` and `task-clarifier` never use subagents.
- Specialist leaves never spawn, request, or rely on subagents.
- Only `$interdisciplinary-council` may use subagents, and only by inheriting from fully authored non-council specialist leaves.

## Repo-local Context

Keep global skills reusable. Put repository commands, paths, conventions, and project-specific architecture in a repo-local adapter skill or local `AGENTS.md`.
