# Platform Notes

## Portable core design

- Skills define reusable methods, not repo-specific facts.
- `SKILL.md` should stay small enough to load cheaply.
- Passive context belongs in `references/`.
- Scripts are optional and should exist only when they improve repeatability.
- Routing depends on leaf boundaries and minimum required inputs, not specialist internals.
- Subagent use is a council-only capability.

## Codex-specific notes

- Codex reads skill frontmatter `name` and `description` for trigger matching.
- `agents/openai.yaml` is useful for user-facing skill display and default prompts when metadata materially improves routing or invocation.
- This toolbox currently includes `agents/openai.yaml` for `interview-me`, `interdisciplinary-council`, and fully authored CTF specialists.
- `product-co-design`, engineering leaves, and ML stubs currently rely on frontmatter only.
- Global installation targets `MECHA_SKILL_ROOT` when set, then `CODEX_HOME/skills` when `CODEX_HOME` is set, otherwise `$HOME/.codex/skills`.
- On Windows, run the Bash scripts from WSL, Git Bash, MSYS, or Cygwin. Git Bash/MSYS/Cygwin default to a Unix-style path for `%USERPROFILE%\.codex\skills` when conversion is available.
- Repo-local `AGENTS.md` files should point to global skills and provide only local facts.

## Claude Code-specific notes

- Treat these skills as portable method documents.
- Use `docs/global-CLAUDE.example.md` as a starting point for global instructions.
- Use `templates/repo-CLAUDE.template.md` for project-level adaptation.
- If Claude Code gains a native skill metadata format, keep the global contracts and add host-specific metadata beside `agents/`.

## Revisit when platform practices evolve

- Native global skill installation paths
- Host-specific metadata schemas
- Subagent permission and naming models
- Whether repo-local wrappers should be skills, markdown instructions, or host-native configuration
- Validation tooling for skill trigger descriptions and context size
