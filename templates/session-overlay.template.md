---
name: <overlay-name>
description: <one constructive sentence describing the session behavior and explicit invocation cue>
---

# <Overlay Title>

## Purpose

<What this overlay changes about collaboration without owning the primary task.>

## Do Not Use

- <Situation where this behavior would interfere with the task.>
- Do not spawn, request, or rely on subagents.

## Needs

- An explicit user invocation in the current session.
- The active task, applicable instructions, and user preferences.

## Session Overlay Contract

- Activate only through explicit user invocation in the current session.
- Compose with the active task or interactive loop; do not take ownership of
  its outcome or completion.
- Preserve instruction priority, correctness, evidence, safety, and the active
  task's output contract when shaping behavior.
- Remain active until the user deactivates it or the session ends.
- When durable work state already exists, follow the shared resume-candidate
  contract without treating recorded state as activation authority.

<Add the overlay's operational behavior in concise domain-specific sections.>

## Returns

<Describe the effect on the underlying task's response or artifact.>

## Done Conditions

- <Condition showing the overlay was applied without weakening the task.>
- <Condition showing state or next action remains clear.>

## Lifecycle Participation

<Link the shared lifecycle contract when the overlay may use matching work
records. Read it only when it is not already available in the current context.
Do not create durable state merely to remember the overlay.>

## Persistence And Yield

<Name the overlay-specific progress or stop condition without repeating the
underlying task or host persistence contract.>
