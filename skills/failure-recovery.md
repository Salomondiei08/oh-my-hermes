---
name: failure-recovery
description: Use when cron, gateway, deploy, log scanning, or agent work fails and the founder needs a saved error with recovery steps
version: 1.0.0
tags: [cron, failure, recovery, dead-letter, operations]
---

## When to Use

- A scheduled job fails.
- A long-running agent stops without a useful founder-visible reason.
- The founder asks why an autonomous loop is stuck.

## Prerequisites

- `~/.hermes/scripts/run-cron-safe.sh` installed.
- Notification backend configured for alerts when available.

## Procedure

1. Wrap recurring jobs with:
   ```bash
   ~/.hermes/scripts/run-cron-safe.sh --project myapp --name log-scan -- command args
   ```
2. On failure, inspect the newest file under:
   ```bash
   ~/.hermes/oh-my-hermes/dead-letter/myapp/
   ```
3. Redact secrets before summarizing.
4. Create or update a kanban task with the failing command, exit code, likely
   cause, and next recovery action.
5. Notify the founder only for actionable new patterns.

## Pitfalls

- Do not paste full command output if it includes request bodies or credentials.
- Do not retry paid or destructive operations automatically.

## Verification

- A failed wrapped command creates a `600` dead-letter file.
- `/status` or `project-status` reports a non-zero dead-letter count.
