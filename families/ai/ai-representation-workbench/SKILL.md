---
name: ai-representation-workbench
description: Design and validate features, states, constraints, knowledge, embeddings, or heuristics for AI problems.
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

1. Read `../references/representation-workbench.md` and
   `../references/evidence-integrity.md`.
2. Start with the simplest representation preserving relevant structure.
3. Implement or specify transformations, features, states, knowledge, or
   heuristics with provenance.
4. Verify semantics, information boundaries, cost, and reload behavior.
5. Use ablation or controlled comparison when complexity needs evidence.

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

- `../references/representation-workbench.md` — stage playbook
- `../references/evidence-integrity.md` — evidence and leakage integrity
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional numerical performance
- `../references/search-performance.md` — conditional GOFAI performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
