---
name: cto-status-report
description: Use when the CTO Agent needs to send the founder a summary of everything in flight, completed, or blocked
version: 2.0.0
tags: [cto, report, kanban, status, founder]
---

## Overview

Summarizes product outcomes, decisions, release health, security, and actionable
runtime signals. PR activity appears only when it needs a founder decision.

## When to Use

- Every morning at 9am (cron-triggered)
- After any incident
- When founder asks "what's going on?"
- When CTO Agent detects a stalled task (> 4 hours in same column)

## Prerequisites

- Hermes kanban is available and initialized.
- Hermes memory contains deployment and health logs if deployments have happened.
- Founder notification channel is configured through `send-notification` or Hermes Gateway.

## Procedure

1. **Read kanban state:**
   ```bash
   hermes kanban list
   hermes kanban stats
   ```

2. **Read recent deployment log:**
   Retrieve from Hermes memory: key `deployment-log` (last 5 entries)

3. **Read health log:**
   Retrieve from Hermes memory: key `ops-health-log` (last 24 hours)

4. **Read pending approvals:**
   Retrieve from Hermes memory: key `pending-approval`

5. **Compose report** — plain English, lead with what matters most:

   ```
   Good morning. Here's where things stand.

   Shipped since last report:
   - [Feature/fix in plain English] — live at [url]
   - [Feature/fix in plain English]

   In progress right now:
   - [What Dev Agent is working on] (started [X hours ago])

   Waiting for your input:
   - [Product outcome] — reply YES to ship, NO with feedback, CLOSE, or LATER

   Blocked:
   - [What's blocked and why it needs a decision]

   Product signals:
   - [Meaningful customer, growth, security, or runtime learning]

   Everything else is healthy. Production is responding in [Xms].
   ```

   If nothing is blocked and nothing awaits approval:
   ```
   Good morning. All good — nothing needs your attention today.
   [n] tasks completed this week. Production is healthy.
   ```

6. **Send via `send-notification`** using founder's primary platform.

7. **Save to Hermes memory:** key `status-report-log`, append `{ sentAt: now, blockedCount, awaitingCount, doneCount }`.

## Tone rules

- Lead with what requires founder action — put blocked/awaiting items first
- If nothing needs action, say so in the first sentence
- Never list file names, error codes, or technical stack details
- "The login bug is fixed" not "Fixed null pointer in src/middleware.ts:42"
- Keep it under 200 words — founders are busy

## Pitfalls

- Do not send a report if there is nothing to report (no pending items, no incidents). Skip morning report and resume tomorrow.
- If the health log shows intermittent failures (< 3 in 24h), mention it briefly: "Had two brief hiccups overnight — nothing serious, monitoring closely."
- If production has been down > 5 minutes, do NOT wait for the morning report. Alert immediately via `send-notification`.

## Verification

- Report sent and logged to memory
- Founder received it on their platform
- All blocked and awaiting-approval items mentioned
