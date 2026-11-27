#!/usr/bin/env bash
# Configure optional creative and publishing credentials without exposing them in chat.

set -euo pipefail
umask 077

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
ENV_FILE="$HERMES_HOME/.env"

usage() { echo "Usage: $0 [--buffer|--seedance|--openai|--all|--check]"; }

has_value() {
  local key="$1"
  [ -n "${!key:-}" ] || grep -Eq "^${key}=.+" "$ENV_FILE" 2>/dev/null
}

upsert_secret() {
  local key="$1" value="$2" temporary
  temporary="$(mktemp "${TMPDIR:-/tmp}/omh-env.XXXXXX")"
  if [ -f "$ENV_FILE" ]; then
    awk -v key="$key" 'index($0, key "=") != 1 { print }' "$ENV_FILE" > "$temporary"
  fi
  value="${value//\'/\'\\\'\'}"
  printf "%s='%s'\n" "$key" "$value" >> "$temporary"
  mkdir -p "$HERMES_HOME"
  mv "$temporary" "$ENV_FILE"
  chmod 600 "$ENV_FILE"
}

prompt_secret() {
  local key="$1" label="$2" value
  if has_value "$key"; then
    echo "[OK] $label is already configured"
    return
  fi
  read -r -s -p "$label: " value
  echo ""
  if [ -z "$value" ]; then
    echo "[SKIP] $label was not configured"
    return
  fi
  upsert_secret "$key" "$value"
  unset value
  echo "[OK] $label saved to $ENV_FILE"
}

configure_buffer() {
  if ! command -v buffer >/dev/null 2>&1; then
    echo "[NEEDED] Install the official CLI: npm install -g @bufferapp/cli"
  fi
  echo "Create a personal key in Buffer Settings > API. Do not paste it into chat."
  prompt_secret BUFFER_API_KEY "Buffer API key"
  echo "Run 'buffer doctor' after opening a new Hermes session."
}

configure_seedance() {
  echo "Create an Ark API key in the official Volcengine console after enabling Seedance."
  prompt_secret ARK_API_KEY "Volcengine Ark API key"
  has_value SEEDANCE_BASE_URL || upsert_secret SEEDANCE_BASE_URL "https://ark.cn-beijing.volces.com/api/v3"
  has_value SEEDANCE_MODEL || upsert_secret SEEDANCE_MODEL "doubao-seedance-2-0-260128"
  echo "[OK] Seedance defaults configured; generation still requires spend approval"
}

configure_openai() {
  echo "OpenAI is optional unless selected as the Hermes model or creative provider."
  prompt_secret OPENAI_API_KEY "OpenAI API key"
}

check_integrations() {
  for key in OPENAI_API_KEY BUFFER_API_KEY ARK_API_KEY; do
    if has_value "$key"; then echo "[OK] $key configured"; else echo "[OPTIONAL] $key not configured"; fi
  done
}

case "${1:---check}" in
  --buffer) configure_buffer ;;
  --seedance) configure_seedance ;;
  --openai) configure_openai ;;
  --all) configure_openai; configure_buffer; configure_seedance ;;
  --check) check_integrations ;;
  -h|--help) usage ;;
  *) usage; exit 2 ;;
esac
