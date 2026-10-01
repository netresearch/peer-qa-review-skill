<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Peer QA Review Skill

A Claude Code skill that turns Round-1 IT QA into a repeatable runbook: structured lifecycle, severity vocabulary, comment template, edge cases, and anti-patterns. Generic for any IT/Ops team.

## What this skill is for

Round-1 QA is the **internal team review** of completed work *before* it goes to customer acceptance (Round-2 / QA2) or is resolved internally. It is performed by a peer (not the implementer, not the customer, not an automated bot) and verifies:

1. **Formal correctness** — the ticket is clearly described, the work is documented, links to MR/PR/pipeline/inventory are present, console output exists for key actions.
2. **Functional resolution** — the reported problem is actually fixed; reviewer **re-runs** verification, not just trusts the implementer's output.
3. **Inventory & related artefacts** — IOS/CMDB/inventory updated, sibling tickets consistent, parent epic in a sane state.
4. **Documentation & runbook** — README/role-meta matches reality, runbook reviewed for staleness, CHANGELOG entry where applicable.
5. **Rollback / backout** — snapshot or backup before risky change, backout path documented.
6. **Communication** — for customer-affecting / org-wide / security-relevant changes: announcement posted (Matrix / email / blog).

The skill produces a **single structured QA comment** on the ticket with `(/) (x) (!) (i) (?)` severity icons and a clear verdict (Pass-resolve / Pass-QA2 / Bounce-to-In-Progress / Won't-do).

## Compatibility

Agent Skill following the [open standard](https://agentskills.io). Works with Claude Code, and any other agent runtime that implements the spec.

## Installation

### Composer (PHP Projects)

```bash
composer require netresearch/peer-qa-review-skill
```

Requires [netresearch/composer-agent-skill-plugin](https://github.com/netresearch/composer-agent-skill-plugin).

### npm (Node Projects)

```bash
npm install --save-dev \
  @netresearch/agent-skill-coordinator \
  github:netresearch/peer-qa-review-skill
```

Requires [@netresearch/agent-skill-coordinator](https://github.com/netresearch/node-agent-skill-coordinator), which discovers the skill in `node_modules` and registers it in `AGENTS.md` via a `postinstall` hook. For pnpm, also allowlist the coordinator's postinstall:

```json
{
  "pnpm": {
    "onlyBuiltDependencies": ["@netresearch/agent-skill-coordinator"]
  }
}
```

## Companion skills (optional)

- [`jira-communication`](https://github.com/netresearch/jira-skill) (public) — required for ticket I/O. In Stage 0, `qa-gather.sh` runs its `jira-qa-gather.py` script (`qa-gather.py` before jira-integration 3.13), or falls back to its `jira-issue.py`, `jira-comment.py` and `jira-worklog.py`.
- Internal team-specific skills (private to your org) — for project-list overrides, inventory CRUD (CMDB, IOS), announcement channels (Matrix / Slack / Email), and workflow-specific lifecycle rules. The skill defers to them with *"if your team has an internal IT/maintenance/ITSM skill, consult it for project-specific overrides."*

## Tests

The behavioural tests for `skills/peer-qa-review/scripts/qa-gather.sh` live in `tests/qa-gather.sh`. They run offline and need bash, `find` and coreutils; neither `uv` nor the `jira-communication` skill has to be installed, because the test puts a stub `uv` first on `PATH` that records each call, and builds fake `jira-communication` trees under a temporary `HOME` and `CLAUDE_PLUGIN_ROOT`:

```bash
bash tests/qa-gather.sh
```

They cover the usage exit (64), the preference of `jira-qa-gather.py` over `qa-gather.py` and over the fallback, each search root including a plugin cache root, passing arguments through, returning the exit status, the three fallback calls with their failure handling, and the exit 1 with install hint when nothing is found. The test runs the script with the bash that runs the test, so `docker run --rm -v "$PWD":/src:ro -w /src bash:3.2 bash tests/qa-gather.sh` checks it against the bash 3.2 that macOS ships.

Each check prints `ok` or `FAIL`; a `FAIL` line names the expectation that was not met and is followed by the script's exit status, stdout, stderr and the recorded `uv` calls. The file exits 1 when any check failed. In CI, the Skill Tests workflow (`.github/workflows/tests.yml`) runs every `tests/**/*.sh` on each pull request and on pushes to `main`, and fails when the repository ships scripts under `skills/*/scripts/` but no test ran.

The skill's Markdown is not executed; Skill Validation (`.github/workflows/lint.yml`) checks its structure and lints it, and `pre-commit run --all-files` runs the same linters locally. `skills/peer-qa-review/evals/qa-discipline.md` holds scenarios for grading a review transcript and is not run. A pull request that adds or changes behaviour in a script adds or updates a check in `tests/` that fails without the change.

## Dependencies

- **Runtime of `qa-gather.sh`:** bash (3.2 or later), `find`, `dirname` and [uv](https://docs.astral.sh/uv/), plus the `jira-communication` skill of the `jira-integration` plugin from [netresearch/jira-skill](https://github.com/netresearch/jira-skill), installed through an agent plugin marketplace. The script locates that skill at run time below `$CLAUDE_PLUGIN_ROOT` or `$HOME/.claude/plugins/cache`; it is not declared in `composer.json` or `package.json`, because a Composer or npm install would not place it there. `uv` resolves the Python dependencies of the `jira-communication` scripts.
- **Packaging:** `composer.json` requires `netresearch/composer-agent-skill-plugin`; `package.json` declares `@netresearch/agent-skill-coordinator` as a peer dependency. Both register the skill in the consuming project. No lock file is committed; the skill-repo validator requires that there is no `composer.lock`.
- **Development and CI:** the pre-commit hooks are pinned by `rev:` in `.pre-commit-config.yaml`. The workflows call reusable workflows from `netresearch/skill-repo-skill` and `netresearch/.github` at `@main`; the third-party actions inside those are pinned to commit SHAs there.
- **Tracking:** Renovate (`renovate.json`, extending `github>netresearch/renovate-config`) opens update pull requests, for example for the pre-commit hook revisions, and `.github/workflows/auto-merge-deps.yml` hands Renovate and Dependabot pull requests without a `deps-major` or `deps-no-automerge` label to the organisation's auto-merge workflow, which merges them after the pull request's other checks have passed. The licence and vulnerability rules for dependencies are those of the organisation's security policy linked below.

## Governance and policies

This repository follows the Netresearch organisation policies:

- [Governance](https://github.com/netresearch/.github/blob/main/GOVERNANCE.md): ownership, roles, how decisions are made and disputes resolved, and continuity.
- [Roadmap](https://github.com/netresearch/.github/blob/main/ROADMAP.md): planned and explicitly excluded work for the coming year.
- [Handling of dependency and code analysis findings](https://github.com/netresearch/.github/blob/main/SECURITY.md#handling-of-dependency-and-code-analysis-findings): thresholds, deadlines and the exception process for dependency (SCA) and static analysis (SAST) findings.
- [Secret management](https://github.com/netresearch/.github/blob/main/SECURITY.md#secret-management): how CI and release credentials are stored, accessed and rotated.
- [Access roster](https://github.com/netresearch/.github/blob/main/docs/access-roster.md): who holds administrative access to this repository and the organisation.

The architecture of this skill (actors, components, data flows) is described in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and its security assurance case (threat model, trust boundaries, countermeasures and limits) in [docs/SECURITY-ASSURANCE.md](docs/SECURITY-ASSURANCE.md).

The checks that run on every pull request, as the organisation's rules for code analysis findings ask, are listed in [CONTRIBUTING.md](CONTRIBUTING.md#checks-on-pull-requests).

## License

Dual-licensed: MIT for code, CC-BY-SA-4.0 for content. See `LICENSE-MIT` and `LICENSE-CC-BY-SA-4.0`.
