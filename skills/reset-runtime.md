---
name: reset-runtime
description: Use when a Hermes server has stale gateway sessions, bad runtime state, or must be backed up before a fresh agent setup
version: 1.0.1
tags: [reset, backup, runtime, gateway, recovery]
---

## When to Use

- A Telegram bot keeps using stale provider, model, or session state.
- The founder wants a brand new Hermes agent on an existing server.
- Runtime state should be backed up before reconfiguration.

## Prerequisites

- Shell access to the server.
- Explicit founder approval.

## Procedure

1. Confirm this is a runtime reset, not a repo reset.
2. Identify and close every other CLI session, worker and scheduled writer first;
   the helper stops the gateway/dashboard but cannot prove arbitrary CLI writers
   have exited. Set the intended HERMES_HOME and durable HERMES_BACKUP_DIR outside
   that home, then run:
   ```bash
   "${HERMES_HOME:-$HOME/.hermes}/scripts/reset-runtime.sh" --yes
   ```
3. Check exit status. Stop/snapshot failure must abort before moving state. Keep
   the owner-only `.tar.gz` backup path and reset directory printed by the helper.
   It snapshots SQLite using the backup API, then moves state.db together with its
   WAL/SHM siblings and sessions/checkpoints/logs aside. Follow backup-hermes-data
   for an isolated filtered-extraction restore rehearsal before relying on recovery.
4. Re-run `server-bootstrap` or `setup-cto` only for the intended setup. Verify
   profile, credentials, gateway identity and health before resuming scheduled work.

## Pitfalls

- Do not delete `.env`, skills, workflows, agents, or scripts.
- Do not run destructive cleanup without a backup.

## Verification

- Backup archive exists, is owner-only, and its isolated restore rehearsal is recorded.
- Stale sessions/logs/state were moved aside.
- Credentials and installed Oh My Hermes files remain available.
