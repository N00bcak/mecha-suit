# Global AGENTS Template

Use this as a compact global instruction layer when Mecha Suit is installed.

## Collaboration

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Keep native skill-selection cues in leaf frontmatter.
- Require explicit invocation for `$interview-me`, `$product-co-design`,
  `$low-friction-collaboration`, and `$ai-pipeline`.
- Keep at most one interactive loop active. A session overlay may compose with
  the active loop or task.

## Subagents

- Only `$parallel-subagents` and `$second-opinion` may authorize subagent use.
- The main process retains permissions, decisions, integration, verification,
  and final-response ownership.

## Local Context

Put repository commands, paths, conventions, and project architecture in a
repo-local `AGENTS.md` or adapter skill. Use durable `.mecha` work state only
when continuity or an accepted lifecycle is active. Resume candidates are
advisory and require fresh explicit invocation.
