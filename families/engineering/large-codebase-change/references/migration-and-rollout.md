# Migration and Rollout

Reference for safely shipping database migrations, API changes, and staged rollouts.

---

## Database migration safety

Every migration must satisfy:

- [ ] **Reversible**: a corresponding down migration exists and is tested
- [ ] **No data loss**: columns/tables are not dropped until reads are fully removed
- [ ] **Lock-aware**: no long-running locks on large tables (see lock duration table below)
- [ ] **Tested on a copy**: run against a production-size dataset copy before deploying

### Lock duration by operation (PostgreSQL)

| Operation | Lock type | Safe on large tables? |
|---|---|---|
| `ADD COLUMN` (nullable, no default) | `ACCESS EXCLUSIVE` (brief) | Yes |
| `ADD COLUMN` with default (PG 11+) | `ACCESS EXCLUSIVE` (brief) | Yes |
| `ADD COLUMN` with default (PG < 11) | `ACCESS EXCLUSIVE` (rewrites table) | No — backfill separately |
| `DROP COLUMN` | `ACCESS EXCLUSIVE` (brief) | Yes (metadata only) |
| `ADD INDEX` | `SHARE` (blocks writes) | No — use `CONCURRENTLY` |
| `ADD INDEX CONCURRENTLY` | None (weak locks only) | Yes |
| `ADD NOT NULL constraint` | `ACCESS EXCLUSIVE` (scans table) | No — use `NOT VALID` + `VALIDATE` |
| `ALTER COLUMN TYPE` | `ACCESS EXCLUSIVE` (rewrites table) | No — create new column, backfill, swap |
| `RENAME COLUMN` | `ACCESS EXCLUSIVE` (brief) | Yes (but breaks queries using old name) |

### Schema change patterns

**Add column:**
```sql
ALTER TABLE t ADD COLUMN new_col TYPE;
-- Safe. No backfill needed if nullable with no default.
```

**Rename column (two-phase):**
```
Phase 1: Add new column, dual-write to both, backfill old rows
Phase 2: Switch reads to new column, stop writing old column
Phase 3: Drop old column
```

**Drop column:**
```
Step 1: Remove all code that reads the column
Step 2: Deploy. Verify no queries reference the column.
Step 3: Drop the column in a migration
```

**Add NOT NULL to existing column:**
```sql
-- Step 1: Add constraint as NOT VALID (no table scan)
ALTER TABLE t ADD CONSTRAINT t_col_nn CHECK (col IS NOT NULL) NOT VALID;

-- Step 2: Backfill NULLs in batches
UPDATE t SET col = default_value WHERE col IS NULL AND id BETWEEN ? AND ?;

-- Step 3: Validate (scans table but holds weaker lock)
ALTER TABLE t VALIDATE CONSTRAINT t_col_nn;
```

## API versioning

### Safe (non-breaking) changes

- Adding a new optional field to a response
- Adding a new endpoint
- Adding a new optional query parameter
- Widening a type (e.g., accepting both string and number)

### Breaking changes (require versioning)

- Removing or renaming a response field
- Changing a field's type
- Removing an endpoint
- Making an optional parameter required
- Changing error response structure

### Versioning approaches

| Approach | Pros | Cons |
|---|---|---|
| URL path (`/v2/resource`) | Explicit, easy to route | URL proliferation |
| Header (`Accept: application/vnd.api+json;v=2`) | Clean URLs | Hidden, harder to test |
| Query param (`?version=2`) | Simple | Easy to forget |

**Regardless of approach:** old versions must continue working during the transition period. Set a deprecation timeline and communicate it.

## Feature flags

### When to use

- Gradual rollout (1% -> 10% -> 50% -> 100%)
- Testing a change in production with real traffic
- Long-running feature branches that need to merge to main frequently
- Kill switch for risky changes

### When NOT to use

- Simple, low-risk changes (the flag adds more complexity than it removes)
- One-shot migrations (flag would never be toggled back)
- Changes that cannot meaningfully run partially (e.g., schema-level changes)

### Flag hygiene

- [ ] Flag has an owner and a removal date
- [ ] Flag defaults to "off" in production
- [ ] Code paths for both flag states are tested
- [ ] Flag is removed within 2 weeks of full rollout

## Backward compatibility

During rollout, two versions of your code coexist. Both must work.

**Checklist:**
- [ ] Old clients can read data written by new code
- [ ] New code can read data written by old code
- [ ] Old and new code can run simultaneously without corrupting shared state
- [ ] Queued jobs/messages created by old code can be processed by new code (and vice versa)
- [ ] Cached values from old code are handled gracefully by new code

## Rollback strategies

| Strategy | Recovery time | Preparation needed |
|---|---|---|
| Redeploy previous version | Minutes | Immutable artifacts, known-good version tag |
| Feature flag toggle | Seconds | Flag already in place |
| Database rollback migration | Minutes to hours | Down migration written and tested |
| Data restore from backup | Hours | Regular backups, tested restore procedure |

**Before deploying, answer:**
- Can this be rolled back by deploying the previous version?
- If a migration ran, can it be reversed?
- If reversal is impossible, what is the manual remediation plan?

## Data migration patterns

### Backfill in batches

```
1. Process rows in batches of 1000-10000
2. Sleep between batches to avoid overwhelming the database
3. Log progress (rows processed, errors encountered)
4. Make the backfill idempotent so it can be re-run safely
5. Verify completion: count rows that still need processing
```

### Dual-write during transition

```
1. Deploy code that writes to both old and new location
2. Backfill old data into the new location
3. Verify old and new are in sync
4. Switch reads to the new location
5. Stop writing to the old location
6. Remove old data after a safety period
```

### Verify before cutting over

- Row counts match (accounting for expected differences)
- Spot-check sample records
- Run validation queries comparing old and new
- Shadow-read from new while serving from old; alert on mismatches

## Deployment ordering

The safe order depends on whether you are adding or removing a dependency.

**Adding a new field/endpoint/message type:**
```
Deploy consumers first (they must tolerate the new thing)
  → Then deploy producers (they start emitting the new thing)
```

**Removing a field/endpoint/message type:**
```
Deploy producers first (they stop emitting the old thing)
  → Then deploy consumers (they stop expecting the old thing)
```

Getting the order wrong causes either unhandled data (adding) or missing data (removing).
