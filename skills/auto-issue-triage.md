---
name: auto-issue-triage
description: Use when a configured repository needs an hourly issue review that supports the active product outcome without turning issue volume into the roadmap
version: 2.0.0
tags: [github, issues, triage, cron, autonomous]
metadata:
  hermes:
    tags: [github, triage, autonomous, kanban]
    requires_toolsets: [terminal, web]
---

## Overview

Automated supporting triage. It reviews actionable issues against the active
product outcome, creates a kanban task when one clearly advances it, and stays
silent when nothing should change.

## When to Use

- Triggered by Hermes cron (hourly)
- No human present — fully autonomous
- Part of the `cto-loop` workflow

## Prerequisites

- GitHub CLI authenticated: `echo "$GITHUB_TOKEN" | gh auth login --with-token`
- Hermes memory has `github-repo` key set (owner/repo format)
- `GITHUB_USERNAME` set in environment (your GitHub username — Hermes self-assigns issues)
- Cron configured (see Setup below)

## Setup (one-time)

```bash
hermes cron add "0 * * * *" "Run auto-issue-triage for [owner/repo]"
```

Or natural language:
```bash
hermes cron add "every 1h" "Run auto-issue-triage for [owner/repo]"
```

Verify:
```bash
hermes cron list
```

## Procedure

1. **Cost guard — check last run time:**
   Retrieve `triage-last-run` from Hermes memory. If it was less than 45 minutes ago, skip this run and log: `{ skippedAt, reason: "too-soon" }`. This prevents runaway token consumption if the cron fires unexpectedly.

2. **Fetch open issues:**
   ```bash
   gh issue list --repo [owner/repo] --state open \
     --json number,title,labels,createdAt,comments --limit 50
   ```
   If the result contains more than 100 issues, do not score them all. Score the 20 most recently updated and alert the founder: "Over 100 open issues — only top 20 by recency scored. Consider a backlog cleanup."

3. **Score each issue** (0–10, higher = do first):
   - `bug` label: +4
   - `priority:high` label: +3
   - `priority:low` label: −2
   - No labels: +1 (needs triage, flag it)
   - Older than 7 days: +1
   - Has comments: +1 per comment, max +2
   - Already assigned or labeled `in-progress`: skip
   - Labeled `wontfix`, `blocked`, `needs-design`: skip

4. **Check product fit.** Read `PRODUCT_BRIEF.md`, active kanban work, and current
   product goal. Skip an issue that scores highly but conflicts with the active
   outcome. Record it for the Product Agent instead of starting it.

5. **Pick the best aligned issue.** Tie → pick the issue with clearer user
   impact, then the older issue.

6. **Check if a task is already in progress:**
   - Retrieve `current-task` from Hermes memory
   - Already in progress and not blocked → skip, send quick status update
   - Blocked or stalled > 4 hours → escalate via `send-notification`

7. **Create kanban card** via `kanban-task`:
   ```
   kanban_create title="[issue title]" assignee="dev" body="Issue #[n] | Score: [n] | [why in one line] | Acceptance: [2-4 verifiable checks]"
   ```
   Save task ID to memory: `task-id-issue-[n]`.

8. **Assign and label on GitHub:**
   ```bash
   gh issue edit [number] --add-label "in-progress" --add-assignee "$GITHUB_USERNAME"
   ```

9. **Save to memory:** key `current-task` → `{ issueNumber, taskId, title, assignedAt }`. Also update `triage-last-run` → current ISO timestamp.

10. **Spawn Product Agent** when acceptance criteria are missing; otherwise hand
    the ready task to Builder.

11. **If no aligned actionable issues:** update `triage-last-run` and stay silent.

## Pitfalls

- Never start two tasks in parallel. Always check `current-task` memory first.
- Vague issue body → Product Agent infers acceptance criteria and assumptions.
  Ask the founder only when a material irreversible decision remains.
- Do not start an issue merely because it has the highest numerical score.
- Cron sessions cannot create more cron jobs — do not try to schedule inside this skill.

## Verification

- Kanban card created and visible in `hermes kanban list`
- `current-task` in Hermes memory
- Issue labeled `in-progress` on GitHub
