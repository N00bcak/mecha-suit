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
  invocation syntax and collect observations. Outcome fixtures compare project
  instructions alone with the full Mecha stack, retaining objective evidence
  and ungraded human review criteria separately from routing telemetry.
- `tests/` and `test.sh` own deterministic repository invariants.
- `docs/` explains the system to people. It does not define runtime behavior.

## Skill Families

Collaboration skills elicit intent, develop product and domain evidence,
preserve shared language, map decisions, transfer verified state, or provide
bounded delegation and critique.

Engineering skills cover technical research, accepted implementation intent,
work slicing, context-derived web design and frontend implementation,
established-repository changes, greenfield prototypes, difficult diagnosis,
and review. `web-design` owns web UX and visual direction through verified,
fixture-backed frontend behavior when interface design is the primary outcome.
`implementation-spec` owns accepted intent;
`work-slicing` may decompose it but may not change it. `change-review` is the
sole owner of technical review judgment and is read-only unless the user
separately requests fixes. Snapshot audits stay outside `change-review`; bounded
technical audits fit `technical-research`. Large-repository applicability uses
repository structure and affected contracts, not a source-line threshold.
Separate specification and slicing artifacts are conditional on the task, not
prerequisites for ordinary implementation.

The AI family has five callable execution leaves for data preparation, insight
development, representation work, problem modeling, and performance. The
explicit-only `ai-pipeline` skill is a one-time framing manual, not a controller
that invokes or manages those leaves. The family stops at an evaluated
solution; production integration remains engineering work.

Writing skills own long-form prose. `prose-voice` handles general essays,
reports, articles, speeches, and ordinary blog posts. `blog-writing` owns
VitePress-ready posts and CTF writeups for N00bcak's site. Documentation, code
comments, interface copy, advertisements, social posts, and short messages
remain native work.

## Operating Taxonomy

Authority and interaction lifetime are separate. A bounded contributor owns one
result and returns control. A multi-turn contributor owns a narrow explicit
exchange but not the overall process. A multi-step governor owns an explicitly
authorized cross-skill process and its durable state. A session overlay changes
how another active skill works without owning its result. Explicit manuals,
such as `ai-pipeline`, recommend approaches and stop; they are not governors.

Every callable skill uses one of three authoring contracts:

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

Only `multi-step-governance` may create or update a matching
`.mecha/work/<slug>/index.md` record. Contributors return verified artifacts;
the governor links them without selecting or invoking skills. For technical
review, it records the report outcome and gates closure on recorded blockers or
an explicit waiver; it never evaluates or adjudicates technical claims.

Accepted goals, criteria, constraints, and non-goals remain user-authoritative.
New evidence may challenge them but cannot silently rewrite them. Plan
acceptance does not activate governance. Small ad-hoc tasks create no record. Resume candidates are advisory and never reactivate an
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

Portable skill frontmatter contains `name`, `description`, and, for
explicit-only skills, `metadata.invocation: explicit`. That metadata is a
declaration no host enforces; adapters enforce it. Codex uses
`agents/openai.yaml`, and `install.sh` renders a Claude copy of `SKILL.md`
with `disable-model-invocation: true` while linking every other resource back
to the source. Install-time rendering keeps host-only fields out of shared
frontmatter, which Codex validation rejects. Skill names are shared by every
host, so names must avoid host built-ins rather than rely on per-host aliases.
Rendered copies refresh on reinstall.

Project commands, private infrastructure, and repository-specific facts stay
in local instructions or adapter skills. The global toolbox should not make a
small local edit require changes across unrelated skills.

The repository-root `AGENTS.md` governs development of Mecha Suit itself. It
is separate from the consumer prompt under `templates/`; examples may show
customization but never become install sources.

The consumer prompt separates substantive completion from presentation length:
the request determines both what must be fulfilled and how much explanation is
useful. Evidence limits qualify the result without making ideal information a
prerequisite for progress. Investigation remains the agent's responsibility
within available capabilities; assumptions support analysis but never supply
missing authorization to edit. These universal rules compose with personal
preferences without activating an overlay or durable process.

## Deliberately Deferred

Mecha Suit does not currently include a generic router, a capability registry,
an adaptive multi-iteration AI controller, or a guaranteed Claude live-eval
adapter. Add one only after a repeated, measured need shows that native host
behavior and narrow leaves no longer suffice.
