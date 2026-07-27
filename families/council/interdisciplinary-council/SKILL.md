---
name: interdisciplinary-council
description: Synthesize genuinely cross-domain specialist perspectives into one recommendation; may use subagents.
---

# Interdisciplinary Council

## Purpose

Produce an integrated recommendation for genuinely cross-domain tasks where one specialist perspective is likely insufficient.

This skill is not a general fallback, planner, or router. It is a synthesis layer for hard tasks that need controlled specialist disagreement and reconciliation.

## Use When

- The task spans multiple specialist families.
- One specialist alone is likely to miss a material risk or opportunity.
- Competing specialist interpretations need reconciliation.
- A hard task benefits from controlled parallel specialist analysis.

## Do Not Use When

- One specialist is clearly sufficient.
- The task is merely ambiguous or underspecified.
- One focused question or an explicit low-risk assumption resolves the ambiguity.
- The user only wants a simple first-pass answer.
- The task needs ordinary implementation planning without cross-domain conflict.
- The relevant non-council specialists are still marked `This is a stub. NEVER CALL THIS SKILL.`

## Subagent Authority

This is the only skill in the toolbox allowed to use subagents. Use subagents only when the host platform and current agent policy permit them.

Allowed subagent archetypes must inherit from exactly one fully authored non-council specialist leaf.

Currently eligible inherited leaves:

- `product-co-design`
- `large-codebase-change`
- `prototype-builder`
- `ctf-triage`
- `reverse-ctf`
- `pwn-ctf`
- `crypto-ctf`
- `web-ctf`
- `forensics-ctf`
- `ai-ctf`
- `misc-ctf`
- `ai-data-preparation`
- `ai-insight-development`
- `ai-representation-workbench`
- `ai-problem-modeling`
- `ai-performance`

Do not use stub specialist leaves as council subagents.

Do not inherit from `interview-me`, `low-friction-collaboration`,
`ai-pipeline`, or any stub leaf. Do not create council-specific subagent roles.
The council itself is not one of the inherited leaves.

## Spawning Policy

- Spawn the fewest specialists needed.
- Prefer two or three focused subagents over many broad ones.
- Give each subagent one narrow question.
- Tell each subagent which leaf it inherits from.
- Keep subagent work independent.
- Do not ask subagents to synthesize each other.

Each subagent must return:

```yaml
inherited_leaf: "<leaf-name>"
assumptions: ["<explicit assumptions>"]
findings: ["<material findings>"]
confidence: "high | medium | low"
unresolved_risks: ["<remaining risks>"]
useful_progress_made: true | false
next_distinct_attempt: "<specific next attempt or null>"
blocker_if_any: "<specific blocker or null>"
recommended_next_action: "<one action>"
```

## Council Persistence Contract

- Define the decision or conflict the council is resolving before consulting specialists.
- Consult the fewest relevant specialists, normally two or three.
- Compare specialist assumptions before comparing conclusions.
- Attempt conflict resolution using evidence quality, task objective, and risk severity.
- If conflict remains, ask whether one narrow second-pass specialist question would produce new evidence.
- Allow at most one second-pass round, and only when the exact discriminating question is known.
- Keep working while the next action is bounded, in-scope, and evidence-producing.

Do not give up early:

- Do not yield before consulting the minimum relevant perspectives.
- Do not yield before naming the conflict or blocker.
- Do not yield because one specialist failed.
- Do not spawn extra specialists unless each has a distinct evidence-producing question.
- Do not treat disagreement, uncertainty, or low confidence as a yield condition by itself.

## Council Yield Conditions

The council may yield only when no bounded specialist question, artifact check, or user decision can move the synthesis forward.

Valid yield states:

- `blocked_needs_user_decision`: the next useful step depends on a user-owned decision.
- `blocked_missing_artifact`: the next useful step depends on an unavailable artifact, command output, file, dataset, binary, or service detail.
- `exhausted_bounded_inquiry`: the council completed the bounded inquiry and another step would repeat prior work, require unsafe guessing, or leave council scope.

When yielding, name the blocker and why more council work would repeat. Do not describe the reason as "low-value work."

## Synthesis Procedure

1. Confirm council mode is justified.
2. Define the decision or conflict to resolve.
3. Select the minimum inherited leaves needed.
4. Frame one narrow question per selected leaf.
5. Collect subagent outputs, or perform the same leaf-bounded analysis locally if subagents are unavailable.
6. Identify agreements, conflicts, and gaps.
7. Resolve conflicts by prioritizing evidence quality, task objective, and risk severity.
8. If unresolved, consider one exact second-pass question that would discriminate between the remaining options.
9. Produce an integrated recommendation or a valid yield state with verification status.

## Conflict Resolution

- Prefer direct evidence over plausible domain intuition.
- Prefer reversible recommendations when confidence is low.
- Surface unresolved disagreement instead of hiding it.
- Do not average incompatible recommendations.
- If a specialist exceeds its inherited boundary, discount that portion and state why.

## Output Contract

Return:

```yaml
status: "recommendation | blocked_needs_user_decision | blocked_missing_artifact | exhausted_bounded_inquiry"
integrated_conclusion: "<short conclusion>"
specialists_consulted: ["<inherited leaf names>"]
conflicts_between_specialists: ["<conflicts or none>"]
chosen_recommendation: "<recommended path or null>"
verification_status: "<what was checked and what was not>"
remaining_uncertainty: ["<open risks>"]
persistence_performed:
    - "<primary specialist pass>"
    - "<conflict comparison>"
    - "<second-pass question considered or attempted>"
useful_progress_found: true | false
blocker: "<specific blocker or null>"
why_more_work_would_repeat: "<specific reason or null>"
next_recovery_step: "<ask user | provide artifact | route to skill | stop>"
next_action: "<one concrete next step>"
```

## References

- Read `references/council-escalation-checklist.md` before escalating a borderline task.
- Read `references/subagent-use-checklist.md` before spawning subagents.
- Use `../../../shared/rubrics/persistence-yield-rubric.md` when the council might yield.
