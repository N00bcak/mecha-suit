---
name: domain-modeling
description: Sharpen domain terminology and record durable decisions against scenarios, code, and evidence. Use when terms or business rules are ambiguous, overloaded, or contradict the code.
---

# Domain Modeling

## Purpose

Build a precise shared domain language and preserve consequential decisions so
later planning and implementation do not reinterpret the user's meaning.

## Do Not Use

- Do not use for ordinary reading of an existing glossary.
- Do not turn a glossary into an implementation specification or scratchpad.
- Do not create tracked domain files without an existing convention or explicit
  user approval.
- Do not spawn, request, or rely on subagents.

## Needs

- The domain question and available user or repository context.
- Existing glossary, decision records, schemas, code, and prior evidence.
- The audience and consequences of a mistaken model.

## Returns

- Canonical terms, definitions, relationships, invariants, and examples.
- Contradictions between stated language, evidence, and code.
- Candidate or promoted glossary and decision artifacts.
- Unresolved modeling questions and downstream implications.

## Done Conditions

- Material terms have one clear meaning in the current context.
- The model survives representative normal and edge-case scenarios.
- Facts, interpretations, preferences, and decisions remain distinguishable.
- Durable knowledge is captured locally or promoted with authorization.

## Workflow

1. Read existing domain documents and relevant decisions before proposing new
   language.
2. Identify the ambiguous concept or relationship and the decision it affects.
3. Test candidate meanings against concrete scenarios, repository behavior, and
   available evidence.
4. Name contradictions directly and ask one focused user-owned question when
   the resolution changes the model.
5. Record resolved terms immediately in the active candidate artifact or the
   repository's established convention when durable state is active. Otherwise
   keep the result in the conversation unless the user requests persistence.
6. Offer a durable decision record only when the decision is consequential,
   hard to reverse, and surprising without its rationale.

Keep a glossary about domain meaning. Keep implementation choices in decision
records or specifications. Reuse repository terminology when it is accurate;
do not impose a new vocabulary merely for consistency with this skill.

## Promotion

When durable state is active and no tracked convention exists, keep candidates
in a user-requested artifact. Offer explicit promotion once a term or
decision will matter beyond the current effort. On approval, use the
repository's chosen location; propose `CONTEXT.md` and `docs/adr/` only as
defaults, never as hidden requirements.

## Progress

Progress is a resolved term, tested invariant, exposed contradiction, or
durable decision. Test the model against one meaningful edge case and available
evidence before returning remaining uncertainty.
