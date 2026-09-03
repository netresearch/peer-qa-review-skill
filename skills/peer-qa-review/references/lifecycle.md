# Lifecycle

The 6-stage Round-1 IT QA lifecycle. Stages are sequential — do not skip or reorder them.

## Stage -1: Claim the ticket

The QA queue is normally a **team queue** with no assignee. Reviewer self-assigns and continues.

| Current assignee | Action |
|------------------|--------|
| Unassigned | Claim (assign to me) and continue |
| Someone else | Stop — in flight by another reviewer |
| Me, from a prior implementation phase | Stop — cannot self-QA. Hand off to another teammate. See `edge-cases.md`. |
| Me, from a prior abandoned QA attempt | Continue |

Every row in that table compares the current assignee against **you**, so resolve both before deciding — and resolve them by *asking the ticket system*, not by inferring. Your own account name is a lookup (`jira-communication`: `jira-user.py me`), not something to reconstruct from git config, a shell environment, or a credentials file — those hold a token or a commit identity, which need not match the ticket-system account. Read the current assignee off the ticket the same way: from the Stage-0 bundle if it reports one, otherwise by querying the field directly. Neither value is worth guessing, and both are one call.

The claim is a loan, not ownership: clear your reviewer assignment on a passing verdict — unassign on resolve, hand to the product owner on QA2 (Stage 5, "Assignee on exit").

## Stage -1b: Watch the queue, and treat a fired event as work

Applies whenever the review happens inside a live window rather than after it.

Arm a watcher on the epic's children **when the window opens**, not once you get
round to it. And handle what it says: a watcher whose events you absorb is worse
than none, because you stop looking while believing you are covered.

Measured on one window: the watcher was armed 3h45m in, fired twice with exactly
the two transitions it existed to catch, and both were passed over in silence —
the next reply after each was about something else. It then timed out with two
hours of window left and was never re-armed. In between, a status table went out
with three wrong rows.

Two rules, both cheap:

- **A fired event is a work item.** Either act on it, or say in the next reply
  that you are deferring it and why. Absorbing it silently is the failure.
- **`Monitor timed out` is not an end state.** Re-arm it or say the queue is now
  unwatched. A watcher that expires quietly leaves you more confident and less
  informed than having none.

## Stage 0: Discover

One call to gather all reviewer-relevant context. With `jira-communication` installed:

```bash
${CLAUDE_SKILL_DIR}/scripts/qa-gather.sh <ISSUE-KEY>
```

Returns: issue + description + comments + worklog + issue links + remote/web links + URLs extracted from description and comments (merge_request, pull_request, pipeline, commit, tag, release, issue_link) + sibling tickets in the same project (60-day window, summary-token overlap).

Reviewing more than one ticket, or reviewing while other work is in flight? **Open `batch-review.md` before starting** — not as a pointer for later. Claim them all (Stage -1) and gather them into files *before* fanning the probes out to sub-agents; that page has the sequence, the briefing template, the single worklog entry per batch, and what never leaves the reviewer (posting, transitions, verdicts). Its fan-out threshold is reviewer wall-clock, not ticket count: three reviews inside a live window qualify. Listing the page without reading it is how a three-ticket review became 151 inline tool calls while the window room stayed silent.

If your team has internal skills for the ticket system / inventory / runbook, they may chain in additional context — consult them.

## Stage 1: Formal correctness

Verify the **ticket itself** is reviewable. See `checklist.md` items F1–F8.

Output: a list of `(/) (x) (!) (i)` items. If F1 (acceptance criteria absent) is `(x)`, you cannot proceed — bounce immediately.

## Stage 2: Functional resolution + Inventory + Guardrails

Verify the **reported problem is fixed**. The reviewer **re-executes** the implementer's verification commands themselves — do not copy-paste the implementer's output. Include fresh `{code}` blocks in the QA comment.

Then verify the change didn't break what the ticket didn't mention: adjacent components, shared-layer downstream consumers, and the unchanged default path of any flag/config touched.

See `checklist.md` items R1–R6 (functional), I1–I4 (inventory), and G1–G3 (guardrails).

For maintenance-style tickets, also run any component-specific QA scripts (e.g. a `gitlab-qa.py` style check) if your team's maintenance skill provides one.

## Stage 3: Documentation + Rollback + Communication

Three smaller pillars combined into one stage:

- **Documentation** (D1–D4): README / role-meta matches reality, runbook reviewed for staleness, CHANGELOG entry where applicable.
- **Rollback / backout** (B1–B3): snapshot or backup taken before risky change, backout path documented and reachable.
- **Communication** (C1–C3): for customer-affecting / org-wide / security-relevant changes — announcement posted (Matrix / Slack / email / blog).

