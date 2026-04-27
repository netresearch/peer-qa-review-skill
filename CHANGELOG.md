# Changelog

All notable changes to the Peer QA Review skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
