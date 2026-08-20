---
name: ai-data-preparation
description: Inspect, type, clean, convert, and package raw data into a documented analysis-ready artifact.
---

# AI Data Preparation

## Purpose

Turn raw data into a documented, reproducible, analysis-ready artifact without
silently changing its meaning.

## Do Not Use

- Do not own deeper pattern discovery — use `ai-insight-development`.
- Do not engineer model features or symbolic representations — use
  `ai-representation-workbench`.
- Do not choose or train solutions.
- Do not spawn, request, or rely on subagents.

## Needs

- Data sources or representative samples.
- Intended observation unit and known field semantics.
- Output format and preservation constraints.
- Applicable privacy, licensing, or repository policies.

## Returns

- Prepared data or a precise preparation specification.
- Schema and semantic-role record.
- Quality findings, lossy operations, provenance, and run path.
- Blockers and the next relevant AI stage.

## Done Conditions

- Raw inputs remain recoverable.
- Conversions and cleaning choices are explicit and reproducible.
- Entity or row accounting and schema expectations are verified.
- A material malformed-input path is checked.

## Workflow

1. Read `../references/data-preparation.md`.
2. Inspect sources, units, semantic roles, missingness, duplicates, invalid
   values, encoding, ranges, cardinality, and alignment.
3. Distinguish missing-data meanings before choosing treatment.
4. Apply the smallest justified conversions and cleaning rules.
5. Package outputs with schema and provenance.
6. Verify idempotence, accounting, and failure behavior.

When writing code, read `../../../shared/rubrics/change-discipline.md` and
`../references/ai-coding-discipline.md`. Use
`../references/numerical-performance.md` only when measured data volume or
numerical work makes it relevant.

If a relevant `ML_PIPELINE.md` exists, read it as advisory context and update
only Data Preparation plus material risks or recommendations.
Never require or create it.

## Progress

Progress is a resolved semantic ambiguity, measured quality issue, reproducible
conversion, or verified artifact. Yield only when another repair or validation
would repeat or require unavailable meaning, policy, or data.

## References

- `../references/data-preparation.md` — stage playbook
- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional data-path performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
