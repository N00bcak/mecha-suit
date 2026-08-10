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
