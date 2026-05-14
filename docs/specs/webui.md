# `webui/` Spec

## Purpose

`webui/` is a local browser control plane for isolated Codex tasks. It creates
task workspaces, runs Codex in Docker or DigitalOcean environments, exposes
steering and terminal access, and keeps cloud execution behind explicit guards.

## Architecture Tree

```text
webui/
    client/     React + Vite UI
    server/     Fastify API, scheduler, providers, Codex bridges
    runner/     Docker runner image
    config/     default YAML configuration
    scripts/    operational helper scripts
    tests/      Vitest tests
```

Generated and dependency directories are excluded from architecture docs:

```text
webui/cache/
webui/dist/
webui/node_modules/
```

## Main Responsibilities

- Manage task lifecycle and durable task state.
- Keep task files under `webui/cache/<task_id>/`.
- Run native Codex app-server inside task containers or droplets.
- Copy only task-local Codex auth into isolated execution environments.
- Preserve Mecha skill assets as read-only runtime context.

## Strengths

- Honest separation between control plane and task workspace.
- Docker and DigitalOcean are modeled through provider boundaries.
- Native Codex app-server mode supports persistent thread IDs.
- Cloud execution is DigitalOcean-only and guarded by config plus environment.

## Architectural Invariants

- Prompt instructions are not a security boundary.
- Task workspace is always the writable root.
- Mecha assets are read-only inside isolated task environments.
- Do not mount DigitalOcean tokens, SSH private keys, or host `~/.codex`.
- `auth.json` may be copied task-locally because native Codex requires it.
- Keep non-DigitalOcean cloud support out unless explicitly requested.

## Common Workflows

- Run `npm test` for WebUI unit coverage.
- Run `npm run build` after TypeScript or client changes.
- Run `npm run runner:build` after runner image changes.
- Generate transport keys with `webui/scripts/generate-codex-transport-key.sh`.

## Future Work

- Add live Docker Codex smoke coverage when a disposable auth profile exists.
- Add opt-in DigitalOcean live smoke coverage.
- Improve terminal PTY behavior and resize handling.
