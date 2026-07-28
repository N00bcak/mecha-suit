# Mecha Suit

Mecha Suit is a reusable skill harness for Codex-first work. It gives your
agent a small, opinionated set of global skills for collaborating on product
ideas, doing specialist work, and escalating only genuinely cross-domain
problems.

Authorship note: Mecha Suit was vibe-coded by Codex and human-QC'ed by the maintainer.

## Read This First

Mecha Suit is not magic safety. It does not make an agent correct, harmless, or production-ready by default. It gives the agent better instructions and cleaner routing boundaries so it is less likely to sprawl, guess silently, or use the wrong mode of work.

You still need to:

- read commands before running them
- inspect diffs before accepting changes
- run tests before trusting output
- keep secrets and private infrastructure out of global reusable skills
- write repo-local instructions for project-specific facts

If you are vibecoding fast, Mecha Suit is the seatbelt, not the driver.

## What This Is

Mecha Suit is a version-controlled library of reusable agent skills.

The basic model:

1. Keep this repository somewhere you control.
2. Install the skill folders as symlinks into an agent skill directory.
3. Put project-specific facts in each project's `AGENTS.md` or in repo-local adapter skills.
4. Let native Codex handle ordinary selection and clarification while global
   skills provide product collaboration, engineering workflows, AI workflows,
   and cross-domain council synthesis.

The harness is designed for Codex first, while keeping the skill documents portable enough to adapt to other agent hosts later.

## What This Is Not

Mecha Suit is not:

- a replacement for code review
- a replacement for tests
- a prompt that should contain every fact about every project
- a permission slip to run destructive commands blindly
- a subagent free-for-all
- a production framework or package manager

The global skills should stay generic. Local facts belong locally.

## Quick Start

From this repository:

```bash
uv sync --dev
./test.sh
```

`uv sync --dev` creates the local `.venv` and installs the test-only dependencies.
The only third-party dependency is PyYAML, which Codex's `skill-creator`
validator uses to parse skill frontmatter. The skill installer and installed
skills do not depend on Python or this environment.

`./test.sh` verifies the harness before you install anything. It checks
Codex-compatible YAML frontmatter, script syntax, skill names, family layout,
subagent boundaries, and install/uninstall behavior against a temporary skill
root.

Install every skill into the default Codex skill root:

```bash
./install.sh
```

By default, this creates symlinks under:

```text
$CODEX_HOME/skills, when CODEX_HOME is set
$HOME/.codex/skills, otherwise
```

On Windows, run the scripts from WSL, Git Bash, MSYS, or Cygwin. The installer
uses the Bash-visible home directory, and converts `USERPROFILE` to a Unix-style
path in common Windows Bash shells when possible.

Install only selected skills:

```bash
./install.sh product-co-design interdisciplinary-council
```

Install into a custom skill root:

```bash
MECHA_SKILL_ROOT="$HOME/.codex/skills" ./install.sh
```

Install into the legacy compatibility root:

```bash
MECHA_SKILL_ROOT="$HOME/.agents/skills" ./install.sh
```

Uninstall every managed symlink:

```bash
./uninstall.sh
```

Uninstall from a custom skill root:

```bash
MECHA_SKILL_ROOT="$HOME/.codex/skills" ./uninstall.sh
```

The install scripts are intentionally conservative. They skip unrelated files, directories, and symlinks instead of overwriting them.

## How Installation Works

`install.sh` discovers skills by looking for:

```text
families/*/*/SKILL.md
```

Each skill directory is symlinked into the selected skill root. The selected root is:

1. `MECHA_SKILL_ROOT`, when set.
2. `$CODEX_HOME/skills`, when `CODEX_HOME` is set.
3. `$HOME/.codex/skills`, otherwise.

For Windows Git Bash, MSYS, or Cygwin, the default root is the Unix-style path
for `%USERPROFILE%\.codex\skills` when `USERPROFILE` can be converted.

The installer is idempotent. Running it twice should report already-installed skills, not duplicate anything.

`uninstall.sh` removes only symlinks that point back to skill directories in this repository. If it sees a real file, directory, or symlink owned by something else, it skips it.

## How The Harness Is Organized

Mecha Suit is organized into skill families:

