# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Mecha Suit is a reusable, symlink-installed skill harness for coding agents (Codex-first, Claude Code-portable). It provides global skills for specialist work and cross-domain council synthesis while leaving ordinary selection and clarification to the host agent. Skills are pure markdown + bash with no external dependencies.

## Commands

```bash
./test.sh                    # Validate harness (syntax, frontmatter, architecture, install behavior)
./install.sh                 # Install all skills as symlinks to the Codex skill root
./install.sh product-co-design  # Install selected skills only
./uninstall.sh               # Remove only managed symlinks
MECHA_SKILL_ROOT="/path" ./install.sh   # Custom install target
```

Always run `./test.sh` after any harness edit.

## Architecture

### Skill families (`families/`)

- **`council/`** — Fully authored. `interdisciplinary-council` is the **only** skill allowed to use subagents. Reserved for genuine multi-specialist work.
- **`collaboration/`** — Fully authored. `interview-me` (explicit-invocation-only scoped interviewing) and `product-co-design` (conversation-first product concept development and critique).
- **`engineering/`** — Fully authored. `large-codebase-change` owns PR-ready changes in repositories above roughly 5k maintained source lines; `prototype-builder` owns isolated greenfield work centered on one demonstrable outcome, without a line-count limit. Both share anti-bloat, continuity, and language-idiom references.
- **`ctf/`** — Fully authored. Specialist leaves for challenge triage, reverse engineering, binary exploitation, cryptography, web exploitation, forensics, AI/ML security, and miscellaneous challenges.
- **`ai/`** — Fully authored. `ai-pipeline` is an explicit-only one-time framing manual; five callable leaves own data preparation, insight development, representations, problem modeling, and performance across ML, deep learning, GOFAI, and hybrid systems.

### Skill folder structure

Each skill folder contains `SKILL.md` (runtime behavior with frontmatter), optional `references/` (passive checklists), optional `scripts/` (deterministic helpers), and optional `agents/` (host metadata only when it materially improves routing or invocation). Current `agents/openai.yaml` files exist for `interview-me`, `ai-pipeline`, council, and fully authored CTF specialists; `product-co-design`, engineering leaves, and AI execution leaves rely on frontmatter only.

### Shared resources

- `shared/rubrics/` — toolbox-wide change, persistence/yield, and skill-boundary discipline.
- `shared/examples/` — Skill-selection examples.
- `templates/` — Boilerplate for new leaves, subagent contracts, repo-local AGENTS/CLAUDE files, adapter skills.
- `docs/` — `maintenance-playbook.md`, `platform-notes.md`, example global instructions.

### Install mechanism

`install.sh` discovers skills via `families/*/*/SKILL.md` glob pattern, then symlinks each skill directory into the skill root. The root is `MECHA_SKILL_ROOT`, then `CODEX_HOME/skills`, then `$HOME/.codex/skills`. No registry file to maintain. Both install and uninstall are idempotent and refuse to overwrite unrelated files.

## Key Invariants

1. Native Codex description matching selects skills; the toolbox adds no duplicate router or orchestration layer.
2. Subagent access is **council-only**. Non-council `SKILL.md` files must not contain subagent authorization language.
3. Stub skills must keep the exact stub warning until fully authored.
4. Frontmatter `name:` must match the containing folder name.
5. Runtime behavior goes in `SKILL.md`; maintenance policy goes in `AGENTS.md` and `docs/`.
6. If you change the specialist leaf contract shape, update `templates/leaf-skill.template.md`, README, and `docs/maintenance-playbook.md`.

## Development Practices

### Think before coding

- State assumptions explicitly before implementing.
- If multiple reasonable interpretations exist, name them and choose one deliberately.
- If something is genuinely blocking or structurally ambiguous, stop and ask.
- If ambiguous but non-blocking, state the assumption and proceed.

### Simplicity first

- Write the minimum structure and code that correctly satisfies the task.
- Do not add speculative abstractions, extra configurability, features "for future use", or defensive handling for implausible scenarios.
- If a design is becoming clever, compress it. If 200 lines can honestly be 50, rewrite it.

### Surgical changes

- Touch only what is needed. Do not improve adjacent code unless the request requires it.
- Do not refactor unrelated structures. Match existing style.
- Remove imports, variables, functions, examples, or docs made obsolete by your own change. Do not remove pre-existing dead material unless asked.
- Every changed line should trace back to the task.

### Goal-driven execution

For non-trivial work: (1) state the goal, (2) state assumptions, (3) state the smallest useful plan, (4) implement, (5) verify, (6) summarize what changed and what remains uncertain. Prefer concrete success criteria over vague completion language.

### Change checklist

After meaningful changes:
1. Identify which architectural layer changed (routing, council, specialist, shared template, docs, install logic).
2. Update nearby templates/docs if the contract changed.
3. Audit for boundary drift.
4. Summarize what changed, why, and what remains deferred.

## Style

- 4-space indentation.
- Direct, dense, operational language. No motivational filler.
- Skill names reflect actual function (e.g. `interdisciplinary-council` not a vague orchestration label).
- Skill descriptions use one constructive sentence, normally around 120 characters, naming the owned action and a positive task or artifact cue.
- Scripts only when they improve determinism or remove repeated procedural work.
