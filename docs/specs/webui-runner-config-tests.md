# WebUI Runner, Config, Scripts, And Tests Spec

## Purpose

This spec covers WebUI support folders outside the client/server split: runner
image, configuration, operational scripts, and tests.

## Architecture Tree

```text
webui/
    config/
        default.yaml
    runner/
        Dockerfile
        entrypoint.sh
    scripts/
        generate-codex-transport-key.sh
    tests/
        *.test.ts
        helpers.ts
```

## Main Responsibilities

- Define default local and DigitalOcean execution settings.
- Build a minimal Docker runner capable of running native Codex.
- Generate the dedicated SSH keypair used for DigitalOcean transport.
- Test contracts around config guards, task creation, providers, Codex bridge
  behavior, auth copying, paths, redaction, scheduler, and quota behavior.

## Strengths

- Defaults keep live cloud disabled unless explicitly enabled.
- Runner image is minimal and focused on Codex task execution.
- Tests cover important safety boundaries such as path traversal, redaction, and
  old credential-mode rejection.
- Transport key generation is explicit and refuses overwrite by default.

## Architectural Invariants

- `default.yaml` must not enable live DigitalOcean by default.
- Runner image should not bake in user credentials.
- Scripts must not depend on private infrastructure.
- Tests should verify safety and contract behavior before live integration.
- Do not commit generated keys, task cache, node modules, or build output.

## Common Workflows

- Run `npm run runner:build` after runner changes.
- Run `webui/scripts/generate-codex-transport-key.sh` before live DigitalOcean
  use.
- Run `npm test` after server/client/config/test changes.
- Add tests when changing credential, provider, path, scheduler, or task schema
  behavior.

## Future Work

- Add opt-in live smoke tests that are skipped unless required environment
  variables are present.
- Add a test helper for mocked app-server JSON-RPC transcripts if bridge logic
  expands.
- Add runner image validation if the Dockerfile gains more tooling.
