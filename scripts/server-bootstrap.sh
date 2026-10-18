#!/usr/bin/env bash
# One-command-ish server bootstrap for a fresh Hermes + Oh My Hermes host.

set -euo pipefail
umask 077
for tool in git curl python3; do command -v "$tool" >/dev/null || { echo "[ERROR] $tool required" >&2; exit 1; }; done

export PATH="$HOME/.local/bin:$HOME/.hermes/hermes-agent/venv/bin:$PATH"

PROJECT="default"
REPO=""
PRODUCTION_URL=""
SETUP_TELEGRAM=0
EXPECTED_BOT="${TELEGRAM_EXPECTED_BOT_USERNAME:-}"
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
    --telegram-bot) EXPECTED_BOT="${2:-}"; shift 2 ;;
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
  remote="$(git -C "$INSTALL_DIR" remote get-url origin)"
  case "$remote" in
    https://github.com/salomondiei08/oh-my-hermes|https://github.com/salomondiei08/oh-my-hermes.git|git@github.com:salomondiei08/oh-my-hermes.git) ;;
    *) echo "[ERROR] Existing checkout has an unexpected origin; refusing to execute it" >&2; exit 1 ;;
  esac
  git -C "$INSTALL_DIR" pull --ff-only
fi

bash "$INSTALL_DIR/install.sh"

if [ "$SETUP_TELEGRAM" -eq 1 ]; then
  env_file="${HERMES_HOME:-$HOME/.hermes}/.env"
  mkdir -p "$(dirname "$env_file")"
  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
    read -r -s -p "Telegram bot token: " TELEGRAM_BOT_TOKEN
    echo ""
  fi
  if [ -z "$EXPECTED_BOT" ]; then
    read -r -p 'Expected bot username (without @): ' EXPECTED_BOT
  fi
  [ -n "$EXPECTED_BOT" ] && [ -n "${TELEGRAM_BOT_TOKEN:-}" ] || { echo '[ERROR] Token and expected bot username required' >&2; exit 1; }
  TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" python3 - "$EXPECTED_BOT" <<'BOTCHECK'
import json, os, sys, urllib.request
try:
    with urllib.request.urlopen('https://api.telegram.org/bot' + os.environ['TELEGRAM_BOT_TOKEN'] + '/getMe', timeout=15) as response:
        result = json.load(response)
    if not result.get('ok') or result.get('result', {}).get('username', '').lower() != sys.argv[1].lstrip('@').lower():
        raise ValueError('bot identity mismatch')
    print('[OK] Telegram bot identity matches expected username')
except Exception:
    sys.exit('[ERROR] Bot identity verification failed; no credentials changed')
BOTCHECK
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
    [ ! -L "$env_file" ] || { echo '[ERROR] Refusing symlinked environment file' >&2; exit 1; }
    touch "$env_file"
    chmod 600 "$env_file"
    escaped_token="${TELEGRAM_BOT_TOKEN//\'/\'\\\'\'}"
    tmp_env="$(mktemp)"
    awk 'index($0, "TELEGRAM_BOT_TOKEN=") != 1 { print }' "$env_file" > "$tmp_env"
    printf "TELEGRAM_BOT_TOKEN='%s'\n" "$escaped_token" >> "$tmp_env"
    mv "$tmp_env" "$env_file"
    chmod 600 "$env_file"
    echo "[OK] Telegram token saved to $env_file"
  fi
  hermes gateway setup
  hermes gateway start
fi

project_args=(switch "$PROJECT")
[ -n "$REPO" ] && project_args+=(--repo "$REPO")
[ -n "$PRODUCTION_URL" ] && project_args+=(--url "$PRODUCTION_URL")
"${HERMES_HOME:-$HOME/.hermes}/scripts/project.sh" "${project_args[@]}"

REPO="$("${HERMES_HOME:-$HOME/.hermes}/scripts/project.sh" get GITHUB_REPO "$PROJECT")"
PRODUCTION_URL="$("${HERMES_HOME:-$HOME/.hermes}/scripts/project.sh" get PRODUCTION_URL "$PROJECT")"
PROJECT_SLUG="$PROJECT" GITHUB_REPO="$REPO" PRODUCTION_URL="$PRODUCTION_URL" bash "${HERMES_HOME:-$HOME/.hermes}/scripts/setup-cto.sh"
"${HERMES_HOME:-$HOME/.hermes}/scripts/status.sh"
