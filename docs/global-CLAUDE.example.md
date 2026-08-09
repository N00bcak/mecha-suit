# Global CLAUDE Example

Use this as a concise Claude Code-facing integration note if adapting this toolbox outside Codex.

## Skill Usage

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Require the user to explicitly ask to use `interview-me`,
  `product-co-design`, or `low-friction-collaboration` before applying its
  interaction behavior.
- Keep at most one interactive loop active; a session overlay may compose with
  the active task or loop.
- Do not authorize subagent use outside `parallel-subagents` and
  `second-opinion`.
- A matching `.mecha/work/<slug>/index.md` may provide host-neutral continuity
  only to a collaboration or engineering skill that declares participation.
  Resume candidates require fresh explicit invocation. Automatic Claude Code
  planning-mode activation remains unspecified.

## Boundaries

- Native host behavior owns ordinary selection and clarification.
- Only `parallel-subagents` and `second-opinion` authorize delegation, subject
  to host capability and main-process ownership.

## Local Adaptation

Use thin repo-local wrappers to provide Claude-specific commands, local file layout, and project norms. Do not copy project facts into global skills.
