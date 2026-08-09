# Subagent Collaboration Plan

## Status

This is the historical design record, not runtime behavior. The implemented
contracts live in `families/collaboration/parallel-subagents/` and
`families/collaboration/second-opinion/`; current authorization policy lives in
`AGENTS.md` and focused tests.

## Goal

Replace broad council-style orchestration with two narrow collaboration skills:

- `parallel-subagents` delegates independent, bounded work that can proceed
  concurrently.
- `second-opinion` obtains an independent review of an artifact, conclusion,
  or proposed action.

Both skills keep the main process accountable. The main process owns scope,
permissions, decisions, integration, verification, and the final response.
Subagents supply evidence; they do not become a hidden decision layer.

## Design Principles

1. **Main-process ownership:** delegation never transfers responsibility for
   correctness, safety, or completion.
2. **Minimum context:** give each subagent only the task-local artifacts,
   constraints, and success condition it needs.
3. **Artifact-first exchange:** prefer paths, diffs, logs, prompts, and test
   output over replaying the full conversation.
4. **Independent judgment:** do not leak the desired answer or another
   agent's conclusion when independence is part of the evaluation.
5. **Bounded delegation:** use the fewest subagents needed; prohibit nested
   delegation and open-ended background work.
6. **Visible reconciliation:** the main process reports material disagreement,
   its resolution, verification, and remaining uncertainty.
7. **No hidden chain-of-thought:** request concise findings, evidence,
   assumptions, and recommendations—not private reasoning traces.

## Proposed Skill: `parallel-subagents`

### Purpose

Run two or more genuinely independent subtasks concurrently when doing so
reduces elapsed time or prevents unrelated context from accumulating in the
main process.

### Use When

- Two or more bounded subtasks have separate inputs or change surfaces.
- Each subtask can make useful progress without another subtask's output.
- Parallel work materially improves latency, coverage, or context isolation.
- The main process can inspect and reconcile every returned artifact.

### Do Not Use

- The task is sequential or one result determines the next action.
- One focused subtask is sufficient.
- Subtasks would edit overlapping files or shared mutable state without a
  safe ownership boundary.
- Delegation would merely avoid work the main process should understand.
- Required context is so entangled that every subagent needs the full thread.

### Needs

- One sentence defining the shared outcome.
- A bounded assignment and success condition for each subagent.
- Explicit artifact, file, tool, and mutation boundaries.
- Relevant permissions and forbidden actions.
- The evidence each subagent must return.

### Returns

Each subagent returns:

```yaml
assignment: "<bounded task>"
status: "complete | partial | blocked"
artifacts: ["<path, diff, result, or none>"]
evidence: ["<command, observation, or citation>"]
assumptions: ["<material assumption>"]
risks: ["<remaining risk>"]
recommended_next_action: "<one action or null>"
```

The main process returns the integrated outcome, conflicts found, choices made,
verification performed, and unresolved risks.

### Done Conditions

- Every assignment has a distinct owner and non-overlapping boundary.
- All live subagents are collected or explicitly stopped.
- The main process inspects material outputs rather than forwarding them
  blindly.
- Conflicting edits or conclusions are reconciled explicitly.
- Final verification covers the integrated state.

### Design Boundaries

- Prefer two or three subagents. More requires a concrete coverage argument.
- Spawn only work that can proceed independently alongside useful main-process
  work.
- Default subagent work to read-only when mutation is unnecessary.
- Never let a subagent spawn another subagent.
- Do not use a generic specialist-role registry. Describe the actual bounded
  assignment.

### Workflow Outline

1. Partition the task by independent artifact or change surface.
2. State shared constraints once, then create minimal per-subagent packets.
3. Spawn the fewest useful subagents.
4. Continue main-process work that does not overlap.
5. Collect structured returns and inspect their evidence.
6. Resolve disagreement and integrate changes.
7. Run final verification from the main process.

## Proposed Skill: `second-opinion`

