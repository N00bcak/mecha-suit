---
name: classical-ml-baseline
description: Stub for simple classical ML baselines. This is a stub. NEVER CALL THIS SKILL.
---

# Classical ML Baseline

## Purpose

Establish a simple, credible classical ML baseline with clear evaluation.

## Stub Status

This is a stub. NEVER CALL THIS SKILL.

It exists to preserve architecture, define boundaries, and show what a future fully authored classical ML leaf should own. Use `task-router` or `task-clarifier` instead until this leaf is fully authored.

## Use When

- Dataset framing and target are known.
- The task fits tabular, text-feature, or modest supervised learning baselines.
- The user needs a baseline before more complex modeling.

## Do Not Use

- Do not use before dataset triage when labels, splits, or metrics are unclear.
- Do not use for deep learning-first tasks with strong representation requirements.
- Do not use for production ML system engineering unless baseline modeling is central.
- Do not spawn, request, or rely on subagents.

## Needs

- Dataset schema and target.
- Train/validation/test split strategy.
- Evaluation metric.
- Constraints on interpretability, latency, or dependencies.

## Returns

- Baseline approach.
- Minimal preprocessing plan.
- Evaluation plan or result requirements when execution is requested.
- Comparison point for future models.

## Done Conditions

- A baseline is specified or the blocker is explicit.
- Metric and split are explicit.
- Limitations and next improvement path are clear.

## Persistence And Yield

Useful progress means new evidence, narrowed uncertainty, clearer next action, surfaced risk, or a better-framed baseline plan.

Before yielding:

- Try the primary framing path.
- Try one distinct bounded path or simplification when available.
- Check whether missing information is discoverable from available context.
- Confirm the next action would repeat prior work, require unsafe guessing, or leave this skill's boundary.

Do not yield merely because the task is hard, uncertain, or incomplete.

When yielding, return the attempts made, useful progress found, specific blocker, why more work would repeat, and the next recovery step.

## Designer Notes

Prefer boring, reproducible baselines. Avoid premature model complexity.

## Future Workflow Outline

- Load prepared data.
- Build simple preprocessing.
- Define one or two baseline models.
- Define evaluation on agreed splits.
- Record results and limitations.
