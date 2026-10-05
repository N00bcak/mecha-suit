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
- Do not start jobs beyond the authorized compute, or remote jobs with external
  cost, without user approval.
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

1. Read `../references/evidence-integrity.md`.
2. Reproduce the simplest baseline and verify the data, representation,
   objective, metric, and artifact path.
3. Implement the candidate using repository-native frameworks and conventions.
   For ML or DL, train with visible configuration, checkpoints where material,
   learning diagnostics, and bounded tuning. For GOFAI, construct and tune the
   solver, planner, rules, constraints, or heuristic under explicit cutoff and
   guarantee policies.
4. Evaluate on untouched valid evidence; report uncertainty, calibration,
   subgroup or instance-class behavior, failure modes, and resource use when
   material.
5. Compare candidates under the same contract. Evaluate ensembles only when
   their gain justifies inference and maintenance cost.
6. Perform error analysis and decide whether evidence points to performance,
   problem modeling, representation, insights, or preparation.
7. Save or document the evaluated artifact and a reproducible run path when
   requested.

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
result, diagnosed failure, or rejected hypothesis. Keep iterating within the
authorized budget, choosing each experiment by what it could change, until the
objective is met, resources are spent, or no remaining experiment's expected
gain justifies its cost given validation noise and the remaining budget; then
return evidence and the next action.

## References

- `../references/evidence-integrity.md` — comparison integrity
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — numerical and accelerator work
- `../references/search-performance.md` — search and GOFAI work
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
