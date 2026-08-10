---
name: code-review
description: Review changes for intent fidelity, behavioral correctness and evidence, and maintainability against a fixed point.
---

# Code Review

## Purpose

Review a bounded change along three independent axes so clean code cannot mask
the wrong behavior and passing tests cannot mask intent drift.

## Do Not Use

- Do not edit the reviewed change unless the user separately requests fixes.
- Do not merge the three axes into one score or let one passing axis excuse
  another.
- Do not treat formatting or tool-enforced style as a manual finding.
- Do not spawn, request, or rely on subagents.

## Needs

- A fixed point or enough lifecycle state to identify the implementation
  baseline.
- The diff and applicable repository instructions and standards.
- Accepted intent, specification, acceptance criteria, or an explicit statement
  that none exists.

## Returns

- Separate intent-fidelity, behavioral-correctness, and maintainability reports.
- Findings tied to requirement, evidence, file location, and consequence.
- Review disposition, verification gaps, and next corrective task shape.
- Updated lifecycle review artifact when lifecycle mode is active.

## Done Conditions

- The fixed point and reviewed change surface are explicit.
- Every material finding is reproducible or clearly marked uncertain.
- Acceptance criteria and unrequested behavior are accounted for when intent is
  available.
- Lifecycle completion is granted, blocked, or explicitly waived by the user.

## Workflow

### 1. Freeze The Review Surface

Resolve the user-supplied fixed point. Otherwise use the lifecycle baseline or
the repository's clear merge base. Ask one focused question if no fixed point
can be derived safely. Confirm the reference resolves and the bounded diff is
non-empty before deeper review. Inspect commits, staged and unstaged changes,
and pre-existing dirty paths. If ownership overlaps and changes the review, ask
before attributing the diff.

Read the full diff, relevant repository instructions, accepted intent, linked
decisions, and verification evidence before reporting findings.

### 2. Review Three Axes

**Intent fidelity**

- Map every `AC-*` criterion to implementation and evidence.
- Find missing, partial, incorrectly interpreted, or unauthorized behavior.
- Check constraints, non-goals, compatibility, and user-authorized revisions.

**Behavioral correctness and evidence**

- Inspect logic, error and failure paths, state transitions, resource ownership,
  concurrency, security, and data integrity where relevant.
- Judge whether tests or other checks can actually detect the claimed behavior.
- Run safe focused checks that decide a material finding.

**Maintainability and local standards**

- Apply repository conventions and
  `../../../shared/rubrics/change-discipline.md`.
- Look for unjustified abstraction, scattered policy, confusing interfaces,
  duplication whose extraction would reduce current cost, and drive-by changes.
- Read `../references/design-decision-discipline.md` for consequential interface
  changes.

### 3. Report And Gate

For each finding give axis, severity, confidence, file and location, evidence,
consequence, and smallest corrective action. Keep axes separate and order
findings by severity within each axis. Say when an axis has no findings.

Lifecycle work may pass only when each criterion is supported by implementation
evidence, explicitly deferred by the user, or marked inapplicable with a reason,
and no blocking finding remains. Record the disposition and evidence for every
criterion. The user may explicitly waive review with a recorded reason; the
waiver does not turn missing verification into passing evidence.

## Lifecycle Participation

When a matching record exists, read
`../../../shared/rubrics/lifecycle-contract.md` unless its current contents are
already available in context. Store and link the report, then route intent,
correctness, and maintainability gaps to their owning task shapes.

## Persistence And Yield

Progress is a verified finding, cleared criterion, rejected false positive, or
decisive check. Inspect the full bounded diff and test the highest-risk
uncertainty before returning the three review axes and disposition.
