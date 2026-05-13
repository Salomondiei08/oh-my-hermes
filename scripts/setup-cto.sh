#!/usr/bin/env bash
# setup-cto.sh — creates real Hermes profiles for each CTO loop agent,
# initializes the kanban board, authenticates GitHub CLI, and sets up crons.
# Run once after install.sh. Safe to re-run (idempotent).

set -euo pipefail

HERMES_DIR="$HOME/.hermes"
AGENTS_DIR="$HERMES_DIR/agents"

PASS=0
FAIL=0
WARN=0

ok()   { echo "  [OK]   $1"; PASS=$((PASS+1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }
step() { echo ""; echo "── $1"; }

profile_exists() {
  hermes profile list 2>/dev/null | awk 'NR>2 {print $1}' | sed 's/^◆//' | grep -Fxq "$1"
}

cron_job_exists() {
  local job_name="$1"
  hermes cron list 2>/dev/null | grep -Fq "Name:      $job_name"
}

create_cron_job() {
  local schedule="$1"
  local job_name="$2"
  local prompt="$3"
  local deliver="${4:-local}"

  if cron_job_exists "$job_name"; then
    ok "cron already exists: $job_name"
    return 0
  fi

  if hermes cron create --name "$job_name" --deliver "$deliver" "$schedule" "$prompt" >/dev/null 2>&1; then
    ok "cron created: $job_name"
    return 0
  fi

  if hermes cron add --name "$job_name" --deliver "$deliver" "$schedule" "$prompt" >/dev/null 2>&1; then
    ok "cron created (legacy syntax): $job_name"
    return 0
  fi

  return 1
}

echo ""
echo "Oh My Hermes — CTO Loop Setup"
echo "══════════════════════════════"

# ── 1. Prerequisites ──────────────────────────────
step "1. Checking prerequisites"

if ! command -v hermes &>/dev/null; then
  echo ""
  echo "[ERROR] hermes not found. Install Hermes Agent first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
  exit 1
fi
ok "hermes: $(hermes --version 2>/dev/null || echo 'found')"

if [ ! -d "$AGENTS_DIR" ]; then
  echo "[ERROR] ~/.hermes/agents/ not found — run install.sh first"
  exit 1
fi
ok "~/.hermes/agents/ exists"

MISSING_AGENTS=0
for agent in cto pm dev qa ops; do
  if [ -f "$AGENTS_DIR/$agent.md" ]; then
    ok "agent definition: $agent.md"
  else
    fail "missing: $agent.md — run install.sh first"
    MISSING_AGENTS=$((MISSING_AGENTS+1))
  fi
done

if [ "$MISSING_AGENTS" -gt 0 ]; then
  echo ""
  echo "Run: bash install.sh"
  exit 1
fi

# ── 2. Create Hermes profiles ─────────────────────
step "2. Creating Hermes profiles (cto, pm, dev, qa, ops)"

for profile in cto pm dev qa ops security; do
  if profile_exists "$profile"; then
    ok "profile '$profile' already exists"
  else
    if hermes profile create "$profile" 2>/dev/null; then
      ok "profile '$profile' created"
    else
      warn "Could not create profile '$profile' — check: hermes profile --help"
      echo "         May need: hermes profile new $profile"
    fi
  fi
done

# ── 3. Inject agent roles into profiles ───────────
step "3. Injecting agent role definitions into profiles"

for agent in cto pm dev qa ops security; do
  PROFILE_DIR="$HERMES_DIR/profiles/$agent"
  AGENT_FILE="$AGENTS_DIR/$agent.md"

  if [ -d "$PROFILE_DIR" ]; then
    cp "$AGENT_FILE" "$PROFILE_DIR/agent-role.md"
    ok "role injected: $agent"
  else
    # Profiles may be created lazily — copy will happen on first use
    warn "Profile dir ~/.hermes/profiles/$agent/ not created yet"
    echo "         This is normal — it will be created when you first run:"
    echo "         hermes profile use $agent"
  fi
done

# ── 4. Kanban board ───────────────────────────────
step "4. Initializing kanban board"

if hermes kanban list &>/dev/null 2>&1; then
  ok "kanban board accessible"
else
  if hermes kanban init &>/dev/null 2>&1; then
    ok "kanban board initialized"
  else
    warn "hermes kanban init failed — board may not need explicit init on this version"
  fi
fi

# ── 5. GitHub credentials ─────────────────────────
step "5. Checking GitHub credentials"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  warn "GITHUB_TOKEN not set"
  echo "         Create a fine-grained token at:"
  echo "         github.com → Settings → Developer settings → Personal access tokens → Fine-grained"
  echo "         Required permissions: Contents R/W, Issues R/W, Pull requests R/W, Metadata R"
  echo ""
  echo "         Then:"
  echo "         export GITHUB_TOKEN=your-token"
  echo "         echo \"\$GITHUB_TOKEN\" | gh auth login --with-token"
else
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo 'unknown')
      ok "gh CLI authenticated as: $GH_USER"
    else
      echo "  Authenticating gh CLI with GITHUB_TOKEN..."
      if echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null; then
        ok "gh CLI authenticated"
      else
        fail "gh auth failed — verify token has correct permissions"
      fi
    fi
  else
    fail "gh CLI not installed — install: sudo apt install gh  (or brew install gh)"
  fi
fi

[ -z "${GITHUB_USERNAME:-}" ] && \
  warn "GITHUB_USERNAME not set — auto-issue-triage cannot self-assign issues. Add: export GITHUB_USERNAME=your-username" || \
  ok "GITHUB_USERNAME: $GITHUB_USERNAME"

[ -z "${GITHUB_REPO:-}" ] && \
  warn "GITHUB_REPO not set — CTO loop has no repo to manage. Add: export GITHUB_REPO=owner/repo" || \
  ok "GITHUB_REPO: $GITHUB_REPO"

# ── 6. Gateway / bot token safety ────────────────
step "6. Gateway safety check"

GATEWAY_COUNT=0
if hermes gateway status 2>/dev/null | grep -qi "running"; then
  GATEWAY_COUNT=1
fi

if [ "$GATEWAY_COUNT" -gt 0 ]; then
  warn "Hermes gateway is already running"
  echo ""
  echo "  ╔══════════════════════════════════════════════════════════════╗"
  echo "  ║  IMPORTANT: Do NOT start a separate gateway for each        ║"
  echo "  ║  agent profile. One gateway serves ALL profiles.            ║"
  echo "  ║                                                              ║"
  echo "  ║  Running multiple gateways with the same Telegram bot token ║"
  echo "  ║  causes message conflicts — each message goes to a random   ║"
  echo "  ║  gateway instance.                                           ║"
  echo "  ║                                                              ║"
  echo "  ║  If you cloned this setup to a second machine, use a        ║"
  echo "  ║  different bot token on the second machine.                 ║"
  echo "  ╚══════════════════════════════════════════════════════════════╝"
else
  ok "No duplicate gateway risk"
  echo "         When ready, run: hermes gateway setup && hermes gateway start"
fi

# ── 7. Save config to memory ─────────────────────
step "7. Saving config to Hermes memory"

if [ -n "${GITHUB_REPO:-}" ]; then
  if hermes --oneshot "Remember that the GitHub repo for this Oh My Hermes setup is $GITHUB_REPO." >/dev/null 2>&1; then
    ok "github-repo saved to memory"
  else
    warn "Could not auto-save to memory. Tell Hermes manually:"
    echo "         'remember that github-repo is $GITHUB_REPO'"
  fi
fi

if [ -n "${GITHUB_USERNAME:-}" ]; then
  hermes --oneshot "Remember that the GitHub username for this Oh My Hermes setup is $GITHUB_USERNAME." >/dev/null 2>&1 && \
    ok "github-username saved to memory" || true
fi

# ── 8. Cron jobs ──────────────────────────────────
step "8. Setting up cron jobs"

CRON_FAIL=0

if [ -n "${PRODUCTION_URL:-}" ]; then
  if create_cron_job "*/15 * * * *" "oh-my-hermes health-check" "Run health-check on $PRODUCTION_URL" "local"; then
    :
  else
    warn "Could not add health check cron. Add manually:"
    echo "         hermes cron create --name 'oh-my-hermes health-check' --deliver local '*/15 * * * *' 'Run health-check on $PRODUCTION_URL'"
    CRON_FAIL=1
  fi
else
  warn "PRODUCTION_URL not set — skipping health check cron"
  echo "         Set it and re-run, or add manually after deploy:"
  echo "         hermes cron create --name 'oh-my-hermes health-check' --deliver local '*/15 * * * *' 'Run health-check on https://yourapp.vercel.app'"
fi

if [ -n "${GITHUB_REPO:-}" ]; then
  if create_cron_job "0 * * * *" "oh-my-hermes auto-issue-triage" "Run auto-issue-triage for $GITHUB_REPO" "local"; then
    :
  else
    warn "Could not add triage cron. Add manually:"
    echo "         hermes cron create --name 'oh-my-hermes auto-issue-triage' --deliver local '0 * * * *' 'Run auto-issue-triage for $GITHUB_REPO'"
    CRON_FAIL=1
  fi
else
  warn "GITHUB_REPO not set — skipping triage cron"
fi

if create_cron_job "0 9 * * *" "oh-my-hermes cto-status-report" "Send cto-status-report to founder" "origin"; then
  :
else
  warn "Could not add status report cron. Add manually:"
  echo "         hermes cron create --name 'oh-my-hermes cto-status-report' --deliver origin '0 9 * * *' 'Send cto-status-report to founder'"
  CRON_FAIL=1
fi

if [ -n "${GITHUB_REPO:-}" ]; then
  if create_cron_job "0 9 * * 1" "oh-my-hermes weekly-security-review" "Run security-review supply chain assessment for $GITHUB_REPO" "local"; then
    :
  else
    warn "Could not add supply chain cron. Add manually:"
    echo "         hermes cron create --name 'oh-my-hermes weekly-security-review' --deliver local '0 9 * * 1' 'Run security-review supply chain assessment for $GITHUB_REPO'"
    CRON_FAIL=1
  fi
else
  warn "GITHUB_REPO not set — skipping weekly security assessment cron"
fi

# ── Summary ───────────────────────────────────────
echo ""
echo "══════════════════════════════"
printf "Passed: %d   Warned: %d   Failed: %d\n" $PASS $WARN $FAIL
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "Setup incomplete. Fix failures above and re-run."
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "Setup mostly complete. Address warnings for full functionality."
  echo ""
  echo "When ready:"
  echo "  hermes gateway setup && hermes gateway start"
  echo "  hermes profile use cto"
  echo "  hermes kanban watch"
else
  echo "CTO loop fully configured. Start with:"
  echo ""
  echo "  hermes gateway start      # start messaging gateway"
  echo "  hermes profile use cto    # switch to CTO profile"
  echo "  hermes kanban watch       # open live kanban board"
  echo ""
  echo "Then lock persistent focus (Hermes v0.13+):"
  if [ -n "${GITHUB_REPO:-}" ]; then
    echo "  /goal Manage $GITHUB_REPO as CTO. Triage issues hourly, implement top"
    echo "        priority, get founder approval before merging. Never ship without YES."
  else
    echo "  /goal Manage [owner/repo] as CTO. Triage issues hourly, implement top"
    echo "        priority, get founder approval before merging. Never ship without YES."
  fi
fi
