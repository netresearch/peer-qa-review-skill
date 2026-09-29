<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Security assurance case — peer-qa-review-skill

This document states what a user can expect from this repository in terms of security, and argues why that expectation holds. Every claim names the file that implements it. Reporting a vulnerability: see the [security policy](https://github.com/netresearch/.github/blob/main/SECURITY.md). Components and data flows: [ARCHITECTURE.md](ARCHITECTURE.md).

## What the repository ships

| Part | Files | Runs where |
| --- | --- | --- |
| Skill instructions for an AI agent | `skills/peer-qa-review/SKILL.md`, `skills/peer-qa-review/references/*.md` | Read by the agent as instructions; not executed. The agent runs the commands they describe against the ticket system, code forge and hosts the reviewed ticket names, with the reviewer's privileges. |
| Eval scenarios | `skills/peer-qa-review/evals/qa-discipline.md` | Text for grading a transcript; not executed. |
| Discovery wrapper | `skills/peer-qa-review/scripts/qa-gather.sh` | On the reviewer's machine, started by the agent. |
| Repository checks | `.github/workflows/*.yml`, `.pre-commit-config.yaml`, `tests/qa-gather.sh` | In this repository's CI and on contributors' machines. |

The repository ships no server component, no container image and no library code. It stores nothing and handles no user accounts or credentials of its own; all ticket-system access goes through the separately installed `jira-communication` skill.

## Security requirements

1. `qa-gather.sh` hands the issue key and any further arguments to the `jira-communication` script as separate arguments; nothing a caller passes is interpreted by a shell.
2. `qa-gather.sh` opens no network connection, writes no file and reads no credential itself.
3. `qa-gather.sh` reports failure: it exits with the status of the script it runs, fails when the issue or comment call of the fallback fails, and exits 1 with an install hint when no `jira-communication` script is found.
4. The skill tells the agent to post one QA comment and change the ticket status as the reviewer, and never lets sub-agents post or transition (`batch-review.md`).
5. Nothing committed to this repository contains a secret.
6. A release carries the version that `.claude-plugin/plugin.json` states, and its archives can be verified against the build that produced them.

## Actors and trust boundaries

- **Reviewer and agent.** The agent reads `SKILL.md` and the references and runs commands with the reviewer's privileges; what it runs is decided by the agent and the reviewer, not by this repository. `allowed-tools` in `SKILL.md` pre-approves `${CLAUDE_SKILL_DIR}/scripts/*`, `git`, `glab`, `Read`, `Write` and `Edit`; it does not take any tool away from the agent.
- **Ticket content.** Descriptions, comments and linked artefacts are written by the implementer and other ticket-system users. The skill feeds them to the agent as material to verify, including commands the implementer ran (`lifecycle.md` Stage 2, `checklist.md`).
- **Installed plugins.** `qa-gather.sh` runs, via `uv run`, the first `jira-communication` script it finds below `$CLAUDE_PLUGIN_ROOT` or the reviewer's plugin cache (`$HOME/.claude/plugins/cache`). Whatever is installed there is trusted as the companion skill.
- **`jira-communication` and the ticket system.** The companion skill holds the ticket-system credentials and performs every read and write. `uv` resolves the Python dependencies that skill's scripts declare.
- **Contributors and CI.** Changes are proposed as pull requests and checked by the workflows in `.github/workflows/`. Workflows run on GitHub-hosted runners. `lint.yml`, `tests.yml` and `auto-merge-deps.yml` set `permissions: {}` at the top level and grant their job only the scopes the called reusable workflow needs; `release.yml` has no top-level block and grants its job `contents`, `id-token` and `attestations: write`. `auto-merge-deps.yml` runs on `pull_request_target`, calls the organisation's auto-merge reusable without passing secrets, and does not check out pull request code.

## Threats and countermeasures

| Threat | Countermeasure | Evidence |
| --- | --- | --- |
| An issue key or argument with spaces or shell metacharacters is split or executed by the shell (CWE-78) | The key and arguments are only used in quoted expansions and passed to `exec uv run` and `uv run` as argv entries; the script has no `eval` and builds no command string | `qa-gather.sh`; `tests/qa-gather.sh` ("extra arguments are passed through in order") |
| The wrapper reports success when ticket data could not be read | The preferred script's exit status is the wrapper's (`exec`); the fallback runs under `set -euo pipefail`, so a failing issue or comment call ends it with that status; only the worklog call is allowed to fail | `qa-gather.sh`; `tests/qa-gather.sh` ("a failing preferred script's exit status is returned", "fallback fails when the issue call fails", "fallback fails when the comment call fails") |
| A missing companion skill goes unnoticed and the review proceeds without ticket data | Exit 1 and an install hint on stderr | `qa-gather.sh`; `tests/qa-gather.sh` ("no jira-communication skill exits 1") |
| Credentials leak through this skill | The skill ships no credential handling: `qa-gather.sh` passes none, and `batch-review.md` tells sub-agents to reuse the ticket CLI's credential handling read-only | `qa-gather.sh`, `references/batch-review.md` |
| A reviewer verdict rests on the implementer's pasted output rather than on the system's state | The skill requires re-running verification and fresh output in the comment | `SKILL.md` "Lifecycle", `references/lifecycle.md` Stage 2, `references/anti-patterns.md` |
| Sub-agents in a batch review post or transition tickets on their own | Only the reviewer's agent posts and transitions; agents draft | `references/batch-review.md` "Agents draft; the reviewer posts" |
| A behaviour change in the shipped script goes unnoticed | Skill Tests runs `tests/**/*.sh` on every pull request and fails when scripts ship under `skills/*/scripts/` without a test run | `.github/workflows/tests.yml`, `tests/qa-gather.sh` |
| Insecure shell or workflow patterns | ShellCheck at `style` severity and actionlint run in Skill Validation on every pull request, and in the pre-commit hooks | `.github/workflows/lint.yml`, `.pre-commit-config.yaml` |
| An outdated linter or validator | Renovate proposes updates for the pinned pre-commit hook revisions; they reach `main` through pull requests checked like any other | `renovate.json`, `.pre-commit-config.yaml` |
| A released archive is tampered with | The release workflow checks that the tag is annotated and signed, then publishes a Cosign-signed `SHA256SUMS.txt` and build-provenance attestations for the archives | `.github/workflows/release.yml` (calls the skill-repo-skill release reusable) |

No secret scanning, dependency review or static application security testing runs on pull requests in this repository. Which checks must pass before a change reaches `main` is set in the repository settings, not in this repository.

## Secure design principles applied

- **Least privilege:** `qa-gather.sh` only locates and starts another script; it holds no credential and writes nothing. Workflows grant permissions per job; all but `release.yml` start from `permissions: {}`.
- **Fail-safe defaults:** `qa-gather.sh` runs with `set -euo pipefail` and exits non-zero when it cannot gather the ticket.
- **Economy of mechanism:** the wrapper needs bash, `find`, `dirname` and `uv`; everything ticket-specific lives in the companion skill.
- **Separation of duties:** the reviewer must not be the implementer; a self-review may not reach a terminal verdict without a second reviewer unless the person directing the session explicitly instructs it, and then it is recorded in the comment (`references/lifecycle.md` Stage -1, `references/edge-cases.md` §E, `references/anti-patterns.md` #18). In batch reviews, posting and transitions stay with the reviewer's agent.
- **Open design:** everything the skill tells an agent to do is plain text in `SKILL.md` and `references/`, reviewable before use.

## What a user cannot expect

- The skill gives guidance; it does not enforce it. The agent runs commands with the reviewer's privileges, and `allowed-tools` only removes the confirmation prompt for the tools it lists. Review what an agent proposes to run.
- Ticket content is untrusted input. The skill asks the agent to re-run the implementer's verification, and commands copied from a ticket run with the reviewer's privileges. The skill does not check them.
- `qa-gather.sh` trusts every plugin in the reviewer's plugin cache: it runs the first `jira-communication` script it finds there. When several versions are installed below one search root, the copy used is the first one `find` visits, not necessarily the newest.
- `uv run` may download the Python dependencies the `jira-communication` scripts declare. Their integrity and the handling of ticket-system credentials are the responsibility of that skill.
- The fallback path ignores extra arguments such as `--json` and prints the three raw outputs.
- The QA verdict is a judgement made by a model following the checklist; it can miss defects. The reviewer owns it.
- Security fixes follow the supported-versions rules of the organisation's security policy; older releases may not receive them.
