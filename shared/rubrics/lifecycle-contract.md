# Lifecycle Contract

Use this contract only when durable continuity or an explicitly activated
lifecycle improves the work. It connects leaf skills through verified state;
it never selects, invokes, or orchestrates them.

## Work Record

Prefer an existing project convention with equivalent fields and authority.
Otherwise use `.mecha/work/<slug>/index.md` and the headings from
`templates/work-index.template.md`. On the first fallback record in a Git
repository, add `.mecha/` to `.gitignore` unless already covered. Keep the
index compact and link detailed artifacts.

Modes:

- `continuity` preserves verified state and one next action across sessions.
- `lifecycle` adds accepted intent, linked evidence, implementation,
  verification, review, and handoff state.

Small ad-hoc work creates no record. Activate lifecycle mode only when the user
requests durable lifecycle planning, accepts an implementation contract,
continues a lifecycle handoff, or asks to execute an accepted host plan.
Skill selection alone is not permission to create durable state.

Discover a record from, in order: a path or slug named by the user, the record
established in the conversation, or one active record whose goal clearly
matches. Ignore unrelated records. Ask one focused question if multiple records
plausibly match and the choice changes edits or accepted intent.

## Resume Candidates

`Resume candidates` may remember explicit session overlays or interactive
loops for a matching existing record. Store canonical skill names without host
syntax. A mode adds only itself. Remove it when it completes, is cancelled, or
is explicitly deactivated.

A candidate is not activation authority. Every session requires fresh explicit
invocation. On the first read in a new session, surface unused candidates once.
If an unfinished candidate loop owns `Current activity` or `Next`, ask whether
to reactivate it. If loop candidates conflict, ask the user to choose. Mention
overlay candidates without blocking otherwise authorized work.

Treat candidates as recent context, not locks. Concurrent sessions can make
them stale, so verify them against current activity and user intent.

## Intent Authority

In lifecycle mode, `Goal`, `Acceptance Criteria`, `Constraints`, and
`Non-Goals` form the intent contract.

- Before acceptance, label them draft and distinguish user statements from
  agent interpretations.
- User approval, or a request to execute the latest completed host plan,
  accepts the contract.
- After acceptance, clarify wording only when meaning is unchanged.
- A semantic change requires explicit user authorization. Record the old and
  new meaning, reason, and date in `Revision History`.
- Evidence may challenge intent but may not rewrite it. Surface the conflict
  for a user-owned decision.

The filesystem and tests are authoritative for implementation state; accepted
intent is authoritative for the desired outcome. Reconcile conflicts openly.

## Phase Participation

When a matching record exists:

1. Read the index and only artifacts relevant to the current leaf.
2. Verify material claims before relying on them.
3. Perform the leaf's work without managing other leaves.
4. Link detailed durable output when useful.
5. Update `Control`, `Artifacts`, `Current Evidence`, `Next`, and
   `Open Questions`.
6. Preserve accepted intent unless the user authorized a revision.
7. Describe the next task in ordinary language so native selection can act.

Each phase owns its completion check and transition. No phase declares another
phase complete or promises another skill will run. Revisit earlier work when
evidence requires it; `Current activity` is a focus, not a state machine.

## Evidence and Completion

Give criteria stable IDs such as `AC-1` and map exact commands, observations,
citations, and artifacts back to them. Lifecycle code work is complete only
when:

- every criterion is satisfied, user-deferred, or inapplicable with a reason;
- relevant verification evidence is recorded;
- the three-axis code review has no blocking finding, or the user records an
  explicit waiver;
- compatibility, rollout, and residual risks are visible.

A review waiver does not turn missing verification into passing evidence.

## Code Review Iterations

Use this protocol for code deliverables. In lifecycle mode, keep the detailed
finding ledger in a linked review artifact and only summarize its disposition,
fixed point, and open blocker IDs in the index. In ad-hoc work, use the same
semantics in the conversation without creating durable state.

Before review, the implementation owner records the bounded diff or artifact,
its baseline and reviewed head, criterion evidence, relevant checks, and known
verification gaps. The accepted intent supplies the review basis but does not
limit correctness review to enumerated criteria.

Every finding receives a stable `RF-*` ID and records:

- review axis, location, and concrete claim;
- affected criterion, constraint, invariant, scenario, or authoritative rule;
- reproducible check or evidence;
- consequence and likelihood;
- scope relation: introduced, worsened, required by the change, or pre-existing;
- smallest corrective action and material cost or regression risk;
- state: `open`, `resolved`, or `waived`, plus any implementation response.

Evaluate the finding in two stages. First decide whether the claim is supported.
Prefer reproduced failure, then accepted contracts or required checks, reachable
path analysis, and established local convention. Reviewer confidence, wording,
and preference are not evidence. Then decide whether action is justified in the
current change. Classify the result as:

- `blocking`: supported and necessary before acceptance;
- `non-blocking`: supported but optional in this change;
- `question`: uncertainty requiring a named check;
- `deferred`: supported but outside the current change;
- `rejected`: unsupported, contradicted, unreachable, or preference-only.

A finding may block for an accepted intent, constraint, compatibility, or
required-check violation; an introduced or worsened material correctness,
security, privacy, concurrency, resource, or data-integrity defect; missing
verification for consequential behavior; or a present maintainability hazard
with a demonstrated current cost. A pre-existing defect blocks only when the
current change cannot ship safely without addressing it. Otherwise defer it.
When two approaches are materially equivalent, preserve the implementer's
choice. Scope additions require user acceptance.

The implementation owner answers every blocker as fixed with evidence, rebutted
with counter-evidence, or conflicting with accepted intent. Re-review reconciles
the previous ledger and then inspects the complete current bounded diff. A
failed remediation retains its finding ID. A remediation regression receives a
new ID. A newly discovered pre-existing issue states its scope relation, and an
intent conflict returns to the user rather than becoming implementation scope.
A rebutted blocker remains open until review accepts the counter-evidence or
routes the dispute to adjudication. Do not reopen a resolved finding without
new evidence.

Use these review dispositions:

- `passed`: no open blocker remains;
- `changes required`: supported open blockers require implementation work;
- `intent decision required`: accepted intent needs a user decision;
- `adjudication required`: evidence remains in genuine dispute;
- `waived`: the user explicitly accepts the visible risk.

Repeating a disputed assertion without new evidence requires adjudication; run
a decisive check or shape one independent adjudication task rather than
bouncing the same request back to implementation. Non-blocking, deferred,
rejected, and answered questions do not prevent `passed`.

## Planning-Mode Boundary

When the host forbids writes during planning, return the complete intent
contract and slices in the conversation. Do not create `.mecha` or edit
`.gitignore`. Materialize the accepted plan on the first execution turn.
Host-specific details belong in `docs/platform-notes.md`.

## Legacy Scratchpads

Do not create `SCRATCHPAD.md`. Verify an existing scratchpad against current
files, Git state, and tests. If durable continuation is useful, offer to
reconcile it into a work record. Preserve the original unless the user
authorizes moving or deleting it. For a tracked scratchpad, request permission
to add a visible supersession note with the date and a warning that `.mecha`
state is local to the checkout.

## Ad-Hoc Compatibility

Without a matching record, follow the leaf's ordinary contract. Do not create
lifecycle artifacts, require lifecycle phases, or ask the user to opt out.