C1–C3 are **conditional**: many internal tickets need no announcement. The check is whether one is *needed and missing*, not whether one is universally present.

## Stage 4: Verdict

Pick one outcome:

| Outcome | When |
|---------|------|
| **Pass — resolve** | All `(x)` clear, IT-internal scope |
| **Pass — QA2** | All `(x)` clear, customer-affecting |
| **Bounce — In Progress** | Any `(x)` |
| **Won't-do** | Blocking external prerequisite missing |

Decision rules: `edge-cases.md`.

## Stage 5 budget: a passed review writes ONE status change

A Round-1 pass moves the ticket once. That is the whole write.

This caps **status changes**, nothing else: clearing your assignment and booking
your review time are still required (see "Assignee on exit" and "Log your QA
time" below). Anything beyond one status change needs the ticket owner's
agreement first, and *"the field I wanted is not on this screen"* is never a
reason: the transition's own screen decides what it needs, and reaching a
different screen is not a fix. Measured: two of a colleague's finished tickets
took **twelve**
status changes between them where two were needed, because a missing resolution
was read as a defect and chased across screens, then reversed after the operator
objected. Both tickets now carry that churn in their history permanently.

If you believe more than one change is needed, that belief is the thing to
check first.

## Stage 5: Comment + Transition

One structured comment per template (`comment-template.md`), then transition the ticket:

| Outcome | Transition |
|---------|------------|
| Pass — resolve | QA → the project's terminal reviewed status, usually **Resolved** |
| Pass — QA2 | QA → QA2 (or equivalent customer-acceptance status) |
| Bounce | QA → In Progress, reassign to implementer |
| Won't-do | QA → Closed with resolution "Won't Do" + reopen condition |

### Read the transition list; do not transition by label

Two things bite here, and both are invisible until they have already happened.

**A label can name two transitions.** From one status, `✅ QA` and `❌ QA` may
differ only by emoji and lead to opposite places — Resolved and Reopened. Pass
the **target status** (or the numeric transition id), never the bare label.

**Where the resolution is set is the project's business, not the reviewer's.**
Some workflows set it on the way *into* QA, so a ticket already reads Done while
it waits for review; others populate it at the resolve step; others leave it
empty until a later ceremony closes the ticket. A missing resolution on a passed
ticket is therefore not automatically a defect — check the project's convention
before treating it as one. **Never invent an extra status change to populate a
field**: walking a ticket to Closed to reach a resolution screen rewrites its
history for a field that may have been fine as it was.

**Assignee on exit** — the Stage -1 self-assign was only to *claim* the review; clear it on the way out so a passed ticket doesn't keep the reviewer's name as if it were open work:

| Outcome | Assignee |
|---------|----------|
| Pass — resolve | **Unassign** back to the team queue |
| Pass — QA2 | Assign the **product owner** (per routing) — the ticket moves to them, not back to the queue |
| Bounce | Assign the **implementer** — they own the rework |
| Won't-do | Unassign (no further work for the reviewer) |

Gotcha: a **Resolve** transition often does **not** clear the assignee, whereas **Close** does — so a "Resolved but still assigned to me" ticket is the one to clean up. Verify the assignee after a resolve, and unassign explicitly (e.g. set the field to null) if it stuck.

**Log your QA time** — before you transition, book the review against the ticket. Stage 1 already flags a missing *implementer* worklog (checklist F6); the reviewer's own review time is part of the **same** audit / billing / capacity trail, so log it as a closing step rather than waiting to be asked. Cover the actual review work — re-running verification, reading pipelines/logs, root-cause forensics, writing the comment — not just the transition click.

**Book in your team's system of record, and find out which one that is before booking.** Do not assume it is the ticket system. Where a separate time tracker feeds worklogs into the ticket system, the tracker is the system of record and writing a worklog directly onto the ticket **double-books** — the direct entry plus the one the tracker syncs in later. That is a billing error, and it is not always visible on the ticket afterwards, because the synced entry looks identical to the one you wrote. Booking through the wrong end is also awkward to undo: ticket-system CLIs commonly expose "add worklog" without a matching "delete worklog".

So: check your team's convention (an `AGENTS.md`, a team runbook, or the tracker's own docs) for which system owns time, and use that one. This skill deliberately names no command — the right one is team-specific.

Optional addendum comments are fine for separable concerns (e.g. a separate Confluence-runbook review). Keep the main verdict comment self-contained.

**Then close the session, not just the ticket.** The review is finished when `/retro done` (the `retro` skill's seven-gate check — task, findings, retro, cleanup, open questions, tickets, time) reports every row ✅; a review that filed follow-ups (Stage 3) or found friction owes the retro and the booking as much as the verdict comment.
