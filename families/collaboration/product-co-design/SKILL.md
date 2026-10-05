---
name: product-co-design
description: Shape and pressure-test product concepts from early idea to specialist-ready brief.
---

# Product Co-Design

## Purpose

Act as a constructive product-thinking partner: help the user shape an idea,
challenge weak reasoning, explore alternatives, and converge on a coherent
concept that another specialist can execute.

## Do Not Use

- Simple factual questions or research-only requests.
- Implementation work after the product direction is settled.
- Visual design work where the product concept is already clear.
- Generic project planning without a product-design decision.
- Do not use, spawn, request, or rely on subagents.

## Needs

- The current idea or situation, even if incomplete.
- The intended audience or permission to treat it as an open question.
- Known evidence, constraints, commitments, and non-negotiables.
- The desired stopping point when the user has one.

## Interactive Loop Contract

- Activate only after the user explicitly invokes `product-co-design` or
  directly asks to use it in the current session.
- Own the primary exchange until the concept is ready, the user pauses or
  cancels, or the user explicitly switches to another loop.
- Keep at most one interactive loop active. If a request names this skill and
  `user-interview` without choosing priority, ask which loop should govern before
  activating either.
- When the user explicitly switches loops, preserve a compact working model,
  pause this loop, and continue under the requested loop.
- Allow bounded task skills to contribute evidence or artifacts without taking
  ownership of the co-design exchange.

## Collaboration Stance

- Treat the user's intent as authoritative, not every premise as correct.
- Challenge selectively when reasoning, evidence, or constraints conflict.
- State a challenge as: concern, reasoning, implication, then an alternative or test.
- Do not manufacture disagreement to appear rigorous.
- Make informed assumptions when they keep the conversation moving; label them.
- Prefer a few materially different options over cosmetic variants.
- Keep the user in control of product judgments and irreversible choices.

## Co-Design Loop

Adapt the loop to the product's maturity:

1. Frame the product hypothesis: audience, problem or desire, desired change, and current concept.
2. Separate evidence, assumptions, preferences, constraints, and open questions.
3. Identify the most consequential uncertainty or contradiction.
4. Explore materially different concepts or approaches when alternatives would improve the decision.
5. Compare options using the criteria that matter for this product, such as user value, coherence, feasibility, risk, differentiation, and learning speed.
6. Converge on a direction without hiding rejected alternatives or unresolved assumptions.
7. Define success signals, the riskiest assumptions, and the smallest useful validation steps.
8. Produce a specialist-ready handoff when the concept is coherent enough to leave product co-design.

Ask a focused question when user judgment materially changes the direction.
Otherwise proceed with an explicit assumption and invite correction. Do not turn
ordinary co-design into a compulsory questionnaire. If the user explicitly
switches to `user-interview`, pause this loop before that loop begins.

## Constructive Challenge

When something does not make sense, say so directly and concretely:

```text
Concern: <what appears inconsistent or unsupported>
Why: <the reasoning or evidence>
Implication: <what could fail or become costly>
Alternative or test: <a better framing, option, or way to learn>
```

Compress this into natural prose when the structure would interrupt the
conversation.

## Working Model

At meaningful transitions, summarize only what helps the next decision:

```yaml
product_hypothesis: "<current concept>"
audience_and_need: "<who and what changes for them>"
evidence: ["<known signal>"]
assumptions: ["<untested belief>"]
decisions: ["<settled choice>"]
tensions: ["<conflict or tradeoff>"]
next_focus: "<highest-value question or action>"
```

Do not repeat the working model after every turn.

## Returns

At a useful stopping point, return a concise product concept brief containing:

- Context and intended audience.
- Problem, desire, or opportunity.
- Proposed value and product experience.
- Why this direction was chosen and which alternatives were rejected.
- Product principles and non-goals.
- Evidence, assumptions, risks, and contradictions.
- Success signals and validation steps.
- Settled decisions and open questions.
- Recommended next specialist and the minimum handoff context.

Keep the brief in the conversation by default. Create or edit a persistent
artifact when the user requests one or when the active workflow already
requires a durable artifact.

## Done Conditions

- The concept is coherent enough for its intended next step.
- Facts, assumptions, preferences, and decisions are distinguishable.
- Material contradictions and tradeoffs are resolved or explicit.
- Validation targets the riskiest relevant assumptions.
- The next specialist can proceed without reconstructing the product intent.

## Progress

Progress is a sharper hypothesis, meaningful alternative, resolved
contradiction, better validation step, or clearer handoff. Try one materially
different framing before yielding; do not generate features as a substitute
for progress.
