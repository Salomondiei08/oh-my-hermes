#!/usr/bin/env bash
# One-command-ish server bootstrap for a fresh Hermes + Oh My Hermes host.

set -euo pipefail

PROJECT="default"
REPO=""
PRODUCTION_URL=""
SETUP_TELEGRAM=0
INSTALL_DIR="${OH_MY_HERMES_DIR:-/tmp/oh-my-hermes}"

usage() {
  cat <<'USAGE'
Usage:
  server-bootstrap.sh [--project slug] [--repo owner/repo] [--url https://app] [--telegram]

Environment:
  TELEGRAM_BOT_TOKEN may be set before running. If --telegram is passed and the
  token is missing, the script prompts securely without echoing it.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2:-default}"; shift 2 ;;
    --repo) REPO="${2:-}"; shift 2 ;;
    --url|--production-url) PRODUCTION_URL="${2:-}"; shift 2 ;;
    --telegram) SETUP_TELEGRAM=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

if ! command -v hermes >/dev/null 2>&1; then
  echo "[INFO] Installing Hermes Agent"
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
fi

if [ -e "$INSTALL_DIR" ] && [ ! -d "$INSTALL_DIR/.git" ]; then
  INSTALL_DIR="${INSTALL_DIR}-$(date -u +%Y%m%dT%H%M%SZ)"
fi

if [ ! -d "$INSTALL_DIR/.git" ]; then
  git clone https://github.com/salomondiei08/oh-my-hermes "$INSTALL_DIR"
else
  git -C "$INSTALL_DIR" pull --ff-only
fi

bash "$INSTALL_DIR/install.sh"

if [ "$SETUP_TELEGRAM" -eq 1 ]; then
  env_file="${HERMES_HOME:-$HOME/.hermes}/.env"
  mkdir -p "$(dirname "$env_file")"
  touch "$env_file"
  chmod 600 "$env_file"
  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
    read -r -s -p "Telegram bot token: " TELEGRAM_BOT_TOKEN
    echo ""
  fi
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && ! grep -q '^TELEGRAM_BOT_TOKEN=' "$env_file"; then
    escaped_token="${TELEGRAM_BOT_TOKEN//\'/\'\\\'\'}"
    printf "TELEGRAM_BOT_TOKEN='%s'\n" "$escaped_token" >> "$env_file"
    echo "[OK] Telegram token saved to $env_file"
  fi
  hermes gateway setup >/dev/null 2>&1 || true
  hermes gateway start >/dev/null 2>&1 || true
fi

project_args=(switch "$PROJECT")
[ -n "$REPO" ] && project_args+=(--repo "$REPO")
[ -n "$PRODUCTION_URL" ] && project_args+=(--url "$PRODUCTION_URL")
"${HERMES_HOME:-$HOME/.hermes}/scripts/project.sh" "${project_args[@]}"

PROJECT_SLUG="$PROJECT" GITHUB_REPO="$REPO" PRODUCTION_URL="$PRODUCTION_URL" bash "${HERMES_HOME:-$HOME/.hermes}/scripts/setup-cto.sh" || true
"${HERMES_HOME:-$HOME/.hermes}/scripts/status.sh"
