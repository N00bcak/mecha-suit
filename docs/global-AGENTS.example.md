# Global AGENTS Example

Use this file as a compact global instruction layer when this toolbox is installed.

## Collaboration Defaults

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Keep native skill-selection cues in leaf frontmatter rather than duplicating
  them here.
- Require explicit invocation for `$interview-me`, `$product-co-design`, and
  `$low-friction-collaboration`; do not infer their session behavior.
- Keep at most one interactive loop active. A session overlay may compose with
  the active loop or task.
- Do not authorize subagent use outside these two dedicated skills.

## Subagent Policy

- Only `$parallel-subagents` and `$second-opinion` may authorize subagent use.
- The main process retains permissions, decisions, integration, verification,
  and final-response ownership.

## Repo-local Context

Keep global skills reusable. Put repository commands, paths, conventions, and project-specific architecture in a repo-local adapter skill or local `AGENTS.md`.

Use a matching `.mecha/work/<slug>/index.md` only when durable continuity or an
accepted lifecycle is active. Do not make unrelated ad-hoc work opt out.
Resume candidates are advisory. Never activate one without a new explicit user
invocation in the current session.
