# Review Contract

Use this contract for evidence-gated code-review findings whether review occurs
inside governed work or as a bounded contributor result.

## Findings

Give every finding a stable `RF-*` ID with its review axis, location, concrete
claim, affected criterion or rule, reproducible evidence, consequence, scope
relation, smallest corrective action, and state: `open`, `resolved`, or `waived`.

First decide whether the claim is supported. Prefer reproduced failure, then an
accepted contract or required check, reachable-path analysis, and established
local convention. Then decide whether action is justified in the current
change. Classify it as `blocking`, `non-blocking`, `question`, `deferred`, or
`rejected`.

A supported finding blocks only for an accepted-intent or constraint violation,
an introduced or worsened material defect, missing consequential verification,
or a demonstrated present maintainability cost. Preference and speculation do not block. Preserve IDs through re-review; a failed remediation keeps its ID and
a remediation regression receives a new one.

## Disposition

Use one disposition: `passed`, `changes required`, `intent decision required`,
`adjudication required`, or `waived`. Repeated disputes without new evidence
need adjudication or a decisive check. A waiver makes risk visible; it does not
make missing verification pass.
