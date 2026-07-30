# Skill Selection Examples

## Collaboration

- "Help me turn this rough product idea into a coherent concept" -> `product-co-design`
- "Pressure-test this service idea and identify what we need to validate" -> `product-co-design`
- "Interview me about what I want from this project" -> `interview-me` (explicit invocation only)
- "Keep this debugging session direct and remind me what changed after each tool run" -> `low-friction-collaboration`
- "Give me one clear next step at a time, but do not skip the technical reasoning" -> `low-friction-collaboration`
- "Update the independent Python and TypeScript packages in parallel; they share no files" -> `parallel-subagents`
- "Research these two unrelated source sets and return separate evidence summaries" -> `parallel-subagents`
- "Run the migration first, then update callers based on its output" -> native sequential work; do not delegate in parallel
- "Independently review this production migration plan before I approve it" -> `second-opinion`
- "Check whether this local formatting change is correct" -> routine verification; do not request a second opinion
- "What port does HTTPS normally use?" -> native Codex (already a low-load answer)

## Engineering

- "Fix this one-line parsing bug in a 50k-line service" -> `large-codebase-change`
- "Edit this existing 2k-line utility" -> native Codex
- "Build a new isolated CSV viewer web app" -> `prototype-builder`
- "Create a greenfield CLI that converts JSON to CSV" -> `prototype-builder`
- "Migrate the database schema in this large service" -> `large-codebase-change`; load its migration reference
- "Update Python and TypeScript callers in this large polyglot repository" -> `large-codebase-change`; load only the Python and TypeScript primers

## AI

- "Use ai-pipeline to frame this churn problem end to end" -> `ai-pipeline` (explicit invocation only)
- "Classify these columns, quantify missingness, and package a clean dataset" -> `ai-data-preparation`
- "Find and validate meaningful cohort or temporal patterns in this dataset" -> `ai-insight-development`
- "Build leakage-safe features for these sensor windows" -> `ai-representation-workbench`
- "Choose between boosted trees, a neural model, and a hybrid for this task" -> `ai-problem-modeling`
- "Train and compare these candidates under the agreed split and metrics" -> `ai-performance`
- "Design a state representation and admissible heuristic for this planner" -> `ai-representation-workbench`
- "Benchmark and tune this constraint solver on representative instances" -> `ai-performance`

## Native clarification

- "Help with my project" -> native clarification; no skill yet
- "Assess a product concept whose feasibility depends on an unfamiliar ML approach" -> choose the primary specialist; use `second-opinion` only when an independent consequential review is warranted
- "Integrate a security audit tool into this large codebase and verify it catches known vulnerability classes" -> `large-codebase-change`
