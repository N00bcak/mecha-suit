---
name: ai-pipeline
description: Frame AI problems from raw evidence through representation, solution design, and evaluation in one initial pass.
---

# AI Pipeline

## Purpose

Create a one-time conceptual map of an AI problem across data, insight,
representation, solution design, and evaluation. Support statistical ML, deep
learning, Good Old-Fashioned AI, and hybrid systems.

This skill is an explicit manual, not an implicit router or an experiment
controller.

## Use When

- The user explicitly invokes `ai-pipeline`.
- The problem needs an end-to-end initial framing before focused execution.
- A theoretical AI problem benefits from the same pipeline without empirical
  execution.

## Do Not Use

- Do not invoke this skill implicitly for ordinary AI work.
- Do not transform data, implement representations, construct solutions,
  train, search, or evaluate.
- Do not manage later experiment iterations or automatically invoke leaves.
- Do not spawn, request, or rely on subagents.

## Needs

- Intended outcome or decision.
- Available data, code, domain knowledge, or theoretical assumptions.
- Constraints on correctness, compute, latency, interpretability, safety, or
  deployment.
- Success criteria or permission to identify them through the interview.

## Returns

- Repository-root `ML_PIPELINE.md`, or its complete content when persistence is
  unavailable.
- Explicit observations, assumptions, hypotheses, proposals, and unknowns.
- A domain-calibrated candidate portfolio.
- Recommended execution leaves and intentionally skipped stages.

## Done Conditions

- The objective, regime, evidence, constraints, and success criteria support a
  credible initial pass.
- Every pipeline stage is addressed or explicitly marked inapplicable or
  unknown.
- The candidate portfolio reflects the task and resource regime.
- `ML_PIPELINE.md` is safely persisted or returned verbatim with the
  persistence limitation.

## Methodology

### 1. Inspect Before Interviewing

Read available problem statements, data descriptions, schemas, code, notebooks,
prior results, and an existing `ML_PIPELINE.md`. Do not perform leaf execution
to fill gaps.

If an existing file covers the same problem, preserve empirical leaf results.
If it covers another problem, ask before replacing or archiving it.

### 2. Interview One Question at a Time

Ask the highest-value unanswered question, wait for the response, then choose
the next question. Establish:

- objective and decision context;
- available evidence, data, knowledge, or environment;
- constraints and consequences of failure;
- success criteria.

Do not force a fixed questionnaire. Stop when remaining uncertainty can be
represented honestly in the initial pass.

### 3. Recognize the Regime

Read `../references/task-regimes.md`. Identify statistical ML, deep learning,
GOFAI, hybrid, or an adjacent regime. Read
`../references/evidence-integrity.md` before classifying claims.

### 4. Draft One Initial Pass

Use `../references/pipeline-contract.md`. Sketch:

- preparation concerns;
- insight and structural hypotheses;
- feature, state, knowledge, constraint, embedding, or heuristic directions;
- problem formulation and candidate solutions;
- construction, training, search, and evaluation design.

Use a diverse candidate portfolio for classical ML when appropriate. Emphasize
representations and heuristics for GOFAI. For expensive deep learning, prefer
one primary architecture plus cheap baselines, ablations, or a
decision-changing challenger.

### 5. Persist and Handoff

Write or update `ML_PIPELINE.md` at the project root. If writing is impossible,
return the complete Markdown content and say it was not persisted.

Recommend only leaves with material next work:

- `ai-data-preparation`
- `ai-insight-development`
- `ai-representation-workbench`
- `ai-problem-modeling`
- `ai-performance`

Stop after the initial pass. Native Codex and the user control later flow.

## Persistence And Yield

Useful progress means a resolved framing question, better regime recognition,
clearer evidence status, or a credible initial pipeline section.

Before yielding, inspect available context, ask the next material question, and
determine whether further framing would repeat or require unavailable
user-owned information. Return the completed initial pass or the exact blocker.

## References

- `../references/pipeline-contract.md` — required artifact and ownership
- `../references/task-regimes.md` — task recognition and portfolio policy
- `../references/evidence-integrity.md` — evidence and validation integrity
- `../references/data-preparation.md` — preparation stage contract
- `../references/insight-development.md` — insight stage contract
- `../references/representation-workbench.md` — representation stage contract
- `../references/problem-modeling.md` — modeling stage contract
- `../references/performance.md` — performance stage contract
