# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Mecha Suit is a reusable, symlink-installed skill harness for coding agents (Codex-first, Claude Code-portable). It provides global skills for specialist work while leaving ordinary selection and clarification to the host agent. Skills are pure markdown + bash with no external dependencies.

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

- **`collaboration/`** — Fully authored. Conversation specialists plus
  product research, domain modeling, decision mapping, portable handoff,
  `parallel-subagents` for bounded independent delegation, and `second-opinion`
  for independent consequential review.
- **`engineering/`** — Fully authored. Technical research, accepted
  specifications, work slicing, large-repository changes, greenfield
  prototypes, bug diagnosis, and three-axis code review share lifecycle,
  anti-bloat, behavior-first, design, and language-idiom references.
- **`ai/`** — Fully authored. `ai-pipeline` is an explicit-only one-time framing manual; five callable leaves own data preparation, insight development, representations, problem modeling, and performance across ML, deep learning, GOFAI, and hybrid systems.
- **`writing/`** — Fully authored. `humanizer` owns long-form prose authoring
  and revision; `blogpost-writing` owns VitePress-ready posts and CTF writeups
  in N00bcak's voice.

### Skill folder structure

Each skill folder contains `SKILL.md` (runtime behavior with frontmatter), optional `references/` (passive checklists), optional `scripts/` (deterministic helpers), and optional `agents/` (host metadata only when it materially improves routing or invocation). Current explicit-only `agents/openai.yaml` files exist for `interview-me`, `product-co-design`, `low-friction-collaboration`, and `ai-pipeline`; other collaboration, engineering, AI execution, and writing leaves rely on frontmatter only.

### Shared resources

- `shared/rubrics/` — toolbox-wide lifecycle, research, change,
  persistence/yield, and skill-boundary discipline.
- `shared/examples/` — Skill-selection examples.
- `templates/` — Task, session-overlay, and interactive-loop authoring
  contracts plus repo-local AGENTS/CLAUDE files and adapter skills.
- `docs/` — `maintenance-playbook.md`, `platform-notes.md`, example global instructions.

### Install mechanism

`install.sh` discovers skills via `families/*/*/SKILL.md` glob pattern, then symlinks each skill directory into the skill root. The root is `MECHA_SKILL_ROOT`, then `CODEX_HOME/skills`, then `$HOME/.codex/skills`. No registry file to maintain. Both install and uninstall are idempotent and refuse to overwrite unrelated files.

## Key Invariants

1. Native Codex description matching selects skills; the toolbox adds no duplicate router or orchestration layer.
2. Only `parallel-subagents` and `second-opinion` may authorize subagent use;
   both preserve main-process ownership and prohibit nested delegation.
3. Every skill uses the task, session-overlay, or interactive-loop authoring
   contract; future ideas remain in specs until callable.
4. Session overlays and interactive loops are explicit-invocation-only, and at
   most one interactive loop is active at a time.
5. Frontmatter `name:` must match the containing folder name.
6. Runtime behavior goes in `SKILL.md`; maintenance policy goes in `AGENTS.md` and `docs/`.
7. If you change a skill contract shape, update the applicable template, README,
   maintenance playbook, subsystem specs, and focused tests.
8. Optional durable state lives under `.mecha/work/<slug>/`; it connects leaves
   through artifacts and never selects or orchestrates them.

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
1. Identify which architectural layer changed (routing, subagent policy, specialist, shared template, docs, install logic).
2. Update nearby templates/docs if the contract changed.
3. Audit for boundary drift.
4. Summarize what changed, why, and what remains deferred.

## Style

- 4-space indentation.
- Direct, dense, operational language. No motivational filler.
- Skill names reflect actual function (e.g. `product-co-design` not a vague helper label).
- Skill descriptions use one constructive sentence, normally around 120 characters, naming the owned action and a positive task or artifact cue.
- Scripts only when they improve determinism or remove repeated procedural work.
