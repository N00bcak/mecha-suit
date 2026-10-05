# AI Challenges

Use this guide when the requested outcome is model or solver performance
against an objective. Code fixes inside an AI project follow the software
engineering guide instead.

## Explore

Own repeated improvement. Iterate across data, representations, models or
solvers, and ensembles, letting evidence decide which stage to revisit. Use
theory to choose experiments: prefer the experiment whose result would most
change the next decision.

Draw on your own knowledge deliberately. Before choosing experiments, state
the theory relevant to this problem's structure, such as the data regime,
noise, inductive biases, and known failure modes, and derive candidates from
it. Treat theory-based predictions as hypotheses for the evaluation to confirm
or reject. Verify version-sensitive knowledge, such as library APIs and recent
methods, against installed documentation or source rather than recall.

## Deliver

Deliver the best evaluated artifact against the objective, with a
reproducible run path.

## Missing resources

Inspect supplied data, documentation, and reachable context thoroughly before
declaring anything missing. When something is truly unavailable, continue with
what exists and name the gap.

## Expensive actions

Weigh each run's expected value against its cost. Training runs and searches
within authorized compute are ordinary work and need no further approval;
spending beyond that authorization does.

## Stop

Stop when the objective is met, the authorized resources are spent, or no
remaining experiment's expected gain justifies its cost given validation noise
and the remaining budget. A flat result, such as an ablation or diagnostic
that shows no gain, lowers that expectation but is not by itself a reason to
stop.

## Escalate

Escalate spending beyond the authorization, or a conflict between the stated
objective and what the evaluation can measure.

## Bookkeeping

For an experiment campaign, keep a working log at `.mecha/logs/<slug>.md` in
the workspace, adding `.mecha/` to `.gitignore` in a Git repository if absent.
Record each experiment's configuration, result, and evaluation noise, the
conclusions drawn, and the current frontier. Update it at meaningful steps and
build the report from it.

It is working notes, not a record: it never activates or resumes a skill, and
its claims must be checked against current files before you rely on them in a
later session. Skip it for short tasks.

## Report

Report the best result under one fixed, valid evaluation; which experiments
mattered and why; failed directions; and remaining promising ones.
