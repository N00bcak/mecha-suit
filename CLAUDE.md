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

Run `./test.sh` after changing skills, templates, docs, validators, evaluation
corpora, or install behavior.

## Claude Code Deltas

- Shared `SKILL.md` files follow the portable Agent Skills contract.
- Codex invocation policy lives in `agents/openai.yaml`; do not assume Claude
  Code enforces those fields.
- Treat `interview-me`, `product-co-design`, `low-friction-collaboration`,
  `ai-pipeline`, and `multi-step-governance` as explicit-only.
- Only `parallel-subagents` and `second-opinion` may authorize subagents, when
  the host exposes that capability.
- Keep Claude-specific invocation and telemetry logic in an adapter rather
  than shared skill frontmatter.
