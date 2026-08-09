---
name: technical-research
description: Resolve software and architecture questions through primary technical sources, repository evidence, and reproducible checks.
---

# Technical Research

## Purpose

Resolve a bounded software, API, architecture, compatibility, or standards
question with evidence strong enough to guide an engineering decision.

## Use When

- Official documentation, source code, specifications, standards, or papers
  must be reconciled.
- Library, platform, compatibility, or implementation feasibility is unclear.
- A technical claim needs a reproducible check before planning or coding.

## Do Not Use

- Do not own user, market, workflow, or product-alternative research; use
  `product-research`.
- Do not diagnose a reported failure whose main need is a reproducer and cause;
  use `diagnosing-bugs`.
- Do not implement the researched change unless separately requested.
- Do not spawn, request, or rely on subagents.

## Needs

- The engineering decision and bounded question.
- Relevant repository, runtime, versions, constraints, and prior evidence.
- Required confidence and acceptable validation cost.

## Returns

- Cited technical findings and reproducible repository observations.
- Compatibility, feasibility, security, performance, or maintenance implications.
- Explicit inferences, limitations, confidence, and unresolved evidence.
- A durable research artifact when requested or lifecycle mode is active.

## Done Conditions

- Decision-relevant claims trace to owning sources or reproducible checks.
- Version and environment applicability are explicit.
- Conflicting sources or repository behavior are reconciled or visible.
- The supported decision or next decisive check is clear.

## Workflow

1. Read `../../../shared/rubrics/research-integrity.md`.
2. State the question, decision, versions, constraints, and evidence threshold.
3. Inspect repository code, configuration, manifests, tests, and local docs
   before searching externally.
4. Prefer official docs, source code, specifications, standards, original
   research, and first-party release or compatibility records.
5. Run the smallest safe reproducible check when documentation alone cannot
   settle actual behavior.
6. Challenge the leading answer with a version mismatch, alternate source, or
   representative failure condition when material.
7. Return findings separately from the engineering recommendation.

Do not treat a successful toy example as proof of production fitness. State the
gap between documented behavior, reproduced behavior, and the target system.

## Lifecycle Participation

When a matching work record exists, read
`../../../shared/rubrics/lifecycle-contract.md`. Save findings under
`.mecha/work/<slug>/research/` or the established convention, link the artifact,
and update evidence without rewriting accepted intent.

Without a matching record, answer in the conversation or persist only when the
user requests it.

## Persistence And Yield

Useful progress means a verified technical claim, eliminated option, measured
constraint, or narrower compatibility risk.

Before yielding, inspect the owning source and try one bounded reproducible or
contrary check when feasible. Return evidence, versions, confidence, blocker,
and the next decisive action.
