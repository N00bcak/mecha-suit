# Representation Workbench Playbook

This stage summary supports `ai-pipeline` planning. At runtime, the
`ai-representation-workbench` Workflow governs.

1. Define what information the representation may use and when it is available.
2. Start from the simplest representation that preserves task-relevant
   structure.
3. For ML, design transformations, features, selections, aggregations,
   embeddings, or pretrained representations with provenance and fit scope.
4. For GOFAI, design states, operators, constraints, knowledge, abstractions,
   symmetries, or heuristics with explicit semantics.
5. Implement a reproducible transformation or construction path when execution
   is requested.
6. Check dimensionality, sparsity, collisions, unknown values, invariants,
   leakage, compute and memory cost, and serialization.
7. Use ablation or controlled comparison when evidence is needed to justify a
   complex representation.

Return the representation artifact or specification, its contract, tests, and
known information loss. Leave final solution selection to problem modeling.
