<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# peer-qa-review-skill

Agent skill that turns Round-1 IT QA of a ticket into a runbook: lifecycle, checklist, severity vocabulary and comment template. The skill is Markdown plus one shell script, `skills/peer-qa-review/scripts/qa-gather.sh`, which collects the ticket data through the `jira-communication` skill.

## Repo Structure

```
skills/peer-qa-review/
  SKILL.md                  skill definition and trigger description
  references/               lifecycle, checklist, severity, comment template, edge cases, anti-patterns, batch review
  scripts/qa-gather.sh      Stage 0 wrapper around the jira-communication scripts
  evals/qa-discipline.md    scenarios for grading a review transcript (not run)
tests/qa-gather.sh          behavioural tests for qa-gather.sh
docs/                       ARCHITECTURE.md, SECURITY-ASSURANCE.md
plugin.json                 Agent Plugins manifest
.claude-plugin/plugin.json  Claude Code manifest
composer.json, package.json distribution metadata (Composer, npm)
.github/workflows/          CI callers of reusable workflows
.github/template.yaml       drift record against the skill template of netresearch/.github
```

## Commands

- Tests: `bash tests/qa-gather.sh` (offline; needs bash, `find` and coreutils)
- Tests against bash 3.2: `docker run --rm -v "$PWD":/src:ro -w /src bash:3.2 bash tests/qa-gather.sh`
- Hooks and linters: `pre-commit install --install-hooks`, then `pre-commit run --all-files`

## Rules

- Licensing is split: code is MIT ([LICENSE-MIT](LICENSE-MIT)), documentation and skill content are CC-BY-SA-4.0 ([LICENSE-CC-BY-SA-4.0](LICENSE-CC-BY-SA-4.0)); `composer.json` declares `(MIT AND CC-BY-SA-4.0)`.
- Keep `plugin.json` and `.claude-plugin/plugin.json` in sync; Skill Validation (`lint.yml`) runs the skill-repo-skill manifest sync check, and the `check-version-parity` pre-commit hook checks the versions.
- No `composer.lock` is committed; the skill-repo validator requires that (see [README.md](README.md)).
- A change to behaviour in `qa-gather.sh` adds or updates a check in `tests/` that fails without it ([README.md](README.md)).
- The workflow files that also exist in the `skill` template of `netresearch/.github` are governed by it; `.github/template.yaml` lists the intentional exception (`lint.yml`: `shellcheck-severity: style`).
- The ruleset on `main` requires the status check `tests / Skill Tests`.

## References

- [README.md](README.md): installation, tests, dependencies, policies
- [CONTRIBUTING.md](CONTRIBUTING.md): checks that run on pull requests
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): components and data flow
- [docs/SECURITY-ASSURANCE.md](docs/SECURITY-ASSURANCE.md): trust boundaries and countermeasures
- [skills/peer-qa-review/SKILL.md](skills/peer-qa-review/SKILL.md): skill content
