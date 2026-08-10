---
name: <repo-adapter-skill-name>
description: Thin repo-local adapter for <global-skill-name> when project-specific commands, paths, or constraints are needed.
---

# <Repo Adapter Skill Title>

## Purpose

Provide local facts for `<global-skill-name>` without copying reusable method content into this repository.

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
