# Round-1 QA Checklist

All checks, organised by pillar. Apply the severity in the rightmost column when a check fails. See `severity.md` for the full vocabulary.

## Pillar F — Formal correctness

| # | Check | Severity if failing |
|---|-------|---------------------|
| F1 | **Description** has clear, testable acceptance criteria (or numbered Task list) | `(x)` if absent — cannot QA |
| F1.5 | **Description currency**: does the description still accurately describe what was actually delivered? Scope shifts, emerged requirements, surfaced constraints, and important tradeoffs that came up during work should be folded back into the *description* (not buried in comments). The description is the canonical record for future readers. Concrete drift to scan for: task checkboxes still unticked for work that was completed, status/phase tables showing outdated states, and version strings the deploy has since superseded (description claims vX while production runs vY). | `(x)` at resolve time if the description **contradicts the delivered outcome**, i.e. still frames the work as not-yet-done (in-progress status/phase table, unticked boxes for completed work, or a superseded version), same principle as §J; `(!)` if stale and misleading but not contradictory; `(i)` if minor drift |
| F2 | **Implementer-side comments** document each step with `{code}` blocks containing both the command and its output | `(!)` per missing block |
| F3 | **Console output / screenshot** for the actual fix is present | `(x)` if no proof at all; `(!)` if partial |
| F4a | **Structured issue links** — related issues, predecessor, inventory item are linked via the ticket system's *issue-link feature* (not just mentioned in prose). Bidirectional traceability matters: someone navigating from the inventory item should find this ticket. **Verify by querying issue links, not by reading the description**. *Parent Epic / Parent / Sprint are out of scope here — see the "parent-Epic exception" note below.* | `(!)` per missing link |
| F4b | **External work artefacts** — MR/PR, pipeline, registry/release — present in comments or as web/remote links, and reachable. Prefer GitHub/GitLab native shorthand (`owner/repo#123`, `group/project!456`, `owner/repo@7c12680`) over full URLs for trusted shared-namespace projects; full URLs for pipelines, branches, releases, and cross-org links. See `comment-template.md` "Link conventions". | `(!)` per missing or 404 |
| F5 | *(merged into F4b)* | — |
| F6 | **Worklog** present (≥ 1 entry, plausible duration) | `(!)` — should-have. Worklogs are part of the audit/billing/capacity trail; the team has agreed to log work, so missing entries shouldn't be normalised as merely a hint. |
| F7 | **Comment formatting**: ticket-system-native markup (Jira: wiki, not Markdown), no leaking `**bold**`, `# heading`, em-dashes `--` | `(i)` |
| F8 | *(deprecated — replaced by Stage -1 claim)* | — |

Note F1: "acceptance criteria absent" is the one finding you should bounce on without going further. Without criteria, there is no testable bar.

Note F1.5: **record F1.5 explicitly in the Formal section of every QA comment, even when it passes `(/)`.** It is the check most often skipped silently — a reviewer confirms F1 (criteria exist) and moves on without ever asking whether the *summary and description still match what was delivered and whether the scope held*. A silently-skipped currency check reads as "verified" when it wasn't. State the verdict as a bullet (per `comment-template.md` formatting): `* (/) F1.5: summary + description current, scope held`, or the drift finding. If your review is fanned out across sub-agents, require the F1.5 line in each one's output so it cannot be dropped.

Note F4a: don't conflate "mentioned in description prose" with "linked via issue-link feature". A common self-deception is reading the description, seeing `INV-146`, and assuming it must be linked. **Always verify against the actual issue-link list** (Jira: `Issue Links` section / API `issuelinks` array). If a related ticket is mentioned in prose but not linked, that's a `(!)` — and an easy fix (add the link).

Note F4a (reviewer-side): apply the same rule to *your own* QA comment. Every ticket key, MR/PR URL, commit hash, runbook page, or vault entry you mention as a reviewer should also exist as a structural link on the ticket. If the QA comment introduces a *new* reference — typical case: "filed follow-up as NEW-TICKET", "see MR !N", "fixed by commit abc123" — create the structural link (issue link for tickets, web link for external URLs) *before* posting the comment, not after. The inline mention is for narrative; the link is the relationship that survives someone navigating in from the *other* side. Anti-pattern caught the hard way: QA comments referencing a follow-up ticket only inline, leaving the navigation one-way.

Note F4a (parent-Epic exception): the parent Epic lives in Jira's dedicated *Epic Link* custom field, not in the issue-link list. Don't add a redundant `relates to <epic>` issue-link — it duplicates a relationship that Jira already expresses structurally (epic badge in the child, "Issues in Epic" panel in the parent, JQL via `"Epic Link" = EPIC-KEY`). Same exclusion applies to the *Parent* field on sub-tasks (JQL `parent = PARENT-KEY`), the *Sprint* field (JQL `sprint = "Sprint X"`), and any other dedicated Jira-native relationship field. The link-audit rule covers references the implementer/reviewer *introduces*; Jira-built-in structural fields are out of scope.

