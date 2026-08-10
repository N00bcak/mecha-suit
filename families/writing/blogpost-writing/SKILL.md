---
name: blogpost-writing
description: Author VitePress-ready blog posts and CTF writeups in N00bcak's evidence-grounded, adaptable personal voice.
---

# Blogpost Writing

## Purpose

Author complete posts for N00bcak's VitePress site while matching the range of
the author's established voice. Treat technical blogs and CTF writeups as
different genres rather than applying the loudest stylistic habits everywhere.

Think as thoroughly as the topic requires before composing. Clear prose must
carry the technical reasoning, not replace it.

## Do Not Use

- Generic long-form prose with no connection to this site or voice; use
  `humanizer`.
- Inventing personal experiences, opinions, experiments, results, challenge
  steps, or conversations.
- Publishing, committing, or deploying the post unless separately requested.
- Do not use, spawn, request, or rely on subagents.

## Needs

- The post type: technical/personal blog or CTF writeup.
- The intended reader, central point, and desired outcome.
- Notes, sources, code, results, images, and author-owned experiences needed to
  support the post.
- The intended publication date when it is not the current date.

Ask one focused question when a missing author-owned fact or judgment would
materially change the post. Discover public or repository facts before asking.

## Voice And Site Context

Read `references/n00bcak-voice.md` before drafting or substantially rewriting a
post. Select the profile matching the post type and evidence; do not combine
every observed tendency.

When working in the website repository, inspect one or two nearby posts and the
current post index or loader before writing. Local conventions override the
bundled profile when the site has evolved.

## Workflow

1. Fix the thesis, reader payoff, evidence, and post type.
2. Distinguish sourced facts from personal experience and interpretation.
3. Choose a structure that serves the material:
    - Technical/personal blog: motivate the question, develop the reasoning,
      show concrete evidence, and state what was learned.
    - CTF writeup: establish context, preserve challenge facts, explain the
      solve or design path, and include reflection only where supported.
4. Research claims that require current or precise support. Prefer primary
   sources and preserve useful links.
5. Draft the full post in the selected voice. Let humor, asides, emphasis, and
   register changes arise from the material.
6. Verify code, calculations, technical claims, links, and result descriptions
   in proportion to their importance. Label anything not independently checked.
7. Review for caricature, invented personality, generic AI phrasing, and
   unexplained jumps in the technical argument.

## Returns

Return VitePress-ready Markdown beginning with:

```yaml
---
title: "<post title>"
date: YYYY-MM-DD
---
```

Use only established frontmatter unless the repository requires more. Suggest:

- `docs/blog/YYYY-MM-DD-<slug>.md` for technical or personal posts.
- `docs/writeups/YYYY-MM-DD-<slug>.md` for CTF posts.

Use repository-relative asset and post links when their targets are known. Do
not create placeholder anecdotes or results. If the user explicitly prefers an
incomplete scaffold, mark missing material plainly.

## Done Conditions

- The post is complete, evidence-grounded, and ready for the intended site path.
- Its voice fits both N00bcak and the particular genre without forced quirks.
- Technical explanations, code, links, and personal claims are faithful to the
  available material.
- Remaining verification gaps or publication steps are explicit.

## Persistence And Yield

Progress is a settled thesis, resolved evidence gap, verified explanation, or
completed section. Try one alternate framing when needed; yield only when
continuing would invent author-owned material or unsupported claims.
