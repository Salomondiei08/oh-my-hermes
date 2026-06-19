#!/usr/bin/env bash
# setup-cto.sh — creates real Hermes profiles for each product-loop agent,
# initializes the kanban board, authenticates GitHub CLI, and sets up crons.
# Run once after install.sh. Safe to re-run (idempotent).

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.hermes/hermes-agent/venv/bin:$PATH"

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
AGENTS_DIR="$HERMES_DIR/agents"

PASS=0
FAIL=0
WARN=0

ok()   { echo "  [OK]   $1"; PASS=$((PASS+1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }
step() { echo ""; echo "── $1"; }

hermes_has_subcommand() {
  local group="$1"
  local subcommand="$2"

  hermes "$group" "$subcommand" --help &>/dev/null && return 0
  hermes "$group" --help 2>/dev/null | grep -Eq "(^|[[:space:]])$subcommand([[:space:],]|$)"
}


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

require_hermes_subcommand() {
  local group="$1"
  local subcommand="$2"
  local label="$3"

  if hermes_has_subcommand "$group" "$subcommand"; then
    ok "$label"
  else
    fail "$label missing — update Hermes Agent or check: hermes $group --help"
  fi
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

PROFILE_CREATE_SUBCOMMAND=""
if hermes_has_subcommand profile create; then
  PROFILE_CREATE_SUBCOMMAND="create"
elif hermes_has_subcommand profile new; then
  PROFILE_CREATE_SUBCOMMAND="new"
fi

require_hermes_subcommand profile list "hermes profile list supported"
if [ -n "$PROFILE_CREATE_SUBCOMMAND" ]; then
  ok "hermes profile $PROFILE_CREATE_SUBCOMMAND supported"
else
  fail "hermes profile create/new missing — update Hermes Agent or check: hermes profile --help"
fi
require_hermes_subcommand profile use "hermes profile use supported"
require_hermes_subcommand kanban list "hermes kanban list supported"
require_hermes_subcommand kanban init "hermes kanban init supported"
require_hermes_subcommand kanban watch "hermes kanban watch supported"
require_hermes_subcommand cron list "hermes cron list supported"
require_hermes_subcommand cron status "hermes cron status supported"
require_hermes_subcommand cron add "hermes cron add supported"

if hermes_has_subcommand computer-use status; then
  if hermes computer-use status &>/dev/null; then
    ok "Hermes computer use ready"
  else
    warn "Computer use is optional and not ready — run: hermes computer-use install"
  fi
else
  warn "Hermes computer-use command unavailable — update Hermes to enable CUA"
fi

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Hermes runtime preflight failed. Fix missing command support and re-run."
  exit 1
fi

if [ ! -d "$AGENTS_DIR" ]; then
  echo "[ERROR] ~/.hermes/agents/ not found — run install.sh first"
  exit 1
fi
ok "~/.hermes/agents/ exists"

if [ "${OH_MY_HERMES_SETUP_CTO_CONFIRM:-}" != "1" ]; then
  echo ""
  echo "This script has side effects: creates Hermes profiles, checks GitHub auth,"
  echo "writes Hermes memory, and schedules cron jobs."
  if [ -t 0 ]; then
    read -r -p "Continue? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Cancelled."
      exit 0
    fi
  else
    echo "[ERROR] Refusing unattended CTO setup without explicit confirmation."
    echo "Re-run with: OH_MY_HERMES_SETUP_CTO_CONFIRM=1 bash scripts/setup-cto.sh"
    exit 1
  fi
fi

MISSING_AGENTS=0
for agent in cto pm designer dev qa ops security; do
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
step "2. Creating Hermes profiles (cto, pm, designer, dev, qa, security, ops)"

for profile in cto pm designer dev qa ops security; do
  if hermes profile list 2>/dev/null | grep -qw "$profile"; then
    ok "profile '$profile' already exists"
  else
    case "$PROFILE_CREATE_SUBCOMMAND" in
      create|new)
        CREATE_ARGS=()
        if [ "$profile" = "designer" ] || [ "$profile" = "security" ]; then
          CREATE_ARGS+=(--no-alias)
        fi

        if hermes profile "$PROFILE_CREATE_SUBCOMMAND" "$profile" "${CREATE_ARGS[@]}" 2>/dev/null; then
          ok "profile '$profile' created"
        else
          warn "Could not create profile '$profile' — check: hermes profile --help"
        fi
        ;;
      *)
        warn "Could not create profile '$profile' — no supported profile create command"
        ;;
    esac
  fi
done

# ── 3. Inject agent roles into profiles ───────────
step "3. Injecting agent role definitions into profiles"

for agent in cto pm designer dev qa ops security; do
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
  echo "         export GITHUB_TOKEN=***"
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

hermes_memory_set() {
  local key="$1"
  local value="$2"
  # Try direct CLI first (cheaper, reliable); fall back to chat if not available
  if hermes memory set "$key" "$value" &>/dev/null 2>&1; then
    return 0
  elif hermes chat -q "Save to memory: key=$key value=$value" --max-turns 2 &>/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

if [ -n "${GITHUB_REPO:-}" ]; then
  if hermes_memory_set "github-repo" "$GITHUB_REPO"; then
    ok "github-repo saved to memory"
  else
    warn "Could not auto-save github-repo. Tell Hermes manually:"
    echo "         'remember that github-repo is $GITHUB_REPO'"
  fi
fi

if [ -n "${GITHUB_USERNAME:-}" ]; then
  if hermes_memory_set "github-username" "$GITHUB_USERNAME"; then
    ok "github-username saved to memory"
  else
    warn "Could not auto-save github-username"
  fi
fi

# ── 8. Cron jobs ──────────────────────────────────
step "8. Setting up cron jobs"

CRON_FAIL=0

ensure_cron() {
  local name="$1"
  local schedule="$2"
  local prompt="$3"
  local cron_list

  cron_list=$(hermes cron list --all 2>/dev/null || hermes cron list 2>/dev/null || true)

  if echo "$cron_list" | grep -Fq "$name" || echo "$cron_list" | grep -Fq "$prompt"; then
    ok "cron already exists: $name"
    return 0

  fi

  if hermes cron add --help 2>/dev/null | grep -q -- "--name"; then
    CRON_ARGS=(--name "$name")
  else
    CRON_ARGS=()
  fi

  if hermes cron add "${CRON_ARGS[@]}" "$schedule" "$prompt" 2>/dev/null; then
    ok "cron created: $name"
    return 0
  fi

  warn "Could not create cron: $name"
  CRON_FAIL=1
  return 0
}

if [ -n "$PRODUCTION_URL" ]; then
  ensure_cron "oh-my-hermes-health" "*/15 * * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run health-check on $PRODUCTION_URL and save a dead letter if the check fails."
  ensure_cron "oh-my-hermes-log-observer" "15 * * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run observe-logs for $PRODUCTION_URL. Deduplicate known events and notify only on new actionable High or Critical groups."
else
  warn "PRODUCTION_URL not set — skipping health check cron"
  echo "         Set it and re-run, or add manually after deploy:"
  echo "         hermes cron create --name 'oh-my-hermes health-check' --deliver local '*/15 * * * *' 'Run health-check on https://yourapp.vercel.app'"
fi

if [ -n "$GITHUB_REPO" ]; then
  ensure_cron "oh-my-hermes-product-review" "0 * * * *"     "Use failure-recovery for project ${PROJECT_SLUG:-default}: review active product work and actionable GitHub issues for $GITHUB_REPO. Keep one product outcome active and do not treat issue volume as the roadmap."
else
  warn "GITHUB_REPO not set — skipping product and issue review cron"
fi

  ensure_cron "oh-my-hermes-product-review" "0 * * * *"     "Use failure-recovery for project ${PROJECT_SLUG:-default}: review active product work and actionable GitHub issues for $GITHUB_REPO. Keep one product outcome active and do not treat issue volume as the roadmap."
  ensure_cron "oh-my-hermes-security-daily" "30 8 * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run security-review daily mode for $GITHUB_REPO: check tracked secret exposure and new Critical dependency advisories. Deduplicate known findings."
  ensure_cron "oh-my-hermes-security-weekly" "0 9 * * 1" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run security-review weekly mode for $GITHUB_REPO: full dependency, configuration, and supply-chain assessment."
>>>>>>> 9e3e68f (feat: add first-run server operating layer)
else
  warn "GITHUB_REPO not set — skipping scheduled security assessments"
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
  echo "CTO product loop fully configured. Start with:"
  echo ""
  echo "  hermes gateway start      # start messaging gateway"
  echo "  hermes profile use cto    # switch to CTO profile"
  echo "  hermes kanban watch       # open live kanban board"
  echo ""
  echo "Then lock persistent focus (Hermes v0.13+):"
  if [ -n "$GITHUB_REPO" ]; then
    echo "  /goal Build, launch, operate, and improve the product in $GITHUB_REPO."
    echo "        Keep one outcome active, verify it, and ask only at irreversible boundaries."
  else
    echo "  /goal Build, launch, operate, and improve this product. Keep one outcome"
    echo "        active, verify it, and ask only at irreversible boundaries."
  fi
fi
