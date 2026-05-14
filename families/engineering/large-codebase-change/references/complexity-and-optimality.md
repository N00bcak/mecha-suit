# Complexity and Optimality

## YAGNI — When to Abstraction

Add abstraction when:
- The same logic exists in 3+ places and is changing together.
- A clear domain boundary exists (e.g., separate "parse" from "execute").
- The interface is shared across teams/services and needs a stable contract.

Do not add abstraction when:
- There is only one implementation and no evidence a second is coming.
- The "pattern" was seen once and might not recur.
- The abstraction is more complex than the duplication it removes.

**The test:** would removing the abstraction and inlining the code make things simpler with no loss of correctness? If yes, the abstraction is premature.

## Signs of Over-engineering

| Sign | Example | Fix |
|---|---|---|
| Wrapper adds nothing | `UserServiceWrapper` that delegates every method to `UserService` | Remove wrapper, call directly |
| Generics for one type | `Repository<T>` but only `Repository<User>` exists | Use concrete type until a second type appears |
| Config for constants | Externalizing values that never change (port 443, HTTP methods) | Hardcode; move to config only when ops needs to change it |
| Factory for one product | `createHandler()` that always returns the same handler | Construct directly |
| Interface for one impl | `IFooService` with only `FooService`, no mock needed | Remove interface; extract if a second impl appears |
| Premature plugin system | Extension points with zero extensions | Delete; add when the first plugin is built |
| Abstraction layering | Controller calls service calls repository calls DAO for a simple CRUD read | Collapse layers that add no logic |

## Signs of Under-engineering

| Sign | Example | Fix |
|---|---|---|
| Copy-pasted logic diverging | Same 20-line block in 4 files, each with slight bug fixes applied differently | Extract shared function |
| No boundary at natural seam | Parsing, validation, and execution interleaved in one 300-line function | Split at the parse/validate/execute boundaries |
| Stringly-typed interfaces | Passing `"admin"` as a string instead of an enum/constant | Introduce a type or constant set |
| Raw SQL scattered | Query strings duplicated across handlers with no parameterization | Centralize queries or use a query builder |
| Error handling by convention | Callers expected to check a magic return value (-1, null) | Use the language's error/exception/result type |

## Asymptotic Complexity Quick Reference

| Operation | Typical Cost | Notes |
|---|---|---|
| Array/list index access | O(1) | |
| Array/list append | O(1) amortized | May trigger resize |
| Array/list insert at front | O(n) | Shifts all elements |
| Array/list search (unsorted) | O(n) | |
| Hash map/set lookup | O(1) average | O(n) worst case with bad hash |
| Hash map/set insert | O(1) average | |
| Balanced tree lookup/insert | O(log n) | |
| Sort (comparison-based) | O(n log n) | |
| Binary search (sorted array) | O(log n) | |
| BFS/DFS graph traversal | O(V + E) | |
| Matrix multiplication (naive) | O(n^3) | |
| Generating all subsets | O(2^n) | |
| Generating all permutations | O(n!) | |

## Common Accidentally-quadratic Patterns

### Nested loops over same collection
```
for item in items:            # O(n)
    if item not in seen_list: # O(n) — linear scan
        seen_list.append(item)
# Fix: use a set for `seen`, making lookup O(1)
```

### N+1 queries
```
users = db.query("SELECT * FROM users")          # 1 query
for user in users:
    orders = db.query("SELECT * FROM orders WHERE user_id = ?", user.id)  # n queries
# Fix: JOIN or batch query with IN clause
```

### String concatenation in loop
```
result = ""
for s in strings:    # O(n) iterations
    result += s      # O(total_length) each time — copies entire string
# Fix: use StringBuilder, join(), or list append + single join
```

### Repeated linear search
```
for id in ids:                   # O(n)
    match = find_in_list(items, id)  # O(m) each time
# Fix: build a dict/map from items first, then look up by key
```

### Quadratic deduplication
```
unique = []
for item in items:          # O(n)
    if item not in unique:  # O(n) — scans unique list
        unique.append(item)
# Fix: use a set, or sort + adjacent dedup
```

## Data Structure Selection

| Need | Use | Not |
|---|---|---|
| Ordered sequence, index access | Array / Vec / List | Linked list (poor cache, O(n) index) |
| Fast membership test | Hash set | Array scan |
| Key-value lookup | Hash map | List of pairs |
| Sorted order + lookup | Balanced tree (TreeMap/BTreeMap) | Sorted array (expensive insert) |
| FIFO processing | Queue / Deque | Array with shift (O(n) front removal) |
| LIFO processing | Stack (array-backed) | Linked list (overhead) |
| Priority-based processing | Heap / Priority queue | Sorted list (O(n) insert) |
| Fast prefix/substring search | Trie / suffix structure | Repeated full-string scan |
| Graph with sparse edges | Adjacency list | Adjacency matrix (wastes space) |
| Graph with dense edges | Adjacency matrix | Adjacency list (wastes pointers) |

## When NOT to Optimize

- **Small n.** If the collection never exceeds ~100 elements, O(n^2) is fine. Measure before rewriting.
- **Cold paths.** Code that runs once at startup or once per user request is rarely a bottleneck.
- **Readability trade-off.** If the "optimized" version is harder to understand and the performance gain is unmeasurable, keep the simple version.
- **No profiling data.** Do not optimize based on intuition. Profile first, identify the actual bottleneck, then optimize that.
- **Premature caching.** Caching adds invalidation complexity. Only cache when you have measured latency or load problems.

**The rule:** write correct, clear code first. Optimize only when measurements show a specific bottleneck, and keep the optimization localized.

## Database Query Patterns

| Problem | Symptom | Fix |
|---|---|---|
| N+1 queries | One query per row in a loop | JOIN, subquery, or batch IN clause |
| Missing index | Slow queries on filtered/sorted columns | Add index on WHERE/ORDER BY columns; check EXPLAIN |
| Unbounded query | `SELECT *` with no LIMIT on large table | Add LIMIT/pagination; require bounds |
| Full table scan | Query ignores available indexes | Check EXPLAIN; rewrite predicate to use index; avoid functions on indexed columns |
| SELECT * | Fetches unused columns, wastes bandwidth | Select only needed columns |
| Cartesian join | Missing or wrong JOIN condition | Verify ON clause matches intended relationship |
| Lock contention | Long-running transactions block others | Shorten transactions; use optimistic locking for read-heavy workloads |
| Unparameterized queries | SQL injection risk + no query plan caching | Use parameterized queries / prepared statements always |
