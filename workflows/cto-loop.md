---
name: cto-loop
description: Fully autonomous multi-agent CTO system with kanban tracking and founder approval gate
version: 2.0.0
tags: [autonomous, cto, workflow, github, kanban, agents]
---

## Overview

Five specialized agents, one CTO orchestrating. The founder sees a kanban board and gets a plain-English message when something needs approval. Nothing ships without a human YES.

## Agents

| Agent | Role | Triggers |
|---|---|---|
| **CTO Agent** | Orchestrates, monitors, escalates | Always running |
| **PM Agent** | Triages GitHub issues → kanban tickets | Hourly cron |
| **Dev Agent** | Implements tickets → PRs | PM assigns |
| **QA Agent** | Reviews PRs → founder summary | Dev completes PR |
| **Ops Agent** | Deploys, monitors, notifies | Merge + scheduled |

## The loop

```
CRON — every hour
  │
  ▼
PM AGENT: auto-issue-triage
  ├─ No actionable issues → "All caught up" → sleep
  ├─ Issue too vague → ask founder for clarification → sleep
  └─ Issue scored + ticketed → kanban-task (backlog)
        │
        ▼
CTO AGENT: reviews backlog, assigns to Dev Agent

DEV AGENT: picks top backlog ticket
  ├─ kanban-task (in-progress)
  ├─ choose-engine → implement
  └─ create-github-pr
        │ kanban-task (review)
        ▼
QA AGENT: review-github-pr
  ├─ FAIL → kanban-task (blocked) → feedback to Dev → Dev fixes
  └─ PASS → founder summary
        │ kanban-task (awaiting-approval)
        ▼
CTO AGENT: await-merge-approval
  ├─ YES → gh pr merge
  │     │
  │     ▼
  │  OPS AGENT: post-deploy-followup
  │     ├─ health check PASS → kanban-task (done) → notify founder
  │     └─ health check FAIL → incident → alert founder → kanban-task (blocked)
  │
  ├─ NO  → feedback saved → reopen issue → kanban-task (backlog) → loop
  └─ LATER → remind in 2h → loop
```

## Kanban board (what the founder sees)

```
Backlog       In Progress    Review         Awaiting Approval    Done
──────────    ───────────    ──────         ─────────────────    ────
#42 Login     #38 Fix        PR #41         PR #40: Add onboard  #39 Dark mode
#44 Payment   redirect       billing        → Reply YES/NO       #37 Bug fix
#45 CSV...                                                       #35 Perf fix
```

## Monitoring (Ops Agent, always on)

Cron jobs Hermes sets up automatically:

```bash
hermes cron add "*/15 * * * *" "Run health-check on [production-url]"
hermes cron add "0 * * * *"    "Run auto-issue-triage for [owner/repo]"
hermes cron add "0 9 * * *"    "Send cto-status-report to founder"
```

## Multi-agent execution

Hermes supports spawning up to 3 parallel sub-agents. In the CTO loop:
- The **CTO Agent** (main session) orchestrates and monitors
- It spawns **PM**, **Dev**, **QA**, **Ops** as sub-agents when assigning work
- Sub-agents share memory and kanban with the main session
- Max 3 parallel tasks at once (Hermes default)

## Setup

Tell Hermes once:

```
Set up the CTO loop for [owner/repo]. 
Send approvals to me on [Telegram / Slack / Discord / WhatsApp].
```

What Hermes does:
1. Saves `github-repo` and `approval-platform` to memory
2. Runs `hermes cron add` for triage, health check, and morning report
3. Confirms setup and shows the live kanban board

## Live board

```bash
hermes kanban watch    # live dashboard — see all tasks in real time
hermes kanban list     # snapshot of current tasks
```

## Customization (tell Hermes anytime)

```
pause the CTO loop until Monday
only work on bugs this week
skip issue #42, it's blocked on design
make triage run every 30 minutes
show me the kanban board
what is the Dev Agent working on right now?
```

## What the founder actually does

Receive a message. Read 10 lines. Reply YES or NO. That's it.
