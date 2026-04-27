# Comment Template

One structured comment at the end of QA. Use Jira wiki markup. Optional addendum comments for separable concerns. For long reviews with action items, also post a *TL;DR action comment* — see the bottom of this file.

## Format pillar findings as bulleted lists

Use `*` (or `**` for sub-items) at the start of each finding line — *not* bare lines with severity-icon prefixes.

**Why**: line-wrap. Findings often run long (multiple linked tickets, file paths, command output references). On bare severity-icon lines, the wrap continuation lands at the left margin, under the icon, which is hard to scan. With formal list items, Jira's `<li>` indent makes wrap continuation align under the *text*, not the bullet — so each finding stays visually grouped.

```jira
h4. Formal correctness
* (/) F1: Description has clear acceptance criteria
* (/) F4a: Structured Jira issue links:
** NRS-4317 — parent, Closed
** IOT-146 — VM inventory, In use
** SRVV-104 — related, Closed
* (!) F6: No worklog entries — should-have per audit/billing/capacity
```

Renders as a properly nested `<ul>` with bullet, severity icon, and indented sub-items. Long lines wrap under the text.

**Avoid the bare-line style** for pillar findings:

```jira
h4. Formal correctness
(/) F1: Description has clear acceptance criteria...
(!) F6: No worklog entries — long line that will wrap...
```

This renders with `<br/>` between items; long lines wrap to the left margin, under the icon, breaking visual grouping.

**Exceptions** — keep prose paragraphs (not lists) for:

- The Verdict header sentence ("All must-have checks pass.")
- The Follow-up section narrative
- Re-execution / unverifiable-evidence explanations that follow a finding (the explanation is a paragraph under the bullet, not its own bullet)
- The TL;DR comment uses **numbered** `#` items, not `*` — actions deserve sequence.

## Template

```jira
h3. IT Internal QA — {passed | failed | won't do}

h4. Formal correctness
(/) Description has clear acceptance criteria (N numbered tasks)
(/) Implementer comments document each step with command+output
(/) Linked: {parent}, {MR/PR}, {inventory ticket}
(!) {finding}
(i) {hint}

h4. Functional verification
{code:bash}
{reviewer-run command + fresh output — not copy-pasted from implementer}
{code}
(/) {scenario re-run, succeeds}
(/) Pipeline {N} for {tag}: success
(/) Tag {v} exists on merge {sha}

h4. Inventory / linked artefacts
(/) {inventory ticket}: updated to {new value}
(!) {discrepancy}

h4. Documentation
(!) {README / meta / runbook discrepancy}
(i) {improvement hint}

h4. Rollback / backout
(/) Snapshot taken before change: {evidence}
(/) Backout path documented: {how}

h4. Communication
(-) n/a — internal-only change   |   (/) Announced in {channel}   |   (!) Customer-affecting; no announcement found

h4. Process compliance
(/) Comments in {code} blocks throughout
(/) Inventory updated immediately
(i) {minor compliance hint}

h4. Verdict
(/) All must-have checks pass.
(!) N should-fix items: {brief list}
(i) M hints for next time: {brief list}

Ready to {transition-name-from-your-system}.
```

The **verdict line** must match your ticket system's actual transition name *and* the routing rule. For example, in a system where "QA passed" transitions to a customer-acceptance status, do not write "Ready to transition to QA passed" if the verdict is "internal-resolve" — that's a contradiction. Use the literal transition name that matches the routing decision (e.g. "Resolve" for internal-resolve, "QA passed" only when the next stop really is customer acceptance).

Keep it tight. Skip pillars that don't apply (e.g. omit "Communication" if `(-)` n/a). Don't pad with `(/)` for every check — list `(/)` items only when they're load-bearing or non-obvious.

## Sanity scan before posting

Re-read your own comment before clicking *Add*. Common self-introduced bugs:

1. **Severity inconsistency** — declaring "all must-haves pass" while a `(x)` is present elsewhere. Scan for `(x)` first; if any, the verdict must be Bounce or Won't-do.
2. **Reviewer-side limitations marked `(x)`** — "I couldn't SSH" is `(!)` or `(i)`, not `(x)`. See `severity.md`.
3. **F7 violations in your own comment** — display-text links where convention is full URLs, `{{monospace}}` for commands when convention is `{code}` blocks, Markdown leakage (`**bold**`, `# heading`).
4. **Transition-name vs verdict mismatch** — the verdict's *meaning* and the *literal transition name* must agree (see above).
5. **Pillar P claims vs actual content** — if your P-pillar says "comments use `{code}` blocks" while your comment uses `{{monospace}}` for commands, that's the very contradiction the runbook is meant to prevent.

## Example 1 — Pass (NRS-4365 shape)

