# Global CLAUDE Adaptation

For a global Claude instruction file, start with
`templates/global-AGENTS.template.md`. Add only the host differences below;
use `EXAMPLE_PROMPT.md` as an example of a concise downstream customization.

## Claude-Specific Differences

- `install.sh` copies the global template to `~/.claude/CLAUDE.md`; use this
  file only when maintaining a separate Claude prompt.
- Claude Code does not read Codex `agents/openai.yaml` metadata. Installed
  Claude copies of `user-interview`, `product-co-design`,
  `low-friction-collaboration`, `ai-pipeline`, and `multi-step-governance`
  carry `disable-model-invocation: true`; manual copies must preserve that.
Let the host own ordinary selection and clarification. Put Claude-specific
commands, project layout, and invocation behavior in thin local instructions;
do not copy project facts into global skills. Only multi-step-governance owns
matching `.mecha` state; resume candidates require fresh explicit invocation.
