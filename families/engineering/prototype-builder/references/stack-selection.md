# Constraint-Led Stack Selection

Choose a stack only after framing the prototype's user, core outcome, and
observable demonstration.

## Decision Order

1. Honor the user's explicit preference.
2. Reuse an available runtime and local toolchain.
3. Follow a critical library that directly enables the hypothesis.
4. Fit the required deployment, device, distribution, or execution target.
5. Prefer technology likely maintainers can understand and run.

If several choices remain, select the one with the shortest credible path to
the vertical slice and the fewest new moving parts. Record the decisive
constraint; do not conduct broad framework shopping.

## Questions That Matter

- Does the demonstration require a browser, native device, single binary,
  notebook, server, or embedded target?
- Must another person run it without installing a runtime?
- Does the hypothesis depend on a specific SDK, protocol, model, database, or
  hardware API?
- Is performance, portability, or deployment itself part of what is being
  tested?
- Is there an existing conventional stack in the surrounding workspace?

## Avoid / Prefer

| Avoid | Prefer |
|---|---|
| Selecting a framework because it is fashionable | Selecting from explicit constraints |
| Adding a second language for a minor component | One coherent stack unless a critical boundary requires otherwise |
| Introducing build orchestration before code runs | The repository or runtime's existing commands |
| Assuming a hosted vendor is required | The smallest local or deployed environment that demonstrates the outcome |
| Designing for a hypothetical production migration | Documenting promotion signals and revisiting later |

After choosing, load only the shared language primers that apply. Use their
idioms without adding production layers.
