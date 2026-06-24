# Severity Vocabulary

## The icon set

Reuse the standard Atlassian / Jira-wiki icon set. Do **not** invent new categories — reviewers and implementers should not have to learn fresh vocabulary.

| Icon | Wiki source | Meaning | Action |
|------|-------------|---------|--------|
| `(/)` | `(/)` | verified / passed | none |
| `(x)` | `(x)` | **MUST**: blocking — ticket cannot resolve until fixed | bounce to In Progress |
| `(!)` | `(!)` | **SHOULD**: real issue, non-blocking *for this ticket* | document; create follow-up if structural |
| `(i)` | `(i)` | **HINT**: improvement suggestion / next-time nice-to-have | document; no action required |
| `(?)` | `(?)` | open question for implementer | block on answer |
| `(off)` | `(off)` | not applicable here | none — explicit "we considered this and it doesn't apply" |

In rendered Jira these become coloured icons. In other systems (GitHub, GitLab, Markdown), use the literal strings — they read clearly even unrendered.

**Never use `(-)` or literal `*n/a*` text for "n/a"**: in Jira wiki the `(-)` token renders as a *red* forbidden / no-entry icon, which visually screams "error / blocked / denied" — readers scan it as a failure even though the line lists something that was *considered and intentionally skipped*; and `*n/a*` is just off-vocabulary (bold prose where the icon set has a token for exactly this). Use `(off)` for both (for example, `(off) G2: n/a — reason`), as it renders as a subtle grey switched-off lamp, which reads as "nothing active here" without alarm colour. The other tokens (`(/) (x) (!) (i) (?)`) render with semantically-correct icons.

Also avoid using `(/)`, `(x)`, `(!)`, `(i)`, `(?)` literally in *prose* when you mean to *refer to* a finding by its severity. Jira will render the icon mid-sentence, which is visually confusing. Write "the SHOULD-fix finding" or "the warning above" instead of "the `(!)`".

## How to choose

Ask three questions in order:

1. **Does the ticket fail its acceptance criteria, or actively break something?** → `(x)`
2. **Is it a real issue that should be addressed, but doesn't block this ticket's purpose?** → `(!)`
3. **Is it just a "next time, consider…" suggestion?** → `(i)`

If you can't decide between `(!)` and `(i)`: ask whether the issue would still be worth fixing if the ticket were already closed. Yes → `(!)` (file a follow-up). No → `(i)`.

## Findings fixed by the reviewer

When you report an issue *and* fix it yourself during the review, keep both facts visible: the finding keeps its severity icon, the fix gets a paired `(/)`.

Inline, for one-line fixes:

```jira
* (!) foo bar did not work — (/) fixed <how> during QA
```

Nested, when the fix deserves its own evidence line:

```jira
* (!) foo bar did not work
** (/) fixed during QA: <how>, proved by <link to pipeline/commit/output>
```

Never collapse the pair into a bare `(/)` (the audit trail must show the issue existed and that the reviewer fixed it), and never leave a bare `(!)` standing when it is already fixed (it reads as an open should-fix and skews the verdict).

## Praise and ratings

Developers are humans too — when QA turns up a genuinely *positive unexpected* finding (exemplary docs, communication beyond the bar, a clever guard the ticket didn't ask for), say so with a leading `(y)` (thumbs up), `(*)` (star) or `:)`:

```jira
* (y) Org-wide heads-up published days before the flip, with a grace period for the assigned MRs
```

**Keep it sparse** — one praise line per review at most, and only for above-expectation work. Routine compliance gets `(/)`, not applause; inflationary praise devalues the signal.

Independently, the **closing sentence** of the QA comment may carry a 1–5 star rating of the overall implementation quality, e.g. `(*)(*)(*)(*) (4/5)`. Rough scale: 5 = exemplary, fit as a reference for others; 4 = strong with a minor flaw; 3 = solid standard work; 2 = passed with notable gaps; 1 = barely passed. The rating is optional and never replaces the verdict line.

## Examples from real tickets

### `(x)` — blocking

> *(x) container image for 1.2.2 does not exist on ghcr.io. Cannot deploy without a published image.*
> — NRT-4567, resolved as Won't-do

> *(x) F1: Description has no acceptance criteria. Cannot QA — bouncing to In Progress for clarification.*

### `(!)` — should-fix

> *(!) molecule.yml references requirements.yml but file doesn't exist. Generates warning. Recommend either creating an empty requirements.yml or removing the dependency block.*
> — NRS-4199 QA review (Björn Marten)

> *(!) :latest image tags in CI — components are pinned (@v0.2.0) but Docker images are :latest. A breaking rebuild upstream would silently propagate.*
> — NRS-4356 QA review (Sebastian Mendel)

### `(i)` — hint

> *(i) timezone test missing `when: setup_time` guard. Other feature tests use this pattern — should be consistent.*

> *(i) same cgroup v1 legacy warning as IOT-71 — not blocking, worker runs fine after 30s v2 fallback.*
> — NRS-4240 QA review (Björn Marten)

### `(?)` — open question

> *(?) Was the OPNsense config snapshot taken before the major upgrade? I see the patch-update comment but not a snapshot mention.*

### `(off)` — n/a

> *(off) Communication (C1–C3): change is internal-only (CI image refresh), no announcement needed.*

## Anti-patterns in severity choice

- **Inflating `(x)` to look thorough** — only use `(x)` when the ticket genuinely cannot resolve. Over-bouncing wastes everyone's time.
- **Using `(x)` for reviewer-side limitations** — "I couldn't SSH to the host" or "I don't have access to the staging environment" is *not* a blocker on the ticket. The work might be fine; the reviewer's verification is just incomplete. Per `edge-cases.md` A, document explicitly with `(!)` (limitation worth noting) or `(i)` (limitation, but implementer's evidence is otherwise solid). Reserve `(x)` for things wrong with the *implementation*, not the *review*.
- **Downgrading `(x)` to `(!)` to be polite** — if a fix doesn't actually fix the bug, it's `(x)`. Politeness is in *tone*, not in severity.
- **Using `(!)` for things that aren't issues** — "I would have done this differently" is `(i)` (or no comment at all), not `(!)`.
- **Using `(?)` as a hidden `(x)`** — if you'd bounce regardless of the answer, just bounce. `(?)` is for genuinely unknown.
- **Internal inconsistency** — declaring "all must-haves pass" while still having a `(x)` somewhere in the comment. If you have a `(x)`, the verdict is bounce or won't-do, period. Re-read your own comment before posting.

## Mapping to verdict

- Any `(x)` → **Bounce** to In Progress (or **Won't-do** if the blocker is external).
- All `(x)` clear, some `(!)`/`(i)` → **Pass** (resolve or QA2).
- All clear → **Pass** (resolve or QA2).

`(!)` and `(i)` items are documented in the QA comment but do not block the verdict. If a `(!)` is structural, file a follow-up ticket.
