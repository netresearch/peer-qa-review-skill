# Evals — QA discipline (stub)

TDD-style behavioural evals for the QA-discipline guidance added in
`checklist.md` (Pillar R, Pillar F F1.5), `edge-cases.md` (§E, §J), `lifecycle.md`
(Stage 5 "Assignee on exit"), and `batch-review.md`. Each scenario states the situation, the input
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
- On pass, reviewer unassigns the ticket back to the team queue, verifying the
  assignee actually cleared — a Resolve transition may leave it set, in which
  case the fix is to clear the field, **not** to transition further.
- On bounce, the implementer is the assignee.

**Fail signal**: a passed/resolved ticket is left assigned to the reviewer; or
the reviewer reaches a terminal status the pass did not call for in order to
get a screen that clears the field.

## E3b — Obey the transition's own field spec

**Situation**: on pass, the transition list from `QA` offers two entries whose
labels differ only by emoji (`✅ QA` → Resolved, `❌ QA` → Reopened). The resolve
transition declares **no fields**; the ticket's resolution is empty. A different
transition from the same status, to Closed, declares `resolution` as required.

**Input**: the transition list **expanded with its fields**
(`?expand=transitions.fields`), plus the post-transition state.

**Expect**:
- The reviewer reads the field spec before transitioning, and supplies exactly
  the fields the chosen transition marks `required` — nothing more.
- The reviewer selects the transition by the **id** from the expanded listing.
  Neither the label nor the target status is a safe selector — both can name
  more than one transition, and those lead to different places.
- The post-transition status is asserted to be **Resolved**, not `Reopened` —
  the target is the check on the outcome, never the handle used to get there.
- The empty resolution is left empty, because the transition did not ask for it.
  The reviewer does not reason from the status name, from another project's
  behaviour, or from a remembered convention.

**Fail signal**: the reviewer transitions without ever reading the field spec; or
transitions by ambiguous label; or walks the ticket to a further status
(typically Closed) for the sole purpose of reaching a screen that accepts a
resolution, adding status changes the review did not require. Deciding from a
remembered per-project convention counts as a fail even when the outcome happens
to be right — the transition was available to be asked.

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

## E6: Description contradicts the delivered outcome → (x) at resolve (F1.5)

**Situation**: at the verdict step the work is done and verified, but the
description still frames the ticket as not-yet-done: an in-progress status/phase
table, task boxes unticked for completed work, or a version string the deploy has
superseded.

**Input**: reviewer reaches the F1.5 check / verdict.

**Expect**:
- Reviewer records F1.5 as `(x)` (blocker), not a waved-through `(!)`, because the
  canonical record contradicts what shipped (same principle as §J), and does not
  resolve until the description is folded to match the delivered scope.

**Fail signal**: reviewer flags the stale description as a `(!)` should-fix and
resolves anyway, leaving the description contradicting what was delivered.

## E7: Time booked into the wrong system of record (Stage 5)

**Situation**: the team books time in a dedicated time tracker that syncs its
entries into the ticket system. The ticket system's CLI also exposes an
"add worklog" command.

**Input**: reviewer reaches the Stage 5 "Log your QA time" step.

**Expect**:
- Reviewer establishes which system owns time *before* booking, and books there.
- Reviewer does **not** reach for the ticket system's worklog command because it
  is the closest tool to hand.

**Fail signal**: the review is booked directly onto the ticket, duplicating the
entry the tracker syncs in later — a double-booking that is hard to spot
afterwards because both entries look alike.

## E8: Quoted output is not reconciled with the attached log (F3b)

**Situation**: the implementer pasted a `{code}` excerpt (a run recap, an exit
code, an image digest) *and* attached the full session log it came from.

**Input**: reviewer reaches the F3 evidence check.

**Expect**:
- Reviewer opens the attachment and reconciles the load-bearing values in the
  excerpt against it, then states in the QA comment that the two agree.

**Fail signal**: reviewer records F3 as `(/)` because output "is present",
treating a hand-copied excerpt as equivalent to the artefact it was copied from.

## E9: Surprising probe graded without a control (Pillar G)

**Situation**: a reachability or behavioural probe returns something that looks
wrong — a 404, a default certificate, an empty result — on the thing the ticket
just changed.

**Input**: reviewer must assign a severity to it.

**Expect**:
- Reviewer runs the identical probe against a sibling whose state is already
  known, and grades the finding from the comparison.
- The comparison appears in the QA comment as rows, not as the claim "behaves
  like its peers".
- Where the control shows the result is the baseline, it is recorded as `(i)`
  context, not `(x)` against this ticket.

**Fail signal**: reviewer either bounces the ticket on a result that is normal
for every peer, or waves it through as "probably expected", in both cases from a
single uncontrolled probe.

## E10: Batch of N tickets → agents draft, reviewer posts (`batch-review.md`)

**Situation**: sixteen maintenance tickets sit in QA at once. The reviewer
fans the evidence-gathering out to five sub-agents, grouped by component
(2–4 tickets each). One agent's draft carries a `(x)` "CHANGELOG regressed"
claim and a `(?)` about a host's reachability; another agent goes idle
without reporting, its review files already on disk.

**Input**: reviewer runs the batch from Stage -1 through Stage 5.

**Expect**:
- Reviewer claims **all** tickets under their own account and gathers every
  Stage-0 bundle into files *before* any agent starts; agents read files and
  run read-only probes only.
- Every agent reads a written briefing first (READ-ONLY, re-run, evidence per
  claim, F1.5 line, deliverables, never post/transition).
- Reviewer re-runs the load-bearing probe behind the `(x)` personally
  (`git show <tag>:CHANGELOG.md | grep -c …`) before the verdict, settles the
  `(?)` with their own probe or downgrades it to `(!)` with the reason, and
  posts **no** `(?)`.
- Reviewer reads the idle agent's deliverable files instead of waiting or
  re-spawning.
- Reviewer posts each main comment first and the TL;DR only on success
  (`&&`), performs every transition and assignee change themselves, logs the
  review time once for the batch, and ends with zero agent processes and no
  clones or scratch files left behind.

**Fail signal**: an agent posts or transitions; a `(?)` or an un-re-measured
`(x)` reaches a posted comment; a TL;DR is posted after a rejected main
comment (`;` chain); "idle" is read as "no findings"; agent processes or
clones outlive the batch; the batch is booked once per ticket instead of once.
