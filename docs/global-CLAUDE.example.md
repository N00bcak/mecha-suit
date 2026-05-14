# Global CLAUDE Example

Use this as a concise Claude Code-facing integration note if adapting this toolbox outside Codex.

## Skill Usage

- Route first with `task-router` when skill choice is unclear.
- Clarify with `task-clarifier` when the task lacks a concrete objective, artifact, or constraint.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Escalate to `interdisciplinary-council` only for real multi-specialist work with fully authored non-council specialists.

## Boundaries

- The router is not an orchestrator.
- The clarifier is not a domain specialist.
- Stub specialist leaves are architecture placeholders, not callable skills.
- Council-style delegation is restricted to `interdisciplinary-council`.

## Local Adaptation

Use thin repo-local wrappers to provide Claude-specific commands, local file layout, and project norms. Do not copy project facts into global skills.
