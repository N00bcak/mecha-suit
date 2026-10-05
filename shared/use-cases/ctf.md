# CTF

Use this guide whenever the requested outcome is a flag, including ML-based or
AI-themed challenges.

## Explore

Own the solve. Keep working autonomously through failed attempts, dead ends,
and pivots; being stuck or unsure is not a reason to hand back. Test the
obvious hypothesis immediately, and widen the search when it fails.

Use known techniques to recognize patterns. When nothing fits cleanly, stop
retrying the nearest technique and analyse the mechanism instead: model what
the system actually does, list the assumptions it relies on, and find the one
the author broke. Ask what differs from the standard construction; novelty is
usually where the weakness is. Treat author intent as evidence: every supplied
artifact has a purpose. Build small experiments, such as local replicas,
oracles, or instrumented runs, to test hypotheses about the mechanism cheaply.

When progress stalls, work through these before concluding anything:

1. Re-enumerate every supplied file, service, and hint; a stall usually means
   something given has not been fully used.
2. Re-check what you believe and why, starting with cheap beliefs that matter.
3. Widen the hypotheses: reconsider what category of problem this really is.
4. Run cheap experiments that distinguish the remaining hypotheses, and keep a
   record of dead ends so you do not revisit them.
5. Change technique when the current line stops producing new information.

## Deliver

Deliver the flag and how it was obtained, with any solve script.

## Missing resources

Presume every file and endpoint the challenge needs is provided and reachable.
A resource that seems missing is most likely hidden, derived, or part of the
puzzle. Treat it as inaccessible only when:

- the user confirms a mistake, such as a file they forgot to attach; or
- a remote instance blocks access despite correct attempts (the browser, the
  right protocol, plausible headers) and the block is not part of the
  challenge.

## Expensive actions

Abstain from expensive runs such as brute force unless you have very good
reason to believe they are the only way forward, for example when analysis
has reduced the search space to something small. When you run one, record
why, keep it bounded, and prefer local runs over load on a remote service.

## Stop

Stop when you have the flag, when a severe blocker below applies, or when the
agreed time or resources run out.

## Escalate

Escalate only for severe blockers:

- the next step would leave the challenge's scope, such as the scoreboard,
  other teams, event infrastructure, or unrelated hosts;
- the only way forward breaks an event rule or harms shared infrastructure;
- a resource is confirmed inaccessible as described above;
- a legal or safety concern beyond the CTF framing.

## Bookkeeping

For a multi-step solve, keep a working log at `.mecha/logs/<slug>.md` in the
workspace, adding `.mecha/` to `.gitignore` in a Git repository if absent.
Record resources and reconnaissance, hypotheses, attempts and results, dead
ends and why, and the current frontier. Update it at meaningful steps and build
the briefing from it.

It is working notes, not a record: it never activates or resumes a skill, and
its claims must be checked against current files before you rely on them in a
later session. Skip it for short tasks.

## Report

Whenever you stop without the flag, brief the user as a teammate who knows
nothing about the challenge. This briefing is the proportional report:

- the apps, files, and endpoints given, and what each is;
- the reconnaissance done and what it showed;
- why the challenge is unsolved: what was tried, what was not tried and why,
  and exactly where you are stuck.
