#!/usr/bin/env bash
# Founder-readable status for the current Oh My Hermes project.

set -euo pipefail

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

load_project_env() {
  local slug="$1"
  local env_file="$HERMES_HOME/projects/$slug.env"
  if [ -f "$env_file" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$env_file"
    set +a
  fi
}

connected() {
  local key="$1"
  [ -n "${!key:-}" ] && echo "connected" || echo "not connected"
}

line() {
  printf '%-14s %s\n' "$1" "$2"
}

project="$(current_project)"
load_project_env "$project"

echo "Oh My Hermes Status"
echo "==================="
line "Project" "$project"
line "Repo" "${GITHUB_REPO:-not connected}"
line "Production" "${PRODUCTION_URL:-not connected}"

if command -v hermes >/dev/null 2>&1; then
  line "Hermes" "$(hermes --version 2>/dev/null || echo connected)"
  line "Gateway" "$(hermes gateway status 2>/dev/null | head -1 || echo unknown)"
  line "Model" "$(hermes config show 2>/dev/null | grep -E 'provider|model' | head -2 | tr '\n' ' ' || echo unknown)"
  cron_count="$(hermes cron list 2>/dev/null | grep -Ec '^[[:space:]]*[0-9]+|oh-my-hermes' || true)"
  line "Crons" "${cron_count:-0} visible"
else
  line "Hermes" "not installed"
  line "Gateway" "not available"
  line "Model" "not available"
  line "Crons" "not available"
fi

line "OpenAI" "$(connected OPENAI_API_KEY)"
line "Buffer" "$(connected BUFFER_API_KEY)"
line "Seedance" "$(connected ARK_API_KEY)"

dead_dir="$HERMES_HOME/oh-my-hermes/dead-letter"
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
