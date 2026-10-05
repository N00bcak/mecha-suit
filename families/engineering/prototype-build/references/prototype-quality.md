# Risk-Calibrated Prototype Quality

A prototype must produce observable evidence for its core outcome. Everything
else is justified by the demonstration's use and consequence of failure.

## Always Required

- A working end-to-end primary path.
- One material failure path with understandable behavior.
- Conventional install and run instructions.
- A visible list of shortcuts and intentionally deferred work.
- No silent corruption, credential exposure, or disguised placeholder output.

## Add Only When Material

| Concern | Material when |
|---|---|
| Automated tests | Repeated iteration could regress the core hypothesis or manual observation is unreliable |
| CI | Multiple contributors or a required remote workflow depends on repeatable checks |
| Migrations | Durable data must survive schema evolution during the experiment |
| Deployment automation | Deployment is part of the hypothesis or repeated demos need it |
| Authentication | Identity or access control is the behavior being tested, or exposed data requires it |
| Persistence | Restart survival or multi-session state is part of the outcome |
| Documentation beyond run steps | Another user must operate, evaluate, or extend the artifact |
| Monitoring | Unattended runtime behavior is part of the experiment |

These items are neither categorically required nor forbidden. Implement the
smallest version that makes the evidence trustworthy.

## Scope and Structure

- Build one vertical slice before secondary behavior.
- Prefer a direct local implementation over production architecture.
- Accept small duplication when extraction would add navigation or concepts.
- Add error handling for realistic demonstration inputs.
- Avoid speculative configuration, provider interfaces, service layers, and
  extension points.
- Keep dependencies limited to those used by the observable path.

## Visible Shortcuts

Document shortcuts near the run path or limitation they affect. State the
consequence and promotion trigger, for example:

```text
Data is stored in memory and is lost on restart. Add durable storage if the
prototype must support multi-session evaluation.
```

Do not hide discarded records, stale values, insecure defaults, or simulated
results behind successful output.

## Promotion Signals

Reassess the prototype posture when real users depend on it, sensitive or
durable data appears, uptime matters, production integration begins, or
compatibility obligations develop.

Promotion does not automatically select `large-codebase-change`. Use that skill
only when the resulting existing repository is large and its affected modules,
consumers, or compatibility boundaries warrant that method; otherwise use
native host behavior.
