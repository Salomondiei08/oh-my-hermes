#!/usr/bin/env bash
set -e

HERMES_DIR="$HOME/.hermes"
SKILLS_DIR="$HERMES_DIR/skills"
WORKFLOWS_DIR="$HERMES_DIR/workflows"
AGENTS_DIR="$HERMES_DIR/agents"
SCRIPTS_DIR="$HERMES_DIR/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Oh My Hermes — installer"
echo "========================"

# Check Hermes is installed
if [ ! -d "$HERMES_DIR" ]; then
  echo ""
  echo "[ERROR] ~/.hermes not found. Install Hermes Agent first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
  echo "  Then run: hermes"
  exit 1
fi

if [ ! -d "$SCRIPT_DIR/skills" ] \
  || [ ! -d "$SCRIPT_DIR/workflows" ] \
  || [ ! -d "$SCRIPT_DIR/agents" ] \
  || [ ! -f "$SCRIPT_DIR/scripts/setup-integrations.sh" ]; then
  echo ""
  echo "[ERROR] install.sh must be run from a full Oh My Hermes checkout."
  echo "        This installer copies repo files; piping only install.sh is not enough."
  echo ""
  echo "        Run:"
  echo "          git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes"
  echo "          bash /tmp/oh-my-hermes/install.sh"
  exit 1
fi

mkdir -p "$SKILLS_DIR"
mkdir -p "$WORKFLOWS_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$SCRIPTS_DIR"

# Install skills
SKILLS_INSTALLED=0
if [ -d "$SCRIPT_DIR/skills" ]; then
  for skill in "$SCRIPT_DIR/skills"/*.md; do
    [ -f "$skill" ] || continue
    cp "$skill" "$SKILLS_DIR/"
    SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
  done
fi

# Install the just-in-time credential helper used by integration skills.
install -m 700 "$SCRIPT_DIR/scripts/setup-integrations.sh" "$SCRIPTS_DIR/setup-integrations.sh"

# Install workflows
WORKFLOWS_INSTALLED=0
if [ -d "$SCRIPT_DIR/workflows" ]; then
  for workflow in "$SCRIPT_DIR/workflows"/*.md; do
    [ -f "$workflow" ] || continue
    cp "$workflow" "$WORKFLOWS_DIR/"
    WORKFLOWS_INSTALLED=$((WORKFLOWS_INSTALLED + 1))
  done
fi

# Install agents
AGENTS_INSTALLED=0
if [ -d "$SCRIPT_DIR/agents" ]; then
  for agent in "$SCRIPT_DIR/agents"/*.md; do
    [ -f "$agent" ] || continue
    cp "$agent" "$AGENTS_DIR/"
    AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
  done
fi

echo ""
echo "[OK] Skills installed:    $SKILLS_INSTALLED → $SKILLS_DIR"
echo "[OK] Workflows installed: $WORKFLOWS_INSTALLED → $WORKFLOWS_DIR"
echo "[OK] Agents installed:    $AGENTS_INSTALLED → $AGENTS_DIR"
echo "[OK] Integration setup:   $SCRIPTS_DIR/setup-integrations.sh"
echo ""
echo "Next steps:"
echo "  1. cd into your project directory"
echo "  2. bash $SCRIPT_DIR/scripts/bootstrap.sh"
echo "  3. Fill in AGENTS.md and .env.example"
echo "  4. Tell Hermes: 'set up the CTO loop for [owner/repo]'"
echo ""
echo "Verify: bash $SCRIPT_DIR/scripts/verify.sh"
