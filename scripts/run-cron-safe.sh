#!/usr/bin/env bash
# Failure metadata is durable; arbitrary tool output and arguments may contain secrets.
set -euo pipefail
umask 077
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
PROJECT="default"
NAME="cron"
usage() { echo 'Usage: run-cron-safe.sh [--project slug] [--name job-name] -- command [args...]'; }
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project|--name)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      if [ "$1" = --project ]; then PROJECT="$2"; else NAME="$2"; fi
      shift 2 ;;
    --) shift; break ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] Expected -- before command" >&2; exit 2 ;;
  esac
done
[ "$#" -gt 0 ] || { usage >&2; exit 2; }
for value in "$PROJECT" "$NAME"; do
  case "$value" in ''|.*|*[!a-zA-Z0-9._-]*) echo '[ERROR] Invalid project/job name' >&2; exit 2 ;; esac
done
set +e
"$@" >/dev/null 2>&1
code=$?
set -e
[ "$code" -ne 0 ] || exit 0
dead_dir="$HERMES_HOME/oh-my-hermes/dead-letter/$PROJECT"
mkdir -p "$dead_dir"
log_file="$(mktemp "$dead_dir/$(date -u +%Y%m%dT%H%M%SZ)-$NAME.XXXXXX")"
mv "$log_file" "$log_file.log"
log_file="$log_file.log"
{
  printf 'project=%s\njob=%s\nexit_code=%s\n' "$PROJECT" "$NAME" "$code"
  printf 'timestamp=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo 'Tool output and arguments omitted because they may contain credentials.'
  echo 'Inspect the failed job locally; send only a reviewed summary through send-notification.'
} > "$log_file"
echo "[ERROR] Job $NAME for $PROJECT failed ($code). Dead letter: $log_file" >&2
exit "$code"
