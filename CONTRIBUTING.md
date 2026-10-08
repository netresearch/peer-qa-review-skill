<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: Netresearch DTT GmbH -->

# Contributing

How to run the tests and what they cover is described in the [README](README.md#tests).

## Checks on pull requests

The organisation's [rules for dependency and code analysis findings](https://github.com/netresearch/.github/blob/main/SECURITY.md#handling-of-dependency-and-code-analysis-findings) ask a repository to name the checks that run on its pull requests. These checks run on every pull request:

- Skill Validation (`.github/workflows/lint.yml`): skill structure, plugin manifest sync, markdownlint, yamllint, actionlint, JSON syntax, plugin and SKILL.md version checks, ShellCheck at style severity; its ruff and checkpoint-schema steps find no files here.
- Skill Tests (`.github/workflows/tests.yml`).
- Security (`.github/workflows/security.yml`): Betterleaks secret scanning of the git history, zizmor on the workflow files, Dependency Review (pull requests only), and Composer Audit with Opengrep SAST through the `security.yml` workflow of `netresearch/typo3-ci-workflows`. For Opengrep findings see the [organisation's static analysis rule](https://github.com/netresearch/.github/blob/main/SECURITY.md#static-analysis-sast).
- Template drift (`.github/workflows/check-template-drift.yml`): fails when a file governed by the `skill` template of `netresearch/.github` differs from it; the intentional exceptions are listed in `.github/template.yaml`.
- Eval Validation (`.github/workflows/eval-validate.yml`) and Harness Verification (`.github/workflows/harness-verify.yml`): reusable workflows of `netresearch/skill-repo-skill`.
- Labeler (`.github/workflows/labeler.yml`): applies labels from `.github/labeler.yml` through a shared workflow of `netresearch/.github`, on `pull_request_target`, without checking out the pull request's code.
- Auto-merge dependency PRs (`.github/workflows/auto-merge-deps.yml`), skipped unless Renovate or Dependabot opened the pull request, and for pull requests labelled `deps-major` or `deps-no-automerge`.
- Configured outside the workflow files: CodeQL analysis of the workflow files (`Analyze (actions)`, GitHub code scanning default setup), SonarCloud Code Analysis (SonarCloud automatic analysis), the DCO check and the CodeRabbit review status. Code scanning reports the CodeQL and SonarCloud results again as the `CodeQL` and `SonarCloud` check runs. GitHub secret scanning with push protection is enabled as a repository setting.

OpenSSF Scorecard (`.github/workflows/scorecard.yml`) does not run on pull requests: it runs on pushes to `main` and `master`, weekly and on manual dispatch.