```jira
h3. IT Internal QA — passed

h4. Formal correctness
(/) Description has clear acceptance criteria (4 numbered tasks)
(/) Implementer comments document each step with command+output
(/) Linked: NRS-4317 (parent), MR !9 (role), MR !315 (consumer)
(!) No CHANGELOG entry for v1.7.7 — minor, team-wide pattern
(i) No worklog logged

h4. Functional verification
{code:bash}
ssh exocortex.nr 'systemctl is-active vault && vault status | head -3'
active
Sealed             false
Version            2.0.0
{code}
(/) Vault active and unsealed on exocortex.nr (re-checked just now)
(/) Pipeline 204129 for v1.7.7: success
(/) Tag v1.7.7 exists on merge 95f7770

h4. Inventory / linked artefacts
(/) IOT-146: nothing to update (ticket is about ansible role, not host inventory)
(!) meta/main.yml platforms still lists only bookworm — should add trixie

h4. Documentation
(!) README "Currently supported platforms" still says Debian 12 only
(i) Adding a debian13 scenario to molecule would have caught this in CI

h4. Rollback / backout
(/) Single-line template change; rollback = revert tag bump in requirements.yml + re-run ansible. Documented implicitly via git history.

h4. Communication
(-) n/a — internal-only change to internal infrastructure

h4. Process compliance
(/) Comments in {code} blocks throughout
(i) No tmux session attached — single-host single-template change, below the threshold

h4. Verdict
(/) All must-have checks pass.
(!) 2 should-fix items: README + meta/main.yml platform metadata.
(i) 2 hints for next time: molecule debian13 scenario, CHANGELOG entry.

Ready to transition to QA passed.
```

## Example 2 — Bounce

```jira
h3. IT Internal QA — failed

h4. Formal correctness
(x) F3: No console output for the verification step. Implementer comment claims "tested locally, works" but no command/output captured.
(/) Description has clear acceptance criteria

h4. Functional verification
(x) Re-running the verification command on staging fails:
{code:bash}
$ <command>
<error output>
{code}
The fix is not idempotent — second run errors on existing resource.

h4. Verdict
(x) 2 blocking issues. Bouncing to In Progress.

Please:
1. Capture command+output for each verification step (F3).
2. Make the playbook idempotent — second run should be no-op (R3).
```

## Example 3 — Won't-do (NRT-4567 shape)

```jira
h3. IT Internal QA — won't do (blocking external prerequisite)

h4. Why
(x) Container image for 1.2.2 does not exist on ghcr.io.

{code}
docker manifest inspect ghcr.io/netresearch/<component>:1.2.2
no such manifest
{code}

GitHub releases v1.2.1 and v1.2.2 are tagged but no Docker images were published. Only 1.2.0 and latest are on ghcr.io.

h4. Reopen condition
The CI for https://github.com/netresearch/<component> doesn't publish Docker images on release. Reopen this ticket once the GitHub Actions release workflow is fixed and v1.2.2 (or later) images are available.

h4. Follow-up filed
{NEW-TICKET}: fix GitHub Actions release workflow for <component> to publish Docker images.

Resolving as Won't-do.
```

## Two-comment pattern for long reviews

The structured QA comment is the audit trail — complete, traceable, written for future readers. But it's also long. The implementer who just finished the work often needs *one thing*: "do I need to do anything?"

For reviews with **action items** (bounce, won't-do with reopen condition, pass with structural follow-ups), post a **second comment** immediately after the main one — a short TL;DR addressed to the implementer.

When to do this:

| Verdict | TL;DR comment? |
|---------|----------------|
| Pass — clean, no follow-ups | Skip — main comment is enough |
| Pass — with structural follow-ups or backfill asks | Post TL;DR |
| Pass — with `(!)` items the implementer should know about | Post TL;DR |
| Bounce | Always post TL;DR — the implementer needs to know what to fix |
| Won't-do | Always post TL;DR — reopen condition + follow-up ticket |

### TL;DR template

```jira
h3. TL;DR for [~implementer.username] — what needs doing now

Verdict: *{passed | failed | won't do}*. {one-line status of the ticket itself}

# *{action 1}* — {short rationale, link to follow-up ticket if any}
# *{action 2}* — {short rationale}

{Optional: "Nothing here blocks anything. Detail in the full QA review above."
 OR: "Bouncing — fix #1 and re-transition. Detail above."}
```

### TL;DR principles

- **Mention the implementer** with `[~username]` so they get a notification.
- **Lead with the verdict** in one sentence — they want to know if they need to act before reading anything else.
- **Numbered list of concrete actions only** — no severity icons, no pillar references, no quoted findings. Each item should be doable in ≤ 1 sentence.
- **Cross-reference the audit-trail comment** at the end ("Detail above") rather than repeating the analysis.
- **Skip if there's no action**. A clean pass with no follow-ups doesn't need a TL;DR — that just adds noise.

### Why two comments and not one

It's tempting to put the TL;DR at the *top* of the structured comment instead. Don't — for two reasons:

1. The main comment is the *audit trail*. Future readers (next sprint planning, postmortem, similar incident) read it for the analysis, not the actions. A TL;DR on top buries the audit-trail header (`h3. IT Internal QA — passed`).
2. Jira notifications quote the *first* lines of a comment in email/Matrix previews. A separate TL;DR comment makes the action items the preview, which is what the implementer needs.
