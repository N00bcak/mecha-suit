---
name: humanizer
description: Write and revise long-form prose with a natural, genre-aware voice while preserving meaning, evidence, and authorial intent.
---

# Humanizer

## Purpose

Write or revise long-form prose so it reads as deliberate human communication
rather than generic generated copy. Preserve the work's substance and the
author's actual voice instead of imposing a stock conversational persona.

Think as thoroughly as the task requires before composing. Simplicity in the
prose must not come from reducing the reasoning.

## Use When

- Writing a paper, essay, report, article, speech, or ordinary blog post.
- Revising long-form prose for a more natural or specific voice.
- Auditing a draft for formulaic, inflated, or machine-like writing habits.

## Do Not Use

- Technical documentation, API references, code comments, or interface copy.
- Short messages, advertisements, marketing copy, or social posts.
- Determining whether a person or model authored a text. Style is not proof of
  provenance.
- Posts intended for N00bcak's site or voice; use `blogpost-writing`.
- Do not use, spawn, request, or rely on subagents.

## Needs

- The purpose, audience, genre, and required claims.
- Sources, notes, or evidence for factual work.
- The draft when revising, and any voice sample or explicit tone requirement.

If author-owned facts, experiences, or judgments are material and unavailable,
ask one focused question. Never manufacture them to make prose feel personal.

## Voice Priority

Use, in order:

1. Explicit user instructions and supplied writing samples.
2. The draft's deliberate register, cadence, and quirks.
3. Conventions appropriate to the genre, audience, and purpose.

Do not add slang, jokes, anecdotes, opinions, or first-person claims merely to
signal humanity.

## Workflow

1. Establish what the piece must accomplish and what evidence supports it.
2. Separate sourced facts, author claims, interpretation, and uncertainty.
3. Choose an argument and structure appropriate to the genre.
4. Write directly, using concrete claims and transitions earned by the logic.
5. When revising or auditing substantial prose, read
   `references/revision-patterns.md` and apply only the relevant checks.
6. Recheck meaning, qualifications, citations, quotations, code, and deliberate
   stylistic choices against the inputs.
7. Remove edits that merely exchange one formula for another.

For an audit, report the strongest patterns with examples and explain their
effect. Do not count isolated words as defects.

For a revision, make the smallest changes that resolve the actual problems.
Strong passages may remain unchanged.

For blank-page authoring, return complete prose rather than narrating the
workflow. Add a short note about assumptions or unresolved evidence only when
it helps the user evaluate the result.

Edit a named file in place only when the user requests a file change. Preserve
frontmatter, links, citations, quotations, and embedded code unless changing
them is part of the task.

## Done Conditions

- The prose fulfills its purpose for the intended reader.
- Claims and uncertainty remain faithful to the available evidence.
- Voice choices fit the author and genre rather than a generic persona.
- The result has been checked for formulaic patterns without being flattened.

## Persistence And Yield

Useful progress means a clearer argument, better-supported claim, more faithful
voice, or completed section.

Before yielding, try the primary structure and one materially different
framing or revision when the first remains weak. Yield only when missing
author-owned information or evidence would otherwise require invention. Return
the specific gap and the next useful input.
