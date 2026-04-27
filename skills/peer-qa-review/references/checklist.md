# Round-1 QA Checklist

All checks, organised by pillar. Apply the severity in the rightmost column when a check fails. See `severity.md` for the full vocabulary.

## Pillar F — Formal correctness

| # | Check | Severity if failing |
|---|-------|---------------------|
| F1 | **Description** has clear, testable acceptance criteria (or numbered Task list) | `(x)` if absent — cannot QA |
| F2 | **Implementer-side comments** document each step with `{code}` blocks containing both the command and its output | `(!)` per missing block |
| F3 | **Console output / screenshot** for the actual fix is present | `(x)` if no proof at all; `(!)` if partial |
| F4 | **Linked issues** are present where expected: parent epic, MR/PR, inventory issue, related-bugs, predecessor | `(!)` per missing link |
| F5 | **External references**: MR/PR URL, pipeline URL, registry/release URL — present and reachable | `(!)` per missing or 404 |
| F6 | **Worklog** present (≥ 1 entry, plausible duration) | `(i)` (often inconsistent — should-have, not must-have) |
| F7 | **Comment formatting**: ticket-system-native markup (Jira: wiki, not Markdown), no leaking `**bold**`, `# heading`, em-dashes `--` | `(i)` |
| F8 | *(deprecated — replaced by Stage -1 claim)* | — |

Note F1: "acceptance criteria absent" is the one finding you should bounce on without going further. Without criteria, there is no testable bar.

Note F7: applies equally to **the reviewer's own QA comment**. Common violations to scan for before posting:

- *Display-text links* `[text|url]` when convention is full URLs (or vice versa — match the team's house style).
- *`{{monospace}}` for commands* in prose when convention is `{code}` blocks. Especially galling when the same comment claims the opposite under Pillar P.
- *Transition-name vs verdict mismatch* — e.g. writing "Ready to transition to **QA passed**" when the routing rule for IT-internal scope is **Resolve** (and "QA passed" goes to QA2). The verdict's *meaning* and the *transition name* must agree.

## Pillar R — Functional resolution

The reviewer **re-runs** these. Copy-pasting the implementer's output does not satisfy R-checks.

| # | Check | How |
|---|-------|-----|
| R1 | **Re-run the failing scenario** from the original report. Does it now succeed? | Per ticket. Capture fresh output. |
| R2 | **Re-run the implementer's verification commands**, capture fresh `{code}` blocks for the QA comment | Don't trust stale output |
| R3 | **Idempotence** for IaC / config-mgmt: a re-run applies cleanly with `changed=0` (or, if not, the diff is explicable) | Ansible: `ansible-playbook --diff`; Terraform: `tofu plan` |
| R4 | **No collateral damage**: failed services, error-level logs since the change, container health, dependent services | `systemctl --failed`, `journalctl -p err --since '1h ago'`, etc. |
| R5 | **Tag/release exists** where claimed (annotated vs lightweight is `(i)`; missing is `(x)`) | `git for-each-ref refs/tags/<v>` |
| R6 | **CI pipeline** for the merged commit/tag was green | `glab api projects/<id>/pipelines?ref=<tag>` or equivalent |

Severity: each R-check failing on its own is `(x)` for R1–R4 (the fix doesn't actually work or breaks something else); `(!)` for R5–R6 (artefacts present but quality flag).

## Pillar I — Inventory & related artefacts

| # | Check | Severity |
|---|-------|----------|
| I1 | **Inventory / CMDB** entry updated where applicable (e.g. IOS "Current Version" custom field for maintenance tickets) | `(x)` for maintenance tickets if missing; `(!)` otherwise |
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
