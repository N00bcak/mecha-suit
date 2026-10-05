# CLAUDE.md

@AGENTS.md

The imported `AGENTS.md` is the authoritative development contract. See
[Platform Notes](docs/platform-notes.md) for Claude Code differences; do not
restate shared rules here.

## Commands

```bash
uv sync --dev
./test.sh
./install.sh
./uninstall.sh
```

## Claude Code deltas

- Claude Code does not read `agents/openai.yaml`. Explicit-only skills reach
  Claude through `install.sh`, which renders them with
  `disable-model-invocation: true`; never add that field to source frontmatter.
- Invoke skills as `/name` here; Codex uses `$name`.
- Live Claude evals run through `scripts/eval_hosts.py` and need
  `CLAUDE_CODE_OAUTH_TOKEN`.
