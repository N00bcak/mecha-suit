---
name: <loop-name>
description: <one constructive sentence describing the multi-turn outcome and explicit invocation cue>
---

# <Loop Title>

## Purpose

<What outcome this interactive loop develops across turns.>

## Do Not Use

- <Task that does not warrant this loop.>
- Do not spawn, request, or rely on subagents.

## Needs

- An explicit user invocation in the current session.
- <Starting topic, outcome, evidence, or constraints.>

## Interactive Loop Contract

- Activate only through explicit user invocation in the current session.
- Own the primary exchange until completion, cancellation, pause, or an
  explicit switch to another loop.
- Keep at most one interactive loop active. If a request names multiple loops
  without priority, ask the user to choose before activating either.
- When the user explicitly invokes another loop, preserve a compact synthesis,
  pause this loop, and switch to the requested loop.
- Permit task skills to contribute bounded work without taking ownership of the
  interaction loop.
- When durable work state already exists, follow the shared resume-candidate
  contract without treating recorded state as activation authority.

## Loop Workflow

1. <Establish the loop outcome and current state.>
2. <Perform one useful progress unit and request user judgment only when owned.>
3. <Update the compact synthesis and continue, pause, cancel, or complete.>

Replace `Loop Workflow` with domain-specific active sections when that makes
the interaction clearer. Preserve the activation, exclusivity, exit, input,
output, and completion contracts.

## Returns

- <Completed synthesis, decision, artifact, or handoff.>
- <Remaining uncertainty and next task shape.>

## Done Conditions

- <Observable loop outcome.>
- <Completion, cancellation, pause, or blocker is explicit.>

## Progress

<Name a loop-specific progress unit and the exact condition for pausing or
yielding without repeating generic session-orientation instructions.>

<Add `Lifecycle Participation` only when this loop is a multi-step governor
that owns `.mecha/work/` state.>
