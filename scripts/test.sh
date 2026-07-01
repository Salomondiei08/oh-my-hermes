#!/usr/bin/env bash
# Smoke tests — validates Oh My Hermes install without a live Hermes session

PASS=0
FAIL=0
HERMES_DIR="$HOME/.hermes"

ok()   { echo "[PASS] $1"; PASS=$((PASS+1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }

echo "=== Oh My Hermes Smoke Tests ==="
echo ""

echo "Skills:"
for skill in \
  clarify-requirements product-brief create-skill design-handoff choose-engine \
  implement-with-claude-code implement-with-codex deploy-to-vercel connect-supabase \
  setup-monitoring health-check send-notification post-deploy-followup \
  manage-github-issues create-github-pr auto-issue-triage review-github-pr \
  await-merge-approval kanban-task cto-status-report backup-hermes-data \
  security-review onboarding rollback computer-use product-marketing \
  creative-production observe-logs publish-with-buffer generate-with-seedance \
  project-switch project-status failure-recovery server-bootstrap \
  ship-this-idea reset-runtime; do
  if [ -f "$HERMES_DIR/skills/$skill.md" ]; then
    ok "  skill: $skill"
  else
    fail "  skill: $skill (missing from ~/.hermes/skills/)"
  fi
done

echo ""
echo "Workflows:"
for wf in idea-to-deploy design-to-code deploy-and-monitor github-ops cto-loop ship-this-idea; do
  if [ -f "$HERMES_DIR/workflows/$wf.md" ]; then
    ok "  workflow: $wf"
  else
    fail "  workflow: $wf"
  fi
done

echo ""
echo "Agents:"
for agent in cto pm designer dev qa ops security; do
  if [ -f "$HERMES_DIR/agents/$agent.md" ]; then
    ok "  agent: $agent"
  else
    fail "  agent: $agent"
  fi
done

echo ""
echo "Skill description format:"
for skill_file in "$HERMES_DIR/skills/"*.md; do
  name=$(basename "$skill_file" .md)
  desc=$(grep '^description:' "$skill_file" | head -1)
  if echo "$desc" | grep -q 'Use when'; then
    ok "  $name"
  else
    fail "  $name — description does not start 'Use when': $desc"
  fi
done

echo ""
echo "CLI tools:"
for cmd in curl git jq gh vercel node npm rg ffmpeg; do
  if command -v $cmd &>/dev/null; then
    ok "  $cmd"
  else
    fail "  $cmd not found"
  fi
done

for script in setup-integrations.sh project.sh status.sh run-cron-safe.sh reset-runtime.sh server-bootstrap.sh ship-this-idea.sh; do
  if [ -x "$HERMES_DIR/scripts/$script" ]; then
    ok "  $script"
  else
    fail "  $script missing or not executable in ~/.hermes/scripts"
  fi
done

echo ""
echo "Hermes commands (skipped in TEST_MODE — requires live Hermes install):"
if [ "${TEST_MODE:-}" = "1" ]; then
  echo "  [SKIP] TEST_MODE=1 — live Hermes runtime not required"
elif command -v hermes &>/dev/null; then
  if hermes kanban --help &>/dev/null 2>&1; then
    ok "  hermes kanban"
  else
    fail "  hermes kanban"
  fi
  if hermes cron list &>/dev/null 2>&1; then
    ok "  hermes cron"
  else
    fail "  hermes cron"
  fi
else
  echo "  [SKIP] hermes not installed — run in normal mode to validate"
fi

echo ""
echo "================================"
echo "Passed: $PASS   Failed: $FAIL"
if [ "$FAIL" -eq 0 ]; then
  echo ""
  echo "All smoke tests passed."
  exit 0
else
  echo ""
  echo "Some tests failed — see above."
  exit 1
fi
