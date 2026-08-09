---
name: implementation-spec
description: Turn settled intent and evidence into an accepted implementation contract with criteria, constraints, and non-goals.
---

# Implementation Specification

## Purpose

Create a decision-complete, user-owned contract for what an engineering change
must accomplish before implementation structure can distort its intent.

## Use When

- Product or engineering direction is settled enough to specify.
- A planning-mode conversation must become an implementation contract.
- Existing notes, decisions, or prototypes need synthesis into acceptance terms.

## Do Not Use

- Do not use while consequential product or domain decisions remain unresolved.
- Do not decompose the contract into delivery slices; use `work-slicing`.
- Do not implement, publish to an issue tracker, or silently accept the contract.
- Do not spawn, request, or rely on subagents.

## Needs

- Settled goal, evidence, decisions, constraints, and non-goals.
- Current system behavior and relevant compatibility obligations.
- User authority to confirm semantic intent.

## Returns

- Draft or accepted goal, stable acceptance criteria, constraints, and non-goals.
- Behavior scenarios, affected contracts, verification expectations, and risks.
- Explicit assumptions and unresolved user-owned decisions.
- Updated lifecycle index, or complete proposed content when writes are forbidden.

## Done Conditions

- The contract states observable required behavior without an unstated product
  or engineering decision.
- Acceptance criteria are independently checkable and use stable identifiers.
- Constraints, non-goals, assumptions, compatibility, and failure behavior are
  explicit where material.
- Acceptance is explicit or the artifact remains clearly draft.

## Workflow

1. Read `../../../shared/rubrics/lifecycle-contract.md`.
2. Inspect available briefs, research, domain artifacts, decision maps,
   prototypes, repository behavior, and existing tests.
3. Separate user facts and decisions from evidence, interpretation, and proposal.
4. Draft the goal, `AC-*` criteria, constraints, non-goals, representative
   scenarios, compatibility needs, and verification expectations.
5. Resolve only user-owned semantic gaps that materially change the contract.
   Discover repository facts rather than asking for them.
6. Present the complete contract for acceptance. Record it as accepted only
   after approval or a request to execute the latest completed planning-mode
   plan.

Keep unstable file paths, code snippets, and task ordering out of accepted
intent unless their exact form is itself a user-owned requirement. Put current
implementation structure in work slices.

## Planning-Mode Boundary

When the host forbids writes, return the complete proposed contract in the
conversation and do not create `.mecha` or edit `.gitignore`. The first
execution turn materializes the latest accepted plan before changing code.

## Lifecycle Participation

User acceptance of the contract activates or promotes lifecycle mode; implicit
selection alone does not authorize filesystem writes. Write the accepted
contract into `.mecha/work/<slug>/index.md` using
`../../../templates/work-index.template.md`, preserving prior verified
continuity state. After acceptance, follow the intent authority rules exactly.

## Persistence And Yield

Useful progress means a checkable criterion, resolved semantic gap, explicit
non-goal, or accepted contract revision.

Before yielding, test the draft against one normal and one material failure or
edge scenario. Return the full draft or accepted contract, blocker, and next
planning action without starting implementation.
