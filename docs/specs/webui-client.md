# `webui/client/` Spec

## Purpose

`webui/client/` is the browser UI for creating, starting, steering, inspecting,
and stopping Mecha WebUI tasks.

## Architecture Tree

```text
webui/client/
    index.html
    src/
        main.tsx
        api.ts
        TaskList.tsx
        TaskView.tsx
        SteeringPane.tsx
        TerminalPane.tsx
        FileBrowser.tsx
        PermissionsEditor.tsx
        EventLog.tsx
        styles.css
```

## Main Responsibilities

- Render task list and task detail views.
- Send REST requests to task APIs.
- Subscribe to task event and terminal WebSockets.
- Surface runtime warnings for host, container, and droplet execution modes.
- Provide file browsing and permission editing.

## Strengths

- Client state is simple and API-driven.
- Runtime boundary warnings are visible in task views.
- File, terminal, steering, and event panes map directly to server endpoints.

## Architectural Invariants

- Browser never receives cloud tokens, SSH private keys, or Codex auth contents.
- Client types in `api.ts` must match server task contract changes.
- The UI describes security boundaries honestly; it must not imply prompt-level
  isolation.
- Keep generated Vite output under `webui/dist/`, not source.

## Common Workflows

- Update `api.ts` when task contract fields change.
- Update `TaskView` and `SteeringPane` when execution modes change.
- Run `npm run build` after client changes.
- Keep layout changes restrained and operational; this is a control plane, not
  a marketing surface.

## Future Work

- Improve loading/error states around long DigitalOcean provisioning.
- Add richer status display for stored Codex thread IDs and auth readiness.
- Improve terminal UX when server-side PTY handling is upgraded.
