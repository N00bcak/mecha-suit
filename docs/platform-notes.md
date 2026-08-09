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

## Codex-specific notes

- Codex reads skill frontmatter `name` and `description` for trigger matching.
- `agents/openai.yaml` is useful for user-facing skill display and default prompts when metadata materially improves routing or invocation.
- This toolbox currently includes `agents/openai.yaml` for `interview-me`,
  and `ai-pipeline`.
- `product-co-design`, `low-friction-collaboration`, engineering leaves, and AI
  execution leaves currently rely on frontmatter only.
- Global installation targets `MECHA_SKILL_ROOT` when set, then `CODEX_HOME/skills` when `CODEX_HOME` is set, otherwise `$HOME/.codex/skills`.
- On Windows, run the Bash scripts from WSL, Git Bash, MSYS, or Cygwin. Git Bash/MSYS/Cygwin default to a Unix-style path for `%USERPROFILE%\.codex\skills` when conversion is available.
- Repo-local `AGENTS.md` files should point to global skills and provide only local facts.

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

- Treat these skills as portable method documents.
- Use `docs/global-CLAUDE.example.md` as a starting point for global instructions.
- Use `templates/repo-CLAUDE.template.md` for project-level adaptation.
- If Claude Code gains a native skill metadata format, keep the global contracts and add host-specific metadata beside `agents/`.

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
