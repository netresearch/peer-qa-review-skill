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

## Stage 0: Discover

One call to gather all reviewer-relevant context. With `jira-communication` installed:

```bash
${CLAUDE_SKILL_DIR}/scripts/qa-gather.sh <ISSUE-KEY>
```

Returns: issue + description + comments + worklog + issue links + remote/web links + URLs extracted from description and comments (merge_request, pull_request, pipeline, commit, tag, release, issue_link) + sibling tickets in the same project (60-day window, summary-token overlap).

Reviewing a batch of roughly six or more tickets at once? Claim them all (Stage -1) and gather them all into files *before* fanning the probes out to sub-agents — `batch-review.md` has the sequence, the briefing template, and what never leaves the reviewer (posting, transitions, verdicts).

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

## Stage 5: Comment + Transition

One structured comment per template (`comment-template.md`), then transition the ticket:

| Outcome | Transition |
|---------|------------|
| Pass — resolve | QA → Closed/Done |
| Pass — QA2 | QA → QA2 (or equivalent customer-acceptance status) |
| Bounce | QA → In Progress, re-assign to implementer |
| Won't-do | QA → Closed with resolution "Won't Do" + reopen condition |

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
