<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Contributing

How to run the tests and what they cover is described in the [README](README.md#tests).

## Checks on pull requests

The organisation's [rules for dependency and code analysis findings](https://github.com/netresearch/.github/blob/main/SECURITY.md#handling-of-dependency-and-code-analysis-findings) ask a repository that does not call the shared security workflows to name its own checks. This repository calls none of them. These checks run on every pull request:

- Skill Validation (`.github/workflows/lint.yml`): skill structure, plugin manifest sync, markdownlint, yamllint, actionlint, JSON syntax, plugin and SKILL.md version checks, ShellCheck at style severity; its ruff and checkpoint-schema steps find no files here.
- Skill Tests (`.github/workflows/tests.yml`).
- Auto-merge dependency PRs (`.github/workflows/auto-merge-deps.yml`), skipped unless Renovate or Dependabot opened the pull request.
- Configured outside the workflow files: CodeQL analysis of the workflow files (`Analyze (actions)`, GitHub code scanning default setup), SonarCloud Code Analysis (SonarCloud automatic analysis), the DCO check and the CodeRabbit review status. Code scanning reports the CodeQL and SonarCloud results again as the `CodeQL` and `SonarCloud` check runs. GitHub secret scanning with push protection is enabled as a repository setting.

No dependency review, Composer Audit or secret-scanning workflow runs on pull requests in this repository.
