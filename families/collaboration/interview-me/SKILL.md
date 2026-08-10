---
name: interview-me
description: Interview the user one focused question at a time.
---

# Interview Me

## Purpose

Build an accurate shared understanding of a user-owned topic through a focused
interview, then return a concise synthesis that can guide the next conversation
or specialist.

## Do Not Use

- Do not infer this loop from ordinary ambiguity or a vague request for help.
- Do not use it to ask for facts available in supplied context or safe local
  inspection.
- Do not use, spawn, request, or rely on subagents.

## Hard Rules

- Ask one focused question at a time and wait for the answer.
- Do not ask the user for facts that supplied context or safe inspection can answer.
- Distinguish the user's statements from your interpretations.

## Needs

- A topic to explore.
- The outcome the user wants from the interview, or permission to clarify it first.
- Any time, depth, privacy, or output constraints the user provides.

## Interactive Loop Contract

- Activate only after the user explicitly invokes `interview-me` or directly
  asks to use it in the current session.
- Own the primary exchange until synthesis is complete, the user pauses or
  cancels, or the user explicitly switches to another loop.
- Keep at most one interactive loop active. If a request names this skill and
  `product-co-design` without choosing priority, ask which loop should govern
  before activating either.
- When the user explicitly switches loops, preserve the current synthesis,
  pause this loop, and continue under the requested loop.
- Allow bounded task skills to contribute discoverable evidence without taking
  ownership of the interview exchange.

## Interview Procedure

1. Restate the topic and desired outcome in one sentence.
2. Identify the smallest set of unknowns that materially affects that outcome.
3. Ask the highest-information question first.
4. Reflect the answer briefly when confirmation would prevent misunderstanding.
5. Follow the answer rather than a fixed questionnaire.
6. When resolving a choice, recommend a default and explain why.
7. When eliciting a mental model, allow open-ended answers instead of forcing options.
8. Surface contradictions gently by naming the tension and asking which interpretation is closer.
9. Periodically summarize the emerging model at meaningful transitions.
10. Stop when the desired outcome is met, answers have saturated, the user stops, or a specific blocker is clear.

## Working Synthesis

Keep periodic synthesis compact:

```yaml
topic: "<what is being explored>"
desired_outcome: "<what the interview should make clearer>"
known: ["<user-stated fact, preference, or decision>"]
inferred: ["<agent interpretation awaiting confirmation>"]
tensions: ["<conflict or uncertainty>"]
next_question: "<one question>"
```

Do not show this structure after every answer. Use it when the conversation
changes direction, a misunderstanding is possible, or the user asks for a
checkpoint.

## Returns

At a useful stopping point, return:

- The interview purpose.
- What was learned.
- User preferences and decisions.
- Material tensions or contradictions.
- Remaining unknowns.
- One recommended next action or specialist handoff.

Keep the result in the conversation by default. Create or edit a persistent
artifact only when the user requests one.

## Done Conditions

- The stated interview outcome is met or a specific blocker is explicit.
- Material conclusions are grounded in the user's answers.
- Inferences and unresolved tensions remain visibly distinct from settled facts.
- The user has a clear next action, decision, or handoff.

## Lifecycle Participation

When the explicitly requested interview belongs to a matching work record,
read `../../../shared/rubrics/lifecycle-contract.md` unless its current contents
are already available in context. Use existing intent, evidence, decisions,
and open questions to avoid repetition. At a meaningful
transition, record the compact synthesis and next task shape without changing
accepted intent semantics.

Lifecycle context does not relax the one-question-at-a-time rule or authorize
questions about discoverable facts. Without a matching record, preserve the
conversation-first persistence default.

While this loop remains active with a matching durable record, add
`interview-me` to `Resume candidates`. Keep it while paused. Remove it when the
loop completes or the user cancels it. Recorded state never activates the loop
in another session.

## Persistence And Yield

Progress changes the shared model, rules out an interpretation, resolves a
tension, or sharpens the next question. Reframe one unproductive question;
stop when another would repeat, guess intrusively, or leave the agreed topic.
