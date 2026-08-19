# Global CLAUDE Adaptation

For a global Claude instruction file, start with
`templates/global-AGENTS.template.md`. Add only the host differences below;
use `EXAMPLE_PROMPT.md` as an example of a concise downstream customization.

## Claude-Specific Differences

- Claude Code does not enforce Codex `agents/openai.yaml` metadata. Preserve
  the global prompt's explicit-only policy for `interview-me`,
  `product-co-design`, `low-friction-collaboration`, and `ai-pipeline`.
Let the host own ordinary selection and clarification. Put Claude-specific
commands, project layout, and invocation behavior in thin local instructions;
do not copy project facts into global skills. Matching `.mecha` work state may
provide continuity, but resume candidates require fresh explicit invocation.
When native implementation or remediation continues a matching lifecycle
record, follow its shared code-review iteration contract even when no
implementation skill is selected.
