---
name: multi-step-governance
description: Govern an explicitly authorized end-to-end outcome across dependent specialist stages and durable evidence.
---

# Multi-Step Governance

## Purpose

Maintain user-authorized, cross-skill work that needs durable intent, evidence,
and an actionable frontier. This loop governs the process; specialist skills do
the bounded work.

## Do Not Use

- Do not use for one bounded artifact, a contained change, or a next task that
  is already clear.
- Do not select, invoke, or delegate to specialist skills.
- Do not spawn, request, or rely on subagents.
- Do not inspect a diff, classify or validate review findings, reopen them, or
  adjudicate technical claims.

## Needs

- An explicit user invocation in the current session.
- An outcome with material dependent stages, or an existing matching work record.

## Interactive Loop Contract

- Activate only through explicit user invocation in the current session.
- Own the governed exchange until completion, cancellation, pause, or an
  explicit switch to another loop.
- Keep at most one interactive loop active. When the user switches to a
  multi-turn contributor, preserve the frontier, pause, and require explicit
  reactivation to resume governance.
- Describe the next specialist task in ordinary language; native host selection
  remains authoritative.
- Read `../../../shared/rubrics/lifecycle-contract.md` when governed durable
  state is authorized or an existing matching record is resumed.

## Workflow

1. Establish the desired outcome, constraints, evidence, and whether durable
   governance is authorized.
2. Create or restore the governed record only when authorized. Executing an
   accepted plan alone does not activate this loop; when explicitly active,
   materialize accepted intent in the record and link contributor evidence.
3. Keep accepted intent, linked contributor artifacts, verified evidence, open
   questions, and one next task shape current.
4. Surface user-owned decisions before changing accepted intent or closing work.
5. Complete or hand off only when the record has the evidence required by its
   accepted criteria.

When governed implementation is ready for review, return the ordinary next task
shape: review the bounded diff against accepted criteria and available
verification evidence. Record the resulting review report link, disposition,
open blocker IDs, explicit waiver state, and next task without re-evaluating
any `RF-*` finding. Route `changes required` to implementation or remediation;
advance after `passed` or explicit `waived` when every other completion
condition is met; surface `intent decision required` and `adjudication
required` as user-owned decisions.

## Returns

- A governed work record when durable state is authorized.
- The current frontier, evidence, risks, and one next task shape.

## Done Conditions

- The outcome is complete, explicitly deferred, cancelled, or handed off.
- Accepted intent, evidence, and remaining risk are visible.

## Lifecycle Participation

This loop is the sole callable owner of `.mecha/work/` lifecycle state. Follow
`../../../shared/rubrics/lifecycle-contract.md`; contributors return artifacts
and evidence but never advance the record themselves.

## Progress

Progress is an accepted decision, verified contributor result, resolved blocker,
or narrower actionable frontier. Pause when the next step belongs to another
explicit loop or user-owned decision.
