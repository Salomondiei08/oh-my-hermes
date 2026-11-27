---
name: kanban-task
description: Use when any agent starts, updates, or completes a unit of work that should be visible on the Hermes kanban board
version: 1.1.1
tags: [kanban, task, tracking, ops, autonomous]
metadata:
  hermes:
    tags: [kanban, tracking, agents]
    requires_toolsets: [terminal]
---

## Overview

Creates and updates cards in the Hermes kanban board (`hermes kanban`). Every agent action that moves work forward must call this skill — the kanban is the source of truth the CTO reads via `hermes kanban watch`.

## When to Use

- A GitHub issue is accepted into the CTO loop.
- An agent starts work, creates a PR, passes review, deploys, or gets blocked.
- The founder needs current task state visible in the live board.

## Prerequisites

- Hermes v0.13+ for heartbeat and zombie recovery behavior.
- Hermes v2026.5.7+ for durable multi-agent Kanban with automatic retries and
  per-task recovery context — earlier versions still work but lack retry history.
- Kanban initialized with `hermes kanban init`.
- A concrete task title and verifiable acceptance criteria.
- A target assignee profile such as `pm`, `dev`, `security`, `qa`, or `ops`.

## Kanban columns

| Status | Meaning |
|---|---|
| Triage | Raw idea or unclear issue, not ready for implementation |
| Todo | Defined work waiting on dependencies or assignment |
| Ready | Assigned work waiting for the dispatcher to spawn the worker |
| Running | Worker profile is actively handling the task |
| Blocked | Worker needs human input or the retry circuit breaker tripped |
| Done | Completed with summary and handoff metadata |

## Procedure

**Create a new task (PM Agent, after triaging an issue):**
```bash
hermes kanban create "Fix: [what] — Issue #[n]" \
  --assignee dev \
  --priority [score] \
  --body "Why: [one sentence]. Acceptance: [verifiable checks]."
```
Or via agent toolset (preferred inside a skill):
```
kanban_create title="Fix: [what]" assignee="dev" body="Issue #[n] | Why: [one sentence] | Acceptance: [verifiable check, e.g. 'GET /api/health returns 200 AND existing tests pass']"
```

Acceptance criteria must be a concrete, verifiable check — not "it works." If you cannot write a specific check, ask for clarification before creating the card.

Save returned task ID to Hermes memory: key `project:<slug>:task-id-issue-[n]`.

**Claim and move to running (Dev Agent):**
```bash
hermes kanban claim [task-id]
hermes kanban comment [task-id] "Dev Agent started at [time]. Engine: [hermes/claude-code/codex]"
```

For long-running work, the worker should call `kanban_heartbeat(note="...")` every few minutes. If a worker crashes or stops heartbeating, Hermes reclaims the task and returns it to `ready` for retry.

**Hand off to security review (Dev Agent, after PR created):**
```bash
hermes kanban complete [task-id] \
  --summary "PR #[number] created: [url]. Implementation ready for security review." \
  --metadata '{"pr_number":"[number]","pr_url":"[url]","next_assignee":"security"}'
```
Then create or assign the next review task to Security Agent.

**Record review passed (QA Agent, after review passes):**
```bash
hermes kanban comment [task-id] "QA passed. Preview healthy. Approval sent to founder at [time]."
```

**Complete (Ops Agent, after merge + healthy deploy):**
```bash
hermes kanban complete [task-id]
hermes kanban comment [task-id] "Merged PR #[n]. Production healthy at [time]."
```

**Block (any agent, when stalled):**
```bash
hermes kanban block [task-id]
hermes kanban comment [task-id] "Blocked: [what is blocking and since when]"
```
Then load `send-notification` — CTO Agent is alerted immediately.

## Quick reference

| Agent | Action | Command |
|---|---|---|
| PM | Issue triaged | `kanban_create(..., assignee="dev")` |
| Dev | Starting work | `hermes kanban claim [id]` |
| Dev | Long-running work | `kanban_heartbeat(note="...")` |
| Dev | PR created | `hermes kanban complete [id] --summary ... --metadata ...` |
| QA | Review passed | `kanban_comment [id] "QA passed..."` |
| Ops | Deployed healthy | `hermes kanban complete [id]` |
| Any | Cannot proceed | `hermes kanban block [id]` |

## Zombie recovery (v0.13+)

If a Dev Agent crashes mid-task, Hermes detects the missed heartbeat and moves
the card back to `ready` automatically. The next worker that claims it gets the
prior run history and can continue from the handoff context.

## Durable multi-agent Kanban (v2026.5.7+)

Tasks now have a built-in retry ledger. When a worker fails, Hermes records the
failure context (exit code, last heartbeat, partial output) and automatically
retries with the next available worker. After a configurable retry limit, the
card moves to `blocked` and the CTO is notified. No manual intervention is
needed unless the card reaches its retry limit or the spawn circuit breaker
gives up.

## Live monitoring

To watch the board in real time:
```bash
hermes kanban watch    # live dashboard
hermes kanban list     # snapshot
hermes kanban stats    # summary counts
```

## Pitfalls

- Save the task ID to memory immediately after `kanban_create` — without it you cannot update or link the card later.
- Do not skip this skill. The kanban is how the CTO monitors the loop.
- `hermes kanban complete` is final. For partial progress, use `kanban_comment` to log state.
- Blocked cards are auto-surfaced in `hermes kanban watch`. Always add a comment explaining what is blocking before blocking the card.
- Worker profiles should prefer `kanban_*` tool calls over shelling out to `hermes kanban` when the dispatcher spawned them.

## Verification

`hermes kanban list` shows the card in the correct state with an accurate comment thread.
