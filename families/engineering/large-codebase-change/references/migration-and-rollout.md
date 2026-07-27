# Migration and Rollout Decisions

Use this reference for database, API, message, configuration, or staged
deployment changes. Derive exact mechanics from the repository's datastore,
toolchain, operating environment, and compatibility contract.

## Assess First

- Which producers, consumers, deployables, and stored records use the contract?
- Can old and new versions run concurrently?
- Is the operation additive, destructive, or a semantic reinterpretation?
- What is the realistic data volume and lock or rewrite behavior?
- How will progress, correctness, and rollback be observed?
- Who owns deployment order and the final destructive step?

## Choose a Change Shape

Use a direct change when deployment is atomic, data is disposable or trivially
recoverable, and no compatibility window exists.

Use expand/migrate/contract when versions overlap or data must remain
available:

1. Add a backward-compatible representation.
2. Deploy readers and writers that tolerate both forms.
3. Backfill or translate data with resumable, observable work.
4. Verify equivalence and switch authoritative reads.
5. Stop producing the old form.
6. Remove it only after consumers and rollback windows permit.

Use a feature flag or staged rollout only when it provides a real kill switch,
limits blast radius, or supplies evidence. Include ownership and removal
criteria so the flag does not become permanent configuration.

## Data Safety

- Follow datastore-specific documentation for locks, rewrites, online index
  operations, and transactional behavior.
- Make long-running backfills resumable and idempotent.
- Bound work using a repository-appropriate key or cursor; choose batch size
  from observed behavior rather than a universal threshold.
- Record progress and errors without exposing sensitive values.
- Compare counts, invariants, checksums, samples, or shadow reads as appropriate
  to the risk.
- Do not claim reversibility when rollback would discard writes made under the
  new schema. Define recovery separately from syntactic down migrations.

## Compatibility and Ordering

- Deploy tolerant consumers before producers emit an additive contract.
- Stop production of an old contract before strict consumers remove support.
- Keep mixed-version behavior explicit in tests.
- For public or cross-team APIs, record deprecation ownership and completion
  criteria.

## Handoff Evidence

Report migration phases, version compatibility, deployment order, validation
queries or tests, observability, abort criteria, rollback or recovery limits,
and the intentionally deferred destructive step.
