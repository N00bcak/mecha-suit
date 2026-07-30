# `families/writing/` Spec

## Purpose

The writing family contains long-form prose specialists. It improves prose
without becoming a universal formatting layer for technical documentation,
code, or ordinary chat.

## Architecture

```text
families/writing/
    humanizer/
        SKILL.md
        references/revision-patterns.md
    blogpost-writing/
        SKILL.md
        references/n00bcak-voice.md
```

## Skill Boundaries

- `humanizer` writes and revises papers, essays, reports, articles, speeches,
  and ordinary blog posts. It does not determine authorship.
- `blogpost-writing` owns VitePress-ready posts and CTF writeups for N00bcak's
  site and takes precedence when that destination or voice is requested.
- Documentation, code comments, interface copy, advertisements, social posts,
  and short messages remain outside this family.

## Context Discipline

- Active workflows and integrity rules stay in each `SKILL.md`.
- `revision-patterns.md` loads for substantial revision, humanization, or
  audits rather than routine blank-page authoring.
- `n00bcak-voice.md` loads for site-specific authoring because the voice profile
  is central to that skill.
- Research sources inform the references but are not runtime dependencies.
- Neither skill requires scripts, host metadata, or subagents.

## Maintenance

Refresh the voice profile only when explicitly requested and use multiple posts
and genres rather than extrapolating from one conspicuous example. Keep routing
examples and stable boundary tests aligned when either skill's ownership
changes.
