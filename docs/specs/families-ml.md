# `families/ml/` Spec

## Purpose

`families/ml/` contains contract-complete placeholder leaves for future machine
learning workflows.

## Architecture Tree

```text
families/ml/
    dataset-triage/
        SKILL.md
    classical-ml-baseline/
        SKILL.md
    deep-learning-experiment/
        SKILL.md
```

## Main Responsibilities

- Reserve narrow future skill boundaries for ML work.
- Define purpose, triggers, exclusions, needs, returns, done conditions, designer
  notes, and future workflow outline.
- Prevent premature execution while the workflows are not fully authored.

## Strengths

- Stubs make future architecture visible without pretending to be ready.
- Stub descriptions prevent native skill selection from invoking unfinished ML
  workflows.
- Contract shape is aligned with the leaf template.

## Architectural Invariants

- Current ML leaves are not callable.
- Each stub must retain `This is a stub. NEVER CALL THIS SKILL.`
- Do not add half-authored ML tactics.
- Do not add bulky references or scripts until a leaf is genuinely being
  authored.
- Native selection and council must not select ML stubs directly.

## Common Workflows

- Handle ML requests with native host capabilities while leaves are stubs.
- When authoring a leaf, preserve the contract shape unless there is a strong
  reason to change it.
- Update README, council eligibility, and templates if a stub becomes fully
  authored.

## Future Work

- Author `dataset-triage` first if repeated ML dataset work appears.
- Add `classical-ml-baseline` and `deep-learning-experiment` playbooks only
  after their minimum viable workflows are clear.
