---
name: portable-handoff
description: Package verified work state into a redacted portable handoff for another session, machine, agent, or collaborator.
---

# Portable Handoff

## Purpose

Transfer enough verified context for a new recipient to continue safely without
reconstructing the work or receiving unnecessary private information.

## Do Not Use

- Do not require a handoff for ordinary phase transitions in one active context.
- Do not duplicate complete tracked plans, decisions, diffs, or logs when the
  recipient can access them.
- Do not include secrets, credentials, private identifiers, or irrelevant
  personal data.
- Do not spawn, request, or rely on subagents.

## Needs

- Target recipient and what they will do next.
- Current conversation, work record, repository state, and relevant artifacts.
- Destination path when the user has one.

## Returns

- One redacted Markdown handoff at the requested path, or the OS temporary
  directory by default.
- Accessible pointers plus inlined local-only context the recipient requires.
- Verification state, blockers, risks, and one actionable next step.

## Done Conditions

- A recipient without conversation memory can orient and begin safely.
- Intent revision, decisions, current state, and evidence are accurate.
- Every pointer is accessible to the intended recipient or its essential
  content is included.
- Sensitive and irrelevant material is absent or visibly redacted.

## Workflow

1. Determine the recipient, environment, purpose, and expected next action.
2. Read the matching work index and verify material claims against repository
   state and recent checks.
3. Reference accessible primary artifacts instead of summarizing them again.
4. Inline essential ignored or machine-local state that the recipient cannot
   access, keeping it concise.
5. Redact sensitive values as `<REDACTED>` and omit unnecessary personal data.
6. Write one Markdown file named `mecha-handoff-<slug>-<timestamp>.md` unless
   the user supplied a destination.

Include: purpose, environment and repository identity, accepted intent revision
or `No lifecycle record`, decisions, completed and partial work, exact
verification evidence, risks, blockers, artifact pointers, the next task shape
in ordinary language, advisory resume candidates, and one next action. State
that candidates require explicit activation in the destination session.

Do not commit, publish, send, or upload the handoff unless separately requested.

## Progress

Progress is verified transferable state, an accessible pointer, or a resolved
recipient-context gap. Before yielding, check the packet as the recipient,
verify the next action when safe, and scan for sensitive content.
