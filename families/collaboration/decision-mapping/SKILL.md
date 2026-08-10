---
name: decision-mapping
description: Map and resolve decisions blocking a long-horizon effort until its destination is ready for implementation specification.
---

# Decision Mapping

## Purpose

Make a large, uncertain effort navigable by recording the destination, decision
dependencies, resolved choices, and the next decision that can be made without
guessing.

## Do Not Use

- Do not use for a feature already clear enough to specify.
- Do not turn unknown territory into speculative tickets.
- Do not implement the destination or manage later execution.
- Do not spawn, request, or rely on subagents.

## Needs

- A proposed destination and reason it matters.
- Known constraints, decisions, evidence, and exclusions.
- The user-owned judgments that cannot be discovered from the environment.

## Returns

- A decision map with destination, resolved choices, open decisions,
  dependencies, unclear territory, and out-of-scope work.
- One next decision or evidence task on the current frontier.
- A clear handoff to `implementation-spec` when the route is resolved.

## Done Conditions

- The destination is precise enough to bound the map.
- Every open decision is actionable now or remains explicitly unclear.
- Resolved decisions retain their rationale and evidence pointers.
- The path to an implementation contract is clear, or a specific blocker is
  recorded.

## Workflow

1. Establish the destination before mapping the route.
2. Separate settled decisions, sharp open decisions, unclear future territory,
   and out-of-scope work.
3. Add dependency edges only when one decision genuinely requires another.
4. Work the next unblocked decision. Discover facts locally. When the primary
   task becomes evidence gathering, record product or technical research as the
   next task shape; ask the user only for judgments they own.
5. Record the answer once with its rationale and evidence. Update dependent
   decisions and clarify newly visible territory.
6. Stop mapping when no material decision remains before specification.

Use stable identifiers such as `D-1` and names that remain readable without the
identifier. A decision map is an index of decisions, not a store for duplicated
research, specifications, or implementation plans.

## Lifecycle Participation

When the user explicitly requests durable lifecycle planning or accepts the map
as lifecycle intent, read `../../../shared/rubrics/lifecycle-contract.md` unless
its current contents are already available in context. Then activate lifecycle
mode, store the map at
`.mecha/work/<slug>/decision-map.md` when no project convention exists, and link
research, domain, prototype, and decision artifacts from the work index.
Implicit selection alone does not authorize filesystem writes; until the user
authorizes persistence, keep the draft map in the conversation.

Do not accept the implementation contract; `implementation-spec` owns that
transition.

## Persistence And Yield

Progress is a sharper destination, resolved decision, corrected dependency, or
actionable question. Work one frontier item or identify its exact prerequisite,
then return the map state without drifting into implementation.
