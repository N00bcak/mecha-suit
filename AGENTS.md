# AGENTS.md

## Purpose

This repository defines a reusable "Mecha Suit" skill toolbox for Codex-first development, with future-friendly compatibility for Claude Code.

This file governs how to DEVELOP the toolbox itself.
It does not replace the runtime instructions inside each skill's `SKILL.md`.

## Scope

This file applies to:
- architecture changes
- new skill creation
- edits to existing skills
- templates
- install / uninstall scripts
- maintenance docs
- shared rubrics and examples

This file does NOT define end-user runtime behavior for individual skills beyond repo-wide architectural invariants.

## Behavioral defaults

These rules exist to reduce common coding-agent failure modes while developing this repo.
They are the repo-specific version of the higher-level practices summarized in
`CODESTYLE.md`: think before coding, simplicity first, surgical changes, and
goal-driven execution.

When editing this repository:
- treat this `AGENTS.md` as the authoritative rule set
- use `CODESTYLE.md` for rationale and high-level development practice
- if the two conflict, follow `AGENTS.md` because it is tailored to Mecha Suit

## Development environment

- Use `uv` for the repository's Python development environment.
- Run `uv sync --dev` to create or update `.venv` from `uv.lock`.
- Run `./test.sh` after synchronization.
- Keep Python packages in the development dependency group. Do not make them
  runtime requirements for installed skills or for `install.sh`.
- Add a dependency only when a repository test or deterministic development
  tool requires it. PyYAML is currently the sole third-party dependency,
  matching Codex `skill-creator` frontmatter validation.
- Commit `uv.lock`; never commit `.venv`.
- When changing skill frontmatter rules, keep `scripts/validate_skills.py`
  aligned with Codex's `skill-creator` `quick_validate.py`.

### 1. Think before coding
Do not assume silently.

Before implementing:
- State assumptions explicitly.
- If multiple reasonable interpretations exist, name them briefly and choose one deliberately.
- If a simpler approach exists, prefer it and say so.
- If something is genuinely blocking or structurally ambiguous, stop and ask.
- If something is ambiguous but non-blocking, state the assumption and proceed.

Do not hide confusion.
Do not silently pick one interpretation when the choice materially affects architecture.

### 2. Simplicity first
Write the minimum structure and code that correctly satisfies the task.

Do NOT add:
- speculative abstractions
- extra configurability that was not requested
- extra features "for future use"
- generalized frameworks for one-off needs
- defensive handling for implausible scenarios unless the architecture clearly needs it

If a design is becoming clever, compress it.
If 200 lines can honestly be 50, rewrite it.

### 3. Surgical changes
Touch only what is needed.

When editing existing files:
- Do not improve adjacent code unless the request requires it.
- Do not refactor unrelated structures.
- Match existing style unless this repo explicitly standardizes something else.
- If you notice unrelated problems, mention them. Do not fix them automatically.

When your own change creates local cleanup needs:
- remove imports, variables, functions, examples, or docs made obsolete by YOUR change
- do not remove pre-existing dead material unless asked

Every changed line should trace back to the task.

### 4. Goal-driven execution
Convert tasks into verifiable goals.

For non-trivial work:
1. state the goal
2. state assumptions
3. state the smallest useful plan
4. implement
5. verify
6. summarize what changed and what remains uncertain

Prefer concrete success criteria over vague completion language.

Examples:
- "Improve skill selection" -> "Tighten frontmatter trigger boundaries, update docs/templates if the contract changes, then verify consistency."
- "Add a skill" -> "Create skill folder, define boundaries, define output contract, update template/docs if needed, then verify architecture invariants still hold."

## Core architectural invariants

### 1. Native Codex selection and clarification are the top layer
Codex selects callable skills directly from their frontmatter descriptions and
handles ordinary ambiguity before invocation.

Do not add a toolbox router, orchestration layer, registry, or duplicate
selection table. Keep selection cues in leaf descriptions.

For ambiguous work:
- inspect available context before asking
- separate mixed goals and their dependencies
- state reversible, low-risk assumptions and proceed
- ask one focused question only when a missing user-owned decision materially
  changes the work

### 2. Subagent access is council-only
Only `interdisciplinary-council` may use subagents.

No other skill may:
- spawn subagents
- request subagents
- assume subagents are available
- defer core behavior to hidden parallel delegates

If future subagent use is introduced anywhere else, treat that as an architectural change requiring:
- README update
- maintenance-playbook update
- template review
- explicit rationale in the final summary

### 3. Council is for genuine cross-domain work
`interdisciplinary-council` is for tasks that genuinely require multiple specialist perspectives.

Do NOT route to council merely because:
- the task is underspecified
- the task is ambiguous
- the user gave little context
- one specialist is probably enough

Resolve ordinary ambiguity before selecting a skill.
Use council for multi-specialist reasoning.

### 4. Specialist leaves stay narrow
Specialist leaves should do one job well.

Current non-council specialist leaves include:
- `interview-me`
- `product-co-design`
- `large-codebase-change`
- `prototype-builder`
- `ctf-triage`
- `reverse-ctf`
- `pwn-ctf`
- `crypto-ctf`
- `web-ctf`
- `forensics-ctf`
- `ai-ctf`
- `misc-ctf`
- `dataset-triage`
- `classical-ml-baseline`
- `deep-learning-experiment`

Avoid broad umbrella skills unless there is a clear architectural reason.

