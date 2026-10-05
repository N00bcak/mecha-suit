# Mecha Suit

Mecha Suit is a small, version-controlled toolbox of reusable skills for coding
agents. It is Codex-first and keeps its shared skill documents portable enough
for other Agent Skills-compatible hosts.

The toolbox helps an agent collaborate on product decisions, carry out focused
engineering and AI work, and write long-form prose. It improves working
discipline; it does not replace your judgment, tests, review, or production
safeguards.

## Install

Prepare and verify this checkout:

```bash
uv sync --dev
./test.sh
```

Install all skills into the default Codex skill root:

```bash
./install.sh
```

On a fresh Codex setup, installation also copies the default consumer global
instructions from `templates/global-AGENTS.template.md` to
`$CODEX_HOME/AGENTS.md`, or `$HOME/.codex/AGENTS.md` when `CODEX_HOME` is not
set. If that file contains non-default instructions, installation
aborts before changing skills. To back up and replace it with Mecha Suit's
default prompt, run:

```bash
./install.sh --use-custom-global-instructions
```

The backup is kept under `.mecha/backups/global-instructions/` in this checkout.

The same run installs for Claude Code into `$CLAUDE_CONFIG_DIR/skills`, or
`$HOME/.claude/skills`, and copies the same global instructions to
`~/.claude/CLAUDE.md` under the same abort and backup rules. Explicit-only skills are
rendered with Claude's `disable-model-invocation`; rerun `./install.sh` after
editing those skills. Reinstalling also prunes managed links left dangling by
renamed or removed skills. Pass `--no-claude` to skip Claude Code.

`uninstall.sh` removes managed skill links. A full uninstall also removes an
unmodified Claude instruction copy and the render tree it created; it never
changes the Codex global instructions. After the template changes, existing
copies no longer match it, so refresh them with
`./install.sh --use-custom-global-instructions`, which backs up each old copy.

Install only selected skills:

```bash
./install.sh product-co-design large-codebase-change
```

Choose a different root when needed:

```bash
MECHA_SKILL_ROOT="/path/to/skills" ./install.sh
```

The default skill root is `$HOME/.agents/skills`; `CODEX_HOME` affects global
Codex instructions, not skill installation. On Windows, run the scripts through
WSL, Git Bash, MSYS, or Cygwin.

The installer creates symlinks and will not overwrite unrelated files,
directories, or links. It is safe to run again. If it finds links managed by
this checkout in the deprecated `$CODEX_HOME/skills` or `$HOME/.codex/skills`
location, it leaves them unchanged and prints the exact explicit uninstall
command. Remove those legacy links to avoid duplicate skill entries.

To remove links managed by this checkout:

```bash
./uninstall.sh
```

Use the same `MECHA_SKILL_ROOT` for uninstalling if you supplied one during
installation.

## Use

Tell the agent what outcome you want and share the context you already have.
The host normally chooses a matching skill from its description. You do not
need to memorize the toolbox.

The installed global prompt treats review, research, explanation, and planning
requests as authorization for inspection and analysis. An explicit implementation
request or approval of proposed changes authorizes edits and supporting checks
within the agreed scope without repeated approval. The agent seeks agreement
for unresolved user-owned decisions or commitments beyond existing authorization.
Durable `.mecha` work state requires explicitly invoked `multi-step-governance`.

Four modes start only when you ask for them:

- `product-co-design` shapes a product concept through a multi-turn exchange.
- `user-interview` runs a focused, one-question-at-a-time interview.
- `ai-pipeline` frames an AI effort and creates an initial pipeline plan.
- `multi-step-governance` manages an authorized end-to-end effort across
  dependent specialist stages.

See [Skills at a Glance](docs/skills.md) for the input and output of every
skill.

Keep project-specific commands, paths, architecture, and restrictions in that
project's `AGENTS.md` or a repo-local adapter. Global skills should remain
portable. `EXAMPLE_PROMPT.md` shows one concise downstream customization; it is
not installed and does not define this repository's development rules.

## Safety

Mecha Suit is a seatbelt, not the driver. Before accepting agent work:

- read commands before running them;
- inspect the diff;
- run the relevant tests;
- keep secrets and private infrastructure out of reusable skills;
- use extra care around data, authentication, billing, deployments, and
  security boundaries.

Only `parallel-subagents` and `second-opinion` may authorize subagent use. The
main agent still owns scope, permissions, integration, verification, and the
final response.

## Repository Map

- `families/` contains the installable skills.
- `shared/` contains cross-skill runtime contracts and rubrics.
- `templates/` contains repeatable skill and host-instruction starting points,
  including the installable consumer global AGENTS prompt.
- `evals/` contains host-neutral routing and interaction cases.
- `tests/` and `test.sh` contain deterministic checks.
- `docs/` contains the short human handbook.

For maintainers, start with [AGENTS.md](AGENTS.md), then use
[Architecture](docs/architecture.md), the
[Maintenance Playbook](docs/maintenance-playbook.md), and
[Platform Notes](docs/platform-notes.md) as needed.

## Troubleshooting

If a skill does not appear, confirm that the host reads the root used by the
installer and that the link points to this checkout.

If installation skips a path, it belongs to something else. Inspect it and
decide manually whether it should move; the installer will not take ownership.

If `./test.sh` fails, read the first `[fail]` line, run `uv sync --dev`, fix the
reported contract or structure, and run the test again.

Live routing evaluation is optional and separate from deterministic tests:

```bash
uv run python scripts/run_interaction_evals.py \
    --host codex \
    --corpus evals/interaction-boundary.json \
    --split validation \
    --runs 3
```

The runner adapts the host-neutral corpus to Codex through an ephemeral app-server
thread per run. Turns in one interaction case share that thread; unrelated cases
remain isolated. Explicit skills use structured bindings, while implicit
skill-file-read evidence remains heuristic. Review live responses rather than
treating them as a merge gate.

Use `--host claude` or `--host both` to run the same cases on Claude Code. Each
Claude run gets a temporary `CLAUDE_CONFIG_DIR`, so your installed skills and
instructions never leak in. Authenticate once with `claude setup-token` and
export the printed token as `CLAUDE_CODE_OAUTH_TOKEN`.

For paired task-outcome comparisons, start with the offline fixture preview:

```bash
uv run python scripts/run_outcome_evals.py --dry-run
```

The outcome runner compares project instructions alone against the same
project with Mecha's global prompt and full catalog. Live runs require explicit
model and effort settings and remain optional; pass `--host claude` to compare
on Claude Code (the objective checks still run in Codex's read-only sandbox). See the
[maintenance playbook](docs/maintenance-playbook.md#compare-actual-outcomes)
for isolation requirements and manual review of the resulting evidence.
