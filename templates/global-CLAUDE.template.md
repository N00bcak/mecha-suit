# Global CLAUDE Adaptation

For a global Claude instruction file, start with
`templates/global-AGENTS.template.md`. Add only the host differences below;
use `EXAMPLE_PROMPT.md` as an example of a concise downstream customization.

## Claude-Specific Differences

- Claude Code does not enforce Codex `agents/openai.yaml` metadata. Preserve
  the global prompt's explicit-only policy for `interview-me`,
  `product-co-design`, `low-friction-collaboration`, `ai-pipeline`, and
  `multi-step-governance`.
Let the host own ordinary selection and clarification. Put Claude-specific
commands, project layout, and invocation behavior in thin local instructions;
do not copy project facts into global skills. Only multi-step-governance owns
matching `.mecha` state; resume candidates require fresh explicit invocation.
