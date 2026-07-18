---
name: peer-qa-review
description: "Use when reviewing a teammate's completed work as Round-1 IT QA (before customer acceptance / QA2 / internal close). Triggers: tickets moved to QA, 'ready for QA' / 'ready for review' comments, or requests for 'IT QA review' / 'peer review' / 'internal QA' / 'quality gate'. Covers a 6-stage lifecycle, severity vocabulary, comment template, edge cases, anti-patterns. Generic for any IT/Ops team."
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires a ticket system (Jira tested) and shell access. Companion: jira-communication skill."
metadata:
  author: Netresearch DTT GmbH
  version: "0.5.3"
  repository: https://github.com/netresearch/peer-qa-review-skill
allowed-tools: Bash Read Write Edit
---

# Peer QA Review (Round 1)

A teammate marked work **ready for QA**. Verify before it reaches customer
acceptance, QA2, or close: re-run verification; check formal correctness,
inventory, docs; post a structured comment; transition. Not rubber-stamping;
detail in `references/`.

## When it applies

Triggers: see description. **Skip** if: still In Progress (transition
first); already QA2 (different scope); already closed (post-mortem only); or you
are the implementer (no self-review; per-PR, §E).

A ticket-system skill is required (Jira: `jira-communication`) for Stage 0
discovery. Consult maintenance skills for overrides.

## Lifecycle

- **-1 Claim**: team queue, self-assign to *claim* only (clear on exit, see
  routing); someone else's, stop; never self-review, by authorship not
  assignee (`edge-cases.md` §E).
- **0 Discover**: `scripts/qa-gather.sh <KEY>` (`--json` to parse).
- **1 Formal** (description, linkage, console-output, worklog); **2 Functional,
  Inventory, Guardrails** (re-run; update inventory; check adjacent components,
  shared-layer downstream, default path); **3 Docs, Rollback, Communication**.
- **4 Verdict** (routing below); **5 Comment, Transition, Worklog**: internal QA
  comment; on QA2 also a customer handover.

## Severity icons

Reuse the Atlassian set. `(/)` passed; `(x)` MUST/blocking (bounce); `(!)`
SHOULD (document, follow-up if structural); `(i)` hint; `(?)` open question
(block); `(off)` n/a (never `(-)` or `*n/a*`).

## Output

One internal QA comment: header `h3. IT Internal QA`, h4 section per pillar,
severity icons, a verdict line.

**On a QA2 verdict, post a second, separate comment: the customer handover.**
The internal QA comment is addressed to IT and never states the acceptance
check, leaving the approver lost. The handover is plain (no jargon or icons):
what was delivered, the one acceptance check, the next step.

## Verdict routing

- **Pass, resolve**: all `(x)` clear, IT-internal; QA to Closed/Done, then
  clear your assignment — Resolve often leaves the assignee set; Close clears it.
- **Pass, QA2**: all `(x)` clear, customer-affecting; post the QA comment **and**
  a customer handover; QA to QA2, assign the product owner.
- **Bounce**: any `(x)`; QA to In Progress, comment the blocker, reassign.
- **Won't-do**: blocking external prerequisite; document, file a follow-up,
  resolve Won't-do with a reopen condition.

When uncertain, default to QA2.

## Anti-patterns

The cardinal one: **no re-execution by the reviewer** — copy-pasting the
implementer's output is not QA. Others (giant final comments, Jira Markdown
leakage, end-of-run inventory, tags without a green pipeline) in
`references/anti-patterns.md`.

## References

`references/lifecycle.md`, `references/checklist.md` (checks by pillar);
`references/severity.md`; `references/comment-template.md` (template, examples,
customer handover); `references/edge-cases.md` (QA2 routing, bounce, won't-do,
self-review); `references/anti-patterns.md`.
