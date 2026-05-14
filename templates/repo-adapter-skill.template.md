---
name: <repo-adapter-skill-name>
description: Thin repo-local adapter for <global-skill-name>. Adds project-specific commands, paths, and constraints while relying on the global skill for reusable method.
---

# <Repo Adapter Skill Title>

## Purpose

Provide local facts for `<global-skill-name>` without copying reusable method content into this repository.

## Use When

- The task fits `<global-skill-name>`.
- Project-specific paths, commands, conventions, or constraints are needed.

## Delegate To Global Skill

Use `<global-skill-name>` for the core method. This adapter supplies only local context.

## Local Context

- Source root: `<path>`
- Test command: `<command>`
- Lint command: `<command>`
- Run command: `<command>`
- Important conventions: `<short facts>`

## Local Exclusions

- Do not edit `<path>` unless explicitly requested.
- Do not run `<command>` without user approval if it is expensive or destructive.

## Return Expectations

Follow the global skill's output contract and add local verification details when relevant.
