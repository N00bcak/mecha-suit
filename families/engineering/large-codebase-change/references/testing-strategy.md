# Risk-Calibrated Testing

Select tests from the changed behavior, affected boundaries, and consequence of
failure. Do not apply a fixed test pyramid or coverage quota.

## Decision Aid

| Change shape | Evidence to prioritize |
|---|---|
| Bug fix | A regression test that fails without the fix |
| Local behavior | Focused unit or component test plus a material error case |
| Shared contract | Producer/consumer or contract tests and affected integrations |
| Persistence | Integration tests against the repository's realistic test store |
| Refactor | Existing behavior tests; add characterization only for material gaps |
| Concurrency | Deterministic coordination tests and configured race tooling |
| Performance | A representative benchmark only when performance is the claim |
| Configuration | A test proving the configured path is actually consumed |

Prefer the lowest-cost test that observes the real failure. Add broader tests
when a boundary or blast radius makes focused evidence insufficient.

## Test Design

- Assert observable behavior, stable contracts, and meaningful side effects.
- Use existing fixtures and repository test patterns.
- Cover a failure path that could invalidate the change.
- Keep tests deterministic and clean up owned resources.
- Mock external boundaries only when the real boundary is unavailable or too
  costly; do not mock the implementation under test.
- Do not test trivial delegation, framework internals, or exact incidental text.

## Verification Sequence

1. Run the narrowest test that can fail for the changed behavior.
2. Run static checks and tests for affected packages or modules.
3. Expand to integration, contract, or end-to-end coverage when shared state or
   compatibility is involved.
4. Run the repository's broader required suite before handoff when practical.

When a command cannot run, report the exact command, failure, and remaining
uncertainty. Distinguish demonstrated pre-existing failures from failures
introduced by the diff.
