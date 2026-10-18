---
name: failure-recovery
description: Use when cron, gateway, deploy, log scanning, or agent work fails and the founder needs a saved error with recovery steps
version: 1.1.1
tags: [cron, failure, recovery, dead-letter, operations]
---

## When to Use

- A scheduled job fails.
- A long-running agent stops without a useful founder-visible reason.
- The founder asks why an autonomous loop is stuck.

## Prerequisites

- `~/.hermes/scripts/run-cron-safe.sh` installed.
- Notification backend only if a reviewed manual notification is needed.
- Hermes v0.19+ for cron durable audit history.

## Procedure

1. Wrap recurring jobs with:
   ```bash
   ~/.hermes/scripts/run-cron-safe.sh --project myapp --name log-scan -- command args
   ```
2. On failure, first check the Hermes cron audit history (v0.19+ durable audit):
   ```bash
   hermes cron history log-scan          # per-job history with exit codes
   hermes cron history --failed          # all failed jobs across all crons
   ```
3. Then inspect the newest dead-letter file:
   ```bash
   ~/.hermes/oh-my-hermes/dead-letter/myapp/
   ```
4. The wrapper records only project, job, timestamp and exit code. It deliberately
   discards arbitrary stdout/stderr and command arguments on success and failure;
   no automatic redaction guarantee or automatic notification exists. Inspect the
   job definition and provider audit privately for the cause. If more diagnostics
   are needed, use an explicitly reviewed secret-safe command; do not rerun an
   operation merely to capture its raw output.
5. Create/update the existing Hermes task with project/job, exit code, evidence,
   likely cause and next recovery action. Never persist raw credentials, command
   arguments or provider response bodies.
6. Optionally use send-notification with a reviewed sanitized summary for an
   actionable new failure. Verify receipt separately; wrapper failure is not proof
   any message was sent.

## Pitfalls

- Do not paste full command output if it includes request bodies or credentials.
- Do not retry paid or destructive operations automatically.
- Repeated failures require diagnosis; neither gateway restart nor job exit alone
  establishes the root cause.

## Verification

- A failed wrapped command creates a `600` dead-letter file.
- `hermes cron history` shows the job's failure with an exit code.
- `/status` or `project-status` reports a non-zero dead-letter count.
