# Edge Cases

Decisions that don't fit cleanly in the checklist.

## A. The implementer's evidence is unverifiable

Production-only verification, destructive test, only observable during a maintenance window that has now passed. The reviewer cannot re-run R1 / R2.

**Decision**: Treat the implementer's evidence as primary. Document explicitly in the QA comment that re-execution was not possible *and why*. Do **not** silently accept — the explicit note matters for audit.

```jira
h4. Functional verification
(i) Re-execution not possible: the destructive test (data-migration dry-run) has already consumed its input batch.
(/) Implementer's captured output reviewed: the migration completed cleanly, row counts match.
```

## B. Failed prerequisites discovered in QA (NRT-4567 pattern)

The component being updated doesn't exist upstream / can't be deployed / depends on a fix elsewhere.

**Verdict**: Won't-do (not Bounce). The implementer didn't do anything wrong — the world isn't ready for the change.

QA comment must include:

1. **Evidence** the prerequisite is missing (404 from registry, missing tag, broken pipeline).
2. **Pointer** to where the prerequisite must be fixed (which repo / which CI job / which ticket).
3. **Reopen condition** — concrete signal that says "now this ticket can be retried."
4. *Optional but recommended*: file the follow-up ticket and link it.

## C. Sibling-ticket pattern deviation

When parallel tickets share a runbook (multiple host upgrades, traefik updates across a fleet, room-by-room migrations), spot-check that this ticket's evidence pattern matches its siblings.

**Decision**: If this ticket's evidence is *thinner* than its siblings without explanation, `(!)` and ask why. If it's *more thorough*, `(/)` — that's just better work. Pattern *deviations* are the thing to flag, not symmetry.

## D. QA2 vs internal-resolve routing

After QA passes, where does the ticket go next?

| Scope | Route to |
|-------|----------|
| Internal infrastructure (server playbooks, internal tooling, CI components, internal monitoring, dev environments) | Internal-resolve (Closed/Done) |
| Customer-affecting (a customer's hosted instance, customer's domain, hosted services for clients, user accounts, customer-visible config) | QA2 |
| Mixed (touches customer-relevant config but the change is invisible to the customer) | QA2 — err on the side of more eyes |

**When uncertain, default to QA2** and let the product owner / customer-success rep approve.

**On QA2, leave the approver a handover — not just the QA comment.** The internal QA comment is addressed to IT (infra detail, severity icons) and never states the acceptance check, so a customer / product owner lands on it and is lost: they don't know what was delivered or what to confirm. Routing to QA2 therefore means *two* comments — the internal QA comment (audit trail) **and** a separate, plain-language customer handover that says what was delivered, the one check to perform, and the next step. Never hand the internal QA comment over as the handover. Template + worked example: `references/comment-template.md` § "Customer handover comment (QA2 only)".

## E. Reviewer is also implementer

You cannot review your own work. The first-person bias is too strong; even with discipline, you'll miss things.

**Decision**: Hand off to another teammate. If genuinely no other reviewer is available right now:

1. **Document the constraint** in the QA comment explicitly: *"Self-review by implementer due to no available reviewer at <time>. Requesting asynchronous sanity check from <colleague> when available."*
2. **Flag for colleague**: post a follow-up comment / ping in the team channel asking for a real second pair of eyes.
3. **Do not transition** to "QA passed" until at least one other set of eyes has acknowledged the work — even if it's just a `(/)` from a colleague after the fact.

## F. The ticket should not have been put in QA

Common signals: implementation was clearly aborted ("WIP, will continue Monday"), required pre-work isn't done (a dependency ticket is still open), the implementer ticks "ready for QA" while admitting in the same comment that something is missing.

**Decision**: Bounce immediately, no full QA pass needed. Reason in the QA comment:

```jira
h3. Bouncing to In Progress

(x) Pre-conditions for QA aren't met yet:
- {specific signal, e.g. "dependency ticket NRS-1234 is still in progress"}
- {or: "comment from <date> says 'still need to test on staging'"}

Re-transition once {specific condition} holds.
```

## G. Comment thread is too tangled to summarise

Long discussion threads, multiple back-and-forth corrections, side-quests interleaved with main work. Hard to tell what the *final state* is.

**Decision**: Ask the implementer to post a clean summary comment first ("ready for QA — final state: X, Y, Z"). Then QA against that summary, not against the whole thread.

## H. The verdict is "Pass but I'd like an addendum"

When the work passes but you want to flag something separable — a Confluence-runbook update, a side-quest the implementer did along the way, a sibling-ticket inconsistency, a process-improvement suggestion.

**Decision**: Keep the main verdict comment self-contained ("Ready to transition to QA passed"). Post a *separate addendum comment* with `h3.` heading like *"QA addendum: Confluence docs"* or *"QA addendum: side-quests"*. This keeps the audit trail clean and lets the team find the addendum later by topic.

## I. The audit trail of console output is missing for a key action

Implementer ran something irreversible (data migration, prod deploy, account deletion) but didn't capture the output — only summarised in prose.

**Decision**: Don't bounce automatically — sometimes the action genuinely happened cleanly and a re-run would prove it. Re-run if non-destructive; for genuinely destructive actions, ask the implementer to provide whatever record they do have (terminal scrollback, dashboard screenshot, system logs from the time window).

If nothing exists at all → `(!)` for this ticket plus a process-compliance note in the QA comment, but pass if the action's effects are independently verifiable now.

If nothing exists *and* the effects can't be independently verified → `(x)` and bounce. We don't accept "trust me" for irreversible production changes.
