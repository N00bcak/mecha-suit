# Maintenance Playbook

## Expand a specialist stub into a full skill

1. Keep the existing contract sections intact.
2. Add only the workflow needed for repeated real tasks.
3. Move passive background material into `references/`.
4. Add scripts only when they reduce repeated procedural text or improve deterministic reliability.
5. Keep the `Do Not Use` section current so the router can preserve clean boundaries.
6. Preserve the rule that specialist leaves do not spawn, request, or rely on subagents.
7. Remove the explicit stub warning only when the skill is genuinely fully authored.

Expansion is complete when the skill can handle its intended task without requiring repo-specific facts and without becoming a broad generalist.

## Add a new specialist leaf

1. Create `families/<family>/<skill-name>/SKILL.md`.
2. Start from `templates/leaf-skill.template.md`.
3. Add `references/` or `scripts/` only when they carry useful content or preserve an existing scaffold shape.
4. Define trigger boundaries using purpose, use cases, exclusions, needs, and returns.
5. Update `README.md` and `shared/examples/routing-examples.md`.
6. Update `task-router` only if the new leaf changes top-level routing decisions.

Do not redesign the router for each new leaf. The router should rely on leaf purpose, trigger boundary, and minimum required input.

Contract-complete stubs must say `This is a stub. NEVER CALL THIS SKILL.` until they are fully authored. Do not let a stub sound executable or production-ready.

Do not add `agents/` metadata to specialist leaves by default. Use host metadata only when it materially improves routing or invocation behavior.

## Verify changes

Run:

```bash
./test.sh
```

The test command validates shell syntax, install/uninstall behavior, frontmatter names, routing-family layout, and subagent boundary rules. Add focused checks there when a new executable invariant is introduced.

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

## Choose where future behavior belongs

- Put classification, next-skill choice, and minimal handoff context in `task-router`.
- Put ambiguity reduction and one focused missing-input question in `task-clarifier`.
- Put reusable domain execution methods in a specialist leaf.
- Put controlled cross-domain synthesis in `interdisciplinary-council`.

If the task needs one domain, do not use the council. If the task is merely unclear, use the clarifier before considering the council.

## Govern subagent use

- Keep subagent permission exclusive to `interdisciplinary-council`.
- Council subagents must map to one existing non-council specialist leaf.
- Do not create council-specific subagent roles outside the inherited leaf set.
- Prefer two or three focused subagents over broad parallel analysis.
- Require each subagent to return assumptions, findings, confidence, unresolved risks, and a recommended next action.
- Make the council synthesize. Subagents must not synthesize each other.

When adding a new specialist that should be council-eligible, update the council's allowed inherited leaf list deliberately.
