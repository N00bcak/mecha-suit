# Behavior-First Development

Use this method when the user requests test-first work, a regression needs a
durable guard, or a meaningful automated check can observe new behavior before
implementation.

## Feedback Contract

Choose the highest practical interface through which a real caller observes the
behavior. A useful check:

- exercises the behavior or failure named by the acceptance criterion;
- can fail when that behavior is absent or wrong;
- obtains expected results independently from the implementation;
- remains stable when internal structure changes;
- runs quickly and deterministically enough for repeated use.

When no appropriate automated interface exists, establish another explicit
feedback loop and record why a durable test is not currently credible.

## Vertical Loop

1. Select one acceptance criterion and one observable behavior.
2. Write or identify the smallest check that can go red for that behavior.
3. Run it and confirm the expected failure. A different nearby failure is not a
   valid red state.
4. Implement only enough behavior to make that check pass.
5. Run it green, then run affected neighboring checks.
6. Refactor only while the behavior remains green.
7. Record the command and criterion mapping.

Do not write every imagined test before implementation. Let each completed
slice inform the next. Avoid mocks of internal collaborators, private-method
tests, tautological expectations, and snapshots with no independent oracle.

## Failure Paths

Test a material invalid input, dependency failure, compatibility path, or
resource boundary when its failure would undermine the requested outcome. Do
not add edge cases merely to satisfy a quota.
