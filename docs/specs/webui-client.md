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
        TaskCreateDialog.tsx
        TaskView.tsx
        SteeringPane.tsx
        TerminalPane.tsx
        FileBrowser.tsx
        PermissionsEditor.tsx
        EventLog.tsx
        styles.css
```

## Main Responsibilities

- Render an attention-first CTF task queue and task detail cockpit.
- Provide separate single-task and batch-intake dialog workflows.
- Send REST requests to task APIs.
- Subscribe to task events for the read-only Codex transcript and use a
  separate WebSocket only for the explicit runner Shell tab.
- Surface runtime warnings for host, container, and droplet execution modes.
- Provide file browsing and permission editing.

## Strengths

- Client state is simple and API-driven.
- Desktop operators can supervise the queue, Codex console, and inspector in one view.
- Runtime boundary warnings are visible in task views.
- File, transcript, steering, shell, and event panes map directly to server
  endpoints.

## Architectural Invariants

- Browser never receives cloud tokens, SSH private keys, or Codex auth contents.
- Client types in `api.ts` must match server task contract changes.
- The UI describes security boundaries honestly; it must not imply prompt-level
  isolation.
- Keep generated Vite output under `webui/dist/`, not source.

## Common Workflows

- Update `api.ts` when task contract fields change.
- Update `TaskView` and `TerminalPane` when execution modes change.
- Run `npm run build` after client changes.
- Keep the dark cockpit layout operational and information-dense; this is a
  control plane, not a marketing surface.

## Layout Contract

- At 1280px and wider, render an independently collapsible 220-560px task
  queue, flexible console workspace, and independently collapsible 280-560px
  inspector.
- Between 1024px and 1279px, expose the inspector as a right-side drawer.
- Sort queue sections by attention, running, ready, and done while preserving
  newest-first server order within each section.
- Store presentation preferences only, including queue/inspector widths and
  open states, in browser local storage.
- Keep the xterm console denser than the surrounding UI so long Codex and shell
  output remains scannable without shrinking application controls.
- Refit xterm rows and columns whenever its container changes size. Sanitize
  terminal control sequences from the read-only Codex transcript, while leaving
  the interactive Shell stream unchanged.
- Keep native app-server output read-only in the Codex console; interactive
  keystrokes belong only to the Shell tab.

## Future Work

- Improve loading/error states around long DigitalOcean provisioning.
- Add richer status display for stored Codex thread IDs and auth readiness.
- Improve runner Shell UX when server-side terminal handling is upgraded.
