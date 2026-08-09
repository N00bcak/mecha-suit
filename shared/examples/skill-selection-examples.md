# Skill Selection Examples

## Collaboration

- "Use $product-co-design to turn this rough product idea into a coherent concept" -> `product-co-design` interactive loop
- "Help me think about this rough product idea" -> native product assistance; do not activate the loop implicitly
- "Research how dispatchers currently handle failed deliveries and what competing tools support" -> `product-research`
- "Use $product-co-design to decide which delivery workflow we should build from these findings" -> `product-co-design`, using the research as evidence
- "Our code and docs use account, customer, and user inconsistently; help us define them" -> `domain-modeling`
- "This migration is too large to plan in one session; map the decisions we must resolve first" -> `decision-mapping`
- "Package the verified state of this work so I can continue on another machine" -> `portable-handoff`
- "Use $interview-me to interview me about what I want from this project" -> `interview-me` interactive loop
- "Use $low-friction-collaboration for this debugging session" -> `low-friction-collaboration` session overlay
- "Give me one clear next step at a time" -> follow the direct request natively; do not activate an overlay implicitly
- "Use $interview-me and $product-co-design" -> ask which exclusive loop should govern before activating either
- "Update the independent Python and TypeScript packages in parallel; they share no files" -> `parallel-subagents`
- "Research these two unrelated source sets and return separate evidence summaries" -> `parallel-subagents`
- "Run the migration first, then update callers based on its output" -> native sequential work; do not delegate in parallel
- "Independently review this production migration plan before I approve it" -> `second-opinion`
- "Check whether this local formatting change is correct" -> routine verification; do not request a second opinion
- "What port does HTTPS normally use?" -> native Codex (already a low-load answer)

## Engineering

- "Check the official API and source to determine whether this SDK supports streaming retries" -> `technical-research`
- "Turn the decisions in this conversation into accepted behavior, constraints, and acceptance criteria" -> `implementation-spec`
- "Break this accepted implementation contract into independently verifiable vertical slices" -> `work-slicing`
- "Fix this one-line parsing bug in a 50k-line service" -> `large-codebase-change`
- "Edit this existing 2k-line utility" -> native Codex
- "Build a new isolated CSV viewer web app" -> `prototype-builder`
- "Create a greenfield CLI that converts JSON to CSV" -> `prototype-builder`
- "Migrate the database schema in this large service" -> `large-codebase-change`; load its migration reference
- "Update Python and TypeScript callers in this large polyglot repository" -> `large-codebase-change`; load only the Python and TypeScript primers
- "This intermittent cache corruption has resisted two fixes; diagnose it" -> `diagnosing-bugs`
- "Investigate and fix this intermittent failure in a 50k-line service" -> `diagnosing-bugs` for the uncertain cause, then `large-codebase-change` for the supported repair
- "Review the changes since main against the accepted specification" -> `code-review`
- "Independently challenge this code review conclusion" -> `second-opinion`, not `code-review`
- "Find out why this documented API behaves differently in version 4" -> `technical-research` when the main question is the external contract; `diagnosing-bugs` when the main question is a failing local behavior

## Optional lifecycle

- "Rename this local variable" -> native Codex; create no `.mecha` record
- "Keep durable state for this multi-session refactor" -> the applicable engineering leaf with a continuity-mode work record
- "Use planning mode to make this feature decision-complete" -> `implementation-spec`, plus `work-slicing` when multiple implementation units are needed
- "Continue the accepted checkout lifecycle in `.mecha/work/checkout/index.md`" -> the leaf matching the recorded next task shape
- "Review this lifecycle implementation and close it if it is ready" -> `code-review`; completion requires all three axes or an explicit user waiver
- A resumed record names `product-co-design` as the unfinished next loop -> ask whether to reactivate it before continuing
- A resumed record names `low-friction-collaboration` as a candidate -> mention explicit reactivation without blocking the requested task

## AI

- "Use ai-pipeline to frame this churn problem end to end" -> `ai-pipeline` (explicit invocation only)
- "Classify these columns, quantify missingness, and package a clean dataset" -> `ai-data-preparation`
- "Find and validate meaningful cohort or temporal patterns in this dataset" -> `ai-insight-development`
- "Build leakage-safe features for these sensor windows" -> `ai-representation-workbench`
- "Choose between boosted trees, a neural model, and a hybrid for this task" -> `ai-problem-modeling`
- "Train and compare these candidates under the agreed split and metrics" -> `ai-performance`
- "Design a state representation and admissible heuristic for this planner" -> `ai-representation-workbench`
- "Benchmark and tune this constraint solver on representative instances" -> `ai-performance`

## Writing

- "Write an essay from these notes without flattening my argument" -> `humanizer`
- "Humanize this report while preserving its citations and qualifications" -> `humanizer`
- "Rewrite these API docs and code comments" -> native Codex, not `humanizer`
- "Write a generic long-form blog article" -> `humanizer`
- "Draft a technical post for n00bcak.github.io" -> `blogpost-writing`
- "Turn these challenge notes into a CTF writeup in my site style" -> `blogpost-writing`
- "Tell me whether AI wrote this essay" -> no authorship verdict

## Native clarification

- "Help with my project" -> native clarification; no skill yet
- "Assess a product concept whose feasibility depends on an unfamiliar ML approach" -> choose the primary specialist; use `second-opinion` only when an independent consequential review is warranted
- "Integrate a security audit tool into this large codebase and verify it catches known vulnerability classes" -> `large-codebase-change`
