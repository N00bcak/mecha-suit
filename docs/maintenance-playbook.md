# Maintenance Playbook

## Choose the contract

Create a skill only when its runtime behavior is complete and callable. Keep
future concepts in `docs/architecture.md`.

- Use `templates/task-skill.template.md` for a bounded outcome.
- Use `templates/session-overlay.template.md` for behavior that composes with
  another task or loop.
- Use `templates/interactive-loop.template.md` for a multi-turn exchange that
  owns conversational control.

Task skills are the default. Overlays and loops declare their contract in the
body and require explicit-invocation metadata. Do not add a frontmatter field
or registry for interaction lifetime.

## Add or revise a skill

1. Start from the applicable template under `families/<family>/<skill>/`.
2. Put positive task and artifact cues in the frontmatter description.
3. Define runtime purpose, exclusions, needs, returns, done conditions, and
   persistence/yield behavior in `SKILL.md`.
4. Add a reference only for passive detail with a direct loading cue. Add a
   script only for repeated deterministic work.
5. Add positive and near-miss cases to `evals/*.json`.
6. Update `docs/skills.md` when the public catalog changes.
7. Run the validator and full deterministic suite.

Do not add a router. Do not add `agents/` metadata to task skills by default.
Explicit-only skills use `agents/openai.yaml` with
`allow_implicit_invocation: false` when the Codex adapter supports it.

Descriptions should be one constructive sentence, normally around 120
characters. Treat that length as editorial guidance, not a validator limit.

## Control context consumption

Use these soft initial-read ranges: 500–750 words for overlays, 500–900 for
ordinary tasks, 800–1,100 for complex engineering skills, and 800–1,200 for
interactive loops. Do not hide active behavior in references to meet them.

Keep a general principle only when the skill turns it into a domain-specific
decision, artifact, invariant, or verification step. Load shared and family
references only when their stated condition applies. Re-read a shared contract
after context loss, suspected staleness, or a file change; do not create cache
flags or a registry.

Keep consumer global instructions as one stable, static prefix. Put changing
project facts and task state in repo-local instructions, artifacts, or the
conversation. State universal policy once; do not duplicate it in every skill
or turn a summary into a substitute for primary evidence.

## Maintain multi-step governance

The work index never routes or invokes skills. Only `multi-step-governance`
updates it; contributors return bounded artifacts and evidence. Preserve
semi-auto work as session-local orientation, keep accepted intent
user-authoritative, and put detailed phase output behind artifact links.

When the lifecycle contract changes, update
`templates/work-index.template.md`, focused tests, architecture, and platform
notes.

For code-review iterations, keep the detailed `RF-*` finding ledger in a linked
report. The work index holds only the review fixed point, disposition, and open
blocker summary. Preserve finding IDs across remediation, distinguish validity
from current actionability, and do not turn preferences or unsupported claims
into lifecycle blockers.

## Maintain behavioral evaluations

Keep reusable prompts and expectations in `evals/*.json`. Store explicit skill
names separately from prompt text so adapters can add host syntax. Use
realistic positives and adjacent near misses; keep the committed split stable
while tuning descriptions.

`./test.sh` validates and dry-renders every corpus without a model. When live
behavioral evidence is worth its cost, run a targeted adapter sample:

```bash
uv run python scripts/run_interaction_evals.py \
    --host codex \
    --corpus evals/skill-routing.json \
    --split validation \
    --runs 1
```

Codex skill-file-read observations are heuristic. An explicit binding without
an observable read is inconclusive. Keep live evaluation outside deterministic
tests and review responses manually.

## Preserve persistence without flailing

Open-ended skills define a bounded first pass, useful progress, at least two
distinct strategies when available, and valid stop states. A useful yield names
attempts, evidence, the exact blocker, confidence, and the next recovery step.
Do not broaden scope as a substitute for progress.

Use `shared/rubrics/change-discipline.md` as the common coding floor. Add
family-specific guidance only for materially different tradeoffs.

## Keep ownership clear

- `AGENTS.md` owns repository rules.
- `docs/architecture.md` owns durable structure and rationale.
- This playbook owns change procedure.
- `docs/platform-notes.md` owns host differences.
- `docs/skills.md` owns the human-facing input/output catalog.
- `evals/*.json` owns routing examples.

Prefer a link over repeated wording. Only `parallel-subagents` and
`second-opinion` may authorize subagents; an allowlist change requires matching
runtime contracts, templates, evaluation cases, tests, and architecture docs.

## Verify

Run:

```bash
uv sync --dev
./test.sh
git diff --check
```

The suite validates portable frontmatter, interaction contracts, Codex
metadata, reference ownership, documentation links, evaluation corpora, shell
syntax, family layout, subagent boundaries, and install/uninstall safety.
