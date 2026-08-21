# Batch review with sub-agents

How one reviewer takes a **batch** of QA tickets through a single Round-1 pass by fanning the evidence-gathering out to sub-agents, while every verdict, comment and transition stays the reviewer's own. The lifecycle in `lifecycle.md` is unchanged; this page says how its stages are sequenced when there are many tickets and several agents.

Exercised on a 16-ticket maintenance batch with 5 agents (2–4 tickets each): all 16 passed, and every load-bearing claim in the agent drafts was re-measured by the reviewer before posting.

## Sizing

Fan-out pays off from roughly **six tickets** upwards. Below that, the reviewer runs the lifecycle inline, one ticket after the other — the briefing, the per-agent deliverables and the re-measuring pass cost more than they save on a handful of tickets.

## Sequence

### 1. Stage -1 for the whole batch, in one loop

Claim **every** ticket first, before any agent starts. The claim is the reviewer's: the reviewer's account is the assignee, not an agent identity, and the same Stage -1 table applies per ticket (someone else's → drop it from the batch; own implementation → drop it, §E). A ticket claimed only after an agent has reported is a ticket another reviewer may already have picked up in the meantime.

### 2. Stage 0 for the whole batch, into files

Run `qa-gather.sh` for every ticket **before** fanning out, and write each bundle to a file (`<ticket-bundle-dir>/<KEY>.txt`, plus the full description and comment thread as `<KEY>.work.txt` if the bundle abbreviates it). Agents read files; they do not each re-query the ticket system. One gather per ticket, by the reviewer, is also what makes the batch reproducible afterwards.

### 3. Group per agent by domain, not per ticket

One agent per **component or domain** (the DNS tickets, the monitoring-stack tickets, the account-lifecycle tickets), carrying 2–4 tickets each. Sibling tickets of one domain share probes, hosts and conventions, so one agent sees the pattern deviations (`edge-cases.md` §C) that a per-ticket agent cannot. One agent per ticket multiplies the setup and loses exactly that cross-check.

### 4. A written briefing every agent reads first

The briefing is a file, not a chat message, and every agent's first instruction is to read it. Template below. It fixes what an agent may do (read-only probes), what it must do (re-run, cite evidence, write the F1.5 line), what it must deliver, and what it must never do (post, transition, mutate). A briefing that carries a wrong premise (a wrong host, a wrong implementer, an out-of-date tag) gets executed, not questioned — so the briefing also tells agents to report contradictions instead of working around them, and the reviewer believes them when they do.

### 5. Agents draft; the reviewer posts

Agents never post comments and never transition. Their deliverable is a review file and a **draft** comment per ticket. Before posting, the reviewer reads the evidence behind every `(x)` and `(!)` in the draft and **re-runs the load-bearing probes personally** — the agent's output is a lead, not a verdict (anti-pattern #12 applies to agent output exactly as it applies to the implementer's). Load-bearing means: the claim the verdict turns on, or the claim that would embarrass the team if wrong. Examples from the 16-ticket batch, each re-measured by the reviewer before the comment went out:

- a "CHANGELOG regressed" claim, checked with `git show <tag>:CHANGELOG.md | grep -c <entry>` against the tag the agent named;
- "stale PTR records removed" on a directory-integrated DNS zone, re-dug against the authoritative server;
- "device is alive" on a decommission ticket, re-pinged (and the sibling control pinged alongside, `edge-cases.md` / eval E9);
- "schedule variables updated" on a CI schedule, re-read through the CI API rather than from the agent's transcript.

### 6. A `(?)` in a draft is addressed to the reviewer

Agents cannot settle an open question — they have no instrument to ask the implementer and no mandate to decide. So every `(?)` in a draft is a question **to the reviewer**: settle it with your own probe, or downgrade it to `(!)` with the reason written in. A `(?)` must not reach the posted comment: by `severity.md` it blocks the verdict, and a posted question nobody is waiting to answer blocks it indefinitely.

### 7. "Idle" is not a report

An agent that goes idle without reporting has not failed and has not passed — read its deliverable files. Agents that hit a session or API limit mid-task skip the report and every cleanup instruction after it, yet the review file and draft comment are usually already on disk. Measure the artefacts, not the status.

### 8. Main comment first, then the TL;DR, chained with `&&`

Where a ticket gets a long internal QA comment plus a short TL;DR / handover comment, post the main comment **first** and the TL;DR **only if that succeeded**: `post-main && post-tldr`. A `;` chain once posted the TL;DR after the main comment had been rejected by the markup validator — the ticket then carried a summary of a comment that did not exist.

### 9. Stop every agent, remove what it left

