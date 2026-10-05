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
adapters. Do not add a frontmatter field or registry for interaction lifetime.

## Add or revise a skill

1. Start from the applicable template under `families/<family>/<skill>/`.
2. Put positive task and artifact cues in the frontmatter description.
3. Define runtime purpose, exclusions, needs, returns, done conditions, and
   persistence/yield behavior in `SKILL.md`.
4. Add a reference only for passive detail with a direct loading cue. Add a
   script only for repeated deterministic work.
5. Add positive and near-miss cases to `evals/*.json`. Use a compact worked
   example when a consequential judgment remains ambiguous; keep examples
   illustrative rather than prescribing a universal output shape.
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

Compose global prompt changes as one coherent contract: replace overlapping
instructions and resolve competing requirements as each rule is written.
Keep response depth tied to the user's purpose while preserving substantive
coverage. Intellectual honesty includes useful progress with imperfect evidence,
not an expectation that the user can supply ideal information. Keep analysis
and implementation authorization distinct, and keep consumer examples limited
to personal preferences rather than duplicated or overriding universal rules.

Codex loads at most 8,000 UTF-8 bytes from a selected `SKILL.md`, including its
frontmatter. The validator fails above that limit and warns at 7,000 bytes so
authors can preserve headroom. It also reports this repository's estimated
catalog contribution and warns at 6,400 characters. Catalog pressure remains
advisory because installed paths and skills from other sources contribute to
the host's final prompt.

## Maintain multi-step governance

The work index never routes or invokes skills. Only `multi-step-governance`
updates it; contributors return bounded artifacts and evidence. Executing an
accepted plan does not activate governance or require a record. Preserve
semi-auto work as session-local orientation, keep accepted intent
user-authoritative, and put detailed phase output behind artifact links.

When the lifecycle contract changes, update
`templates/work-index.template.md`, focused tests, architecture, and platform
notes.

For change-review iterations, keep the detailed `RF-*` finding ledger in a linked
report. The work index holds only the review fixed point, disposition, and open
blocker summary. Preserve finding IDs across remediation, distinguish validity
from current actionability, and do not turn preferences or unsupported claims
into lifecycle blockers. `change-review` owns those judgments; the governor only
records the report outcome and prevents closure while recorded blockers remain
unless the user explicitly waives them.

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

Codex explicit invocations use structured app-server skill inputs and therefore
do not depend on an observable file read. Multi-turn cases reuse one ephemeral
thread per run so their state is realistic without contaminating other cases.
Implicit skill-file-read observations remain heuristic. Keep live evaluation
outside deterministic tests and review interaction behaviors manually.

### Compare actual outcomes

Use `scripts/run_outcome_evals.py` for the five fixture-backed cases in
`evals/outcomes/cases.json`. They cover accepted-plan execution, specification
and slicing, a contained fix, a snapshot audit, and an evidenced diff review.
The existing routing runner remains a selection/interaction probe; loading a
skill is not evidence of correct task completion.

Inspect the cases offline:

```bash
uv run python scripts/run_outcome_evals.py --dry-run
```

For an opt-in live comparison, substitute the model and supported effort you
want to evaluate:

```bash
uv run python scripts/run_outcome_evals.py \
    --case small-fix --model MODEL --effort EFFORT --runs 3 \
    --output /tmp/mecha-outcomes.json
```

Each pair uses the same fixture and user turns, fresh workspaces and threads,
and the same explicit model/effort. Baseline has only project instructions;
treatment adds the consumer global prompt and all Mecha skills with native
selection. The order alternates across repetitions. The runner isolates host
configuration, checks instruction sources and the enabled catalog, and marks
unverified or failed host execution inconclusive. It disables external tool
network access and permits writes only in the disposable workspace. It imports
file-backed Codex authentication or an API key, not personal configuration.
Keychain-only authentication is not copied; use a file-authenticated CLI or an
API-key environment for a live run. Custom provider configurations are not
imported. This is a Codex adapter, not a portable execution guarantee.

The JSON report retains messages, tool events, partial artifacts, objective
checks, scope violations, timing, available usage, and configuration/version
fingerprints before cleanup. Its Markdown companion compares both arms and
leaves manual criteria ungraded. Review unnecessary pauses, unsupported claims,
completion, and actual evidence in the traces. Report objective check results
separately; a completed turn or passing scope check does not mean good work.
Unavailable usage remains null. Do not infer improvement from a tiny sample or
from deterministic tests. Live evaluation is not a merge gate.

Keep evaluator checks outside the agent-editable workspace. The two coding
fixtures use independent input/output vectors; planning and review quality
requires manual judgment. Test each oracle against known broken and corrected
artifacts. Add cases from observed failures rather than expanding a speculative
benchmark matrix. Keep examples used in skills distinct from evaluation tasks.

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
metadata and prompt budgets, source and installed reference resolution,
documentation links, evaluation corpora, shell syntax, family layout, subagent
boundaries, and install/uninstall safety.
