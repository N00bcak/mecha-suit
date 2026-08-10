# Global CLAUDE Template

Use this as a concise Claude Code integration note when adapting Mecha Suit.

## Skill Usage

- Inspect supplied context before asking about missing facts.
- State safe assumptions and ask one focused question only when a user-owned
  decision materially changes the work.
- Treat `interview-me`, `product-co-design`, `low-friction-collaboration`, and
  `ai-pipeline` as explicit-only.
- Keep at most one interactive loop active. A session overlay may compose with
  the active task or loop.
- Only `parallel-subagents` and `second-opinion` may authorize subagents.

## Local Adaptation

Let the host own ordinary selection and clarification. Put Claude-specific
commands, project layout, and invocation behavior in thin local instructions;
do not copy project facts into global skills. Matching `.mecha` work state may
provide continuity, but resume candidates require fresh explicit invocation.
