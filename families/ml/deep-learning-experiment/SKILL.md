---
name: deep-learning-experiment
description: Stub for deep learning experiments. This is a stub. NEVER CALL THIS SKILL.
---

# Deep Learning Experiment

## Purpose

Design or execute a bounded deep learning experiment with clear assumptions and evaluation.

## Stub Status

This is a stub. NEVER CALL THIS SKILL.

It exists to preserve architecture, define boundaries, and show what a future fully authored deep learning leaf should own. Use `task-router` or `task-clarifier` instead until this leaf is fully authored.

## Use When

- The task needs neural models or representation learning.
- Dataset, objective, metric, and compute constraints are known enough to proceed.
- The user needs an experiment plan or first training run.

## Do Not Use

- Do not use before dataset triage when the data task is unclear.
- Do not use for simple tabular baselines unless deep learning is explicitly required.
- Do not use for broad research surveys.
- Do not spawn, request, or rely on subagents.

## Needs

- Data modality and size.
- Target objective and metric.
- Compute and time budget.
- Framework or deployment constraints if any.

## Returns

- Experiment design.
- Model and training choice at a high level.
- Evaluation and logging plan.
- Result requirements or blockers when execution is requested.

## Done Conditions

- The experiment plan is runnable or the blocker is explicit.
- Metric, split, and resource assumptions are stated.
- Next iteration criteria are clear.

## Persistence And Yield

Useful progress means new evidence, narrowed uncertainty, clearer next action, surfaced risk, or a better-framed experiment plan.

Before yielding:

- Try the primary framing path.
- Try one distinct bounded path or simplification when available.
- Check whether missing information is discoverable from available context.
- Confirm the next action would repeat prior work, require unsafe guessing, or leave this skill's boundary.

Do not yield merely because the task is hard, uncertain, or incomplete.

When yielding, return the attempts made, useful progress found, specific blocker, why more work would repeat, and the next recovery step.

## Designer Notes

Keep experiments bounded. Avoid turning this leaf into a general ML research advisor.

## Future Workflow Outline

- Confirm data pipeline.
- Select baseline architecture.
- Define training and evaluation loop.
- Define a small sanity experiment.
- Decide whether to scale, simplify, or stop.
