# Platform Notes

## Portable core design

- Skills define reusable methods, not repo-specific facts.
- `SKILL.md` should stay small enough to load cheaply.
- Passive context belongs in `references/`.
- Scripts are optional and should exist only when they improve repeatability.
- Routing depends on leaf boundaries and minimum required inputs, not specialist internals.
- Only `parallel-subagents` and `second-opinion` authorize subagent use, and
  only when the host exposes the required capability.
- `multi-step-governance` alone owns the host-neutral work-index contract in
  `shared/rubrics/lifecycle-contract.md`; contributors return bounded evidence.
- Task skills are the default interaction model. Session overlays and
  interactive loops declare their contract in `SKILL.md`; no registry or
  custom frontmatter field encodes the taxonomy.
- Portable validation follows the Agent Skills frontmatter contract. Host
  invocation policy and presentation metadata are validated separately.

## Codex-specific notes

- Codex reads skill frontmatter `name` and `description` for trigger matching.
- `agents/openai.yaml` is useful for user-facing skill display and default prompts when metadata materially improves routing or invocation.
- This toolbox includes explicit-only `agents/openai.yaml` metadata for
  `user-interview`, `product-co-design`, `low-friction-collaboration`,
  `ai-pipeline`, and `multi-step-governance`.
- Other collaboration leaves, engineering leaves, and AI execution leaves
  currently rely on frontmatter only.
- Global skill installation targets `MECHA_SKILL_ROOT` when set, otherwise
  `$HOME/.agents/skills`. The deprecated `$CODEX_HOME/skills` or
  `$HOME/.codex/skills` root remains discoverable by Codex, so the installer
  warns about managed legacy links and supplies an explicit cleanup command.
- `install.sh` also provisions the canonical consumer prompt from
  `templates/global-AGENTS.template.md` at `$CODEX_HOME/AGENTS.md`, or
  `$HOME/.codex/AGENTS.md` when `CODEX_HOME` is unset. Global instructions and
  the portable skill root are resolved independently.
  It aborts on non-default instructions unless
  `--use-custom-global-instructions` is explicit; that replacement backs up
  the old file under this checkout's `.mecha/backups/global-instructions/`.
- The repository-root `AGENTS.md` governs Mecha Suit development only.
  `EXAMPLE_PROMPT.md` is a downstream customization example, not the installed
  prompt or a development contract.
- On Windows, run the Bash scripts from WSL, Git Bash, MSYS, or Cygwin. Git
  Bash/MSYS/Cygwin default to a Unix-style path for
  `%USERPROFILE%\.agents\skills` when conversion is available.
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
  Acceptance does not activate governance or require durable state. Only an
  explicitly active `multi-step-governance` creates or updates its work record;
  contributors return the accepted contract and evidence.
- If the user requests revisions rather than execution, keep the contract draft.

### Authority and initiative

- Review, research, explanation, and planning requests authorize inspection and
  analysis. An explicit implementation request or approval of proposed changes
  authorizes edits and supporting checks within the agreed scope without
  repeated approval. Unclear implementation intent requires approval before edits.
- The agent seeks agreement for unresolved user-owned decisions or commitments
  beyond existing authorization. Host mode restrictions still apply; planning
  mode does not authorize implementation.

## Claude Code-specific notes

- `install.sh` also installs every skill into `$CLAUDE_CONFIG_DIR/skills`, or
  `$HOME/.claude/skills`. Plain skills are symlinks to the source. Pass
  `--no-claude` to install or uninstall for Codex only.
- Skills that need a Claude adapter are rendered under
  `<claude config>/.mecha-render/`, which mirrors the repository shape so
  relative references resolve. Only `SKILL.md` is copied; everything else
  links to the source. Rerun `./install.sh` after editing a rendered skill's
  `SKILL.md`.
- `metadata.invocation: explicit` renders as `disable-model-invocation: true`,
  which Claude enforces natively while keeping `/<skill>` available. Do not add
  that field to source frontmatter; Codex validation rejects it.
- Skill names are identical across hosts. Avoid names of Claude Code
  built-ins such as `code-review`, `simplify`, or `security-review`.
- Claude loads a project `AGENTS.md` only when no `CLAUDE.md` exists, so a repo
  `CLAUDE.md` should import it with `@AGENTS.md`. The installer copies the
  global template to `<claude config>/CLAUDE.md` under the same
  custom-instruction abort and backup rules as Codex. It is a copy, not a link,
  because Claude Code skips a symlinked `~/.claude/CLAUDE.md` in Cowork
  sessions; links left by earlier installs are migrated automatically. Full
  uninstall removes an unmodified copy and the render tree.
- Reuse the host-neutral evaluation corpora when a verified Claude runner is
  available; keep Claude invocation and telemetry handling in its adapter.

## Validation and evaluation layers

- `scripts/validate_skills.py` checks the portable core, Mecha Suit interaction
  contracts, Codex metadata, prompt budgets, and runtime references as distinct
  layers. Pass `--installed-root` to verify references through installed skill
  aliases as well as the source tree.
- `./test.sh` is deterministic and does not require an agent host, credentials,
  network access, or model calls.
- `evals/*.json` keeps routing and interaction cases independent of host
  invocation syntax.
- `scripts/run_interaction_evals.py` is opt-in. Its Codex app-server adapter
  binds explicit skills structurally and runs every turn in an interaction case
  through one ephemeral thread. It still infers implicit skill use from
  `SKILL.md` read commands and labels that evidence as heuristic.
- The JSON corpora contain no `$` or `/` invocation syntax; adapters add it at
  execution time.

### Codex outcome comparisons

The separate `scripts/run_outcome_evals.py` adapter verifies model, effort,
instruction sources, enabled skills, configuration provenance, and sandbox
settings before sending a user turn. It was checked against the local Codex
0.146.0 app-server schema. Missing telemetry or incompatible host behavior
produces an inconclusive result; it never silently relaxes isolation. Built-in
skills are disabled in both arms. Integration tools and subagent capability are
disabled equally in this bounded comparison; runtime skill authorization rules
are unchanged. This measures the isolated Mecha stack, not every installed
plugin or a user's ambient host customization.

Evaluator commands use the app-server command API under a read-only sandbox.
They do not start model turns. See the maintenance playbook for opt-in runs and
interpretation; deterministic tests use a fake app server without credentials.

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
