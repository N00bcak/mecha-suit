# AGENTS.md

## Purpose and scope

This repository develops Mecha Suit, a reusable Codex-first skill toolbox with
portable Agent Skills contracts. This file is authoritative for changes to the
toolbox: skills, templates, shared resources, evaluation corpora, validators,
install scripts, and documentation. Runtime behavior remains in each skill's
`SKILL.md`.

## Development environment

- Use `uv` for Python development.
- Run `uv sync --dev`, then `./test.sh` after meaningful changes.
- Keep development packages in the development dependency group. Installed
  skills and `install.sh` must not depend on them.
- Add dependencies only for deterministic repository tooling. Commit `uv.lock`
  and never commit `.venv`.
- Keep `scripts/validate_skills.py` aligned with the portable Agent Skills
  contract and its Codex profile aligned with Codex `skill-creator` validation.

## Working discipline

State the goal and material assumptions before a non-trivial change. Add the
smallest useful plan only when the change touches an architecture invariant or
the install scripts. Inspect available context before asking questions. If a
missing user-owned choice changes architecture or scope, ask one focused
question; otherwise state a reversible assumption and proceed.

Implement the minimum coherent change. Do not add speculative abstractions,
configuration, defensive machinery, or future features. Touch only lines that
trace to the task, match existing style, and remove only cleanup made obsolete
by your change. Mention unrelated issues without fixing them.

Define concrete success criteria, verify in proportion to risk, and inspect the
resulting diff. Do not claim verification you did not perform.

## Architecture invariants

### Native selection is the top layer

- The host selects callable skills from leaf frontmatter and handles ordinary
  clarification.
- Do not add a router, registry, orchestration layer, score matrix, or
  duplicate selection table.
- Keep positive task and artifact cues in each leaf description.

### Skills stay narrow

- Specialist leaves own one recognizable job. The catalog lives in
  `docs/skills.md` and `families/`; do not copy it here.
- `ai-pipeline` is an explicit-only conceptual manual rather than a specialist
  execution leaf.
- Add no broad umbrella skill without a demonstrated ownership gap.
- Skill names are shared by every host, so avoid host built-in names.

### Interaction lifetime shapes the contract

Skills also have authority roles: bounded contributors return one result,
multi-turn contributors own a narrow exchange, multi-step governors own an
authorized durable process, and overlays own no result. Explicit manuals remain
outside this runtime-role taxonomy.

Every skill uses one interaction model:

- A task skill owns a bounded outcome and then returns control.
- A session overlay changes how another task or loop is conducted without
  owning its result.
- An interactive loop owns a multi-turn exchange until it completes, pauses,
  is cancelled, or is explicitly replaced.

Task skills are the default. Overlays declare `Session Overlay Contract` and
loops declare `Interactive Loop Contract` in `SKILL.md`; do not encode this in
frontmatter or a registry. Overlays and loops are explicit-only. At most one
loop is active, while an overlay may compose with one task or loop. Durable
state may suggest a resume candidate but never activates a skill.

Create skill directories only for fully authored, callable contracts. Keep
future concepts in `docs/architecture.md` until then.

### Subagent authorization has two owners

- Only `parallel-subagents` and `second-opinion` may authorize subagent use.
  Every other skill must not spawn, request, assume, or depend on subagents.
- Both authorized skills must check host capability, preserve main-process
  ownership, prohibit nested delegation, and require structured evidence.
- `parallel-subagents` requires independent non-overlapping work;
  `second-opinion` requires one non-leading review and main-process
  adjudication.

### Durable work does not route

- Only `multi-step-governance` may update a matching
  `.mecha/work/<slug>/index.md` record under
  `shared/rubrics/lifecycle-contract.md`.
- Contributors return verified artifacts; the record does not select or invoke
  skills.
- Accepted intent remains user-authoritative. Ad-hoc work creates no record.
- `.mecha/logs/` holds non-authoritative working notes that any use case may
  write; they never select, activate, or resume a skill.

## File ownership

- `SKILL.md`: active runtime behavior and output contract.
- `references/`: concise passive knowledge, checklists, and decision aids.
- `scripts/`: portable deterministic helpers that remove repeated work.
- `agents/`: host metadata only when invocation policy or presentation needs it.
- `evals/`: host-neutral prompts and observable expectations.
- `tests/`: deterministic contracts and adapter-rendering checks.
- `templates/`: repeatable authoring shapes and host-instruction starting points.
- `docs/`: the human handbook; no runtime behavior.
- `shared/`: cross-skill runtime contracts with multiple direct consumers.
  `shared/use-cases/` holds use-case guides whose direct consumer is the global
  instructions' stubs.

Do not move active instructions into references merely to shrink `SKILL.md`.
Every reference must have a direct consumer and a clear loading cue. Do not add
scripts that only wrap trivial prose. Do not add task-skill metadata by
default; explicit overlays and loops require explicit-invocation metadata.

## Authoring skills

Use the template matching the interaction lifetime. Runtime skills define
purpose, exclusions, needs, returns, done conditions, and progress
behavior. Add references or scripts only after the core playbook earns them.

Descriptions name the owned action, then add a "Use when …" cue for the
situation that should trigger the skill, normally around 160-180 characters.
Both Codex and Anthropic skill guidance ask for what and when; routing evals on
both hosts improved with the cue. Keep
adjacent boundaries in the runtime contract rather than filling frontmatter
with warnings. Declare manual-only invocation once as
`metadata.invocation: explicit`; hosts do not read it, so host adapters
(`agents/openai.yaml`, install-time Claude rendering) enforce it and the
validator keeps them aligned.

Use direct operational language and 4-space indentation. Preserve portability:
no hardcoded local paths, private infrastructure, or repo-specific commands in
global skills. Keep project facts in local instructions or adapters.

Every callable skill must have a positive case in `evals/*.json`, plus
near-miss cases for material adjacent boundaries. Prompts remain independent
of host syntax; `explicit_invocations` records manual selection. Deterministic
tests must not require a model, credentials, network, or nondeterministic
output. Live evaluation is optional evidence, not a merge gate.

If a public skill or contract changes, update the applicable template,
`docs/skills.md`, `docs/maintenance-playbook.md`, focused tests, evaluation
cases, and `docs/architecture.md` only where ownership or rationale changed.

## Gotchas

- Run `install.sh`, `uninstall.sh`, and live evals only with temporary
  `CODEX_HOME`, `CLAUDE_CONFIG_DIR`, and `MECHA_SKILL_ROOT`; never against the
  real home directory unless the user asks.
- `./test.sh` rewrites the tracked `scripts/__pycache__` bytecode; restore it
  before reviewing the diff.
- Bulk renames also match shell variables and eval ids; review every hit.
- Live Claude evals need `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token`;
  live runs cost money, so ask before starting them.

## Definition of done

A meaningful change is done when:

- changed files are internally consistent and architecture invariants hold;
- new complexity has a demonstrated purpose;
- templates, docs, and evaluation cases remain aligned;
- `uv sync --dev`, `./test.sh`, and relevant focused checks pass;
- the diff contains no unrelated cleanup.

Finish with a compact decision record: goal, assumptions, chosen approach,
files touched, verification, and remaining risk. Use
`docs/architecture.md` for durable rationale, not a historical plan or a second
copy of these rules.
