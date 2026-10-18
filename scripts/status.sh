#!/usr/bin/env bash
# Founder-readable status for the current Oh My Hermes project.

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.hermes/hermes-agent/venv/bin:$PATH"

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current_project() {
  if [ -x "$SCRIPT_DIR/project.sh" ]; then
    "$SCRIPT_DIR/project.sh" current
  elif [ -f "$HERMES_HOME/projects/current" ]; then
    cat "$HERMES_HOME/projects/current"
  else
    echo "default"
  fi
}

configured() {
  local key="$1"
  if [ -n "${!key:-}" ] || python3 - "$HERMES_HOME/.env" "$key" <<'CHECK'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
for line in path.read_text().splitlines() if path.exists() else []:
    match = re.fullmatch(r"(?:export\s+)?" + re.escape(sys.argv[2]) + r"\s*=\s*(.*)", line)
    if match and match[1].strip().strip("\"'"):
        sys.exit(0)
sys.exit(1)
CHECK
  then echo "configured (unverified)"; else echo "not configured"; fi
}

line() {
  printf '%-14s %s\n' "$1" "$2"
}

project="$(current_project)"
GITHUB_REPO="$(bash "$SCRIPT_DIR/project.sh" get GITHUB_REPO "$project")"
PRODUCTION_URL="$(bash "$SCRIPT_DIR/project.sh" get PRODUCTION_URL "$project")"

echo "Oh My Hermes Status"
echo "==================="
line "Project" "$project"
line "Repo" "${GITHUB_REPO:-not connected}"
line "Production" "${PRODUCTION_URL:-not connected}"

if command -v hermes >/dev/null 2>&1; then
  line "Hermes" "$(hermes --version 2>/dev/null || echo unavailable)"
  gateway_status="$(hermes gateway status 2>/dev/null || true)"
  if [ -n "$gateway_status" ]; then
    if grep -q "User gateway service is running" <<< "$gateway_status" || grep -q "Active: active" <<< "$gateway_status"; then
      line "Gateway" "running"
    else
      line "Gateway" "$(head -1 <<< "$gateway_status")"
    fi
  else
    line "Gateway" "unknown"
  fi
  model_line="$(hermes config show 2>/dev/null | grep -E "Model:|provider|default" | head -1 | sed -E 's/^[[:space:]]+//; s/[{}]//g' || true)"
  line "Model" "${model_line:-unknown}"
  cron_count="$(hermes cron list 2>/dev/null | grep -Ec '^[[:space:]]*[0-9]+|oh-my-hermes' || true)"
  line "Crons" "${cron_count:-0} visible"
else
  line "Hermes" "not installed"
  line "Gateway" "not available"
  line "Model" "not available"
  line "Crons" "not available"
fi

line "OpenAI" "$(configured OPENAI_API_KEY)"
line "Buffer" "$(configured BUFFER_API_KEY)"
line "Seedance" "$(configured ARK_API_KEY)"

dead_dir="$HERMES_HOME/oh-my-hermes/dead-letter/$project"
if [ -d "$dead_dir" ]; then
  dead_count="$(find "$dead_dir" -type f | wc -l | tr -d ' ')"
else
  dead_count="0"
fi
line "Dead letters" "$dead_count"

echo ""
echo "Next:"
if [ "${dead_count:-0}" != "0" ]; then
  echo "- Review failed jobs in $dead_dir"
elif [ -z "${GITHUB_REPO:-}" ]; then
  echo "- Add repo context with: project.sh switch $project --repo owner/repo"
elif [ -z "${PRODUCTION_URL:-}" ]; then
  echo "- Add production URL after first deploy"
else
  echo "- Send: ship this idea: <one sentence>"
fi
