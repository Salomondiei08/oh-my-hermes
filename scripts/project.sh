#!/usr/bin/env bash
# Project context helper for Oh My Hermes.

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
PROJECTS_DIR="$HERMES_HOME/projects"
CURRENT_FILE="$PROJECTS_DIR/current"

usage() {
  cat <<'USAGE'
Usage:
  project.sh switch <slug> [--repo owner/repo] [--url https://app.example.com]
  project.sh current
  project.sh list
  project.sh env-path [slug]
USAGE
}

validate_slug() {
  case "$1" in
    ''|*[!a-zA-Z0-9._-]*)
      echo "[ERROR] project slug must use only letters, numbers, dot, underscore, or dash" >&2
      exit 2
      ;;
  esac
}

project_env_path() {
  local slug="$1"
  printf '%s/%s.env\n' "$PROJECTS_DIR" "$slug"
}

cmd_switch() {
  local slug="${1:-}" repo="" url="" env_file
  [ -n "$slug" ] || { usage; exit 2; }
  validate_slug "$slug"
  shift || true

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --repo) repo="${2:-}"; shift 2 ;;
      --url|--production-url) url="${2:-}"; shift 2 ;;
      *) echo "[ERROR] unknown option: $1" >&2; exit 2 ;;
    esac
  done

  mkdir -p "$PROJECTS_DIR"
  env_file="$(project_env_path "$slug")"
  touch "$env_file"
  chmod 600 "$env_file"
  printf '%s\n' "$slug" > "$CURRENT_FILE"

  if [ -n "$repo" ] && ! grep -q '^GITHUB_REPO=' "$env_file"; then
    printf "GITHUB_REPO='%s'\n" "$repo" >> "$env_file"
  fi
  if [ -n "$url" ] && ! grep -q '^PRODUCTION_URL=' "$env_file"; then
    printf "PRODUCTION_URL='%s'\n" "$url" >> "$env_file"
  fi

  echo "[OK] Current project: $slug"
  echo "[OK] Project env: $env_file"
}

cmd_current() {
  if [ -f "$CURRENT_FILE" ]; then
    cat "$CURRENT_FILE"
  else
    echo "default"
  fi
}

cmd_list() {
  mkdir -p "$PROJECTS_DIR"
  find "$PROJECTS_DIR" -maxdepth 1 -name '*.env' -type f -exec basename {} .env \; | sort
}

cmd_env_path() {
  local slug="${1:-}"
  if [ -z "$slug" ]; then
    slug="$(cmd_current)"
  fi
  validate_slug "$slug"
  project_env_path "$slug"
}

case "${1:-}" in
  switch) shift; cmd_switch "$@" ;;
  current) cmd_current ;;
  list) cmd_list ;;
  env-path) shift; cmd_env_path "$@" ;;
  -h|--help|'') usage ;;
  *) usage; exit 2 ;;
esac
