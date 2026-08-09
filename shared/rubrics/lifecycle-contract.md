# Lifecycle Contract

Use this contract only when durable continuity or an explicitly activated
lifecycle improves the current work. It connects leaf skills through verified
state without selecting, invoking, or orchestrating them.

## Work Record

Use the repository's existing work-state convention when it provides the same
fields and authority boundaries. Otherwise use:

```text
.mecha/work/<slug>/index.md
```

When creating the first fallback record in a Git repository, add `.mecha/` to
the repository's `.gitignore` unless an existing rule already covers it. Use a
short stable slug. Keep separate efforts in separate directories.

Read `templates/work-index.template.md` from the Mecha Suit repository for the
canonical headings. Keep the index compact; point to detailed artifacts rather
than copying them into it.

### Modes

- `continuity`: durable state for ordinary multi-session work. It does not
  activate specification, slicing, or review requirements.
- `lifecycle`: accepted intent and linked evidence guide work through relevant
  discovery, planning, implementation, verification, review, and handoff.

Small self-contained ad-hoc work creates no record. Promote continuity mode to
lifecycle mode only when the user explicitly requests durable lifecycle
planning, accepts an implementation contract, continues from a lifecycle
handoff, or accepts a host planning-mode output that will guide execution.

Skill selection alone is not permission to create durable state. If decision
mapping is selected implicitly, work in the conversation until the user asks
to persist the map or accepts it as lifecycle intent.

### Discovery

Prefer, in order:

1. A work-record path or slug named in the request or handoff.
2. The work record already established in the current conversation.
3. One active record whose goal clearly matches the requested work.

Ignore unrelated records. If more than one record plausibly matches and the
choice changes what will be edited or treated as accepted intent, ask one
focused question.

## Intent Authority

In lifecycle mode, `Goal`, `Acceptance Criteria`, `Constraints`, and
`Non-Goals` are the intent contract.

- Before acceptance, label them draft and distinguish user statements from
  agent interpretations.
- The user's approval of the contract, or request to execute the latest
  completed planning-mode plan, accepts it.
- After acceptance, an agent may clarify wording only when meaning is
  unchanged.
- A semantic change requires explicit user authorization. Record the old
  meaning, new meaning, reason, and date in `Revision History`.
- New implementation evidence may challenge intent but may not rewrite it.
  Surface the conflict and route back to the user-owned decision.

The filesystem and tests are authoritative for implementation state. The
accepted intent contract is authoritative for the desired outcome. Reconcile a
conflict explicitly; do not silently make one agree with the other.

## Phase Participation

When a matching work record exists:

1. Read the index and only the linked artifacts relevant to the current leaf.
2. Verify material state claims before relying on them.
3. Perform the leaf's own work; do not manage other leaves.
4. Write detailed output to a linked artifact when durable output is useful.
5. Update `Control`, `Artifacts`, `Current Evidence`, `Next`, and
   `Open Questions`.
6. Preserve locked intent unless the user authorized a revision.
7. Name the next task shape in ordinary language so native selection can choose
   the next leaf.

A phase owns its completion check and transition update. No phase may declare
another phase complete or promise that another skill will run.

Research, domain modeling, decision work, diagnosis, and implementation may be
revisited when evidence requires it. `Current activity` records present focus;
it is not a one-way state machine.

## Evidence And Completion

Give acceptance criteria stable identifiers such as `AC-1`. Map implementation
and verification evidence back to those identifiers. Record exact commands,
observations, citations, or artifacts rather than a generic statement that
verification passed.

Lifecycle code work may enter `complete` only when:

- every acceptance criterion is satisfied, explicitly deferred by the user, or
  marked inapplicable with a reason;
- relevant verification evidence is recorded;
- the three-axis code review has no unresolved blocking finding, or the user
  explicitly waived review and the reason is recorded;
- known compatibility, rollout, and residual risks are visible.

A review waiver does not convert missing verification into passing evidence.

## Planning-Mode Boundary

When the host forbids writes during planning mode, return the complete proposed
intent contract and work slices in the conversation. Do not create `.mecha` or
edit `.gitignore` from that mode. On the first execution turn, materialize the
latest accepted plan before implementation begins.

Keep this rule host-neutral. Host-specific activation and persistence details
belong in `docs/platform-notes.md`.

## Legacy Scratchpads

Do not create new `SCRATCHPAD.md` files. If an existing scratchpad appears:

1. Read and verify it against current files, Git state, and tests.
2. Offer to reconcile its useful state into a `.mecha` work record when
   durable continuation is needed.
3. Preserve the original unless the user explicitly authorizes moving or
   deleting it. If the scratchpad is tracked, do not make an ignored work
   record its silent successor: request permission to add a visible
   supersession note to the scratchpad, including the reconciliation date and
   warning that `.mecha` state is local to the checkout.

## Ad-Hoc Compatibility

When no matching work record exists and the task does not warrant durable
continuity, follow the leaf's ordinary contract. Do not create lifecycle
artifacts, require lifecycle phases, or ask the user to opt out.
