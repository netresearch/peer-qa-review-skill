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

- [`jira-communication`](https://github.com/netresearch/jira-skill) (public) — required for ticket I/O. The bundled `qa-gather.py` script is used in Stage 0.
- Internal team-specific skills (private to your org) — for project-list overrides, inventory CRUD (CMDB, IOS), announcement channels (Matrix / Slack / Email), and workflow-specific lifecycle rules. The skill defers to them with *"if your team has an internal IT/maintenance/ITSM skill, consult it for project-specific overrides."*

## License

Dual-licensed: MIT for code, CC-BY-SA-4.0 for content. See `LICENSE-MIT` and `LICENSE-CC-BY-SA-4.0`.
