---
name: backup-hermes-data
description: Use when Hermes memory, skills, or kanban data needs to be backed up before a major change, on a schedule, or after a crash recovery
version: 1.0.0
tags: [backup, ops, recovery, memory, kanban]
metadata:
  hermes:
    tags: [backup, data, ops]
    requires_toolsets: [terminal]
---

## Overview

Tarballs `~/.hermes/` and ships it to a remote destination (S3, Dropbox, or local path). Hermes has no native backup — this skill is the only way to protect memory, skills, kanban state, and profiles from data loss.

## When to Use

- Before `hermes update` or any version upgrade
- On a daily cron as routine protection
- After an agent crash to capture last-known-good state
- Before destructive operations (profile reset, skill purge)

## Prerequisites

- `~/.hermes/` exists with data
- One of: `aws` CLI + S3 bucket, `rclone` configured, or a local backup path

## Procedure

**1. Snapshot to local file:**
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="/tmp/hermes-backup-$TIMESTAMP.tar.gz"
tar -czf "$BACKUP_FILE" -C "$HOME" \
  --exclude='.hermes/cache/playwright' \
  .hermes
echo "Backup written: $BACKUP_FILE ($(du -sh "$BACKUP_FILE" | cut -f1))"
```

**2. Ship to remote — choose one:**

S3:
```bash
aws s3 cp "$BACKUP_FILE" "s3://$HERMES_BACKUP_BUCKET/hermes/$TIMESTAMP.tar.gz"
```

Rclone (Dropbox, Google Drive, Backblaze, etc.):
```bash
rclone copy "$BACKUP_FILE" "$HERMES_RCLONE_REMOTE:hermes-backups/"
```

Local only (keep last 7):
```bash
BACKUP_DIR="${HERMES_BACKUP_DIR:-$HOME/hermes-backups}"
mkdir -p "$BACKUP_DIR"
cp "$BACKUP_FILE" "$BACKUP_DIR/"
ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +8 | xargs -r rm
```

**3. Log to Hermes memory:**
```
Save to memory: key=last-hermes-backup value=[timestamp] destination=[where]
```

## Environment variables

| Variable | Required for | Example |
|---|---|---|
| `HERMES_BACKUP_BUCKET` | S3 | `my-hermes-backups` |
| `HERMES_RCLONE_REMOTE` | rclone | `dropbox` |
| `HERMES_BACKUP_DIR` | local only | `/mnt/backups` |

Set at least one. If none set, backup stays in `/tmp/` — ephemeral, not useful for disaster recovery.

## Cron setup (recommended)

Daily at 3am:
```bash
hermes cron add "0 3 * * *" "Run backup-hermes-data"
```

## Restore

```bash
hermes stop
tar -xzf hermes-backup-[timestamp].tar.gz -C "$HOME"
hermes gateway start
hermes profile use cto
```

## Pitfalls

- `~/.hermes/` can exceed 500MB if Playwright Chromium is installed. The `--exclude` flag above skips it.
- `~/.hermes/memory/` is the most critical directory — if nothing else, back that up.
- Never restore over a running Hermes instance — stop first.

## Verification

- Tarball exists at destination
- `tar -tzf [file] | grep memory/MEMORY.md` confirms memory is included
- Hermes memory shows `last-hermes-backup` key updated to today's date
