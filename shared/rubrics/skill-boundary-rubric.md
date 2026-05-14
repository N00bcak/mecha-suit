# Skill Boundary Rubric

Use this rubric when editing or adding skills.

## Good boundary

- The skill has one primary job.
- The trigger description says when to use it and when not to use it.
- The required inputs are minimal and explicit.
- The return shape is predictable.
- The skill does not duplicate another leaf's method.

## Warning signs

- The skill can solve nearly any task.
- The skill contains repo-specific facts.
- The skill needs many references loaded before doing basic work.
- The skill uses subagents outside `interdisciplinary-council`.
- The router must understand internal tactics to select it.

## Repair

- Move passive detail into references.
- Split unrelated duties into separate leaves.
- Add exclusions.
- Tighten the output contract.
- Route ambiguous cases through `task-clarifier`.
