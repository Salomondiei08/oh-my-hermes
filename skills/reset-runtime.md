---
name: reset-runtime
description: Use when a Hermes server has stale gateway sessions, bad runtime state, or must be backed up before a fresh agent setup
version: 1.0.0
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
2. Run:
   ```bash
   ~/.hermes/scripts/reset-runtime.sh --yes
   ```
3. Keep the backup path from the output.
4. Re-run `server-bootstrap` or `setup-cto`.

## Pitfalls

- Do not delete `.env`, skills, workflows, agents, or scripts.
- Do not run destructive cleanup without a backup.

## Verification

- Backup tarball exists.
- Stale sessions/logs/state were moved aside.
- Credentials and installed Oh My Hermes files remain available.
