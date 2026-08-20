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

- A fixed point or enough repository state to identify the implementation
  baseline.
- The diff and applicable repository instructions and standards.
- Accepted intent, specification, acceptance criteria, or an explicit statement
  that none exists.

## Returns

- Separate intent-fidelity, behavioral-correctness, and maintainability reports.
- A stable `RF-*` finding ledger tied to requirement or invariant, evidence,
  scope relation, consequence, classification, and corrective action.
- Review disposition, verification gaps, remediation reconciliation, and next
  corrective task shape.

## Done Conditions

- The fixed point and reviewed change surface are explicit.
- Every material finding is reproducible or clearly marked uncertain.
- Every finding passes separate validity and current-actionability checks.
- Acceptance criteria and unrequested behavior are accounted for when intent is
  available.
- Re-review preserves finding identity and distinguishes failed fixes,
  remediation regressions, late discoveries, and intent conflicts.

## Workflow

### 1. Freeze The Review Surface

Resolve the user-supplied fixed point. Otherwise use the repository's clear
merge base. Ask one focused question if no fixed point
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

### 3. Qualify Findings

Give each finding a stable `RF-*` ID. Record its axis, concrete claim, affected
file and location, criterion, constraint, invariant, scenario, or authoritative
rule, evidence, consequence and likelihood, scope relation, state, and smallest
corrective action with material cost or regression risk.

First test validity. Prefer a reproduced failure, then an accepted contract or
required check, reachable-path analysis, and established local convention.
Confidence, emphatic wording, and preference are not evidence. Then test whether
the finding warrants action in this change. Classify it as `blocking`,
`non-blocking`, `question`, `deferred`, or `rejected` using
  `../../../shared/rubrics/review-contract.md` as the policy source.

Do not block on an equally valid alternative, polish, speculative future cost,
or an unrelated pre-existing defect that does not make the current change
unsafe. A high-consequence uncertainty may request a named decisive check
without presuming that code must change.

### 4. Reconcile Re-Review

When a prior report exists, reconcile every previous blocker before inspecting
the complete current bounded diff. A failed fix retains its ID. Give a
remediation regression a new ID and label its provenance. Do not reopen a
resolved finding or repeat a rebutted assertion without new evidence. Route
intent conflicts to the user. Route unchanged evidence disputes to
adjudication rather than another generic implementation request.

### 5. Report And Gate

Keep axes separate and order actionable findings by consequence. Say when an
axis has no findings. Use one disposition from the shared review contract: `passed`,
`changes required`, `intent decision required`, `adjudication required`, or
`waived`. Only open blockers produce `changes required`; optional, deferred,
rejected, and answered items do not prevent passage.

The user may explicitly waive review with a visible reason; the waiver does not
turn missing verification into passing evidence.

## Progress

Progress is a verified finding, cleared criterion, rejected false positive, or
decisive check. Inspect the full bounded diff and test the highest-risk
uncertainty before returning the three review axes and disposition.
