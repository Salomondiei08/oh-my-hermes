---
name: backup-hermes-data
description: Use when Hermes memory, skills, or kanban data needs to be backed up before a major change, on a schedule, or after a crash recovery
version: 1.0.1
tags: [backup, ops, recovery, memory, kanban]
metadata:
  hermes:
    tags: [backup, data, ops]
    requires_toolsets: [terminal]
---

## When to Use

Before upgrades/destructive changes or for scheduled runtime recovery snapshots.

## Prerequisites

- Python 3.9+ for snapshot creation; Python 3.12+ for the filtered extraction
  rehearsal below. Installed `scripts/backup-runtime.py` and readable HERMES_HOME.
- Durable destination outside HERMES_HOME, enough disk space, and knowledge of
  every writer (gateway, CLI sessions, workers and cron).
- Remote credentials and encryption tooling only if uploading; never store them
  in the archive command, Git, task body or memory.

## Procedure

1. Identify and stop all Hermes writers using the installed runtime's supported
   stop mechanism. Verify no sessions/workers/cron still write runtime files;
   abort if quiescence cannot be established. SQLite's backup API protects database
   consistency, but does not synchronize separate memory/session files.
2. Create an owner-only destination on durable storage, outside HERMES_HOME:
   ```bash
   umask 077
   BACKUP_DIR="${HERMES_BACKUP_DIR:-$HOME/hermes-backups}"
   mkdir -p "$BACKUP_DIR"
   chmod 700 "$BACKUP_DIR"
   python3 "${HERMES_HOME:-$HOME/.hermes}/scripts/backup-runtime.py" --destination "$BACKUP_DIR"
   ```
   Check exit status and the returned owner-only `.tar.gz` archive (root `hermes/`). The helper copies runtime
   files and uses SQLite backup connections for databases; never tar a live DB/WAL
   pair or discard WAL before snapshotting. Do not silently fall back to raw copies.
3. Inspect archive inventory privately: credentials may be included and must remain
   owner-only. Record archive path and timestamp at
   `project:<slug>:last-hermes-backup` (runtime-wide snapshot, scoped log).
4. Perform a restore rehearsal before relying on this backup. With Python 3.12+,
   extract into a fresh owner-only directory outside the live runtime:
   ```python
   import os, pathlib, sys, tarfile, tempfile
   if sys.version_info < (3, 12):
       raise SystemExit("Restore rehearsal requires Python 3.12+ extraction filters")
   os.umask(0o077)
   archive = pathlib.Path(sys.argv[1]).resolve()
   rehearsal = pathlib.Path(tempfile.mkdtemp(prefix="hermes-restore-"))
   with tarfile.open(archive, "r:gz") as source:
       source.extractall(rehearsal, filter="data")
   runtime = rehearsal / "hermes"
   if not runtime.is_dir():
       raise SystemExit("Archive has no hermes/ runtime root")
   print(runtime)
   ```
   Pass the returned archive path as the Python program's first argument. Never
   remove the extraction filter or extract over production. With networking, cron
   and gateway disabled, use the installed Hermes version's documented read-only/
   offline APIs against that isolated `hermes/` directory to read representative
   memory, tasks and sessions. Run SQLite `PRAGMA integrity_check` for each restored
   database and compare representative records/counts with the quiescent source.
   Record actual checks and limitations; extraction alone is not successful recovery.
5. For off-host recovery, encrypt the snapshot with an existing approved tool/key
   before upload to private S3/rclone storage; keep the recovery key separately.
   Verify a downloaded copy decrypts and passes the same rehearsal. Never print
   tokens, signed URLs, archive contents or credentials. Do not prune old backups
   automatically during this procedure.
6. Restart only writers intentionally stopped and verify runtime health. A real
   restore needs explicit destructive-change approval, stopped writers, an additional
   pre-restore snapshot, and the rehearsed version-compatible restore process.

## Pitfalls

- SQLite backup is database-consistent, not a cross-file runtime transaction.
- Credential-bearing snapshots need owner-only local access and encrypted remote storage.
- Never restore into a live Hermes directory or start messaging/cron during a rehearsal.

## Verification

Snapshot helper and integrity checks pass, memory/tasks/sessions are read in an
isolated restore rehearsal, and remote recovery is reported separately if untested.
