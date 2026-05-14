# Routing Checklist

Use this only when the routing table in `SKILL.md` is not enough.

## Cheap classification checks

- Is the user asking for skill selection rather than task execution?
- Is there a concrete artifact: repo, file, dataset, binary, service, prompt, or experiment?
- Is one specialist clearly sufficient?
- Is the task missing an artifact, objective, or constraint?
- Is the task genuinely cross-domain, or merely unclear?

## Default decisions

- Existing codebase work goes to `large-codebase-change`.
- Small greenfield work goes to `prototype-builder`.
- CTF challenge with clear category goes directly to the matching CTF specialist leaf.
- CTF challenge with unknown or ambiguous category goes to `ctf-triage`.
- ML work goes to `task-clarifier` while ML leaves are still stubs.
- Ambiguity goes to `task-clarifier`.
- Council is only for real multi-specialist reasoning with fully authored non-council leaves.

## Minimum handoff

Include only:

- Selected skill
- Confidence
- One-sentence user goal
- Explicit inputs
- Explicit constraints
- Reason for route
