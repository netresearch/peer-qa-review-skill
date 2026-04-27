# Changelog

All notable changes to the Peer QA Review skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.5] - 2026-04-27

### Added

- **Two-comment pattern for long reviews** — `references/comment-template.md` now documents when and how to post a TL;DR action-item comment alongside the main structured QA comment. The main comment is the audit trail (complete, written for future readers); the TL;DR is for the implementer who needs to know "do I need to do anything?" in 30 seconds. Includes:
  - Decision table: when to post a TL;DR (always for bounce/won't-do/pass-with-follow-ups, skip for clean passes).
  - TL;DR template: implementer @-mention, one-line verdict, numbered action list, cross-reference to audit comment.
  - Rationale for two comments instead of TL;DR-on-top: keeps the audit-trail header intact and makes the TL;DR the email/Matrix notification preview.

## [0.1.4] - 2026-04-27

### Changed

- Pillar F refinements driven by the fourth NRS-4365 dogfood pass:
  - **F4 split into F4a (structured issue links) and F4b (external URLs)**. Common self-deception caught: a related ticket mentioned in description prose is *not* the same as one linked via the issue-link feature. Always verify against the actual issue-link list, not the description text. F5 merged into F4b.
  - **F6 worklog severity upgraded from `(i)` to `(!)`**. Worklog is part of the audit/billing/capacity trail; missing entries shouldn't be normalised as "merely a hint" because team practice is inconsistent.
  - **New F1.5: Description currency**. Does the description still describe what was actually delivered? Scope shifts, emerged requirements, surfaced constraints belong in the description for future readers, not buried in comments.
- Caught while updating my own NRS-4365 QA comment: I marked F4 as passed because IOT-146 was mentioned in the description, but the structured issue-link list only had NRS-4317 and SRVV-104. Added IOT-146 as a proper Relation link, and updated the runbook so the next reviewer doesn't make the same mistake.

## [0.1.3] - 2026-04-27

### Changed

- Third pass of NRS-4365 dogfood — actually fetched the *rendered* HTML of my own QA comment and found two more issues the runbook didn't flag:
  - **`(-)` token renders as 🚫 (forbidden / no-entry) in Jira, not as "n/a"** — visually misleading. The runbook said `(-) = n/a`, but Jira's actual emoticon mapping is closer to "forbidden". Updated `severity.md`: use literal `*n/a*` text instead of the `(-)` token in Jira. The other tokens render with semantically-correct icons.
  - **Severity tokens in prose render as icons mid-sentence** — `"the (!) finding"` becomes `"the [warning-icon] finding"`, visually confusing. Updated `severity.md` to recommend prose alternatives: "the SHOULD-fix finding" / "the warning above".
- Lesson methodology: the previous two dogfood passes (v0.1.1, v0.1.2) reviewed the *source* of my QA comment. v0.1.3 reviewed the *rendered HTML output*. Source-only review missed the icon-mapping bugs entirely. Worth adding "fetch and read the rendered output" as a sanity-scan step, but Jira-API access isn't universal — leaving as informal guidance.

## [0.1.2] - 2026-04-27

### Changed

- Second NRS-4365 dogfood pass found that my own posted QA comment had several formatting violations the runbook should have caught (display-text link, `{{monospace}}` for commands while attesting to the opposite under Pillar P, transition-name vs verdict mismatch). Folded back as concrete runbook improvements:
  - `references/checklist.md` F7: added a "common violations to scan for in your own comment" note covering display-text-vs-full-URL, `{{monospace}}`-for-commands, and transition-name vs verdict mismatch.
  - `references/comment-template.md`: replaced the static verdict-line template with parameterised guidance that ties the verdict's *literal transition name* to the routing rule. Added a "Sanity scan before posting" section listing the common self-introduced bugs.

## [0.1.1] - 2026-04-27

### Changed

- `references/severity.md` anti-patterns section: added two entries surfaced during the NRS-4365 dogfood.
  - "Using `(x)` for reviewer-side limitations" — e.g. "I can't SSH to the host"; that's a reviewer-access gap, not a blocker on the ticket. Per `edge-cases.md` A, use `(!)` or `(i)`.
  - "Internal inconsistency" — declaring "all must-haves pass" while a `(x)` is present elsewhere in the comment. Re-read your own comment before posting.

## [0.1.0] - 2026-04-27

### Added

- Initial skill: SKILL.md entry point + 7 reference files (lifecycle, checklist, severity, comment-template, edge-cases, anti-patterns, frameworks).
- 6-stage Round-1 QA lifecycle: Claim → Discover → Formal → Functional+Inventory → Documentation+Rollback+Communication → Verdict.
- Severity vocabulary based on Atlassian icon set: `(/)` pass · `(x)` blocking · `(!)` should-fix · `(i)` hint · `(?)` open question.
- Jira-wiki-markup comment template with `h3. IT Internal QA` heading and h4 sections for code-review, functional QA, inventory, documentation, rollback, communication, verdict.
- Edge-case decisions: bounce, won't-do, self-review handoff, unverifiable evidence, sibling-ticket pattern deviation, QA2-vs-internal-resolve routing.
- Frameworks alignment notes (ITIL Post-Implementation Review, Scrum Definition of Done) for credibility, without locking the runbook into any single framework.
- `scripts/qa-gather.sh` thin wrapper around the `jira-communication` skill's `qa-gather.py` for one-call discovery; falls back to multiple calls if the bundled script isn't present.
