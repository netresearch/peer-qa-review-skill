<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Architecture

This repository ships one agent skill, `peer-qa-review`: Markdown instructions that an AI agent follows when it performs a Round-1 IT QA review of a ticket, and one shell script that gathers the ticket's context. Security properties and limits: [SECURITY-ASSURANCE.md](SECURITY-ASSURANCE.md). Update this page in the pull request that adds, removes or rewires a component below.

## Actors

| Actor | Role |
| --- | --- |
| Reviewer | The person who asks the agent to QA a ticket and owns the verdict. |
| AI agent | Claude Code or another runtime implementing the [Agent Skills](https://agentskills.io) format. It loads `SKILL.md`, runs commands with the reviewer's privileges and writes the QA comment. |
| Ticket system | Jira in the tested setup (`compatibility` in `SKILL.md`). Holds the ticket, comments, worklog and transitions. |
| `jira-communication` skill | Companion skill from [netresearch/jira-skill](https://github.com/netresearch/jira-skill), installed separately as the `jira-integration` plugin. It holds the ticket-system credentials and performs all ticket I/O. |
| Code forge and hosts | Whatever the ticket's work touched (merge requests, pipelines, servers). The agent re-runs verification there with the reviewer's own access. |
| Maintainers and CI | Change this repository through pull requests checked by `.github/workflows/`. |

## Components

| Component | Files | What it does |
| --- | --- | --- |
| Skill entry point | `skills/peer-qa-review/SKILL.md` | Trigger description, the lifecycle stages -1 to 5, severity icons, verdict routing and pointers to the references. Its `allowed-tools` line pre-approves `${CLAUDE_SKILL_DIR}/scripts/*`, `git`, `glab`, `Read`, `Write` and `Edit`. |
| References | `skills/peer-qa-review/references/*.md` | Loaded on demand: `lifecycle.md` (stage details, including read-only Jira REST queries and a transition `POST`), `checklist.md`, `severity.md`, `comment-template.md`, `edge-cases.md`, `anti-patterns.md`, `batch-review.md` (fanning a batch of tickets out to sub-agents). |
| Eval scenarios | `skills/peer-qa-review/evals/qa-discipline.md` | Scenarios to grade a reviewer transcript against; the file states it is not yet a runnable harness. |
| Discovery wrapper | `skills/peer-qa-review/scripts/qa-gather.sh` | Stage 0: finds the `jira-communication` scripts and runs them through `uv` (see the data flow below). |
| Package manifests | `composer.json`, `package.json`, `plugin.json`, `.claude-plugin/plugin.json` | Make the skill installable through Composer, npm and agent plugin marketplaces. |
| Repository checks | `.github/workflows/lint.yml`, `tests.yml`, `release.yml`, `auto-merge-deps.yml`, `.pre-commit-config.yaml`, `tests/qa-gather.sh` | Validation, behavioural tests, release packaging and dependency-update merging; see the README. |

## Data flow of a review

1. The reviewer asks the agent to QA a ticket. The agent loads `SKILL.md`.
2. Stage -1: the agent claims the ticket (assigns it to the reviewer's account), or stops when someone else holds it or the reviewer implemented it (`lifecycle.md`).
3. Stage 0: the agent runs `qa-gather.sh <KEY> [args]`:
   - The script looks for `skills/jira-communication/scripts/utility/jira-qa-gather.py`, then the older name `qa-gather.py`, below `$CLAUDE_PLUGIN_ROOT`, then `$HOME/.claude/plugins/cache/netresearch-claude-code-marketplace/jira-integration`, then `$HOME/.claude/plugins/cache` (`find -maxdepth 8`, first match wins).
   - Found: it replaces itself with `uv run <script> <KEY> [args]`. The `jira-communication` script reads its own configuration, queries the ticket system and prints the bundle (issue, comments, worklog, links, extracted URLs, sibling tickets) on stdout; its exit status is the wrapper's.
   - Otherwise, if `scripts/core/jira-issue.py` is found in the same roots, it runs `jira-issue.py get`, `jira-comment.py list` and `jira-worklog.py list` for the key, each through `uv run`, prints them under `=== ISSUE ===`, `=== COMMENTS ===` and `=== WORKLOG ===`, and exits 0; a failing worklog call is ignored, a failing issue or comment call ends the script with that status. Extra arguments are not passed on.
   - Otherwise it prints an install hint on stderr and exits 1.
   - The wrapper itself opens no network connection, writes no file and handles no credential. Behaviour pinned by `tests/qa-gather.sh`.
4. Stages 1 to 3: the agent reads the bundle and re-runs the implementer's verification in the systems the ticket names, with the reviewer's privileges (`lifecycle.md`, `checklist.md`).
5. Stage 4: the agent picks the verdict (`SKILL.md` "Verdict routing").
6. Stage 5: the agent posts one comment built from `comment-template.md`, performs the transition and books the worklog through `jira-communication` or the REST calls shown in `lifecycle.md`.

With `batch-review.md`, the reviewer's agent runs Stage -1 and Stage 0 for every ticket, writes the bundles to files and hands them to sub-agents; only the reviewer's agent posts comments and transitions tickets.

## Release flow

A signed `v*` tag runs `.github/workflows/release.yml`, which calls the `netresearch/skill-repo-skill` release workflow: it checks that the tag is annotated and signed, builds `.zip` and `.tar.gz` archives of the skill, publishes `SHA256SUMS.txt` signed with Cosign (keyless) and build-provenance attestations for the archives.