- `families/council/`: controlled multi-specialist synthesis.
- `families/collaboration/`: explicit interviewing, low-friction technical
  communication, and conversation-first product co-design.
- `families/engineering/`: fully authored leaves for PR-ready changes in
  repositories above roughly 5k maintained source lines and isolated
  greenfield prototypes centered on one outcome.
- `families/ai/`: an explicit-only initial pipeline manual plus callable leaves
  for data preparation, insight development, representations, problem
  modeling, and performance across ML, deep learning, GOFAI, and hybrids.

Codex selects callable skills directly from their frontmatter descriptions and
handles ordinary ambiguity without a generic routing or clarification skill.

The collaboration, engineering, and AI specialist leaves are fully authored.

## Which Skill Do I Use?

For ordinary ambiguity, let Codex inspect supplied context, state safe
assumptions, and ask one focused question only when a user-owned decision
materially changes the work.

Engineering specialist leaves (`large-codebase-change`, `prototype-builder`),
AI execution leaves (`ai-data-preparation`, `ai-insight-development`,
`ai-representation-workbench`, `ai-problem-modeling`, `ai-performance`) are
fully authored and callable.

Use `large-codebase-change` for any requested edit in a clearly large existing
repository, even when the diff is small. Existing repositories clearly below
roughly 5k maintained source lines stay with native Codex. Use
`prototype-builder` for isolated greenfield prototypes, demos, tools, or apps;
it has no line-count limit.

Use `interview-me` only by explicitly naming or invoking it. It conducts a
scoped, one-question-at-a-time interview and is never an automatic selection
destination.

Use `ai-pipeline` only by explicitly naming or invoking it. It conducts a
one-time framing interview and creates `ML_PIPELINE.md`; it does not execute
the five AI leaves or manage later iteration.

Use `product-co-design` to shape and scrutinize a product, service, workflow,
experience, or product concept from a fuzzy idea through a coherent brief.

Use `low-friction-collaboration` when a dense or multi-step technical exchange
must be easy to follow, resume, and act on without reducing reasoning depth or
precision. It preserves the user's vocabulary, keeps necessary state visible,
and removes avoidable reading and recall work.

Use `interdisciplinary-council` rarely. It is for tasks that genuinely need
multiple specialist perspectives, and only when the relevant non-council
leaves are fully authored. It is not a fallback for ordinary ambiguity.

## Responsible Use

Before asking an agent to work in a repository:

1. Read that repository's `AGENTS.md`.
2. Confirm setup, test, lint, and run commands.
3. Tell the agent what files or areas are out of scope.
4. Run `./test.sh` in this harness after editing the harness.
5. Inspect diffs before committing or deploying.

Do not paste secrets into global skills. Do not hardcode private company systems in global skills. Do not turn one project's local quirks into reusable rules for every future project.

If a command sounds destructive, ask the agent to explain it first. If a change affects data, auth, billing, deployments, or security boundaries, slow down and verify.

## Persistence, Not Flailing

Mecha Suit expects agents to keep working while the work is evidence-producing. Useful progress means new evidence, narrower uncertainty, an improved artifact, an invalidated assumption, a clearer next action, or a risk surfaced with evidence.

Mecha Suit also expects agents to stop before hallucinating, repeating failed moves, or broadening scope irresponsibly. Yielding is allowed only after bounded, distinct attempts and a concise record of attempts, evidence, blocker, and next recovery step.

Hard, uncertain, or incomplete work is not enough reason to stop. The agent must show why another in-scope attempt would repeat prior work, require unsafe guessing, or need input it cannot discover.

## Common Workflows

Install all skills:

```bash
./install.sh
```

Install selected skills:

```bash
./install.sh product-co-design interdisciplinary-council
```

Use a custom skill root:

```bash
MECHA_SKILL_ROOT="/path/to/skills" ./install.sh
```

Add a repo-local `AGENTS.md`:

1. Copy `templates/repo-AGENTS.template.md` into the target repository as `AGENTS.md`.
2. Fill in local commands, paths, generated-file rules, and guardrails.
3. Keep reusable methods out of the local file.

Create a repo-local adapter skill:

1. Copy `templates/repo-adapter-skill.template.md` into the target repository's local skill area.
2. Point it at one global skill.
3. Add only local context: commands, paths, conventions, constraints.

Add or edit a global skill:

