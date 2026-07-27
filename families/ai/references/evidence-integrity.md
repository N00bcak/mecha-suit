# AI Evidence Integrity

## Claim Status

Label material claims as:

- **Observed:** measured or directly present in an artifact.
- **Assumed:** accepted for the current pass without evidence.
- **Hypothesized:** testable explanation or predicted relationship.
- **Proposed:** design choice awaiting implementation or evaluation.

Do not present exploratory patterns as confirmed findings or theoretical
properties as empirical results.

## Leakage and Validation

- Define what information is available at decision time.
- Split at the correct independence unit: entity, group, time, location,
  source, or another domain boundary.
- Fit learned preparation and representation steps only on permitted training
  data.
- Keep selection and tuning evidence separate from final evaluation evidence.
- Detect duplicate, derived, future, proxy-target, and group leakage.
- Match metrics to the actual decision cost and class or outcome distribution.

## Comparisons

- Keep a naive or simple baseline visible.
- Change one material hypothesis at a time when attribution matters.
- Use the same valid data and evaluation contract across candidates.
- Report uncertainty or variability when it can change the conclusion.
- Record resource cost alongside quality when feasibility matters.
- Prefer an honest inconclusive result to a comparison contaminated by changed
  splits, preprocessing, or metrics.

## Reproducibility

Record the data/split identity, transformations, relevant environment and
library versions, random controls, configuration, and artifact locations.
Seeds do not guarantee determinism; report material nondeterminism instead of
claiming exact reproducibility.
