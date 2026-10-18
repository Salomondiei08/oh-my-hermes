#!/usr/bin/env bash
set -uo pipefail
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
export PATH="$HOME/.local/bin:$HERMES_DIR/hermes-agent/venv/bin:$PATH"
MODE="${1:---install-only}"
[[ "$MODE" = --install-only || "$MODE" = --setup ]] || { echo 'Usage: verify.sh [--install-only|--setup]'; exit 2; }
PASS=0
FAIL=0
check() {
  if [ -f "$2" ]; then
    echo "[OK] $1"
    PASS=$((PASS + 1))
  else
    echo "[MISSING] $1 → $2"
    FAIL=$((FAIL + 1))
  fi
}
echo 'Oh My Hermes — verify installed discovery paths'
for skill in clarify-requirements product-brief create-skill design-handoff choose-engine \
  implement-with-claude-code implement-with-codex deploy-to-vercel connect-supabase \
  setup-monitoring health-check send-notification post-deploy-followup manage-github-issues \
  create-github-pr auto-issue-triage review-github-pr await-merge-approval kanban-task \
  cto-status-report backup-hermes-data security-review onboarding rollback computer-use \
  product-marketing creative-production observe-logs publish-with-buffer generate-with-seedance \
  project-switch project-status failure-recovery server-bootstrap ship-this-idea reset-runtime \
  automation-blueprint learn-skill gateway-routing; do
  check "$skill" "$HERMES_DIR/skills/oh-my-hermes/$skill/SKILL.md"
done
for name in idea-to-deploy design-to-code deploy-and-monitor github-ops cto-loop ship-this-idea; do
  check "workflow $name" "$HERMES_DIR/workflows/$name.md"
done
for name in cto pm designer dev qa ops security; do
  check "agent $name" "$HERMES_DIR/agents/$name.md"
done
for name in bootstrap.sh verify.sh uninstall.sh validate-skills.sh setup-cto.sh setup-integrations.sh \
  project.sh status.sh run-cron-safe.sh reset-runtime.sh server-bootstrap.sh ship-this-idea.sh \
  test.sh backup-runtime.py; do
  check "script $name" "$HERMES_DIR/scripts/$name"
  if [ ! -x "$HERMES_DIR/scripts/$name" ]; then FAIL=$((FAIL + 1)); echo "[FAIL] script $name is not executable"; fi
done
check 'AGENTS template' "$HERMES_DIR/templates/AGENTS.md.template"
check 'Next.js health template' "$HERMES_DIR/templates/healthcheck/nextjs-health-route.ts"
if [ "$MODE" = --setup ]; then
  if ! command -v hermes >/dev/null; then echo '[FAIL] hermes CLI missing'; FAIL=$((FAIL + 1)); fi
  for name in cto pm designer dev qa ops security; do
    if [ ! -d "$HERMES_DIR/profiles/$name" ]; then echo "[FAIL] profile $name missing; run setup-cto.sh"; FAIL=$((FAIL + 1)); fi
  done
  if ! hermes kanban list >/dev/null 2>&1; then echo '[FAIL] Hermes kanban unavailable'; FAIL=$((FAIL + 1)); fi
fi
echo "Passed: $PASS   Failed: $FAIL"
[ "$FAIL" -eq 0 ]
