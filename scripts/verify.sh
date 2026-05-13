#!/usr/bin/env bash

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
SKILLS_DIR="$HERMES_DIR/skills"
WORKFLOWS_DIR="$HERMES_DIR/workflows"
PASS=0
FAIL=0

check() {
  local label="$1"
  local path="$2"
  if [ -e "$path" ]; then
    echo "[OK]      $label"
    PASS=$((PASS + 1))
  else
    echo "[MISSING] $label → $path"
    FAIL=$((FAIL + 1))
  fi
}

echo "Oh My Hermes — verify install"
echo "=============================="
echo ""

if command -v hermes &>/dev/null; then
  echo "[OK]      hermes command found"
  PASS=$((PASS + 1))
else
  echo "[MISSING] hermes not in PATH — install Hermes Agent first"
  FAIL=$((FAIL + 1))
fi

check "~/.hermes/"            "$HERMES_DIR"
check "~/.hermes/skills/"     "$SKILLS_DIR"
check "~/.hermes/workflows/"  "$WORKFLOWS_DIR"

echo ""
echo "Skills:"
check "create-skill"               "$SKILLS_DIR/create-skill.md"
check "clarify-requirements"       "$SKILLS_DIR/clarify-requirements.md"
check "product-brief"              "$SKILLS_DIR/product-brief.md"
check "design-handoff"             "$SKILLS_DIR/design-handoff.md"
check "choose-engine"              "$SKILLS_DIR/choose-engine.md"
check "implement-with-claude-code" "$SKILLS_DIR/implement-with-claude-code.md"
check "implement-with-codex"       "$SKILLS_DIR/implement-with-codex.md"
check "deploy-to-vercel"           "$SKILLS_DIR/deploy-to-vercel.md"
check "connect-supabase"           "$SKILLS_DIR/connect-supabase.md"
check "setup-monitoring"           "$SKILLS_DIR/setup-monitoring.md"
check "health-check"               "$SKILLS_DIR/health-check.md"
check "send-notification"          "$SKILLS_DIR/send-notification.md"
check "post-deploy-followup"       "$SKILLS_DIR/post-deploy-followup.md"
check "manage-github-issues"       "$SKILLS_DIR/manage-github-issues.md"
check "create-github-pr"           "$SKILLS_DIR/create-github-pr.md"
check "auto-issue-triage"          "$SKILLS_DIR/auto-issue-triage.md"
check "review-github-pr"           "$SKILLS_DIR/review-github-pr.md"
check "await-merge-approval"       "$SKILLS_DIR/await-merge-approval.md"
check "kanban-task"                "$SKILLS_DIR/kanban-task.md"
check "cto-status-report"          "$SKILLS_DIR/cto-status-report.md"
check "backup-hermes-data"         "$SKILLS_DIR/backup-hermes-data.md"
check "security-review"            "$SKILLS_DIR/security-review.md"
check "onboarding"                 "$SKILLS_DIR/onboarding.md"

echo ""
echo "Agents:"
check "cto"      "$HERMES_DIR/agents/cto.md"
check "pm"       "$HERMES_DIR/agents/pm.md"
check "dev"      "$HERMES_DIR/agents/dev.md"
check "qa"       "$HERMES_DIR/agents/qa.md"
check "ops"      "$HERMES_DIR/agents/ops.md"
check "security" "$HERMES_DIR/agents/security.md"

echo ""
echo "Workflows:"
check "idea-to-deploy"     "$WORKFLOWS_DIR/idea-to-deploy.md"
check "design-to-code"     "$WORKFLOWS_DIR/design-to-code.md"
check "deploy-and-monitor" "$WORKFLOWS_DIR/deploy-and-monitor.md"
check "github-ops"         "$WORKFLOWS_DIR/github-ops.md"
check "cto-loop"           "$WORKFLOWS_DIR/cto-loop.md"

echo ""
echo "Hermes profiles (optional; run setup-cto.sh if missing):"
PROFILES_DIR="$HERMES_DIR/profiles"
for profile in cto pm dev qa ops security; do
  if [ -d "$PROFILES_DIR/$profile" ]; then
    echo "[OK]      profile: $profile"
    PASS=$((PASS + 1))
  else
    echo "[SKIP]    profile: $profile — created by: bash scripts/setup-cto.sh"
  fi
done

echo ""
echo "Kanban (run setup-cto.sh if missing):"
if command -v hermes &>/dev/null && hermes kanban list &>/dev/null 2>&1; then
  echo "[OK]      hermes kanban accessible"
  PASS=$((PASS + 1))
else
  echo "[SKIP]    hermes not installed or kanban not initialized"
fi

echo ""
echo "Scripts:"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
check "bootstrap.sh"    "$SCRIPT_DIR/bootstrap.sh"
check "verify.sh"       "$SCRIPT_DIR/verify.sh"
check "setup-cto.sh"    "$SCRIPT_DIR/setup-cto.sh"
check "uninstall.sh"    "$SCRIPT_DIR/uninstall.sh"

echo ""
echo "=============================="
echo "Passed: $PASS   Failed: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo ""
  echo "Oh My Hermes install looks good."
  echo "Next: cd into your project and run scripts/bootstrap.sh"
  echo "Then run scripts/setup-cto.sh to configure the CTO loop."
else
  echo ""
  echo "Install incomplete — run install.sh to fix missing items."
  exit 1
fi
