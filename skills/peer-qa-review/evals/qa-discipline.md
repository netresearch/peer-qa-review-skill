# Evals — QA discipline (stub)

TDD-style behavioural evals for the QA-discipline guidance added in
`checklist.md` (Pillar R), `edge-cases.md` (§J), and `lifecycle.md`
(Stage 5 "Assignee on exit"). Each scenario states the situation, the input
signal, and the expected reviewer behaviour. These are assertions to grade a
reviewer transcript against — not yet a runnable harness.

## E1 — Merged ≠ reviewed (Pillar R)

**Situation**: a ticket reaches QA with its MR already merged and the change
live. No prior review happened.

**Input**: reviewer is asked to QA it.

**Expect**:
- Reviewer performs a full adversarial code review (reads the diff, checks
  documented commands/runbook against real repo state, looks for unintended
  blast radius) — in the first pass, unprompted.
- Reviewer does **not** say the review is moot / "threads are moot because it's
  merged" and stop at verification-grade AC-checking.

**Fail signal**: reviewer treats merge status as a reason to skip or defer the
adversarial pass, and only deepens after the requester pushes back.

## E2 — Dropped acceptance criterion → bounce (§J)

**Situation**: implementer's closing comment de-scopes an AC ("looks like a
one-off, not worth it") while the AC is still listed and unmet in the
description.

**Input**: reviewer reaches the verdict step.

**Expect**:
- Verdict is **Bounce** (`(x)`), reassigned to the implementer, naming both
  resolution paths (implement it / fold an agreed descope into the description).
- Reviewer does **not** resolve-and-offer-to-file-a-follow-up to wave it through.

**Fail signal**: the unmet AC is recorded as a `(!)` should-fix and the ticket
is resolved, or QA files its own follow-up ticket as a workaround.

## E3 — Claim then unassign on pass (Stage 5)

**Situation**: reviewer self-assigned to claim a team-queue ticket, then passes
it (resolve).

**Input**: post-transition state.

**Expect**:
- On pass, reviewer unassigns the ticket back to the team queue (verifying the
  assignee actually cleared — a Resolve transition may not clear it, Close does).
- On bounce, the implementer is the assignee.

**Fail signal**: a passed/resolved ticket is left assigned to the reviewer.
