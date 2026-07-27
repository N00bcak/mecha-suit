# Search and GOFAI Performance

Load this reference only for search, planning, constraint, symbolic, or hybrid
solution paths.

## Correctness Contract

- Define state identity, legal operators, goals, constraints, and termination.
- Canonicalize equivalent states when correctness permits.
- State completeness and optimality requirements.
- Check heuristic admissibility or consistency when the algorithm relies on
  those properties.
- Make pruning assumptions explicit and test that they preserve required
  solutions.

## Resource Discipline

- Estimate branching, depth, state growth, and dominant memory use.
- Use memoization, duplicate detection, indexing, propagation, or bounds when
  the representation supports them.
- Avoid copying large states when a clear immutable, incremental, or reversible
  representation is available.
- Bound search and report timeout, cutoff, or approximation behavior honestly.

## Evaluation

Benchmark representative easy, typical, adversarial, and scaling instances.
Measure solution validity, quality, expanded states or equivalent work,
latency, and memory. Compare representations and heuristics independently when
the evidence needs to attribute their effects.
