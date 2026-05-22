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

## Stage 0: Discover

One call to gather all reviewer-relevant context. With `jira-communication` installed:

```bash
${CLAUDE_SKILL_DIR}/scripts/qa-gather.sh <ISSUE-KEY>
```

Returns: issue + description + comments + worklog + issue links + remote/web links + URLs extracted from description and comments (merge_request, pull_request, pipeline, commit, tag, release, issue_link) + sibling tickets in the same project (60-day window, summary-token overlap).

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

Optional addendum comments are fine for separable concerns (e.g. a separate Confluence-runbook review). Keep the main verdict comment self-contained.
