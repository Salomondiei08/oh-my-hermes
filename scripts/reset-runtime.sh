#!/usr/bin/env bash
# Stop before snapshotting; a failed stop must never become a data move.
set -euo pipefail
umask 077
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${1:-}" = --help ] || [ "${1:-}" = -h ]; then
  echo 'Usage: reset-runtime.sh --yes (close other CLI sessions first)'
  exit 0
fi
[ "$#" -eq 1 ] && [ "$1" = --yes ] || { echo '[ERROR] Reset requires --yes; close all other Hermes sessions first' >&2; exit 2; }
[ -d "$HERMES_HOME" ] || { echo '[ERROR] Hermes home does not exist' >&2; exit 1; }
command -v hermes >/dev/null || { echo '[ERROR] hermes required to stop runtime safely' >&2; exit 1; }
hermes gateway stop || { echo '[ERROR] Gateway stop failed; no files moved' >&2; exit 1; }
if hermes dashboard --help >/dev/null 2>&1; then
  hermes dashboard --stop || { echo '[ERROR] Dashboard stop failed; no files moved' >&2; exit 1; }
fi
status="$(hermes gateway status 2>&1 || true)"
if ! printf '%s' "$status" | grep -Eqi 'not running|inactive|stopped|no gateway'; then
  echo '[ERROR] Cannot confirm gateway stopped; no files moved' >&2
  exit 1
fi
if printf '%s' "$status" | grep -Eqi 'is running|active: active|"running"[[:space:]]*:[[:space:]]*true'; then
  echo '[ERROR] Gateway still reports running; no files moved' >&2
  exit 1
fi
command -v lsof >/dev/null || { echo '[ERROR] lsof required to check other runtime writers' >&2; exit 1; }
set +e
open_files="$(lsof -t +D "$HERMES_HOME" 2>/dev/null)"
lsof_code=$?
set -e
if [ -n "$open_files" ] || [ "$lsof_code" -gt 1 ]; then
  echo '[ERROR] Runtime files are open or writer check failed; close all sessions before reset' >&2
  exit 1
fi
backup_dir="${HERMES_BACKUP_DIR:-$(dirname "$HERMES_HOME")/.hermes-backups}"
tarball="$(python3 "$SCRIPT_DIR/backup-runtime.py" --destination "$backup_dir")"
[ -s "$tarball" ] || { echo '[ERROR] Snapshot missing; no files moved' >&2; exit 1; }
reset_dir="$(mktemp -d "$HERMES_HOME/reset-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")"
for path in sessions state.db state.db-wal state.db-shm checkpoints logs agent.log errors.log; do
  if [ -e "$HERMES_HOME/$path" ]; then mv "$HERMES_HOME/$path" "$reset_dir/"; fi
done
echo "[OK] Backup: $tarball"
echo "[OK] Runtime state moved to: $reset_dir"
echo '[OK] Configuration, credentials, skills, roles, and profiles preserved'