After an agent has reported (or its files have been read), stop it. The batch ends with **zero** agent processes, and the reviewer removes the clones, temp directories and scratch files the agents created (`<ticket-bundle-dir>/repos/`, per-agent scratch). An agent's "I cleaned up" line is a claim; `pgrep`, `docker ps -a` and `du -sh` on the scratch directory are the check.

### 10. Log the review time once per batch

Book the batch review as one entry in the team's system of record (Stage 5, "Log your QA time"), not sixteen entries. Name the batch and the ticket keys in the description so the audit trail still reaches each ticket.

## Briefing template

Copy, fill the placeholders, save as a file, and make it the first thing every agent reads. Keep the rules block verbatim.

```markdown
# Round-1 IT QA briefing (sub-agent)

You are performing Round-1 IT QA (peer review) of <team> tickets on behalf of
reviewer <reviewer-account>. Implementer is <implementer-account>. Today is <date>.

## Rules (non-negotiable)
- READ-ONLY. Do NOT post comments, do NOT transition, do NOT edit fields,
  do NOT push/commit, do NOT mutate anything on a host (no restarts, no
  deploys, no edits, no VM/container state changes). Read-only probes
  (dig, curl, API GET, git log/show, docker ps, cat, ssh <host> '<read-only cmd>')
  are fine.
- The reviewer RE-RUNS verification. Copy-pasting the implementer's output
  is not QA. Capture your own command + raw output.
- Findings are leads; cite file:line / URL / command output for every
  claim. Name the commit SHA / tag / MR you inspected.
- If this briefing or the ticket carries a wrong premise, SAY SO in your
  report instead of executing it.
- Do not accept the implementer's framing uncritically.

## Inputs
- Ticket bundle (meta): <ticket-bundle-dir>/<KEY>.txt ; full description +
  comments: <ticket-bundle-dir>/<KEY>.work.txt
- Public checklist: <peer-qa-review-skill>/references/checklist.md,
  severity.md, comment-template.md, edge-cases.md
- Team overrides: <team-skill>/... (QA workflow, conventions, infrastructure,
  component registry)
- Ticket system CLI (read-only use): <jira-cli> ... ; if you need raw REST,
  reuse the CLI's credential handling read-only.
- Code hosting: <forge-cli> with <host>. Repos may already be cloned under
  <local-repo-root>/<name> — check before cloning; if you clone, clone into
  <ticket-bundle-dir>/repos/.
- Hosts: ssh <host> (user <reviewer-account>) for generic infra; privileged
  users only where the team's infrastructure reference names them. Never
  change anything.
- <team-specific structural notes: e.g. "for <project-prefix> tickets an
  empty worklog is structural (time tracker books with an empty ticket
  field) -> record as (i), not a finding"; "inventory field <field-id> is
  hidden by the default formatter -> query it explicitly"; "task-checkbox
  tick state is NOT visible in the raw description -> do not report
  'unticked' from the raw text">

## Per-ticket deliverables (write to <ticket-bundle-dir>/<KEY>.review.md)
1. Inspected artefacts: commit SHAs, tags, MRs, pipelines, hosts probed.
2. Findings per pillar F (incl. an explicit F1.5 description-currency
   line), R, I, G, D, B, C, P with severity icons (/) (x) (!) (i) (?) (off)
   and the evidence (command + raw output).
3. Verdict recommendation: pass-resolve | pass-QA2 | bounce | won't-do,
   with the deciding reasons. Also: does the ticket have a Resolution set
   where the workflow needs one at QA entry?
4. A DRAFT comment in the ticket system's markup (h3. IT Internal QA —
   passed|failed, h4 per pillar, bulleted findings, code blocks with YOUR
   re-run output) saved to <ticket-bundle-dir>/<KEY>.comment.txt. Follow
   comment-template.md: every MR/commit/pipeline/tag reference as a link,
   every person as a mention, literal block tags in prose escaped, no
   Markdown, no monospace for commands.
5. Open questions for the reviewer.
6. Anything you left behind (clones, processes) — clean up before finishing.

Report back concisely: per ticket the verdict recommendation + the (x)/(!)
findings + paths of the files you wrote. Do NOT paste the full comment into
the report.
```

## What stays with the reviewer

| Step | Agent | Reviewer |
|------|-------|----------|
| Stage -1 claim | never | all tickets, first |
| Stage 0 gather | reads files | runs gather, writes files |
| Stages 1–3 probes | runs read-only probes, cites evidence | re-runs every load-bearing probe |
| Stage 4 verdict | recommends | decides |
| Stage 5 comment | drafts | reads evidence, settles `(?)`, posts (main, then TL;DR) |
| Stage 5 transition, assignee, worklog | never | per ticket; time logged once per batch |
| Cleanup | reports what it left | stops the agent, verifies nothing is left |
