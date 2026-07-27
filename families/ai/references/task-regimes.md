# AI Task Regimes

Use this map to recognize the problem before selecting a solution. It defines
minimum contracts, not exhaustive domain tutorials.

## Statistical Machine Learning

Includes classification, regression, ranking, forecasting, clustering, anomaly
detection, recommendation, and retrieval.

Identify the prediction or grouping unit, target or objective, observation
time, action time, available information at action time, and failure costs.
Require split and metric choices that match deployment or decision conditions.

Preserve a diverse candidate portfolio when data and compute permit. Include
simple baselines and ensemble-compatible candidates when they provide a useful
comparison rather than automatic complexity.

## Deep Learning

Use when learned representations, modality structure, scale, or an explicit
neural requirement justifies the cost.

Identify input and output structure, supervision, available pretrained assets,
compute and memory limits, acceptable latency, and the cheapest experiment
that can falsify the architecture choice.

Prefer one primary architecture. Add cheap baselines, ablations, or one
material challenger instead of a broad expensive search.

## GOFAI

Includes symbolic reasoning, search, planning, constraint solving, expert
systems, and knowledge representation.

Identify states, actions or operators, constraints, goals, transition rules,
knowledge assumptions, completeness needs, optimality needs, and resource
bounds. Treat representation and heuristic design as first-class work.

Explore competing representations or heuristics when they expose different
structure. Evaluate correctness, termination, search effort, solution quality,
and sensitivity to representative problem instances.

## Hybrid Systems

Use when learned components and symbolic, search, constraint, or retrieval
components have distinct responsibilities.

Define component contracts, information flow, train/evaluation boundaries,
failure propagation, and which component owns uncertainty. Compare the hybrid
against simpler end-to-end and non-learned alternatives when feasible.

## Adjacent Regimes

Representation learning, generative fine-tuning, causal inference,
reinforcement learning, and online learning may alter the ordinary pipeline.
Recognize their objectives, feedback or intervention assumptions, evaluation
unit, and safety constraints explicitly. Use the applicable leaves for bounded
subwork; do not claim a specialized method the references do not provide.
