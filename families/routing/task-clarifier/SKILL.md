---
name: task-clarifier
description: Clarify ambiguous, mixed, or missing-input tasks until the next step is clear.
---

# Task Clarifier

## Purpose

Reduce ambiguity until the next skill or next information request is clear.

This skill improves routing quality. It is not a domain specialist and does not execute the task.

## Hard Rules

- Do not solve the domain task.
- Do not import collaboration, engineering, CTF, ML, or council playbooks.
- Do not produce broad implementation plans.
- Do not use, spawn, request, or rely on subagents.
- Ask at most one user question, and only when no reasonable next step can be framed.

## Ambiguity Categories

- Missing artifact: the task references a repo, file, dataset, model, service, binary, or challenge that is unavailable.
- Missing objective: the artifact is known but the desired outcome is unclear.
- Mixed task type: multiple families appear relevant but the relationship is not clear.
- Unclear constraints: success criteria, environment, allowed tools, or output format materially affect routing.
- Likely council but not proven: multiple specialist families might be needed, but one clear primary route may still exist.

## Clarification Procedure

1. Restate the task in one sentence using only known facts.
2. Identify the smallest missing detail that blocks routing.
3. Decide whether the missing detail can be handled by a specialist as an assumption.
4. If yes, recommend the next skill with that assumption.
5. If no, ask one concise question.

Prefer progress over interrogation. Do not ask for details that the selected specialist can discover cheaply.

## Output Contract

Return:

```yaml
clarified_framing: "<one sentence>"
missing_inputs: ["<only routing-relevant gaps>"]
recommended_next_skill: "<skill-name | none yet>"
question_to_user: "<one concise question, or null>"
confidence: "high | medium | low"
```

If the next skill is still unclear, set `recommended_next_skill` to `none yet` and include exactly one `question_to_user`.

## Reference

Read `references/ambiguity-checklist.md` only when the missing input is not obvious.
