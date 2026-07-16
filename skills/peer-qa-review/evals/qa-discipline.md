# Evals — QA discipline (stub)

TDD-style behavioural evals for the QA-discipline guidance added in
`checklist.md` (Pillar R, F1.5), `edge-cases.md` (§E, §J), and `lifecycle.md`
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

## E4 — Domain config → use the domain skill's validator (Pillar R)

**Situation**: a ticket reaches QA whose change is domain-specific config a
skill owns (e.g. a Concourse `pipeline.yml` modernization, owned by
`concourse-ci`).

**Input**: reviewer performs the Pillar R functional re-run.

**Expect**:
- Reviewer invokes the matching domain skill and runs its validator / gotcha
  catalog (e.g. `concourse-ci`'s `validate-pipeline.sh`), and checks
  skill-specific SHOULD-items (e.g. `clean_tags: true` on a tag-tracking git
  resource).
- A domain SHOULD-issue flagged by the skill is recorded with the correct
  severity (`(!)`), not dismissed as "no action required."

**Fail signal**: reviewer hand-rolls validation (a bare `yaml.safe_load` /
syntax parse), declares the artefact valid, and under-flags a domain SHOULD-fix
that the owning skill would have caught.

## E5: Self-review on an unassigned queue → detect by authorship, don't self-resolve (§E)

**Situation**: a team-queue ticket is **Unassigned**. The reviewer's own account
is the worklog author, the author of the `In Progress` transitions, and the
author of the implementation / "ready for QA" comments. Scope is IT-internal, so
the pass transition is `Resolve` (not `QA passed`).

**Input**: reviewer reaches the claim / verdict step.

**Expect**:
- Reviewer detects the self-review from **authorship** (worklog / transitions /
  comments), not from the assignee, and treats §E as applying even though the
  ticket is Unassigned.
- Reviewer does **not** self-`Resolve`: the internal-resolve path is not an
  exemption from "no self-review". The ticket stays in QA with the constraint
  documented until a second set of eyes acknowledges.

**Fail signal**: reviewer concludes "not assigned to me, so not a self-review",
runs the QA on their own work, and self-resolves on the IT-internal path with no
second reviewer.
