# AI Coding Discipline

These AI-specific rules extend the universal change-discipline floor that
each AI skill loads alongside this file.

## Readability

- Prefer visible dataflow over service-style layers.
- Keep a training, evaluation, or search loop sequential when that makes the
  algorithm easier to inspect.
- Name mathematical and domain operations directly.
- State shapes, units, dtypes, devices, coordinate systems, and invariants at
  boundaries where they are not obvious.
- Extract reusable modules when behavior stabilizes, not merely because an
  exploratory cell or block is long.

## Reproducibility and Provenance

- Preserve raw inputs and make preparation steps idempotent.
- Record data, split, feature, representation, configuration, environment, and
  artifact provenance at the level needed to reproduce the claim.
- Avoid hidden notebook execution-order dependencies. A documented clean run
  must recreate material outputs.
- Make randomness and known nondeterminism explicit.
- Do not commit large data, checkpoints, secrets, or generated artifacts unless
  repository policy and the user require them.

## Verification

Use small realistic or synthetic fixtures to check:

- shapes, dtypes, units, devices, and missing-value behavior;
- fit/transform and leakage boundaries;
- serialization and artifact reloads;
- mathematical or domain invariants;
- numerical tolerances rather than fragile exact equality;
- a material failure path.

Run repository-native formatting, static checks, and tests. Finish with the
shared compression review.
