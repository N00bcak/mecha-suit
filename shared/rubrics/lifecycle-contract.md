# Lifecycle Contract

Only `multi-step-governance` uses this contract. It governs an explicitly
authorized, durable process; it never selects or invokes specialists.

## Work Record

Prefer an existing project convention with equivalent authority. Otherwise use
`.mecha/work/<slug>/index.md` and `templates/work-index.template.md`. Add
`.mecha/` to `.gitignore` on the first fallback record in a Git repository.
Keep the index compact and link detailed artifacts.

Create or update a record only after the user authorizes governed work. A
matching legacy record may be resumed, but its claims must be verified against
current files, Git state, tests, and referenced artifacts before reliance.
Small work creates no work record. It may keep working notes under
`.mecha/logs/`; those notes are not records and carry no lifecycle authority.
Accepting or executing a plan does not activate governance. Only an explicitly
active governor materializes accepted intent and updates the matching record.

## Authority

The governor is the sole record writer. Contributors return bounded artifacts,
findings, and evidence; the governor links their outcomes without granting
contributors phase, intent, or completion authority.

`Goal`, `Acceptance Criteria`, `Constraints`, and `Non-Goals` are
user-authoritative after acceptance. Before acceptance, distinguish user
statements from proposals. A semantic revision requires explicit authorization
and a dated reason. Evidence may challenge intent but cannot silently rewrite it.

## Operating The Record

At meaningful transitions, update control state, artifacts, current evidence,
open questions, and one next task shape. Use stable `AC-*` identifiers and map
verification evidence to them. The governor may record its own paused state as
a resume candidate, but a candidate never activates an explicit mode.

On resumption, surface unused candidates once, verify the record, and ask for
explicit reactivation of an unfinished loop. An overlay candidate is advisory
and never blocks otherwise authorized work.

## Completion And Review

Governed code work completes only when each criterion is satisfied, deferred,
or inapplicable with a reason; relevant evidence is visible; and the recorded
review outcome has no open blocker IDs or has an explicit user waiver. The
governor records only the detailed review report link, disposition, open blocker
IDs, waiver state, and next task. It prevents closure while recorded blockers
remain, but does not inspect a diff, classify or validate findings, reopen them,
or adjudicate technical claims.

Do not create `SCRATCHPAD.md`. Preserve an existing user scratchpad unless the
user authorizes a visible migration or supersession.
