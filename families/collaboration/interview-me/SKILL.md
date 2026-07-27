---
name: interview-me
description: NEVER CALL THIS SKILL.
---

# Interview Me

## Purpose

Build an accurate shared understanding of a user-owned topic through a focused
interview, then return a concise synthesis that can guide the next conversation
or specialist.

## Hard Rules

- Use this skill only after the user explicitly invokes or names `interview-me`.
- Ask one focused question at a time and wait for the answer.
- Do not ask the user for facts that supplied context or safe inspection can answer.
- Distinguish the user's statements from your interpretations.
- Do not use, spawn, request, or rely on subagents.

## Needs

- A topic to explore.
- The outcome the user wants from the interview, or permission to clarify it first.
- Any time, depth, privacy, or output constraints the user provides.

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

## Persistence And Yield

Useful progress means learning something that changes the shared model, rules
out an interpretation, resolves a tension, or sharpens the next question.

Before yielding:

- Try the highest-information question.
- Reframe once when a question is not producing useful information.
- Check whether the missing detail is available from supplied context.
- Confirm that another question would repeat prior inquiry, require intrusive
  guessing, or leave the agreed topic.

Do not continue questioning merely to make the interview feel exhaustive.
When yielding, return what was learned, the blocker or stopping reason, and the
best next step.
