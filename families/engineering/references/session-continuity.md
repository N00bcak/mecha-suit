# Session Continuity

Use `../../../shared/rubrics/lifecycle-contract.md` as the single work-state
contract for engineering tasks.

## When To Persist

Create or update `.mecha/work/<slug>/index.md` only for multi-session work,
broad change surfaces, migrations, significant coordination risk, or explicit
user requests. Small self-contained work keeps state in the conversation.

Use `continuity` mode for ordinary durable state. Use `lifecycle` mode only
under the activation rules in the shared contract.

## Resume Check

Before trusting a work record:

1. Verify referenced files and artifacts exist.
2. Compare its Git branch, recent history, and dirty paths with current state.
3. Re-run the recorded focused check when practical.
4. Update stale implementation state before doing new work.
5. Preserve accepted intent and surface any contradiction with current files.

## Update Cadence

Update at natural boundaries:

- after orientation;
- after a logical implementation or investigation unit;
- when evidence changes the next action;
- after verification or review;
- before yielding.

Keep `Current Evidence` concrete and `Next` immediately actionable. Point to
detailed logs, plans, and reviews instead of expanding the index indefinitely.

## Legacy `SCRATCHPAD.md`

Read and verify an existing scratchpad when it matches the task. Offer to
reconcile it into the work index. Do not create a new scratchpad, and do not
move or delete a user's existing file without explicit authorization.
