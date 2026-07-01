#!/usr/bin/env bash
# Back up and clear stale Hermes runtime state without deleting credentials.

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
YES=0

for arg in "$@"; do
  case "$arg" in
    --yes) YES=1 ;;
    -h|--help)
      echo "Usage: reset-runtime.sh --yes"
      exit 0
      ;;
  esac
done

if [ "$YES" -ne 1 ]; then
  echo "[ERROR] Refusing to reset runtime state without --yes"
  echo "        This backs up ~/.hermes and moves stale sessions/logs/state aside."
  exit 2
fi

[ -d "$HERMES_HOME" ] || { echo "[ERROR] $HERMES_HOME not found"; exit 1; }

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_dir="$HOME/.hermes-backups"
reset_dir="$HERMES_HOME/reset-$timestamp"
mkdir -p "$backup_dir" "$reset_dir"
tarball="$backup_dir/hermes-runtime-$timestamp.tar.gz"

tar -czf "$tarball" -C "$(dirname "$HERMES_HOME")" "$(basename "$HERMES_HOME")"
chmod 600 "$tarball"

if command -v hermes >/dev/null 2>&1; then
  hermes gateway stop >/dev/null 2>&1 || true
  hermes dashboard --stop >/dev/null 2>&1 || true
fi

for path in sessions state.db checkpoints logs agent.log errors.log; do
  if [ -e "$HERMES_HOME/$path" ]; then
    mv "$HERMES_HOME/$path" "$reset_dir/"
  fi
done

echo "[OK] Backup: $tarball"
echo "[OK] Moved stale runtime state to: $reset_dir"
echo "[OK] Preserved config, skills, workflows, agents, scripts, and .env"
