---
name: implementation-spec
description: Turn settled intent and evidence into an accepted implementation contract with criteria, constraints, and non-goals. Use when a change needs a written spec before coding.
---

# Implementation Specification

## Purpose

Create a decision-complete, user-owned contract for what an engineering change
must accomplish before implementation structure can distort its intent.

Use a separate specification when requested or when unresolved complexity
warrants it. A clear request, approved plan, or project criteria can already
supply sufficient intent for ordinary implementation.

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
- A review basis that distinguishes required behavior and evidence from optional
  implementation preferences.
- Explicit assumptions and unresolved user-owned decisions.
- Complete contract content in the conversation or a requested artifact; no
  lifecycle record updates.

## Done Conditions

- The contract states observable required behavior without an unstated product
  or engineering decision.
- Acceptance criteria are independently checkable and use stable identifiers.
- Constraints, non-goals, assumptions, compatibility, and failure behavior are
  explicit where material.
- Reviewers can judge required outcomes without treating one valid
  implementation approach as intent.
- Acceptance is explicit or the artifact remains clearly draft.

## Workflow

1. Inspect available briefs, research, domain artifacts, decision maps,
   prototypes, repository behavior, and existing tests.
3. Separate user facts and decisions from evidence, interpretation, and proposal.
4. Draft the goal, `AC-*` criteria, constraints, non-goals, representative
   scenarios, compatibility needs, and verification expectations.
5. Resolve only user-owned semantic gaps that materially change the contract.
   Discover repository facts rather than asking for them.
6. Check that the contract defines what must be true and evidenced without
   prescribing preferences or pre-enumerating every possible code defect.
7. Present the complete contract for acceptance. Record it as accepted only
   after approval or a request to execute the latest completed planning-mode
   plan.

Keep unstable file paths, code snippets, and task ordering out of accepted
intent unless their exact form is itself a user-owned requirement. Put current
implementation structure in work slices.

## Example: Observable Acceptance

For password reset, `AC-1: Reject an expired reset token with an expiry error
and leave the stored password unchanged` names observable behavior.
`Use a TokenValidator class` is an implementation preference unless the user
has made that interface a requirement. Verify AC-1 with an expired token and a
read of stored credentials; naming a class does not establish acceptance.

## Planning-Mode Boundary

When the host forbids writes, return the complete proposed contract in the
conversation. A request to execute the latest completed plan accepts its
contract; acceptance does not activate governance or require durable state.
Return the contract and evidence without creating or updating lifecycle records.

## Progress

Progress is a checkable criterion, resolved semantic gap, explicit non-goal, or
accepted revision. Test one normal and one material failure scenario before
returning the complete contract without starting implementation.
