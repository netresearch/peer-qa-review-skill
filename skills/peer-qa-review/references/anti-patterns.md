# Anti-patterns

Things to flag in the implementer's comments. Each item below is `(!)` unless noted.

## Comment hygiene

1. **One giant final comment** instead of one-per-step. Kills the audit trail when work is interrupted; reviewers can't tell what was done when.
2. **`{{monospace}}`** for commands instead of `{code}` blocks. Can't be expanded/collapsed, no syntax highlighting, copy-paste eats whitespace.
3. **Markdown leakage** in Jira: `**bold**`, `# heading`, em-dashes `--`, `[display text](url)`. Renders as literal text.
4. **`[display text|url]`** display-text links. Convention in many NR teams is full URLs — the URL shows where it goes, the text becomes a lie when the link is renamed.
5. **No prompt context in `{code}` blocks**: just bare output. The reader can't tell which host or container the command ran in.
6. **Mixing implementer and reviewer voice in one thread** without clear `h3.` headings to separate concerns.

## Evidence quality

7. **Tag without pipeline** — release tag pushed but CI was red, skipped, or not run. The tag claims "this version exists and works"; without green CI, the second half is unsupported. `(x)` if no other evidence; `(!)` if other verification is present.
8. **Inventory bulk-updated at end** instead of immediately after each component. If the work is interrupted, the inventory state is wrong — and the audit trail of *when* each component reached the new version is lost.
9. **No console-output audit trail** for a key irreversible action. Tmux, `script(1)`, terminal recording, pasted blocks — all acceptable. None is not. (Required only for irreversible / multi-step actions, not single-line edits.)
10. **Stale verification output** — implementer captured output once at start of work, never re-ran after the final commit. Reviewer should re-run anyway, but the implementer's stale output is misleading and should be flagged.
11. **Verification commands that don't actually verify the fix** — running `systemctl status` when the bug was about a config-reload race, for example. The command runs cleanly but doesn't exercise the failing scenario.

## Reviewer anti-patterns

12. **Copy-pasting implementer's output** instead of re-running. This is not QA — this is *re-reading*. R-pillar checks require fresh output. Subtler variant: **reasoning a FAIL away** — a verifier reports FAIL and you dismiss it as an "environment artifact" or "known false-positive" *without re-probing*. A FAIL you believe is spurious is still a FAIL until a **precise independent probe** disproves it; present the re-probe evidence, not the reasoning. Sibling cross-check: when QAing a batch, if N-1 items pass an identical probe and one FAILs, the outlier is a real finding, not noise. (Caught in an offboarding batch where a coarse verifier's `AD` FAIL was nearly dismissed as a regex false-positive — a precise re-probe surfaced a live Domain-Admin account for a departed employee.)
13. **Inflating `(x)` to look thorough** — only use blocking severity when the ticket genuinely cannot resolve. Over-bouncing wastes everyone's time. (`severity.md`)
14. **Reviewing in pieces across many comments** instead of one structured QA comment. Hurts auditability — pillars get scattered, the verdict is unclear.
15. **Quoting the entire implementer comment back at them** in the QA comment — wastes space. Reference by date/author/section if you must.
16. **Missing the verdict line** — every QA comment must end with one of: *Ready to transition to QA passed* / *Ready for customer acceptance (QA2)* / *Bouncing to In Progress* / *Resolving as Won't-do*. No verdict = unclear next action.

## Process

17. **Self-review** — see `edge-cases.md` E. The reviewer can't be the implementer. If forced, document the constraint and flag for asynchronous sanity check.
18. **QA2 routing skipped for customer-affecting work** — if the change touches customer-visible state, it must go to customer acceptance, not internal-resolve. Defaulting to QA2 when uncertain is the right call.
19. **No follow-up ticket for structural `(!)` items** — if a should-fix is genuinely structural (architecture, naming, recurring pattern), document it AND file a follow-up. Otherwise it's lost.
20. **Resolving without checking sibling tickets** — when this ticket is one of N parallel tickets, the others may have caught issues this one missed. A 30-second sibling spot-check is cheap insurance.
