# Maintenance Playbook

## Choose an interaction contract

Create a skill directory only when its runtime behavior is fully authored and
callable. Keep future concepts in subsystem specs until then.

- Start bounded outcome work from `templates/task-skill.template.md`.
- Start behavior that composes across a session from
  `templates/session-overlay.template.md`.
- Start a multi-turn exchange that owns conversational control from
  `templates/interactive-loop.template.md`.

Task skills are the default and may still span turns or sessions. An overlay
declares `Session Overlay Contract`; a loop declares
`Interactive Loop Contract`. Do not encode this model in frontmatter or a
central registry.

Overlays and loops require explicit invocation metadata. At most one loop is
active at a time. An overlay may compose with the active task or loop without
owning its result.

## Maintain lifecycle-aware leaves

- Keep native selection in leaf descriptions; the work index never routes or
  invokes skills.
- State each leaf's own lifecycle participation in its `SKILL.md` and point to
  `shared/rubrics/lifecycle-contract.md` for shared state and authority rules.
- Preserve ad-hoc behavior when no matching work record exists.
- Update `templates/work-index.template.md`, lifecycle tests, README, platform
  notes, and collaboration or engineering specs when the state contract changes.
- Keep accepted intent user-authoritative and detailed phase output behind
  artifact pointers.

## Add a new specialist leaf

1. Create `families/<family>/<skill-name>/SKILL.md`.
2. Start from the template matching its interaction lifetime.
3. Add `references/` or `scripts/` only when they carry useful content or preserve an existing scaffold shape.
4. Define trigger boundaries using purpose, use cases, exclusions, needs, and returns.
5. Update `README.md` and `shared/examples/skill-selection-examples.md`.
6. Write frontmatter that lets Codex select the leaf directly.

Do not add a router for new leaves. Native selection should rely on leaf
frontmatter and clear boundaries.

Explicit-only skills such as overlays, loops, and `ai-pipeline` require
`agents/openai.yaml` with `allow_implicit_invocation: false`. Do not let them
become implicit routers.

Do not add `agents/` metadata to task skills by default. Use it when task
invocation must be explicit or when host display materially improves use;
overlays and loops always require explicit-invocation metadata.

Write frontmatter descriptions as one constructive sentence, normally around
120 characters. Name the owned action and a positive task or artifact cue.
Avoid contrastive exclusions, workflow summaries, and repeated repo-wide
policies. Keep a few diagnostic cues only when adjacent skill categories need
them. Treat this as editorial guidance rather than a validator limit.

## Verify changes

Run:

```bash
uv sync --dev
./test.sh
```

`uv sync --dev` creates `.venv` from the committed lockfile. PyYAML is the only
third-party development dependency because Codex's `skill-creator` validator
uses it for frontmatter parsing. Do not add Python packages unless a repository
test or deterministic development tool requires them; runtime skills and the
install scripts must remain independent of this environment.

The test command validates Codex-compatible YAML frontmatter, shell syntax,
install/uninstall behavior, frontmatter names, routing-family layout, and
subagent boundary rules. Add focused checks there when a new executable
invariant is introduced.

## Write open-ended skills

Open-ended skills must be persistent without flailing.

- Define a bounded first-pass workflow.
- Define what useful progress means for the skill.
- Include at least two distinct progress strategies when the domain supports it.
- Define valid stop states and blockers.
- Require a compact decision record: assumptions, attempts, evidence, blocker, confidence, and next step.
- Avoid broadening scope as a substitute for progress.

"I ran out of ideas" must mean "I exhausted the bounded strategy set," not "I am uncertain." Uncertainty is a signal to narrow the task, inspect evidence, ask a focused question, or yield with a specific blocker after the persistence floor is met.

Use `shared/rubrics/persistence-yield-rubric.md` for shared language.

Use `shared/rubrics/change-discipline.md` as the minimum coding floor when
multiple families produce code. Add family-specific coding or performance
guidance when the domain needs materially different tradeoffs rather than
forcing application-development conventions everywhere.

## Choose where future behavior belongs

- Leave ordinary ambiguity reduction and focused missing-input questions to the
  host agent.
- Put reusable domain execution methods in a specialist leaf.

## Govern subagent use

- Only `parallel-subagents` and `second-opinion` may authorize subagent use.
- Both must preserve main-process ownership, prohibit nested delegation, check
  host capability, and require structured evidence returns.
- All other skills must not spawn, request, assume, or depend on subagents.
- Any change to this allowlist is an explicit architecture change requiring
  matching tests, templates, README, and collaboration specs.
