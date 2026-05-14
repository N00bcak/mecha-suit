---
name: task-router
description: Classify a user task into this toolbox's next best skill using narrow, cheap routing. Use when selecting between routing, council, engineering, CTF, or ML leaves; do not use to solve the task.
---

# Task Router

## Purpose

Classify the task, select the next skill when there is a clear fit, and emit the minimum context needed for that next step.

This skill is a router, not an orchestrator.

## Hard Rules

- Do not solve the domain task.
- Do not produce broad implementation plans.
- Do not gather broad context just in case.
- Do not use, spawn, request, or rely on subagents.
- Do not inspect specialist internals unless the leaf name and description are insufficient.
- Do not choose the council for ordinary ambiguity.
- Do not route directly to stub specialist leaves.

## Routing Table

| Signal | Select |
| --- | --- |
| Existing codebase change, integration work, systems-heavy engineering, migrations, shared contracts, tests, refactors | `large-codebase-change` |
| Small greenfield build, prototype, demo, utility, or app likely under about 1kLoC | `prototype-builder` |
| CTF challenge with unknown or ambiguous category | `ctf-triage` |
| Reverse engineering challenge: binary, bytecode, VM, APK, WASM, obfuscation | `reverse-ctf` |
| Binary exploitation challenge: memory corruption, ROP, heap, format string, sandbox escape | `pwn-ctf` |
| Cryptography challenge: RSA, ECC, symmetric, classical cipher, PRNG, hash | `crypto-ctf` |
| Web exploitation challenge: HTTP service, injection, auth bypass, client-side attack | `web-ctf` |
| Forensics challenge: PCAP, disk image, memory dump, steganography, log analysis | `forensics-ctf` |
| AI/ML security challenge: prompt injection, adversarial ML, model extraction, LLM jailbreak | `ai-ctf` |
| Miscellaneous challenge: jail escape, encoding puzzle, OSINT, esoteric language, hardware | `misc-ctf` |
| Dataset, labels, features, leakage, splits, environment, evaluation, modeling feasibility while ML leaves remain stubs | `task-clarifier` |
| Clearly classical supervised baseline or tabular baseline after dataset shape is known while `classical-ml-baseline` remains a stub | `task-clarifier` |
| Clearly deep learning experiment after dataset and objective are known while `deep-learning-experiment` remains a stub | `task-clarifier` |
| Mixed, unclear, underspecified, conflicting, or missing key artifact/objective | `task-clarifier` |
| Genuine cross-domain work requiring multiple specialist interpretations or reconciliation when the relevant non-council leaves are fully authored | `interdisciplinary-council` |

## Minimal Context Policy

Use only the user's request and immediately available metadata. If one small check is needed to distinguish an existing codebase from a greenfield task, inspect only the shallowest relevant artifact such as top-level files or a manifest.

Do not scan a repository, read multiple source files, or collect evidence for a downstream specialist. The selected skill owns that work.

If a task would otherwise fit a specialist leaf that is still marked `This is a stub. NEVER CALL THIS SKILL.`, route to `task-clarifier` and name the blocked stub in `why`.

## Output Contract

Return a compact handoff:

```yaml
selected_skill: "<skill-name>"
routing_confidence: "high | medium | low"
minimum_context:
    task_type: "<short classification>"
    user_goal: "<one sentence>"
    known_inputs: ["<only inputs needed by next skill>"]
    constraints: ["<only explicit constraints>"]
why: "<one short reason>"
not_doing: ["domain solving", "broad planning", "subagents"]
```

If confidence is low, select `task-clarifier`.

## Reference

Read `references/routing-checklist.md` only when the routing choice remains unclear after the table above.
