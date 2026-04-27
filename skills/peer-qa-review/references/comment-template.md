# Comment Template

One structured comment at the end of QA. Use Jira wiki markup. Optional addendum comments for separable concerns.

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

Ready for customer acceptance (QA2).   |   Ready to transition to QA passed.   |   Bouncing to In Progress — see (x) above.
```

Keep it tight. Skip pillars that don't apply (e.g. omit "Communication" if `(-)` n/a). Don't pad with `(/)` for every check — list `(/)` items only when they're load-bearing or non-obvious.

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
