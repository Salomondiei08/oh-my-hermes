#!/usr/bin/env bash
# uninstall.sh — removes all Oh My Hermes files from ~/.hermes/
# Does NOT touch Hermes itself, your memory, or your gateway config.
# Safe to re-run.

set -e

HERMES_DIR="$HOME/.hermes"

echo ""
echo "Oh My Hermes — Uninstall"
echo "════════════════════════"
echo ""
echo "This removes Oh My Hermes skills, workflows, and agent role definitions."
echo "It does NOT touch Hermes itself, ~/.hermes/memory/, or gateway config."
echo ""

SKILLS=(
  clarify-requirements product-brief create-skill design-handoff choose-engine
  implement-with-claude-code implement-with-codex deploy-to-vercel connect-supabase
  setup-monitoring health-check send-notification post-deploy-followup
  manage-github-issues create-github-pr auto-issue-triage review-github-pr
  await-merge-approval kanban-task cto-status-report backup-hermes-data
  security-review onboarding rollback computer-use product-marketing
  creative-production observe-logs publish-with-buffer generate-with-seedance
  project-switch project-status failure-recovery server-bootstrap
  ship-this-idea reset-runtime
)

WORKFLOWS=(idea-to-deploy design-to-code deploy-and-monitor github-ops cto-loop ship-this-idea)
AGENTS=(cto pm designer dev qa ops security)
SCRIPTS=(
  bootstrap.sh setup-cto.sh setup-integrations.sh project.sh status.sh
  run-cron-safe.sh reset-runtime.sh server-bootstrap.sh ship-this-idea.sh
  test.sh uninstall.sh validate-skills.sh verify.sh
)

echo "Will remove:"
echo "  Skills:    ${#SKILLS[@]}"
echo "  Workflows: ${#WORKFLOWS[@]}"
echo "  Agents:    ${#AGENTS[@]}"
echo "  Profiles:  cto, pm, designer, dev, qa, security, ops"
echo ""
read -r -p "Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""

REMOVED=0

for skill in "${SKILLS[@]}"; do
  f="$HERMES_DIR/skills/$skill.md"
  if [ -f "$f" ]; then rm "$f"; echo "  removed: skills/$skill.md"; REMOVED=$((REMOVED+1)); fi
done

for wf in "${WORKFLOWS[@]}"; do
  f="$HERMES_DIR/workflows/$wf.md"
  if [ -f "$f" ]; then rm "$f"; echo "  removed: workflows/$wf.md"; REMOVED=$((REMOVED+1)); fi
done

for agent in "${AGENTS[@]}"; do
  f="$HERMES_DIR/agents/$agent.md"
  if [ -f "$f" ]; then rm "$f"; echo "  removed: agents/$agent.md"; REMOVED=$((REMOVED+1)); fi
done

for script in "${SCRIPTS[@]}"; do
  f="$HERMES_DIR/scripts/$script"
  if [ -f "$f" ]; then rm "$f"; echo "  removed: scripts/$script"; REMOVED=$((REMOVED+1)); fi
done

for profile in cto pm designer dev qa ops security; do
  d="$HERMES_DIR/profiles/$profile"
  if [ -d "$d" ]; then rm -rf "$d"; echo "  removed: profiles/$profile/"; REMOVED=$((REMOVED+1)); fi
done

echo ""
echo "Done. Removed $REMOVED items."
echo ""
echo "Hermes itself is untouched. Memory, gateway, and cron jobs are intact."
echo "To clean up cron jobs:"
echo "  hermes cron list"
echo "  hermes cron remove [id]"
