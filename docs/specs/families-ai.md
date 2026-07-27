# `families/ai/` Spec

## Purpose

`families/ai/` provides one explicit conceptual pipeline manual and five narrow,
callable execution leaves spanning statistical ML, deep learning, GOFAI, and
hybrid systems.

## Architecture Tree

```text
families/ai/
    references/
        pipeline-contract.md
        task-regimes.md
        evidence-integrity.md
        ai-coding-discipline.md
        numerical-performance.md
        search-performance.md
        <one playbook per execution stage>
    ai-pipeline/
        SKILL.md
        agents/openai.yaml
    ai-data-preparation/
        SKILL.md
    ai-insight-development/
        SKILL.md
    ai-representation-workbench/
        SKILL.md
    ai-problem-modeling/
        SKILL.md
    ai-performance/
        SKILL.md
```

## Responsibilities

- `ai-pipeline` performs an explicit one-time framing interview and creates
  `ML_PIPELINE.md`. It does not execute leaves or manage later iteration.
- `ai-data-preparation` owns raw data semantics, quality, conversion, and
  packaging.
- `ai-insight-development` owns evidence-backed pattern and structure
  discovery.
- `ai-representation-workbench` owns features, states, knowledge, constraints,
  embeddings, and heuristics.
- `ai-problem-modeling` owns formalization and candidate solution design.
- `ai-performance` owns construction or training coupled with evaluation.

## Architectural Invariants

- Native Codex selects execution leaves directly.
- `ai-pipeline` is explicit-only and is not council-eligible.
- All five execution leaves are council-eligible but cannot use subagents
  themselves.
- `ML_PIPELINE.md` is required only for the manual. Leaves use it as optional
  advisory context and never create it.
- The family supports statistical ML, deep learning, GOFAI, and hybrids without
  modality- or framework-specific skills.
- The family ends at an evaluated solution; production integration belongs to
  engineering or native Codex.
- The adaptive experiment controller remains a separate future product.

## Coding Policy

Code-producing leaves load the toolbox-wide change discipline and the
AI-specific coding discipline. Numerical/accelerator and search/GOFAI
performance references load only when the solution regime needs them.

Application-style language primers are not imposed on exploratory AI work.
Readable AI code preserves visible dataflow, provenance, reproducibility,
mathematical invariants, and measured performance.

## Common Routing

- Explicit end-to-end framing interview → `ai-pipeline`
- Raw schema, missingness, conversions, or packaging → `ai-data-preparation`
- Pattern, label, cohort, invariant, or domain discovery →
  `ai-insight-development`
- Feature, state, knowledge, embedding, constraint, or heuristic work →
  `ai-representation-workbench`
- Model, architecture, planner, solver, or hybrid selection →
  `ai-problem-modeling`
- Training, search tuning, benchmarking, comparison, or error analysis →
  `ai-performance`
