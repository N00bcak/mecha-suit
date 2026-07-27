# `families/engineering/` Spec

## Purpose

`families/engineering/` contains two general software engineering leaves: one
for changes in clearly large existing repositories and one for isolated
greenfield prototypes organized around a demonstrable outcome.

## Architecture Tree

```text
families/engineering/
    references/
        change-discipline.md
        session-continuity.md
        python-practices.md
        typescript-practices.md
        go-practices.md
        rust-practices.md
        systems-c-cpp-practices.md
        java-jvm-practices.md
    large-codebase-change/
        SKILL.md
        references/
            migration-and-rollout.md
            testing-strategy.md
    prototype-builder/
        SKILL.md
        references/
            prototype-quality.md
            stack-selection.md
```

## Main Responsibilities

- Guide PR-ready changes in repositories above roughly 5k maintained source
  lines.
- Guide isolated greenfield prototypes without a line-count limit.
- Preserve verification discipline and session continuity.
- Share anti-bloat discipline and language idioms across both leaves.

## Strengths

- Separates large-repository integration work from greenfield posture.
- Encodes persistence/yield behavior for long-running engineering tasks.
- Lets each run load only affected language primers and relevant decision aids.

## Architectural Invariants

- Engineering leaves do not use subagents.
- `large-codebase-change` owns any requested change in a clearly large existing
  repository, approximately above 5k maintained source lines. Generated,
  vendored, dependency, and build output do not count.
- The threshold is a routing heuristic; count only when repository size is
  genuinely unclear.
- `prototype-builder` owns isolated greenfield tools, demos, apps, and
  experiments centered on one observable outcome.
- Existing repositories below the large boundary use native Codex unless the
  work is an isolated greenfield artifact.
- Repo-specific facts belong in local `AGENTS.md` or adapter skills, not global
  engineering leaves.

## Common Workflows

- Use `large-codebase-change` for a small edit in a 50k-line repository.
- Use native Codex for an edit in an existing 2k-line repository.
- Use `prototype-builder` for a new isolated CLI or app prototype.
- For a migration in a large service, use `large-codebase-change` and its
  migration reference.
- For a polyglot change, load only primers for languages in the affected files.
- Add references only when they improve repeated execution across many repos.
- Use scratchpads only when durable handoff state is useful.

## Future Work

- Add additional language references only when repeated tasks justify them.
- Keep engineering leaves from turning into a broad project-management layer.
