# Changelog

All notable changes to the Peer QA Review skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **Self-review guard (`edge-cases.md` §E, anti-pattern #17, `SKILL.md`
  "-1 Claim") now detects self-review from authorship, not the assignee.** On a
  team queue the ticket is worked while Unassigned and self-assigned only at QA
  time, so the assignee never reveals the conflict. §E now decides "reviewer is
  also implementer" from the worklog authors, the `In Progress` transition
  authors, and the implementation / "ready for QA" comment authors, and applies
  even when the ticket is Unassigned.
- **The no-self-review block now covers the terminal verdict on both paths.**
  §E previously named only `QA passed` (QA2), leaving the IT-internal `Resolve`
  path uncovered, so an implementer could self-*resolve* their own work with no
  second reviewer. §E, #17, and "-1 Claim" now forbid self-transitioning to
  `Resolve` *and* `QA passed` until a second set of eyes acknowledges.
- **The self-review guard applies per resolved PR/change, not per ticket**
  (`edge-cases.md` §E, anti-pattern #17). When a ticket bundles several PRs the
  guard holds for each one; a PR the implementer resolved/approved/QA-closed
  themselves is a blocking `(x)` that invalidates that change's QA. If a bundle
  mixes your own PRs with a colleague's, split the verdict.
- **`checklist.md` F1.5**: a description that *contradicts the delivered
  outcome* at resolve time (still frames the work as not-yet-done: in-progress
  status/phase table, unticked boxes for completed work, superseded version) is
  now `(x)`, aligning with §J; `(!)` / `(i)` retained for lesser drift.

### Added

- **Eval E5** (`evals/qa-discipline.md`): self-review on an unassigned queue,
  detect by authorship, do not self-resolve on the IT-internal path.
- **`checklist.md` R7 — functional proof, not config presence.** A set/grepped
  config flag or a green healthcheck is not proof the feature works: trigger it
  end-to-end and attach the evidence. A shadowed/overridden config that still
  "reports healthy" is its own trap — verify the *effective* running config,
  not the health endpoint. Mirrored as anti-pattern #21.
- **Anti-patterns #22–#23**: QA findings are to be worked, not clicked away (a
  verdict with open `(!)` / `(?)` is not "passed"); check the current state
  before proposing a fix (the certificate/router/config may already exist).

## [0.5.0] - 2026-06-18

### Added

- **Separate customer handover comment on QA2** — a QA2 verdict now requires two
  comments: the internal `h3. IT Internal QA` comment (audit trail, addressed to
  IT) and a separate, plain-language **customer handover** addressed to the
  approver, stating what was delivered, the one acceptance check to perform, and
  the next step. The internal QA comment is never handed to the customer as the
  handover. New "Customer handover comment (QA2 only)" template and worked
  example in `comment-template.md`; Stage 5, Output, and Pass-QA2 routing in
  `SKILL.md` and the QA2 routing in `edge-cases.md` updated to match.
- **CI skill-validation workflow** (`.github/workflows/lint.yml`) calling the
  `netresearch/skill-repo-skill` reusable `validate.yml`, closing the gap where
  the pre-commit hooks claimed CI enforcement that did not exist.
- **`.markdownlint-cli2.jsonc`** mirroring the reusable's defaults so the local
  pre-commit hook and CI lint with the same config, and **`.gitignore`**.

### Changed

- **`SKILL.md` trimmed to a lean index** (from 1117 words to within the 500-word
  cap) — all detail already lives in `references/*`; every section is retained,
  including the QA2 customer-handover rule. Restores `validate-skill` to green.

## [0.4.1] - 2026-06-11

### Fixed

- **`(off)` instead of `(-)` for n/a findings** — `(-)` renders as a red forbidden icon in Jira and scans as an error although it marks intentionally skipped checks. `severity.md` already warned about this, but `comment-template.md`'s own examples still used `(-)`; both now consistently use `(off)`.
- **`qa-gather.sh` discovery** — the script searched for `utility/qa-gather.py`, but jira-integration >= 3.13 ships `utility/jira-qa-gather.py`, so discovery always failed on current installs and silently fell back to multi-call mode. Discovery now tries explicit names in preference order with one deterministic `find -type f -print -quit` per name (no `| head` pipeline, no SIGPIPE risk under `set -o pipefail`), and the docs state the actual discovery guarantee.

### Added

- **Paired-icon notation for findings fixed by the reviewer** — issues the reviewer reports *and* fixes during the review are written as `(!) finding — (/) fixed <how> during QA` (or nested with fix evidence on its own line). A bare `(/)` hides that the issue existed; a bare `(!)` reads as an open should-fix and skews the verdict (`severity.md`, `comment-template.md`).
- **Sparse praise icons and optional 1-5 star rating** for review verdicts (`severity.md`).
- **Display-text shorthand for pipelines and jobs** in the link conventions (`comment-template.md`).
- **Sanity-scan items 7-9** — escape literal block-markup tags in prose (`\{code\}` — block tags are never inline and would swallow the rest of the line), link referenced attachments with `[^filename]` instead of bare filenames, and use paired icons plus `[shorthand|url]` links on every MR/commit/repo named in a finding (`comment-template.md`).

