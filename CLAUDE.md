# CLAUDE.md

Use [AGENTS.md](AGENTS.md) as the authoritative development contract for this
repository. Use [Platform Notes](docs/platform-notes.md) for known Claude Code
differences. Do not copy those shared rules into this adapter.

## Commands

```bash
uv sync --dev
./test.sh
./install.sh
./uninstall.sh
```

Run `./test.sh` after changing skills, templates, docs, validators, evaluation
corpora, or install behavior.

## Claude Code Deltas

- Shared `SKILL.md` files follow the portable Agent Skills contract.
- Codex invocation policy lives in `agents/openai.yaml`; do not assume Claude
  Code enforces those fields.
- Treat `interview-me`, `product-co-design`, `low-friction-collaboration`, and
  `ai-pipeline` as explicit-only.
- Only `parallel-subagents` and `second-opinion` may authorize subagents, when
  the host exposes that capability.
- Keep Claude-specific invocation and telemetry logic in an adapter rather
  than shared skill frontmatter.
