#!/usr/bin/env bash
# Run a cron command and save actionable failure context.

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
PROJECT="default"
NAME="cron"

usage() {
  echo "Usage: run-cron-safe.sh [--project slug] [--name job-name] -- command [args...]"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2:-default}"; shift 2 ;;
    --name) NAME="${2:-cron}"; shift 2 ;;
    --) shift; break ;;
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

[ "$#" -gt 0 ] || { usage; exit 2; }

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
dead_dir="$HERMES_HOME/oh-my-hermes/dead-letter/$PROJECT"
mkdir -p "$dead_dir"
log_file="$dead_dir/${timestamp}-${NAME}.log"
redacted_command="$(printf '%s' "$*" | sed -E 's/(token|secret|password|api[_-]?key)=([^[:space:];]+)/\1=[REDACTED]/Ig')"

set +e
"$@" >"$log_file.tmp" 2>&1
code=$?
set -e

if [ "$code" -eq 0 ]; then
  rm -f "$log_file.tmp"
  exit 0
fi

{
  echo "project=$PROJECT"
  echo "job=$NAME"
  echo "timestamp=$timestamp"
  echo "exit_code=$code"
  echo "command=$redacted_command"
  echo ""
  echo "--- output ---"
  sed -E 's/(token|secret|password|api[_-]?key)=([^[:space:]]+)/\1=[REDACTED]/Ig' "$log_file.tmp"
} > "$log_file"
rm -f "$log_file.tmp"
chmod 600 "$log_file"

message="Oh My Hermes job failed: $NAME for $PROJECT. Dead letter: $log_file"
if command -v hermes >/dev/null 2>&1; then
  hermes send "$message" >/dev/null 2>&1 || true
fi

echo "$message" >&2
exit "$code"
