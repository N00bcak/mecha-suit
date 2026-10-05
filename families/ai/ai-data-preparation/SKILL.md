---
name: ai-data-preparation
description: Inspect, type, clean, convert, and package raw data into a documented analysis-ready artifact. Use when raw or messy data must become a reproducible dataset before analysis.
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

1. Identify data sources, ownership, modality, observation unit, and raw
   preservation policy.
2. Classify fields by semantic role, not only inferred storage type:
   identifiers, targets, timestamps, groups, measurements, categories, text,
   media, and metadata.
3. Measure missingness, duplicates, invalid values, ranges, units, encoding,
   cardinality, and cross-source alignment.
4. Distinguish absence, censoring, not-applicable values, and collection
   failures before choosing a treatment.
5. Apply the smallest justified conversions and cleaning rules. Record every
   lossy operation.
6. Package analysis-ready data with schema, provenance, and a reproducible run
   path.
7. Verify idempotence, row or entity accounting, schema expectations, and a
   material malformed-input path.

If split policy is unknown, do not fit learned imputers, scalers, vocabularies,
or encoders globally. Surface the dependency on problem modeling.

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

- `../references/pipeline-contract.md` — optional pipeline context
- `../references/ai-coding-discipline.md` — AI implementation quality
- `../references/numerical-performance.md` — conditional data-path performance
- `../../../shared/rubrics/change-discipline.md` — universal coding floor
