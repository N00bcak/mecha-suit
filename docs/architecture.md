# Architecture

Mecha Suit is a library of narrow runtime skills, not an agent framework. The
host selects skills from their frontmatter descriptions and handles ordinary
clarification. The repository adds reusable methods and contracts without a
router, registry, or orchestration layer.

## Ownership

Each layer has one job:

- `families/` owns installable runtime skills grouped into collaboration,
  engineering, AI, and writing.
- A skill's `SKILL.md` owns its active behavior. Its `references/` hold passive
  detail loaded only when a named condition applies. Its `scripts/` exist only
  for repeated deterministic work.
- `shared/` owns the few runtime contracts used across skills: lifecycle,
  research integrity, and change discipline.
- `templates/` owns repeatable authoring shapes, host-instruction starting
  points, and the canonical consumer global AGENTS prompt installed by
  `install.sh`.
- `evals/` owns host-neutral routing and interaction cases. Host adapters add
  invocation syntax and collect observations.
- `tests/` and `test.sh` own deterministic repository invariants.
- `docs/` explains the system to people. It does not define runtime behavior.

## Skill Families

Collaboration skills elicit intent, develop product and domain evidence,
preserve shared language, map decisions, transfer verified state, or provide
bounded delegation and critique.

Engineering skills cover technical research, accepted implementation intent,
work slicing, established-repository changes, greenfield prototypes, difficult
diagnosis, and review. `implementation-spec` owns accepted intent;
`work-slicing` may decompose it but may not change it. `code-review` is
read-only unless the user separately requests fixes.

The AI family has five callable execution leaves for data preparation, insight
development, representation work, problem modeling, and performance. The
explicit-only `ai-pipeline` skill is a one-time framing manual, not a controller
that invokes or manages those leaves. The family stops at an evaluated
solution; production integration remains engineering work.

Writing skills own long-form prose. `humanizer` handles general essays,
reports, articles, speeches, and ordinary blog posts. `blogpost-writing` owns
VitePress-ready posts and CTF writeups for N00bcak's site. Documentation, code
comments, interface copy, advertisements, social posts, and short messages
remain native work.

## Interaction Lifetimes

Every skill uses one of three authoring contracts:

- A task skill owns a bounded outcome and returns control when that outcome is
  complete or blocked.
- A session overlay changes how another active task or loop is conducted but
  does not own its result.
- An interactive loop owns a multi-turn exchange until it completes, pauses,
  is cancelled, or is explicitly replaced.

Task skills are the default. Overlays and loops require explicit invocation in
each session. At most one loop may be active; an overlay may compose with one
task or loop. These are local authoring shapes, not routing metadata.

## Lifecycle Authority

Collaboration and engineering leaves may participate in a matching
`.mecha/work/<slug>/index.md` record when durable continuity or an accepted
lifecycle is useful. The record connects work through verified artifacts; it
never selects or invokes skills.

Accepted goals, criteria, constraints, and non-goals remain user-authoritative.
New evidence may challenge them but cannot silently rewrite them. Small ad-hoc
tasks create no record. Resume candidates are advisory and never reactivate an
explicit mode in a new session.

The full runtime rules live in
[`shared/rubrics/lifecycle-contract.md`](../shared/rubrics/lifecycle-contract.md).

## Subagent Boundary

Only `parallel-subagents` and `second-opinion` authorize subagent use.
`parallel-subagents` applies to genuinely independent, non-overlapping work;
`second-opinion` obtains one non-leading critique of a consequential artifact
or conclusion. Both preserve main-process ownership, require structured
evidence, prohibit nested delegation, and depend on host capability.

This allowlist prevents hidden delegation from becoming a property of every
skill. Changing it is an architecture change and requires matching runtime
contracts, evaluation cases, and deterministic tests.

## Portability

Portable skill frontmatter contains only `name` and `description`. Host policy
and presentation metadata remain adapters. Codex currently uses
`agents/openai.yaml` for explicit-only invocation; Claude Code support is a
documented adaptation rather than a claim of identical enforcement.

Project commands, private infrastructure, and repository-specific facts stay
in local instructions or adapter skills. The global toolbox should not make a
small local edit require changes across unrelated skills.

The repository-root `AGENTS.md` governs development of Mecha Suit itself. It
is separate from the consumer prompt under `templates/`; examples may show
customization but never become install sources.

## Deliberately Deferred

Mecha Suit does not currently include a generic router, a capability registry,
an adaptive multi-iteration AI controller, or a guaranteed Claude live-eval
adapter. Add one only after a repeated, measured need shows that native host
behavior and narrow leaves no longer suffice.