### Changed

- **F1.5 (description currency) names the concrete drift artifacts** — unticked task checkboxes for completed work, outdated status/phase tables, and superseded version strings (`references/checklist.md`).

## [0.4.0] - 2026-05-28

## [0.2.0] - 2026-04-27

First matured release after the initial dogfood loop on NRS-4365. The 0.1.x series was a rapid-iteration cycle (each round catching a different class of bug); 0.2.0 consolidates the stable result.

### Highlights since 0.1.0

- **Stronger severity vocabulary** — explicit anti-patterns including "do not use `(x)` for reviewer-side limitations" and "internal inconsistency between findings list and verdict" (`severity.md`).
- **Sanity-scan step** before posting — re-read your own QA comment for severity inconsistencies, F7 violations, transition-name vs verdict mismatches, and Pillar P attestations contradicted by the comment itself (`comment-template.md`).
- **Jira-specific rendering rules** — `(-)` renders as 🚫 forbidden, not "n/a"; severity tokens in prose render as icons mid-sentence; both call out in `severity.md`.
- **Pillar F refinements** — F4 split into F4a (structured issue links via the issue-link feature, verified against the API not description prose) and F4b (external work artefacts); F6 worklog upgraded `(i)` → `(!)` (audit/billing/capacity is not a courtesy); new F1.5 description currency (does the description still describe what was actually delivered?).
- **Two-comment pattern** for long reviews — the structured comment is the audit trail; an optional TL;DR addressed to the implementer with `[~username]` mention and numbered action items keeps actionability visible without burying the audit-trail header (`comment-template.md`).
- **List format for pillar findings** — bulleted lists (`*` / `**`) instead of bare severity-icon lines, for proper wrap-indent of long findings (`comment-template.md`).
- **GitHub / GitLab shorthand** for trusted shared-namespace projects — `owner/repo#123` (GitHub issue or PR), `group/project!456` (GitLab MR), `group/project@sha` (commits). In Jira, wrap as `[shorthand|url]` for clickability with shorthand-as-display-text (this is *not* the display-text-link anti-pattern; opaque display text was the original target). On GitHub/GitLab, the bare shorthand auto-links natively.
- **Methodology lesson** — every iteration round caught a different *class* of bug. Source-only review consistently misses what's only visible in the rendered output. When possible, fetch and look at the rendered HTML before declaring done.

### Internal links

- `references/severity.md` — full vocabulary, anti-patterns, examples
- `references/checklist.md` — every check by pillar (F1–F8, R1–R6, I1–I4, D1–D4, B1–B3, C1–C3, P1–P6)
- `references/comment-template.md` — comment template, link conventions, list format, two-comment TL;DR pattern, sanity scan

## [0.1.7] - 2026-04-27

### Changed

- **Prefer GitHub / GitLab shorthand over full URLs** for trusted shared-namespace projects. New "Link conventions" section in `references/comment-template.md` and updated F4b in `references/checklist.md`:
  - Repo: `owner/repo` (GitHub) · `group/project` (GitLab)
  - Issue: `owner/repo#123` · `group/project#123`
  - PR / MR: `owner/repo#456` (GitHub uses `#` for both issues and PRs) · `group/project!456` (GitLab `!` for MRs)
  - Commit: `owner/repo@7c12680` · `group/project@7c12680`
  - Branch / pipeline / release / tag: full URL (no clean shorthand)
- Same logic as why we already use bare `NRS-4365` instead of full Jira URLs: shorter, more scannable, project-context inline. Trade-off: shorthand is not auto-linked in Jira (acceptable for internal team comms; auto-linked natively on GitHub/GitLab).
- Verified: GitLab's `!` in `group/project!456` does not trigger Jira's image-macro (`!filename!` requires closing `!`). No escape needed.

## [0.1.6] - 2026-04-27

### Changed

- **Format pillar findings as bulleted lists, not bare severity-icon lines** — `references/comment-template.md` now mandates `*` / `**` bullet prefixes for findings. Reason: long lines wrap. With bare severity-icon lines (`(/) F1: long text...`), Jira renders `<br/>` and wrap-continuation lands at the left margin under the icon, breaking visual grouping. With formal list items (`* (/) F1: long text...`), Jira renders `<ul><li>` and wrap-continuation aligns under the text — each finding stays visually grouped no matter how long.
- The bullet + severity-icon double-marking concern (`• ✓ F1:`) was overweighted; rendered output is orderly, not busy. Past NR practice splits on this anyway (Sebastian uses `*` lists in NRS-4356, Björn uses bare lines in NRS-4321) — codifying the wrap-indent winner.
- Exceptions documented: prose stays prose for Verdict header, Follow-up narrative, and re-execution explanations under a bullet. TL;DR comments keep `#` numbered lists for actions.

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
