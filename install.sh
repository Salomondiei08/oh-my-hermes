#!/usr/bin/env bash
set -euo pipefail

OH_MY_HERMES_REPO="${OH_MY_HERMES_REPO:-https://github.com/salomondiei08/oh-my-hermes.git}"
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
SKILLS_DIR="$HERMES_DIR/skills"
WORKFLOWS_DIR="$HERMES_DIR/workflows"
AGENTS_DIR="$HERMES_DIR/agents"
if [ "${#BASH_SOURCE[@]}" -gt 0 ] && [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$(pwd)"
fi
WORK_DIR="$SCRIPT_DIR"
TEMP_DIR=""

cleanup() {
  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

echo "Oh My Hermes — installer"
echo "========================"

# Check Hermes is installed/configured. HERMES_HOME is supported for nonstandard installs.
if [ ! -d "$HERMES_DIR" ]; then
  echo ""
  echo "[ERROR] Hermes home not found: $HERMES_DIR"
  echo "Install Hermes Agent first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
  echo "  Then run: hermes"
  exit 1
fi

# When this installer is run via curl | bash, SCRIPT_DIR is just the caller's cwd
# and the repo-local skills/workflows/agents folders are not present. Clone a
# temporary copy instead of silently installing zero files.
if [ ! -d "$WORK_DIR/skills" ] || [ ! -d "$WORK_DIR/workflows" ] || [ ! -d "$WORK_DIR/agents" ]; then
  if ! command -v git >/dev/null 2>&1; then
    echo ""
    echo "[ERROR] Repository files are not available and git is missing."
    echo "Install git, or clone manually and run install.sh from the repo root:"
    echo "  git clone $OH_MY_HERMES_REPO /tmp/oh-my-hermes"
    echo "  cd /tmp/oh-my-hermes && bash install.sh"
    exit 1
  fi

  TEMP_DIR="$(mktemp -d)"
  echo "[INFO] Repo files not found next to installer; cloning temporary copy..."
  if ! git clone --depth 1 "$OH_MY_HERMES_REPO" "$TEMP_DIR/oh-my-hermes" >/dev/null 2>&1; then
    echo "[ERROR] Failed to clone $OH_MY_HERMES_REPO"
    echo "Clone manually and run install.sh from the repo root:"
    echo "  git clone $OH_MY_HERMES_REPO /tmp/oh-my-hermes"
    echo "  cd /tmp/oh-my-hermes && bash install.sh"
    exit 1
  fi
  WORK_DIR="$TEMP_DIR/oh-my-hermes"
fi

for required in skills workflows agents scripts; do
  if [ ! -d "$WORK_DIR/$required" ]; then
    echo "[ERROR] Missing required repo directory: $WORK_DIR/$required"
    exit 1
  fi
done

mkdir -p "$SKILLS_DIR" "$WORKFLOWS_DIR" "$AGENTS_DIR"

install_md_dir() {
  local src_dir="$1"
  local dest_dir="$2"
  local count=0
  local item

  shopt -s nullglob
  for item in "$src_dir"/*.md; do
    cp "$item" "$dest_dir/"
    count=$((count + 1))
  done
  shopt -u nullglob

  echo "$count"
}

SKILLS_INSTALLED="$(install_md_dir "$WORK_DIR/skills" "$SKILLS_DIR")"
WORKFLOWS_INSTALLED="$(install_md_dir "$WORK_DIR/workflows" "$WORKFLOWS_DIR")"
AGENTS_INSTALLED="$(install_md_dir "$WORK_DIR/agents" "$AGENTS_DIR")"

if [ "$SKILLS_INSTALLED" -eq 0 ] || [ "$WORKFLOWS_INSTALLED" -eq 0 ] || [ "$AGENTS_INSTALLED" -eq 0 ]; then
  echo ""
  echo "[ERROR] Refusing to report success after installing zero items."
  echo "Skills: $SKILLS_INSTALLED, workflows: $WORKFLOWS_INSTALLED, agents: $AGENTS_INSTALLED"
  echo "Source directory: $WORK_DIR"
  exit 1
fi

echo ""
echo "[OK] Skills installed:    $SKILLS_INSTALLED → $SKILLS_DIR"
echo "[OK] Workflows installed: $WORKFLOWS_INSTALLED → $WORKFLOWS_DIR"
echo "[OK] Agents installed:    $AGENTS_INSTALLED → $AGENTS_DIR"
echo ""
echo "Next steps:"
echo "  1. git clone $OH_MY_HERMES_REPO /tmp/oh-my-hermes  # if you do not already have the repo"
echo "  2. cd into your project directory"
echo "  3. bash /tmp/oh-my-hermes/scripts/bootstrap.sh"
echo "  4. Fill in AGENTS.md and .env.example"
echo "  5. When ready, run: bash /tmp/oh-my-hermes/scripts/setup-cto.sh"
echo ""
echo "Verify: bash /tmp/oh-my-hermes/scripts/verify.sh"
