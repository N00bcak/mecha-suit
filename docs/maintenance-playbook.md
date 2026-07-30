# Maintenance Playbook

## Expand a specialist stub into a full skill

1. Keep the existing contract sections intact.
2. Add only the workflow needed for repeated real tasks.
3. Move passive background material into `references/`.
4. Add scripts only when they reduce repeated procedural text or improve deterministic reliability.
5. Keep the `Do Not Use` section current so native selection preserves clean boundaries.
6. Preserve the rule that only `parallel-subagents` and `second-opinion` may
   authorize subagent use.
7. Remove the explicit stub warning only when the skill is genuinely fully authored.

Expansion is complete when the skill can handle its intended task without requiring repo-specific facts and without becoming a broad generalist.

## Add a new specialist leaf

1. Create `families/<family>/<skill-name>/SKILL.md`.
2. Start from `templates/leaf-skill.template.md`.
3. Add `references/` or `scripts/` only when they carry useful content or preserve an existing scaffold shape.
4. Define trigger boundaries using purpose, use cases, exclusions, needs, and returns.
5. Update `README.md` and `shared/examples/skill-selection-examples.md`.
6. Write frontmatter that lets Codex select the leaf directly.

Do not add a router for new leaves. Native selection should rely on leaf
frontmatter and clear boundaries.

Explicit-only manuals such as `interview-me` and `ai-pipeline` require
`agents/openai.yaml` with `allow_implicit_invocation: false`. Do not let them
become implicit routers.

Contract-complete stubs must say `This is a stub. NEVER CALL THIS SKILL.` until they are fully authored. Do not let a stub sound executable or production-ready.

Do not add `agents/` metadata to specialist leaves by default. Use host metadata only when it materially improves routing or invocation behavior.

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