### Purpose

Obtain one independent critique before the main process commits to a
high-impact conclusion, plan, diagnosis, or diff.

### Use When

- A decision is consequential, uncertain, or difficult to reverse.
- A diagnosis has plausible competing explanations.
- A plan or diff would benefit from adversarial review.
- Anchoring, confirmation bias, or missed edge cases are material risks.

### Do Not Use

- The answer is routine and directly verifiable.
- The user asked for execution and an ordinary test provides stronger evidence.
- The reviewer cannot access the artifact or evidence being judged.
- The main process wants endorsement rather than an independent assessment.

### Needs

- The artifact or question under review.
- The decision criteria and relevant constraints.
- Raw evidence needed to evaluate it.
- A statement of what the reviewer must not change.

Do not provide the main process's preferred answer, confidence, or detailed
rationale unless the task is specifically to critique that rationale.

### Returns

```yaml
verdict: "agree | disagree | uncertain"
material_findings:
  - "<finding tied to evidence>"
missing_evidence:
  - "<gap or none>"
alternative: "<better conclusion or action, if any>"
confidence: "high | medium | low"
recommended_check: "<one decisive check or null>"
```

The main process reports whether it accepted or rejected each material finding
and why.

### Done Conditions

- The review is independent enough for the stated purpose.
- Every material finding points to evidence or a reproducible check.
- The main process adjudicates the review rather than treating it as a vote.
- Any decisive recommended check is run when it is safe and in scope.

### Design Boundaries

- Use exactly one reviewer by default.
- Default to read-only access and no external mutations.
- Review artifacts, not personalities or speculative intent.
- A second opinion complements verification; it does not replace tests,
  authoritative sources, or user decisions.

### Workflow Outline

1. Freeze or identify the artifact to review.
2. Prepare a context-minimal, non-leading review packet.
3. Spawn one reviewer with explicit evaluation criteria.
4. Continue independent verification in the main process.
5. Compare the review with direct evidence.
6. Accept, reject, or qualify each material finding.
7. Record the resulting decision and uncertainty.

## Shared Runtime Guardrails

When these skills are implemented:

- Only `parallel-subagents` and `second-opinion` may authorize subagent use.
- Other skills may be used as task context but must not spawn, request, or
  depend on subagents.
- The skills must check whether the host exposes subagent capability before
  promising delegation.
- Subagents receive no broader permissions than the main task authorizes.
- Destructive actions, publication, external messages, and scope expansion
  remain main-process decisions.
- Cancellation and cleanup are mandatory when delegated work is no longer
  useful.

## Implementation Steps

1. Create both skills under `families/collaboration/` with the repository's
   specialist contract.
2. Keep each `SKILL.md` concise; add no scripts or references initially.
3. Update `AGENTS.md`, README, maintenance documentation, collaboration specs,
   and repo templates to authorize only these two skills.
4. Replace the temporary “no subagent authorization” test with checks that:
   - exactly these two skills may contain authorization language;
   - neither permits nested delegation;
   - both preserve main-process ownership and structured evidence returns;
   - `parallel-subagents` requires independent, non-overlapping work;
   - `second-opinion` requires a non-leading review packet and main-process
     adjudication.
5. Add selection examples for independent parallel work, sequential work,
   consequential review, and routine verification.
6. Validate both skills with Codex's skill validator.
7. Forward-test:
   - a polyglot change with separate file ownership;
   - two independent research artifacts;
   - a diagnosis reviewed without the preferred conclusion;
   - a case where delegation should be refused because work is sequential.
8. Run `uv sync --dev`, `./test.sh`, and `git diff --check`.

## Promotion Criteria

Implement the skills only when the host's subagent interface is stable enough
to test these contracts. Promote them to callable status when forward tests
show that they:

- reduce main-thread context without losing decision traceability;
- avoid duplicate or overlapping work;
- surface disagreement rather than averaging it away;
- leave the main process able to explain and verify the final outcome.
