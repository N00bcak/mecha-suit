---
name: dataset-triage
description: NEVER CALL THIS SKILL.
---

# Dataset Triage

## Purpose

Assess whether a dataset and task framing are ready for modeling, and choose the next ML path.

## Stub Status

This is a stub. NEVER CALL THIS SKILL.

It exists to preserve architecture, define boundaries, and show what a future fully authored dataset triage leaf should own. Use `task-router` or `task-clarifier` instead until this leaf is fully authored.

## Use When

- The user has data, labels, features, metrics, or an ML objective.
- Dataset quality, leakage, splits, or feasibility are unclear.
- The right baseline or experiment family is not yet obvious.

## Do Not Use

- Do not use for pure software engineering unless data readiness is central.
- Do not jump directly into deep learning architecture design.
- Do not tune models before task framing and evaluation are clear.
- Do not spawn, request, or rely on subagents.

## Needs

- Dataset location or description.
- Target variable or learning objective.
- Evaluation metric or business goal if known.
- Constraints on compute, privacy, or deployment.

## Returns

- Dataset readiness assessment.
- Leakage and split risks.
- Recommended next ML skill.
- Minimum baseline recommendation.

## Done Conditions

- The modeling objective is clear enough to proceed or the missing data is explicit.
- Evaluation and split assumptions are stated.
- The next skill or data-cleaning action is identified.

## Persistence And Yield

Useful progress means new evidence, narrowed uncertainty, clearer next action, surfaced risk, or a better-framed dataset readiness assessment.

Before yielding:

- Try the primary framing path.
- Try one distinct bounded path or simplification when available.
- Check whether missing information is discoverable from available context.
- Confirm the next action would repeat prior work, require unsafe guessing, or leave this skill's boundary.

Do not yield merely because the task is hard, uncertain, or incomplete.

When yielding, return the attempts made, useful progress found, specific blocker, why more work would repeat, and the next recovery step.

## Designer Notes

Keep this leaf focused on data and task framing. Detailed modeling workflows belong in baseline or experiment leaves.

## Future Workflow Outline

- Inspect schema and target.
- Check missingness and leakage risks.
- Validate split and metric.
- Recommend baseline or experiment path.
- Record assumptions.
