# Framework Alignment

This runbook is **pragmatic, not framework-compliant**. It's shaped by what works in practice (empirical NR observations across NRS / NRT / SRV* projects) rather than by adherence to any one external standard. That said, several established frameworks describe overlapping concerns, and naming the alignment helps with credibility and onboarding.

## ITIL — Change Enablement / Post-Implementation Review

ITIL's **Post-Implementation Review (PIR)** is the closest-named external practice: a review of a completed change against its objectives, conducted after the change has been implemented but before it's marked closed.

| ITIL PIR concern | This skill |
|------------------|------------|
| Was the change implemented as planned? | Pillar F (formal correctness against acceptance criteria) |
| Did the change achieve its objectives? | Pillar R (functional resolution, reviewer re-run) |
| Were there unexpected side-effects? | R4 (no collateral damage) |
| Backout / rollback verified? | Pillar B |
| Configuration / inventory records updated? | Pillar I |
| Stakeholders informed? | Pillar C (communication) |

**What this skill does *not* import from ITIL**: full Change Advisory Board (CAB) approval workflows, formal Change Manager role, change-window governance. Those are too heavyweight for Round-1 IT QA. If your team uses CAB, that's a separate process upstream of implementation, not Round-1 review.

## Scrum / Agile — Definition of Done

Scrum's **Definition of Done (DoD)** is a team-agreed checklist for "this work is complete." This skill's Pillar F maps to DoD-style "code complete + reviewed + tested + documented" checks.

**Difference**: DoD is the *implementer's* self-check; Round-1 QA is the *peer's* verification of the same. Both should agree, but they're applied by different people at different times.

## Google SRE — Postmortems

Round-1 QA is not a postmortem (no incident occurred), but the postmortem culture's emphasis on **blameless tone**, **evidence-based assertions**, and **action items rather than recriminations** translates well to QA comments.

| Postmortem pattern | Applied here |
|--------------------|--------------|
| Blameless framing | "this fix doesn't exercise scenario X" not "you forgot scenario X" |
| Evidence > assertion | re-run command + paste output, don't just say "I checked" |
| Action items, not blame | each `(x)` and `(!)` says what to do, not just what's wrong |

## NIST SP 800-128 — Secure Configuration Management

NIST 800-128 §3.5 ("Configuration Monitoring") describes **change verification** — confirming that an implemented change has the expected effects and no unexpected ones. Pillars R and B in this skill cover the same ground for security-relevant changes specifically. The skill doesn't claim compliance with 800-128, but its R/B pillars are consistent with the §3.5 checklist.

## What this skill is *not* aligned with

- **CMMI / formal change-control gates** — too heavyweight for Round-1.
- **ISTQB test-design framework** (boundary value, equivalence partitioning, etc.) — that's *test design* by the implementer, not *peer review* by the reviewer.
- **Six Sigma / DMAIC** — different scope (process improvement, not per-ticket review).

## When to reach beyond this skill

If your organisation has a formal change management process (CAB, change windows, security board sign-off), this skill **complements** it rather than replaces it. Round-1 IT QA is the team-internal, peer-level gate. Higher-tier governance, when present, applies on top.
