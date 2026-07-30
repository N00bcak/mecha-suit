# Global CLAUDE Example

Use this as a concise Claude Code-facing integration note if adapting this toolbox outside Codex.

## Skill Usage

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Do not call specialist leaves still marked `This is a stub. NEVER CALL THIS SKILL.`
- Do not authorize subagent use outside `parallel-subagents` and
  `second-opinion`.

## Boundaries

- Native host behavior owns ordinary selection and clarification.
- Stub specialist leaves are architecture placeholders, not callable skills.
- Only `parallel-subagents` and `second-opinion` authorize delegation, subject
  to host capability and main-process ownership.

## Local Adaptation

Use thin repo-local wrappers to provide Claude-specific commands, local file layout, and project norms. Do not copy project facts into global skills.
