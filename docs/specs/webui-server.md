# `webui/server/` Spec

## Purpose

`webui/server/` owns the WebUI control plane: HTTP/WebSocket routes, SQLite
state, scheduler, providers, terminal streams, path safety, and Codex bridges.

## Architecture Tree

```text
webui/server/src/
    main.ts
    config.ts
    db.ts
    scheduler.ts
    reaper.ts
    types.ts
    codex/
        CodexAppServerBridge.ts
        HostCodexCliBridge.ts
        auth.ts
        context.ts
    providers/
        Provider.ts
        LocalDockerProvider.ts
        DigitalOceanProvider.ts
        docker.ts
    tasks/
        createTask.ts
        generateTaskFiles.ts
        fileBrowser.ts
        permissions.ts
    terminal/
        terminalRouter.ts
    utils/
        logs.ts
        paths.ts
        quota.ts
        redactor.ts
```

## Main Responsibilities

- Load and validate configuration.
- Create durable task layouts and SQLite records.
- Provision local Docker containers or DigitalOcean droplets.
- Run native Codex app-server and persist `codexThreadId`.
- Expose task events, files, permissions, steering, and terminal access.
- Reap abandoned intents and expired tasks.

## Strengths

- Provider interface isolates Docker and DigitalOcean lifecycle behavior.
- Scheduler owns provisioning intents before resources are created.
- Safe path helpers enforce workspace boundaries.
- Redaction is centralized before logs and events are emitted.
- Codex auth handling copies only `auth.json`, not the whole Codex home.

## Architectural Invariants

- `Provider.ts` is the backend lifecycle contract.
- Scheduler owns task status transitions.
- Providers own resource provisioning, terminal streams, and destruction.
- Codex bridges own prompt execution, not provider provisioning.
- DigitalOcean live calls require `cloud.enabled`, `cloud.dryRun=false`,
  the live guard, and a host token.
- Do not add collaboration/platform/Discord concepts here.

## Common Workflows

- Change task schema through `types.ts`, `db.ts`, and tests together.
- Change backend lifecycle through `Provider.ts`, providers, scheduler, and
  tests together.
- Change Codex execution through `codex/` bridge tests first.
- Run `npm test` and `npm run build` after server changes.

## Future Work

- Add schema migrations if persistent DB compatibility becomes required.
- Split DigitalOcean API helpers only if provider complexity grows.
- Add stronger process cleanup around long-running app-server sessions.
