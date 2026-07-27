# Problem Modeling Playbook

1. Formalize inputs, outputs, states, actions, targets, objectives, constraints,
   and the conditions under which a solution will be used.
2. Choose validation units, metrics, baselines, and resource measures before
   selecting the main candidate.
3. Identify candidate statistical, neural, symbolic, search, constraint, or
   hybrid solution families that fit the evidence and constraints.
4. For neural candidates, specify input/output structure, inductive biases,
   pretrained assets, losses, capacity, and memory or latency constraints.
5. For GOFAI candidates, specify representation, search or inference procedure,
   guarantees, heuristic assumptions, and resource bounds.
6. Preserve a domain-calibrated portfolio:
   - diverse and ensemble-compatible candidates for classical ML when useful;
   - competing representations or heuristics for GOFAI;
   - one primary deep architecture plus cheap baselines, ablations, or a
     decision-changing challenger.
7. Give each candidate a rationale, evidence requirement, relative cost, and
   pruning condition.

Return an experiment-ready specification. Do not launch materially expensive
training or search from this playbook.