1. Read `AGENTS.md` in this repository.
2. Start specialist leaves from `templates/leaf-skill.template.md`.
3. Keep the skill narrow.
4. Leave the exact stub warning in place until the leaf is fully authored.
5. Update routing examples and README when the visible skill set changes.
6. Run `uv sync --dev`, then `./test.sh`.

Uninstall safely:

```bash
./uninstall.sh
```

If you installed with `MECHA_SKILL_ROOT`, uninstall with the same value.

## What Goes Where

- `SKILL.md`: runtime behavior, trigger boundaries, input needs, output contract, done conditions.
- `references/`: passive checklists, rubrics, examples, and decision aids.
- `scripts/`: deterministic helpers that remove repeated procedural work.
- `templates/`: repeatable authoring patterns.
- `docs/`: human-facing maintenance and platform notes.
- `agents/`: host metadata only when it materially improves routing or
  invocation behavior. `interview-me`, `ai-pipeline`, and council currently use
  Codex metadata; `product-co-design`, `low-friction-collaboration`,
  engineering leaves, and AI execution leaves rely on frontmatter.
- `AGENTS.md`: rules for developing this harness itself.
- `PROMPT.md`: original scaffold prompt, kept as project history.

Do not hide active runtime instructions in `references/`. Do not add scripts unless they improve repeatability. Do not add `agents/` metadata to specialist leaves by default; add it only when a fully authored leaf materially benefits from host display or invocation metadata. Do not remove `This is a stub. NEVER CALL THIS SKILL.` until a leaf is fully authored.

## Verify Changes

Run:

```bash
./test.sh
```

The test harness checks:

- Codex `skill-creator`-compatible YAML frontmatter
- shell syntax for executable scripts
- `SKILL.md` frontmatter names against folder names
- required routing and council layout
- absence of `families/orchestration/`
- non-council subagent boundary rules
- install behavior against a temporary skill root
- idempotent reinstall
- selected-skill install
- missing-skill failure
- unrelated file and symlink protection
- managed uninstall behavior

Add focused checks to `test.sh` when a new executable invariant is introduced.

## Troubleshooting

### The skill root is wrong

Set `MECHA_SKILL_ROOT` explicitly:

```bash
MECHA_SKILL_ROOT="/path/to/skills" ./install.sh
```

Use the same value for uninstalling.

### Install skipped an existing file

The installer refuses to overwrite unrelated files or directories. Inspect the skipped path. Move it yourself if it is safe, then rerun install.

### Install skipped an unrelated symlink

The target name already points somewhere else. The harness will not steal it. Inspect the link with:

```bash
ls -l "$HOME/.codex/skills/<skill-name>"
```

Then decide whether to keep it, rename it, or remove it manually.

### Uninstall skipped a symlink

The symlink does not point back to this checkout. That means it is not managed by this harness. Remove it manually only if you are sure it is not needed.

### A skill does not trigger

Check that the skill is installed in the skill root your agent host actually reads. Then check the skill frontmatter `name` and `description` in its `SKILL.md`.

If the task is vague, inspect supplied context and clarify it before expecting
a specialist skill to trigger.

### `./test.sh` fails

Read the failing `[fail]` line first. The test harness is intentionally small; failures usually mean one of these changed:

- the uv development environment has not been synchronized
- skill frontmatter is not valid YAML accepted by Codex's validator
- a script has invalid shell syntax
- a skill folder name and frontmatter name diverged
- family/council layout changed
- a non-council skill appears to authorize subagents
- install/uninstall safety behavior regressed

Fix the cause, then rerun:

```bash
uv sync --dev
./test.sh
```

## Architectural Rules

- Native Codex owns ordinary skill selection and clarification.
- Only `interdisciplinary-council` may use subagents.
- Council is for genuine cross-domain work, not ordinary ambiguity.
- Specialist leaves do one job well.
- Runtime behavior belongs in `SKILL.md`.
- Repo-maintenance policy belongs in `AGENTS.md` and `docs/`.
- Project-specific facts belong in repo-local instructions or adapter skills.

## Repository Development

Before meaningful changes, read `AGENTS.md`. It defines the rules for developing this harness.

Use `docs/maintenance-playbook.md` for skill maintenance workflow and `docs/platform-notes.md` for host-specific notes.