### 5. Specialist stubs are contract-complete before they become fully authored
A specialist leaf may begin as a contract-complete stub.

A contract-complete stub must define:
1. Purpose
2. Use when
3. Do not use
4. Needs
5. Returns
6. Done conditions
7. Designer notes
8. Future workflow outline

A contract-complete stub must NOT:
- pretend to be fully implemented
- contain a half-baked domain playbook
- include unnecessary scripts
- include bulky references unless foundational

### 6. Runtime behavior belongs in `SKILL.md`
Use:
- `AGENTS.md` for repo-wide development rules
- `SKILL.md` for skill runtime behavior
- `references/` for passive supporting material
- `scripts/` for deterministic helper logic
- `templates/` for repeatable authoring patterns
- `docs/` for human-facing explanation and maintenance policy

Do not stuff repo-maintenance policy into skill files unless it materially affects runtime behavior.

## File and folder responsibilities

### `families/council/`
Contains the only subagent-enabled skill family.

### `families/collaboration/`
Contains conversation-first specialist leaves. `interview-me` is
explicit-invocation-only. `product-co-design` is routable and council-eligible.

### `families/engineering/`, `families/ctf/`, `families/ml/`
Contain specialist leaves.
These should remain narrow and composable.

### `references/`
Use for:
- concise checklists
- rubrics
- decision aids
- stable passive background

Do not move active instructions from `SKILL.md` into `references/` just to hide complexity.

### `scripts/`
Only add a script if it:
- removes repeated procedural text
- improves determinism
- is portable
- does not depend on private infrastructure

Avoid scripts that merely wrap trivial prose.

### `agents/`
Only add metadata files when they materially improve routing or invocation behavior.
Do not add metadata by default.

## Change policy

### Prefer simplification over cleverness
When multiple designs are possible, prefer:
- fewer skills
- sharper boundaries
- lower context usage
- clearer routing
- smaller references
- fewer scripts

Do not introduce registries, score matrices, capability taxonomies, or other control layers unless the current structure has clearly broken down.

### Preserve portability
Do not introduce:
- repo-specific commands into global skills
- hardcoded local paths
- private company infrastructure
- assumptions tied to one language, one framework, or one codebase unless the skill is explicitly scoped that way

### Preserve editability
This repo should stay easy to evolve.
Do not create structures that make a small skill edit require touching many unrelated files.

### Keep templates aligned
If you change the contract shape of specialist leaves, update:
- `templates/leaf-skill.template.md`
- README
- maintenance-playbook
- any example stub that should reflect the new standard

## Authoring standards

### Writing style
- Use direct language.
- Prefer dense, operational instructions.
- Avoid motivational filler.
- Avoid vague "best practices" phrasing when a rule can be stated concretely.

### Indentation
Use 4-space indentation consistently.

### Naming
Use names that reflect actual function.
Examples:
- `interdisciplinary-council`, not a generic "meta-agent"

### Skill descriptions
Descriptions must be good routers.

- Use one constructive sentence, normally around 120 characters.
- Name the owned action and a positive task or artifact cue.
- Make boundaries clear through task shape, not contrastive phrasing.
- Omit workflow summaries and repo-wide policies.
- Keep a few diagnostic cues when adjacent categories need them.
- Treat the length target as editorial guidance, not a validator limit.
- Use host invocation policy, not warning prose, for manual-only skills.

## Council development rules

When editing `interdisciplinary-council`:
- keep it reserved for genuine multi-specialist work
- use the fewest subagents necessary
- prefer 2-3 focused specialist perspectives over broad parallelism
- ensure each subagent question is narrow
- require synthesis at the council layer, not inside subagents

Council outputs should include:
- integrated conclusion
- areas of agreement
- areas of conflict
- chosen recommendation
- verification status
- remaining uncertainty

## Specialist development rules

When turning a specialist stub into a full skill:
1. preserve the existing contract shape unless there is a strong reason to change it
2. write the smallest useful playbook first
3. add references only if they improve repeated execution
4. add scripts only if they improve determinism
5. keep trigger boundaries explicit
6. keep "do not use" boundaries explicit

A specialist should earn additional complexity.
Do not front-load elaborate workflows.

## Maintenance workflow

When making meaningful changes:
1. identify which architectural layer is changing:
    - skill selection
    - council
    - specialist
    - shared template
    - docs
    - install logic
2. state assumptions and success criteria
3. make the smallest coherent change
4. update nearby templates/docs if the contract changed
5. audit for boundary drift
6. summarize:
    - what changed
    - why
    - what assumptions changed
    - what remains intentionally deferred

## Transparency and externalized reasoning

Do not expose hidden chain-of-thought.
Instead, for non-trivial development work on this repo, externalize a compact decision record:

1. goal
2. assumptions and unknowns
3. candidate approaches
4. chosen approach
5. files touched
6. verification performed
7. remaining risks

Keep that record concise and operational.

## Definition of done for repo changes

A meaningful change is done when:
- the changed files are internally consistent
- architectural invariants remain intact
- templates/docs are updated if needed
- new complexity is justified
- routing boundaries remain clear
- the final summary states what was verified and what was not

## Default bias

Bias toward:
- narrow skills
- native skill selection
- council-only subagent use
- contract-complete specialist leaves
- low context overhead
- portable instructions
- future editability

Bias against:
- hidden complexity
- duplicate logic
- broad catch-all skills
- premature workflow elaboration
- architecture sprawl
