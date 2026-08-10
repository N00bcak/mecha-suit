# Platform Notes

## Portable core design

- Skills define reusable methods, not repo-specific facts.
- `SKILL.md` should stay small enough to load cheaply.
- Passive context belongs in `references/`.
- Scripts are optional and should exist only when they improve repeatability.
- Routing depends on leaf boundaries and minimum required inputs, not specialist internals.
- Only `parallel-subagents` and `second-opinion` authorize subagent use, and
  only when the host exposes the required capability.
- Collaboration and engineering leaves share the host-neutral work-index
  contract in `shared/rubrics/lifecycle-contract.md` when durable state is
  active. The contract does not select or invoke skills.
- Task skills are the default interaction model. Session overlays and
  interactive loops declare their contract in `SKILL.md`; no registry or
  custom frontmatter field encodes the taxonomy.
- Portable validation follows the Agent Skills frontmatter contract. Host
  invocation policy and presentation metadata are validated separately.

## Codex-specific notes

- Codex reads skill frontmatter `name` and `description` for trigger matching.
- `agents/openai.yaml` is useful for user-facing skill display and default prompts when metadata materially improves routing or invocation.
- This toolbox includes explicit-only `agents/openai.yaml` metadata for
  `interview-me`, `product-co-design`, `low-friction-collaboration`, and
  `ai-pipeline`.
- Other collaboration leaves, engineering leaves, and AI execution leaves
  currently rely on frontmatter only.
- Global installation targets `MECHA_SKILL_ROOT` when set, then `CODEX_HOME/skills` when `CODEX_HOME` is set, otherwise `$HOME/.codex/skills`.
- On Windows, run the Bash scripts from WSL, Git Bash, MSYS, or Cygwin. Git Bash/MSYS/Cygwin default to a Unix-style path for `%USERPROFILE%\.codex\skills` when conversion is available.
- Repo-local `AGENTS.md` files should point to global skills and provide only local facts.

### Codex resume candidates

- Store canonical skill names in the work record, without `$`.
- On resume, say: `We were using $<skill-name> before this session was resumed.
  It is not active here. To reactivate it, say: "Use $<skill-name>."`
- For multiple compatible candidates, list them in one notice. If multiple
  interactive loops conflict, ask the user to choose one.
- Wait for a response when an unfinished loop owns the next activity. Mention
  overlay candidates without blocking other authorized work.

### Codex planning mode

- Planning mode may naturally select `decision-mapping`,
  `implementation-spec`, and `work-slicing` from the task shape.
- When planning mode forbids writes, return the complete intent contract and
  slices in the conversation. Do not create `.mecha` or edit `.gitignore`.
- A later request to execute the latest completed plan accepts that contract.
  The first execution turn materializes it under `.mecha/work/<slug>/` before
  changing implementation files.
- If the user requests revisions rather than execution, keep the contract draft.

## Claude Code-specific notes

- Claude Code can load the shared Agent Skills-compatible `SKILL.md` files.
- Use `templates/global-CLAUDE.template.md` as a starting point for global instructions.
- Use `templates/repo-CLAUDE.template.md` for project-level adaptation.
- Do not add Claude-only invocation fields to shared frontmatter while they are
  rejected by the current Codex compatibility profile. Explicit-only behavior
  is therefore not host-enforced in Claude Code by this repository yet.
- Reuse the host-neutral evaluation corpora when a verified Claude runner is
  available; keep Claude invocation and telemetry handling in its adapter.

## Validation and evaluation layers

- `scripts/validate_skills.py` checks the portable core, Mecha Suit interaction
  contracts, and Codex metadata as distinct layers.
- `./test.sh` is deterministic and does not require an agent host, credentials,
  network access, or model calls.
- `evals/*.json` keeps routing and interaction cases independent of host
  invocation syntax.
- `scripts/run_interaction_evals.py` is opt-in. Its Codex adapter infers skill
  use from `SKILL.md` read commands and labels the evidence as heuristic.
- The JSON corpora contain no `$` or `/` invocation syntax; adapters add it at
  execution time.

### Planning-mode adapter stub

Purpose: connect Claude Code planning output to the host-neutral work-index
contract without changing planning-mode permissions.

Status: not implemented or promised. Before authoring, verify Claude Code's
current planning-mode write restrictions, acceptance signal, context retention,
skill metadata, and transition into execution. Until then, use the portable
core manually and do not claim automatic materialization.

## Revisit when platform practices evolve

- Native global skill installation paths
- Host-specific metadata schemas
- Changes to host subagent permission, cancellation, and naming models
- Whether repo-local wrappers should be skills, markdown instructions, or host-native configuration
- Validation tooling for skill trigger descriptions and context size
