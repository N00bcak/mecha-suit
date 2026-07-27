# AI Pipeline Contract

`ML_PIPELINE.md` is the one-time initial framing artifact created by
`ai-pipeline`. It is not an experiment orchestrator or a required gate for the
execution leaves.

## Location and Safety

- Write it at the active repository or project root.
- If it describes the same problem, preserve empirical results and revise the
  initial framing in place.
- If it describes another problem, ask before replacing or archiving it.
- If the workspace is not writable, return the complete document in the
  response and state that it was not persisted.

Execution leaves never require or create this file. When it exists and is
relevant, they may update their owned section plus risks and recommendations.

## Template

```markdown
# AI Pipeline — <problem>

## Problem
- Objective:
- Regime: statistical ML | deep learning | GOFAI | hybrid | unknown
- Inputs and outputs:
- Unit of analysis or state:
- Constraints:
- Success criteria:

## Evidence Ledger
| Claim | Status | Source | Confidence |
| --- | --- | --- | --- |
| <claim> | <observed, assumed, hypothesized, or proposed> | <artifact or rationale> | <high, medium, or low> |

## Data Preparation
- Available data or knowledge:
- Semantics and quality concerns:
- Required conversions or packaging:
- Unknowns:

## Insight Development
- Known structure and patterns:
- Hypotheses to test:
- Candidate signals, invariants, or constraints:
- Unknowns:

## Representation Workbench
- Candidate features, states, operators, knowledge, embeddings, or heuristics:
- Provenance and fit boundaries:
- Validation needs:

## Problem Modeling
- Formal problem:
- Validation and metrics:
- Baselines:
- Candidate solution families or architectures:
- Constraints affecting selection:

## Candidate Portfolio
| Candidate | Why it exists | Evidence needed | Resource cost | Prune when |
| --- | --- | --- | --- | --- |
| <candidate> | <rationale> | <test> | <relative cost> | <condition> |

## Performance
- Construction, training, or search plan:
- Evaluation and diagnostics:
- Comparison policy:
- Resource measurements:
- Existing results:

## Recommended Execution
- Primary leaf:
- Additional leaves, if material:
- Intentionally skipped stages:
- Suggested order:

## Risks and Unknowns
- <risk or unknown>
```

## Ownership

- `ai-data-preparation`: Data Preparation.
- `ai-insight-development`: Insight Development.
- `ai-representation-workbench`: Representation Workbench.
- `ai-problem-modeling`: Problem Modeling and Candidate Portfolio.
- `ai-performance`: Performance and empirical candidate outcomes.

Any leaf may add a risk or recommend revisiting another stage. Do not turn the
file into a compulsory workflow log.
