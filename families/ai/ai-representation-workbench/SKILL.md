---
name: ai-representation-workbench
description: Design and validate features, states, constraints, knowledge, embeddings, or heuristics for AI problems. Use when choosing what an AI system should see or encode.
---

# AI Representation Workbench

## Purpose

Create a validated representation that exposes useful problem structure without
leakage or unexplained information loss.

## Do Not Use

- Do not own raw-data cleanup or open-ended insight discovery.
- Do not make final solution-family choices.
- Do not launch expensive training or search.
- Do not spawn, request, or rely on subagents.

## Needs

- Objective and permitted information boundary.
- Prepared evidence or a formal domain.
- Validation unit and leakage constraints.
- Runtime, memory, interpretability, or serialization constraints.

## Returns

- Executable representation artifact or precise specification.
- Provenance, fit scope, semantics, and known information loss.
- Validation, ablation, cost evidence, and tests.
- Implications for problem modeling.

## Done Conditions

- Information availability and fit boundaries are explicit.
- Dimensionality, sparsity, unknowns, invariants, leakage, and serialization are
  checked as applicable.
- Complexity is supported by controlled evidence when material.
- The representation can be reproduced or implemented directly.

## Workflow

1. Read `../references/evidence-integrity.md`.
2. Define what information the representation may use and when it is
   available.
3. Start from the simplest representation that preserves task-relevant
   structure.
4. For ML, design transformations, features, selections, aggregations,
   embeddings, or pretrained representations with provenance and fit scope.
   For GOFAI, design states, operators, constraints, knowledge, abstractions,
   symmetries, or heuristics with explicit semantics.
5. Implement a reproducible transformation or construction path when execution
   is requested.
6. Check dimensionality, sparsity, collisions, unknown values, invariants,
   leakage, compute and memory cost, and serialization.
7. Use ablation or controlled comparison when evidence is needed to justify a
   complex representation.

When writing code, read `../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Load
`../references/numerical-performance.md` for tensor, embedding, accelerator, or
data-intensive paths, and `../references/search-performance.md` for GOFAI
states, heuristics, or search structures.

If relevant `ML_PIPELINE.md` exists, use it as advisory context and update only
Representation Workbench plus material risks or recommendations.
Never require or create it.

## Progress

Progress is a working transform, clarified contract, verified invariant,
informative ablation, or measured constraint. Compare one bounded alternative
when it can discriminate, then return evidence and the next action.

## References

- `../references/evidence-integrity.md` — evidence and leakage integrity
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional numerical performance
- `../references/search-performance.md` — conditional GOFAI performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
