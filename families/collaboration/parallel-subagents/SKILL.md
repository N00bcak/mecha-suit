---
name: parallel-subagents
description: Delegate independent bounded subtasks concurrently and integrate their evidence into one verified outcome.
---

# Parallel Subagents

## Purpose

Run two or more independent subtasks concurrently when delegation materially
improves latency, coverage, or context isolation.

## Use When

- Two or more bounded subtasks have separate inputs or change surfaces.
- Each subtask can progress without another subtask's output.
- The main process can inspect and reconcile every returned artifact.

## Do Not Use

- The work is sequential or one result determines the next action.
- One focused subtask is sufficient.
- Subtasks would edit overlapping files or shared mutable state.
- Required context is so entangled that each subagent needs the full thread.
- Delegation would avoid work the main process must understand.

## Needs

- One sentence defining the shared outcome.
- A bounded assignment and success condition for each subagent.
- Explicit artifact, file, tool, mutation, permission, and forbidden-action
  boundaries.
- The evidence each subagent must return.

## Returns

Require each subagent to return:

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

## Done Conditions

- Every assignment has a distinct owner and non-overlapping boundary.
- All live subagents are collected or explicitly stopped.
- The main process inspects material outputs and reconciles conflicts.
- Final verification covers the integrated state.

## Workflow

1. Check that the host exposes subagent capability. If not, continue without
   promising delegation.
2. Partition work by independent artifact or change surface.
3. Spawn the fewest useful subagents, normally two or three, with task-local
   context.
4. Continue useful main-process work outside their ownership boundaries.
5. Collect every structured return and inspect its evidence.
6. Reconcile disagreements and integrate accepted work.
7. Verify the combined outcome from the main process.

Subagents receive no broader permissions than the main task authorizes.
Subagents must not spawn or request subagents.
Destructive actions, publication, external messages, scope expansion, and final
decisions remain with the main process. Cancel and collect delegated work once
it is no longer useful. Request concise findings and evidence, never hidden
chain-of-thought.

## Persistence And Yield

Useful progress means a completed bounded assignment, inspected evidence, a
reconciled conflict, or verified integrated state.

Before yielding, collect or stop all live subagents, inspect available returns,
and confirm further work would repeat or require a user-owned decision. Return
the assignments, evidence, integration status, blocker, and next recovery step.

## Designer Notes

Keep this as an explicit collaboration primitive, not a role registry or broad
orchestrator. Default delegated work to read-only when mutation is unnecessary.

## Future Workflow Outline

- Improve the contract only when repeated forward tests expose a concrete gap.
- Add no scripts or references until they improve deterministic execution.
