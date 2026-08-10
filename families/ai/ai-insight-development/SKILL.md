---
name: ai-insight-development
description: Develop evidence-backed insights about data, domain structure, dynamics, labels, and candidate solution signals.
---

# AI Insight Development

## Purpose

Discover and challenge patterns or domain structure that can materially change
representations, problem formulation, or solution choice.

## Do Not Use

- Do not perform routine data conversion and packaging.
- Do not silently convert exploratory findings into confirmed claims.
- Do not own final representations, solution choice, or training.
- Do not spawn, request, or rely on subagents.

## Needs

- Prepared or interpretable evidence and its provenance.
- Objective or domain question.
- Sampling, temporal, grouping, or collection context.
- Known constraints and prior findings.

## Returns

- Evidence-backed insights with confidence and limitations.
- Rejected hypotheses and alternate explanations.
- Candidate signals, invariants, constraints, and downstream implications.
- Recommended next analysis or AI stage.

## Done Conditions

- Material insights trace to reproducible evidence.
- Leakage, confounding, cohort, and simple-null explanations are considered.
- Observations and hypotheses are clearly separated.
- Downstream implications and uncertainty are explicit.

## Workflow

1. Read `../references/insight-development.md` and
   `../references/evidence-integrity.md`.
2. Convert the objective into a bounded set of questions.
3. Inspect distributions, relationships, structure, rare cases, labels,
   invariants, or transitions as applicable.
4. Challenge findings with alternate slices and explanations.
5. Record evidence, confidence, limitations, and implications.

When writing analysis code, read
`../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Load
`../references/numerical-performance.md` only for a material numerical or
data-scale bottleneck.

If relevant `ML_PIPELINE.md` exists, use it as advisory context and update only
Insight Development plus material risks or recommendations.
Never require or create it.

## Persistence And Yield

Progress is a tested hypothesis, rejected explanation, discovered structure, or
narrower uncertainty. When evidence permits, test one alternate explanation;
yield with limitations and the next discriminating action.

## References

- `../references/insight-development.md` — stage playbook
- `../references/evidence-integrity.md` — claim and validation discipline
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional numerical performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
