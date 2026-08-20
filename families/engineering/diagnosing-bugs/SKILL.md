---
name: diagnosing-bugs
description: Diagnose difficult bugs and regressions through a tight reproducer, falsifiable hypotheses, and regression evidence.
---

# Diagnosing Bugs

## Purpose

Determine the supported cause of a difficult bug or performance regression
through a symptom-specific feedback loop, then fix it only when authorized.

## Do Not Use

- Do not use for a routine failing test whose cause and repair are already clear.
- Do not implement a fix when the request is diagnosis-only.
- Do not expose secrets from logs, traces, requests, or environment state.
- Do not spawn, request, or rely on subagents.

## Needs

- Exact observed symptom, expected behavior, and available reproduction steps.
- Repository and relevant environment or a redacted captured artifact.
- Authorization boundary: diagnosis only, or diagnosis and fix.

## Returns

- Tight reproduction command or the exact reproduction limitation.
- Minimized case, ranked hypotheses, probes, cause, and confidence.
- Fix and regression evidence when authorized.
- Cleanup, residual risk, and next diagnostic or architectural action.

## Done Conditions

- The reproduced symptom matches the user's report.
- The stated cause follows from discriminating evidence rather than code-reading
  plausibility alone.
- Authorized fixes pass the regression check and original reproduction.
- Temporary instrumentation is removed and evidence gaps remain explicit.

## Workflow

### 1. Establish The Loop

Build the fastest deterministic check that exercises the actual failure and can
distinguish red from green: focused test, CLI fixture, HTTP request, browser
script, trace replay, small harness, property loop, differential check, or
measured performance baseline.

Run it before theorizing. Confirm it observes the user's exact symptom. Tighten
speed, determinism, and assertion specificity. Redact captured output.

If a loop is unavailable, report attempts and request the smallest missing
environment access, redacted artifact, or instrumentation permission. Static
diagnosis may continue only when clearly labelled as lower-confidence and when
it can still produce discriminating evidence.

### 2. Minimize And Hypothesize

Remove inputs, configuration, callers, or steps one at a time while retaining
the failure. Generate several ranked, falsifiable hypotheses when plausible
alternatives exist. For each, state a prediction that distinguishes it.

### 3. Probe

Change one variable at a time. Prefer debugger or direct state inspection,
targeted uniquely tagged instrumentation, bisection, or profiling over broad
logging. Record which prediction each probe tests.

### 4. Fix When Authorized

Read `../references/behavior-first-development.md`. Convert the minimized case
into a failing regression check at a caller-visible interface when credible,
then apply the smallest fix. Re-run the regression, original reproduction, and
affected checks. If no sound test interface exists, record that architecture
finding rather than adding a weak test.

### 5. Clean Up

Remove tagged instrumentation and temporary harnesses unless a retained
diagnostic artifact is useful and clearly named. State the supported cause,
prevention opportunity, verification, and remaining uncertainty.

## Progress

Progress is a tighter loop, smaller reproducer, falsified hypothesis,
discriminating observation, or verified cause. Try one distinct way to raise
the reproduction signal before returning confidence and the next probe.
