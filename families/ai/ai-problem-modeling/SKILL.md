---
name: ai-problem-modeling
description: Formalize AI problems and choose statistical, neural, symbolic, or hybrid solutions. Use when an AI task needs a formal objective and a justified set of candidate approaches.
---

# AI Problem Modeling

## Purpose

Turn evidence and constraints into an experiment-ready formal problem and a
justified portfolio of solution candidates.

## Do Not Use

- Do not own raw preparation, open-ended insights, or representation
  implementation.
- Do not launch materially expensive training or search.
- Do not expand into serving or deployment.
- Do not spawn, request, or rely on subagents.

## Needs

- Objective, available evidence, and representation assumptions.
- Operational constraints and failure costs.
- Validation conditions and available compute or search budget.
- Existing baselines and results when available.

## Returns

- Formal task, validation design, metrics, and baselines.
- Candidate portfolio with rationale, cost, evidence needs, and pruning rules.
- Neural, symbolic, statistical, search, constraint, or hybrid specifications.
- Experiment-ready handoff and unresolved risks.

## Done Conditions

- Inputs, outputs, states, actions, targets, constraints, and objectives are
  explicit where applicable.
- Validation matches intended use.
- Candidate breadth matches the task and resource regime.
- The specification can be executed without an unstated modeling decision.

## Workflow

1. Read `../references/task-regimes.md`,
   `../references/problem-modeling.md`, and
   `../references/evidence-integrity.md`.
2. Formalize the problem and operational validation contract.
3. Establish naive and simple baselines.
4. Select a domain-calibrated candidate portfolio.
5. Define architecture, algorithm, inference, loss, search, or constraint
   details needed for execution.
6. Assign evidence requirements, resource costs, and pruning conditions.

When writing specification or prototype code, read
`../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Consult numerical or search
performance references only when feasibility decisions depend on them.

If relevant `ML_PIPELINE.md` exists, use it as advisory context and update only
Problem Modeling, Candidate Portfolio, and material risks or recommendations.
Never require or create it.

## Progress

Progress is a clearer objective, valid evaluation contract, eliminated
candidate, or experiment-ready decision. Compare one materially different
formulation when the regime supports it, then return the next experiment.

## References

- `../references/task-regimes.md` — task and portfolio recognition
- `../references/problem-modeling.md` — stage playbook
- `../references/evidence-integrity.md` — validation integrity
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional numerical feasibility
- `../references/search-performance.md` — conditional GOFAI feasibility
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