Note F7: applies equally to **the reviewer's own QA comment**. Common violations to scan for before posting:

- *Display-text links* `[text|url]` when convention is full URLs (or vice versa — match the team's house style).
- *`{{monospace}}` for commands* in prose when convention is `{code}` blocks. Especially galling when the same comment claims the opposite under Pillar P.
- *Transition-name vs verdict mismatch* — e.g. writing "Ready to transition to **QA passed**" when the routing rule for IT-internal scope is **Resolve** (and "QA passed" goes to QA2). The verdict's *meaning* and the *transition name* must agree.

## Pillar R — Functional resolution

The reviewer **re-runs** these. Copy-pasting the implementer's output does not satisfy R-checks.

**Use the matching domain skill, don't hand-roll verification.** When the artefact is domain-specific config that a skill owns (Concourse → `concourse-ci`, Terraform/K8s/Docker → the matching skill, TYPO3 → `typo3-conformance`, etc.), invoke that skill and run its validator and gotcha catalog instead of an ad-hoc parse. A domain skill surfaces SHOULD-issues that a generic syntax check misses — e.g. `concourse-ci` ships `validate-pipeline.sh` and flags a missing `clean_tags: true` on a tag-tracking git resource, which a plain `yaml.safe_load` reports as valid. Re-running by hand is necessary but not sufficient; the domain skill is the authoritative checklist.

**"Already merged/applied" does not make the review moot.** If no review happened before the ticket reached QA, *this* QA is the only and last safeguard — so a full adversarial code review is required even when the MR is already merged and the change is live. Merge status only changes where findings *go* (follow-up MRs instead of pre-merge blocks), never *whether* you review. Do the adversarial pass — read the actual diff, sanity-check the documented commands against the real repo state, look for what the change *wasn't* trying to touch — in round 1, not only after the requester asks for it. Verifying that the stated acceptance criteria pass (verification-grade) is necessary but not sufficient; the adversarial pass is what catches the things the AC never named.

| # | Check | How |
|---|-------|-----|
| R1 | **Re-run the failing scenario** from the original report. Does it now succeed? | Per ticket. Capture fresh output. |
| R2 | **Re-run the implementer's verification commands**, capture fresh `{code}` blocks for the QA comment | Don't trust stale output |
| R3 | **Idempotence** for IaC / config-mgmt: a re-run applies cleanly with `changed=0` (or, if not, the diff is explicable) | Ansible: `ansible-playbook --diff`; Terraform: `tofu plan` |
| R4 | **No collateral damage**: failed services, error-level logs since the change, container health, dependent services | `systemctl --failed`, `journalctl -p err --since '1h ago'`, etc. |
| R5 | **Tag/release exists** where claimed (annotated vs lightweight is `(i)`; missing is `(x)`) | `git for-each-ref refs/tags/<v>` |
| R6 | **CI pipeline** for the merged commit/tag was green | `glab api projects/<id>/pipelines?ref=<tag>` or equivalent |
| R7 | **Functional proof, not config presence** — a set/grepped config flag, a present setting, or a green healthcheck is *not* proof the feature works. Exercise it end-to-end (fire the webhook with a real payload, render and screenshot the output, confirm the role/flag actually takes effect) and attach the evidence to the ticket. A shadowed/overridden config that still "reports healthy" is its own trap — verify the *effective* running configuration, not the health endpoint. | Trigger the feature; capture the evidence |

Severity: each R-check failing on its own is `(x)` for R1–R4 and R7 (the fix doesn't actually work, isn't functionally proven, or breaks something else); `(!)` for R5–R6 (artefacts present but quality flag).

## Pillar G — Guardrails (what the change *wasn't* trying to touch)

The R pillar verifies the change fixed what the ticket said it would. The G pillar verifies it didn't break what the ticket didn't mention. Round-1 QA owns this — by QA2 / customer acceptance the cost of finding it is already too high.

| # | Check | Severity |
|---|-------|----------|
| G1 | **Adjacent components** — name two adjacent components the change could have affected but is not trying to. Spot-check each is unchanged. If you cannot name two, the blast radius is not understood. | `(!)` SHOULD; `(?)` if blast radius unclear |
| G2 | **Shared layer downstream** — if the change is in a shared layer (auth, logging, error handling, DB schema, build config), exercise one downstream consumer end-to-end, not just the changed code. | `(x)` MUST if shared layer; `n/a` otherwise |
| G3 | **Unchanged default path** — if the change touches a config file, env var, or feature flag default, verify the unchanged default path still behaves as before. Don't just test the new branch. | `(x)` MUST |
| G4 | **Every enforcement layer on the path** — if the change alters *how a service is reached* (DNS record, address family, port, protocol, route, hostname), enumerate every layer that filters by source address or identity — packet filter / cloud firewall, reverse-proxy allow-list, application-level IP check, WAF, rate limiter — and confirm each already covers the new path. An open firewall is not evidence a request survives at L7. | `(x)` MUST if reachability changes; `n/a` otherwise |

Severity uses the standard icon vocabulary `(/)` `(x)` `(!)` `(i)` `(?)`. A G-finding that demonstrates a real regression is `(x)` MUST and bounces the ticket. A G-finding that surfaces "I cannot tell if X is affected" is `(?)` and blocks on the answer.

### Common false negatives this catches

- Bugfix touched a shared helper; the helper has three callers and only one was tested.
- New feature flag's "off" path silently flipped because the default changed in code, not in config.
- Schema migration's rollback path was never tested (B-pillar checks the migration; G2 checks a real downstream query against rolled-back schema).
- "Refactored for clarity" changed behavior in an edge case the original test suite didn't cover.
- An AAAA record was published for a dual-stack host whose reverse-proxy allow-list carried IPv4 prefixes only: the name resolves, clients prefer IPv6, and every request is rejected at L7 with no fallback — Happy Eyeballs retries connection failures, not HTTP errors. The cloud firewall was open to `::/0`, which looked like proof the path was fine (G4).

For changes with no plausible adjacent surface (e.g. a typo fix in a comment, a one-line README update), G-pillar may be recorded as `n/a` rather than `(/)`.

## Pillar I — Inventory & related artefacts

| # | Check | Severity |
|---|-------|----------|
| I1 | **Inventory / CMDB** entry updated where applicable (e.g. a "Current Version" custom field for maintenance tickets) | `(x)` for maintenance tickets if missing; `(!)` otherwise |
| I2 | **Linked tickets state**: parent epic moves forward, child tickets are themselves in valid states, inventory issues reflect the change | `(!)` per inconsistency |
| I3 | **Sibling tickets**: if this is one of N parallel tickets (e.g. multiple host upgrades), spot-check that this ticket's pattern matches the others | `(i)` — flag deviation |
| I4 | **Side-quests** (improvements made en passant) are documented as separate sub-headings, not lost | `(i)` |

## Pillar D — Documentation & runbook

| # | Check | Severity |
|---|-------|----------|
| D1 | **README / role meta / module manifest** matches reality (e.g. supported-platforms list reflects what we now run on) | `(!)` |
| D2 | **Internal runbook** (Confluence / wiki / repo doc) reviewed for staleness. Minor → propose update; major → flag in QA comment | `(i)` to `(!)` |
| D3 | **CHANGELOG / release notes** present for tagged releases | `(i)` (often inconsistent across teams) |
| D4 | **AGENTS.md / CLAUDE.md / repo-level docs** updated if the change affects future automation | `(i)` |

## Pillar B — Rollback / backout

| # | Check | Severity |
|---|-------|----------|
| B1 | **Snapshot / backup taken** before risky change (VM snapshot, database backup, config archive). Evidence in implementer's comments. | `(x)` for irreversible production changes without a backup; `(!)` otherwise |
| B2 | **Backout path** documented (which command rolls back, where the prior artefact is) | `(!)` |
| B3 | **Backup retention**: archive accessible / not auto-purged before reasonable verification window | `(i)` |

For purely additive changes (new feature, no data migration, no service disruption), B-pillar may not apply — record as `n/a` rather than `(/)`.

## Pillar C — Communication

Conditional. Apply only when the change has external visibility.

| # | Check | Severity |
|---|-------|----------|
| C1 | **Customer-affecting change** → announcement posted to relevant channel (per-customer Slack/Matrix/email/dashboard) | `(!)` if missed |
| C2 | **Org-wide service downtime / behaviour change** → org channel notified (team Matrix room, email list, internal blog) | `(!)` if missed |
| C3 | **Security-relevant action** (password rotation, ACL change, exposed surface reduced) → security log / ticket / sec-channel notified | `(!)` if missed |

For purely internal, behind-the-scenes changes (e.g. bumping a private CI image), C-pillar is `n/a`.

## Pillar P — Process compliance

For tickets in scope of a maintenance / change-management lifecycle skill (your team's internal one), apply these.

| # | Check | Severity |
|---|-------|----------|
| P1 | **Console-output audit trail** attached or pasted for key actions (deploys, irreversible ops). Tmux, `script(1)`, terminal recording, pasted blocks all count. Required only for irreversible / multi-step actions. | `(!)` if missing for an action that needed one |
| P2 | **Comments use `{code}` blocks** (not `{{monospace}}`) per Jira-wiki conventions | `(!)` per violation |
| P3 | **One comment per logical step** — not one giant comment at the end | `(i)` |
| P4 | **Inventory updates posted immediately** after each component, not bulk at end | `(i)` |
| P5 | **Verbose CI / docker / etc output flags used** inside logs (e.g. `docker compose --progress=plain`) — no animated noise | `(i)` |
| P6 | **Phase / transition rule** of the team's maintenance lifecycle respected (IT-internal vs customer routing) | `(x)` if wrong path taken |
