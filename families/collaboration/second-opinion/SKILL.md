---
name: second-opinion
description: Obtain an independent evidence-backed critique of a consequential conclusion, diagnosis, plan, or diff.
---

# Second Opinion

## Purpose

Obtain one independent critique before the main process commits to a
consequential, uncertain, or difficult-to-reverse conclusion or action.

## Do Not Use

- The answer is routine and directly verifiable.
- An ordinary test provides stronger evidence.
- The reviewer cannot access the artifact or evidence being judged.
- The goal is endorsement rather than independent assessment.
- Do not replace tests, authoritative sources, or user-owned decisions with a
  reviewer verdict.

## Needs

- The frozen artifact or question under review.
- Decision criteria, constraints, and raw evidence.
- An explicit statement of what the reviewer must not change.
- A non-leading packet that omits the main process's preferred answer,
  confidence, and detailed rationale unless that rationale is the artifact.

## Returns

Require the reviewer to return:

```yaml
verdict: "agree | disagree | uncertain"
material_findings:
  - "<finding tied to evidence>"
missing_evidence:
  - "<gap or none>"
alternative: "<better conclusion or action, if any>"
confidence: "high | medium | low"
recommended_check: "<one decisive check or null>"
```

The main process reports whether it accepted, rejected, or qualified each
material finding and why.

## Done Conditions

- The review is independent enough for its stated purpose.
- Every material finding points to evidence or a reproducible check.
- The main process adjudicates the review rather than treating it as a vote.
- Any safe, in-scope decisive check is run.

## Workflow

1. Check that the host exposes subagent capability. If not, continue with
   direct verification and do not promise a review.
2. Freeze or identify the artifact and prepare a context-minimal, non-leading
   review packet.
3. Spawn exactly one read-only reviewer by default and prohibit artifact
   mutation.
4. Continue independent verification in the main process.
5. Compare the structured review with direct evidence.
6. Accept, reject, or qualify each material finding.
7. Record the resulting decision, checks, and remaining uncertainty.

Subagents receive no broader permissions than the main task authorizes.
Subagents must not spawn or request subagents.
Destructive actions, publication, external messages, scope expansion, and final
decisions remain with the main process. Cancel and collect the reviewer if the
review becomes unnecessary. Request findings and evidence, never hidden
chain-of-thought.

## Progress

Progress is a completed review, verified finding, rejected weak claim, or
narrower uncertainty. Collect or stop the reviewer, inspect its evidence, and
run any safe decisive check before returning the adjudication.
