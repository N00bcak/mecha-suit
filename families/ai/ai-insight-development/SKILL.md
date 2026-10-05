---
name: ai-insight-development
description: Develop evidence-backed insights about data, domain structure, dynamics, labels, and solution signals. Use when patterns could change how an AI problem is framed or solved.
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

1. Read `../references/evidence-integrity.md`.
2. Turn the objective and domain knowledge into a small set of testable
   questions.
3. Inspect distributions, relationships, cohorts, time or spatial structure,
   label behavior, missingness mechanisms, and rare cases that can change the
   solution. For GOFAI, inspect invariants, symmetries, constraints,
   transition structure, bottlenecks, and failure examples.
4. Use visual, statistical, or structural evidence appropriate to the data and
   sampling process.
5. Challenge attractive findings with alternate slices, confounders, leakage
   checks, and simple null explanations.
6. Record each insight with evidence, confidence, limitations, and its
   implication for representations or problem modeling.

Do not silently turn exploratory associations into confirmatory claims.

When writing analysis code, read
`../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Load
`../references/numerical-performance.md` only for a material numerical or
data-scale bottleneck.

If relevant `ML_PIPELINE.md` exists, use it as advisory context and update only
Insight Development plus material risks or recommendations.
Never require or create it.

## Progress

Progress is a tested hypothesis, rejected explanation, discovered structure, or
narrower uncertainty. When evidence permits, test one alternate explanation;
yield with limitations and the next discriminating action.

## References

- `../references/evidence-integrity.md` — claim and validation discipline
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional numerical performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
