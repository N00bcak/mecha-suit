---
name: ai-performance
description: Construct, optimize, train, and evaluate AI solutions with coupled diagnostics and comparative evidence. Use when building, tuning, or comparing models or solvers.
---

# AI Performance

## Purpose

Construct and optimize AI solutions while evaluating them under one stable,
reproducible evidence contract.

## Do Not Use

- Do not train against an undefined or changing validation contract.
- Do not start materially expensive or remote jobs without user approval.
- Do not silently expand into serving, deployment, or production monitoring.
- Do not spawn, request, or rely on subagents.

## Needs

- Candidate specification, representations, baselines, and evaluation contract.
- Data, domain instances, or environment.
- Compute, time, memory, and resource constraints.
- Required artifacts and reproducibility expectations.

## Returns

- Constructed or trained solution artifacts when requested.
- Comparable quality, diagnostic, uncertainty, failure, and resource evidence.
- Reproducible run path and artifact provenance.
- Decision to accept, iterate, simplify, or revisit another AI stage.

## Done Conditions

- The baseline and candidates use the same valid evaluation contract.
- Training, construction, search, and resource limits are explicit.
- Material failure modes and comparison uncertainty are reported.
- The evaluated solution and production-promotion needs are clear.

## Workflow

1. Read `../references/performance.md` and
   `../references/evidence-integrity.md`.
2. Reproduce the simplest baseline and validate the artifact path.
3. Implement, train, construct, or search using repository-native tools.
4. Evaluate quality, failures, uncertainty, calibration, and resource use as
   applicable.
5. Compare candidates or ensembles fairly.
6. Perform error analysis and identify the stage implicated by the evidence.
7. Save or document evaluated artifacts and the run path when requested.

When writing code, read `../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Load
`../references/numerical-performance.md` for statistical, neural, numerical,
accelerator, or data-intensive work. Load
`../references/search-performance.md` for symbolic, search, planning, or
constraint work.

If relevant `ML_PIPELINE.md` exists, use it as advisory context and update only
Performance, empirical candidate outcomes, and material risks or
recommendations. Never require or create it.

## Progress

Progress is a reproduced baseline, stable run, measured bottleneck, candidate
result, diagnosed failure, or rejected hypothesis. When resources permit, try
one diagnostic or fallback before returning evidence and the next action.

## References

- `../references/performance.md` — stage playbook
- `../references/evidence-integrity.md` — comparison integrity
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — numerical and accelerator work
- `../references/search-performance.md` — search and GOFAI work
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
