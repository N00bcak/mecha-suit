# Performance Playbook

Training or construction and evaluation are one evidence loop. Do not optimize
against a changing or invalid evaluation contract.

1. Reproduce the simplest baseline and verify the data, representation,
   objective, metric, and artifact path.
2. Implement the candidate using repository-native frameworks and conventions.
3. For ML or DL, train with visible configuration, checkpoints where material,
   learning diagnostics, and bounded tuning.
4. For GOFAI, construct and tune the solver, planner, rules, constraints, or
   heuristic under explicit cutoff and guarantee policies.
5. Evaluate on untouched valid evidence; report uncertainty, calibration,
   subgroup or instance-class behavior, failure modes, and resource use when
   material.
6. Compare candidates under the same contract. Evaluate ensembles only when
   their gain justifies inference and maintenance cost.
7. Perform error analysis and decide whether evidence points to performance,
   problem modeling, representation, insights, or preparation.
8. Save or document the evaluated artifact and a reproducible run path when
   requested.

Ask before materially expensive or remote jobs. End with an evaluated solution
and explicit production-promotion needs; do not silently expand into serving or
deployment.
