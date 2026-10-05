---
name: web-design
description: Design and implement distinctive web interfaces from contextual direction through accessible, fixture-backed frontend. Use when visual design and interaction quality matter.
---

# Web Design

## Purpose

Design and implement a context-derived web experience whose structure, visual
language, responsive behavior, and interaction states work as one system.

Own content sites, documentation, interactive infographics, and application
interfaces when visual and interaction design is a primary outcome.

## Do Not Use

- In-conversation explanations, charts, or disposable inline visualizations.
- Product discovery while the audience, problem, or product concept is still
  materially unresolved; use `product-co-design` when explicitly requested.
- Backend implementation, production data integration, or a general-purpose
  prototype whose interface design is incidental.
- Small styling corrections that do not require a visual direction or UX
  judgment.
- Do not use, spawn, request, or rely on subagents.

## Needs

- The intended audience, content or task, and observable frontend outcome.
- The target repository or output location and any required web stack.
- Existing brand, content, assets, routes, components, and design constraints.
- Required states, representative data, and known accessibility constraints.

## Returns

- A selected, implemented web interface in the requested or existing stack.
- Responsive and accessible behavior with working client-side interactions and
  clearly disclosed fixture-backed data.
- Verification evidence, research influences, intentional design decisions,
  integration limits, and remaining risks.

## Done Conditions

- The selected direction is implemented rather than merely described or
  mocked up.
- Applicable primary, failure, empty, loading, selected, destructive,
  keyboard, overflow, and responsive states are functional and inspected.
- Major visual and structural choices trace to the subject, audience, content,
  or interaction rather than a market-category stereotype.
- WCAG 2.2 AA is met for the implemented surface to the extent supported by
  performed automated and manual checks; unverified criteria are explicit.
- Fixture data, missing production seams, shortcuts, and deferred integration
  are visible in the handoff.

## Workflow

### 1. Ground the Interface

Inspect local instructions, the existing interface, content, assets, routes,
components, dependencies, and state model before proposing a direction. Keep a
working visual system when it is established and fit for the request; do not
redesign by default.

Frame the audience, page or task sequence, content hierarchy, repeated actions,
required states, and what must remain recognizable. Separate supplied facts and
constraints from proposed design choices.

Read `references/design-discipline.md` before generating concepts or reviewing
an implementation.

### 2. Research the Subject

When a new direction is required, perform bounded read-only research into the
subject's materials, history, audience, environment, and relevant interface or
editorial precedents. Prefer primary or direct sources for factual and visual
claims. Record what influenced the work and why; do not copy a reference's
composition or imply rights to unavailable fonts, images, or brand assets.

If research access is unavailable, state the limitation. Continue only when the
supplied material still supports defensible directions; otherwise return the
specific evidence gap.

### 3. Establish the Direction

If the user supplies an established direction, selected comp, or binding design
system, use it and proceed to implementation.

Otherwise create exactly three materially different full-page static comps.
Each direction must differ in content sequence or task framing, composition,
typographic behavior, palette logic, and interaction posture—not merely colors
or decoration.

- Build disposable HTML and CSS in a writable scratch location outside the
  production path.
- Use realistic content and show at least one state that affects the design.
- Render and inspect each comp in a browser, then present it as a full-page
  image with a concise rationale and named tradeoffs.
- Identify any proposed navigation, hierarchy, or task-flow change.
- Stop for selection or requested revision before editing production files.

The comps are design evidence, not production code or implementation proof. If
browser rendering and screenshot inspection are unavailable, return that
blocker rather than substituting prose or generated imagery.

### 4. Implement the Selected System

Implement only the selected direction. Use the existing stack and local
patterns; for a new artifact, choose the least machinery that satisfies the
requested runtime and delivery target. Preserve working production seams, but
do not add backend behavior or new production integration. Use representative
fixtures for frontend-only states and label them honestly.

Let interaction and content determine component boundaries. Every control must
work in the demonstrated frontend or be removed. Graphs, status marks,
numbering, and other information-bearing elements must encode real fixture
state. Use motion only when it explains causality, continuity, navigation, or a
state transition, and honor reduced-motion preferences.

Build responsive behavior from content priorities and task continuity rather
than treating mobile as a vertical stack of the desktop page. Make deliberate
decisions about collapse, reordering, density, comparison, labels, navigation,
and overflow.

### 5. Inspect and Verify

Inspect the rendered result at representative wide, intermediate, and narrow
widths. Exercise the primary interaction, keyboard path, and one material
failure or boundary state. Check semantic structure, visible focus, contrast,
zoom and reflow, target clarity, reduced motion, and accessible names with the
best available automated and manual methods.

Remove decorative or structural choices that fail the design-discipline test.
Run repository-native formatting, linting, tests, and builds appropriate to the
changed surface. Report the selected direction, files changed, verification,
fixture boundary, unverified accessibility criteria, and remaining risk.

## Progress

Progress is a grounded design constraint, a materially distinct rendered
direction, an explicit user selection, a working interface state, or verified
responsive and accessible behavior. Yield at the concept-selection checkpoint,
an unavailable rendering requirement, a missing user-owned product decision,
or a backend contract the frontend cannot honestly simulate.
