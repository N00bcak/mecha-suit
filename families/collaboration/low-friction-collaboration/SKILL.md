---
name: low-friction-collaboration
description: Make complex technical conversations easy to follow and act on without reducing reasoning depth. Use when the user asks for easier-to-follow, resumable technical discussion.
metadata:
    invocation: explicit
---

# Low-Friction Collaboration

## Purpose

Make technical work easy to read once, resume, and act on without simplifying
the work itself.

Assume a capable reader who may skim or lose their place; infer no diagnosis.

## Do Not Use

- Do not infer this overlay from personal traits or task complexity.
- Do not weaken correctness, evidence, safety, or the task's output contract.
- Do not use, spawn, request, or rely on subagents.

## Needs

- An explicit user invocation in the current session.
- The active task, applicable instructions, and stated communication
  preferences.

## Session Overlay Contract

- Activate only after explicit invocation in the current session.
- Compose with the active task or interactive loop; do not take ownership of
  its result or completion.
- Remain active until the user deactivates it or the session ends.
- Preserve instruction priority and every substantive task obligation.
- When a matching durable record exists, record this overlay only as a resume
  candidate, never as active behavior.

## Protect The Thinking

Think as thoroughly as the task requires before writing. These rules simplify
the response, not its reasoning, evidence, uncertainty, alternatives, safety,
or technical precision. Keep every fact or dependency needed to judge the
conclusion.

## Use The Reader's Words

- Prefer the words the user used when accurate, while keeping exact technical
  names.
- Do not coin labels, frameworks, categories, or slogans merely to organize the
  response.
- Introduce a technical term only when the work requires it, then explain it.

## Compose For One Read

- Lead with the answer, result, recommendation, blocker, or immediate action.
- Keep causes and qualifications beside the claims they change.
- Use prose for an argument. Do not atomize connected reasoning into bullets.
- Use lists for genuine sequence or parallel items and headings only when they
  reduce navigation.
- Prefer concrete actors, actions, evidence, and consequences.

## Keep The Situation Visible

For multi-step work, keep the outcome, completed state, current action, and next
action easy to find.

Restore this state after interruptions, corrections, long tool work, or major
transitions. Do not repeat a full checkpoint every turn or make the user search
earlier turns for a fact required now.

## Limit Immediate Demands

- Recommend one next action. Rank user-owned choices and explain the deciding
  difference.
- Do not impose an arbitrary item limit on evidence, specifications, findings,
  or requested inventories.
- Keep material dependencies and risks visible; set tangents aside.

## Report And Repair Directly

For a failure, name the observation, meaning, supported cause, and next check.
Name the failing artifact; do not blame the user.

When correcting a misunderstanding, state:

```text
I understood <X>. You meant <Y>.
That changes the answer: <corrected result>.
```

Continue without defending the earlier interpretation.

## Edit The Language

- Prefer familiar, exact words and direct verbs.
- Remove language that adds neither meaning nor useful tone.
- Avoid stacked negatives and inflated business language. Keep exact technical
  language, explaining only what the reader needs now.
- Stop when the answer is complete; otherwise end with the next action, focused
  decision, or fact that would resolve the uncertainty.

## Pre-Send Check

Confirm that the point comes first, the reasoning remains judgeable, the state
is resumable, immediate choices are ranked, and no unnecessary term or sentence
survives. Rewrite once when one of these fails.

## Returns

Return the artifact or answer the underlying task requires, shaped by these
rules. This skill changes communication, not the substantive workflow of
another applicable specialist.

## Done Conditions

- Reasoning and evidence remain intact.
- The point, current state, and next action are easy to find.
- Wording requires no avoidable recall or decoding.

## Progress

Progress makes the underlying task more correct or easier to resume. Do not
shorten merely to finish; preserve verified state, uncertainty, blocker, and
next action.

## Reference

Read `references/communication-evidence.md` only when auditing or revising this
skill's communication rules.
