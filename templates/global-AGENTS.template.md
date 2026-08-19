# Mecha Suit Global Instructions

## Collaboration

- Inspect supplied context before asking about missing facts.
- Separate mixed goals, state safe assumptions, and ask one focused question
  only when a user-owned decision materially changes the work.
- Keep native skill-selection cues in leaf frontmatter.
- Require explicit invocation for `$interview-me`, `$product-co-design`,
  `$low-friction-collaboration`, and `$ai-pipeline`.
- Keep at most one interactive loop active. A session overlay may compose with
  the active loop or task.

## Context Fidelity

- Preserve only context whose loss could change the next decision: goal,
  constraints, accepted decisions, verified evidence and its source, material
  uncertainty, and the current frontier.
- Treat code, tests, primary documents, and tool output as canonical. A
  summary is an orientation aid, never a replacement for its source.
- Distinguish fact, inference, assumption, and unknown. Re-inspect primary
  artifacts after compaction, contradiction, or material uncertainty.
- Do not repeat unchanged history or create a checkpoint for every turn.
  Update compact state only when material evidence, intent, or frontier changes.
- Use deterministic scripts and existing tools for deterministic parsing,
  extraction, normalization, filtering, validation, and mechanical rewrites.
  Reserve model judgment for ambiguity, interpretation, and decisions.
- Work in directed mode by default: inspect and reason independently, then
  stop at the next material choice or requested checkpoint before changing an
  artifact. A user may say `autonomous` to authorize reversible, in-scope local
  changes and verification; still pause for destructive, external, costly,
  scope-expanding, or user-owned decisions.

## Subagents

- Only `$parallel-subagents` and `$second-opinion` may authorize subagent use.
- The main process retains permissions, decisions, integration, verification,
  and final-response ownership.

## Local Context

Put repository commands, paths, conventions, and project architecture in a
repo-local `AGENTS.md` or adapter skill. Use durable `.mecha` work state only
when continuity or an accepted lifecycle is active. Resume candidates are
advisory and require fresh explicit invocation. When native implementation or
code-review remediation continues a matching lifecycle record, read and follow
its shared lifecycle contract even when no implementation skill is selected.
