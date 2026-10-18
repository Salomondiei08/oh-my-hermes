#!/usr/bin/env bash
# setup-cto.sh — creates real Hermes profiles for each product-loop agent,
# initializes the kanban board, authenticates GitHub CLI, and sets up crons.
# Run once after install.sh. Safe to re-run (idempotent).

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.hermes/hermes-agent/venv/bin:$PATH"

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
export HERMES_HOME="$HERMES_DIR"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_SLUG="${PROJECT_SLUG:-$(bash "$SCRIPT_DIR/project.sh" current)}"
# Validate metadata before creating profiles or scheduling work.
project_args=(switch "$PROJECT_SLUG")
[ -z "${GITHUB_REPO+x}" ] || project_args+=(--repo "$GITHUB_REPO")
[ -z "${PRODUCTION_URL+x}" ] || project_args+=(--url "$PRODUCTION_URL")
bash "$SCRIPT_DIR/project.sh" "${project_args[@]}"
GITHUB_REPO="$(bash "$SCRIPT_DIR/project.sh" get GITHUB_REPO "$PROJECT_SLUG")"
PRODUCTION_URL="$(bash "$SCRIPT_DIR/project.sh" get PRODUCTION_URL "$PROJECT_SLUG")"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
GITHUB_USERNAME="${GITHUB_USERNAME:-}"
PROJECT_DIR="$(pwd -P)"
AGENTS_DIR="$HERMES_DIR/agents"
python3 - "$HERMES_DIR" <<'PROFILECHECK'
from pathlib import Path
import sys
home = Path(sys.argv[1]).resolve()
paths = [home / 'profiles', *(home / 'profiles' / name for name in ('cto', 'pm', 'designer', 'dev', 'qa', 'ops', 'security'))]
if any(path.is_symlink() for path in paths):
    sys.exit('[ERROR] Refusing symlinked profile directories before runtime mutation')
PROFILECHECK

PASS=0
FAIL=0
WARN=0

ok()   { echo "  [OK]   $1"; PASS=$((PASS+1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }
step() { echo ""; echo "── $1"; }

# Robustly check profile existence — handles decorators (◆) in hermes output
profile_exists() {
  hermes profile list 2>/dev/null | awk 'NR>2 {print $1}' | sed 's/^◆//' | grep -Fxq "$1"
}

hermes_has_subcommand() {
  local group="$1"
  local subcommand="$2"

  hermes "$group" "$subcommand" --help &>/dev/null && return 0
  hermes "$group" --help 2>/dev/null | grep -Eq "(^|[[:space:]])$subcommand([[:space:],]|$)"
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


require_hermes_subcommand cron list "hermes cron list supported"
require_hermes_subcommand cron status "hermes cron status supported"
require_hermes_subcommand cron create "hermes cron create supported"
require_hermes_subcommand cron edit "hermes cron edit supported (required for safe reconciliation)"
require_hermes_subcommand cron pause "hermes cron pause supported"
require_hermes_subcommand cron resume "hermes cron resume supported"

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
  if profile_exists "$profile"; then
    ok "profile '$profile' already exists"
  else
    case "$PROFILE_CREATE_SUBCOMMAND" in
      create|new)
        CREATE_ARGS=(--no-alias)

        if hermes profile "$PROFILE_CREATE_SUBCOMMAND" "$profile" "${CREATE_ARGS[@]}" 2>/dev/null; then
          ok "profile '$profile' created"
        else
          fail "Could not create profile '$profile' — check: hermes profile --help"
        fi
        ;;
      *)
        fail "Could not create profile '$profile' — no supported profile create command"
        ;;
    esac
  fi
done

# ── 3. Inject agent roles into profiles ───────────
step "3. Injecting agent role definitions into profiles"

for agent in cto pm designer dev qa ops security; do
  if python3 "$SCRIPT_DIR/configure-profile.py" "$HERMES_DIR" "$agent"; then
    ok "loaded role and shared catalog configured: $agent"
  else
    fail "could not bind profile: $agent"
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

if [ -z "$GITHUB_TOKEN" ]; then
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

[ -z "$GITHUB_USERNAME" ] && \
  warn "GITHUB_USERNAME not set — auto-issue-triage cannot self-assign issues. Add: export GITHUB_USERNAME=your-username" || \
  ok "GITHUB_USERNAME: $GITHUB_USERNAME"

[ -z "$GITHUB_REPO" ] && \
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

echo "[OK] Project metadata stored locally; agents load it with project.sh get."
echo "     Setup does not launch a model to populate memory."

# ── 8. Cron jobs ──────────────────────────────────
step "8. Setting up cron jobs"


ensure_cron() {
  local name="$1"
  local schedule="$2"
  local prompt="$3"
  local deliver="${4:-local}"
  local cron_list
  name="oh-my-hermes-$PROJECT_SLUG-${name#oh-my-hermes-}"
  prompt="Project $PROJECT_SLUG; use only memory keys prefixed project:$PROJECT_SLUG:. $prompt"
  if ! cron_list=$(hermes cron list --all 2>/dev/null); then
    fail "cannot list cron jobs; refusing to create potential duplicates"
    return 0
  fi
  if printf '%s\n' "$cron_list" | sed -E 's/^[[:space:]]*Name:[[:space:]]*//' | grep -Fxq "$name"; then
    if hermes cron edit "$name" --schedule "$schedule" --prompt "$prompt" --deliver "$deliver" --workdir "$PROJECT_DIR" >/dev/null 2>&1; then
      if hermes cron resume "$name" >/dev/null 2>&1; then
        ok "cron reconciled: $name"
      else
        fail "cannot resume $name"
      fi
    else
      fail "cannot reconcile $name; inspect hermes cron edit --help"
    fi
    return 0
  fi
  if hermes cron create --name "$name" --deliver "$deliver" --workdir "$PROJECT_DIR" "$schedule" "$prompt" >/dev/null 2>&1; then
    ok "cron created: $name"
  else
    fail "cannot create $name; inspect hermes cron create --help"
  fi
}

pause_cron() {
  local name="oh-my-hermes-$PROJECT_SLUG-$1" listing
  if ! listing=$(hermes cron list --all 2>/dev/null); then
    fail "cannot inspect jobs for cleared target"
    return 0
  fi
  if printf '%s\n' "$listing" | sed -E 's/^[[:space:]]*Name:[[:space:]]*//' | grep -Fxq "$name"; then
    if hermes cron pause "$name" >/dev/null 2>&1; then ok "paused cleared target: $name"; else fail "cannot pause $name"; fi
  fi
}

if [ -n "$PRODUCTION_URL" ]; then
  ensure_cron "oh-my-hermes-health" "*/15 * * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run health-check on $PRODUCTION_URL and save a dead letter if the check fails."
  ensure_cron "oh-my-hermes-log-observer" "15 * * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run observe-logs for $PRODUCTION_URL. Deduplicate known events and notify only on new actionable High or Critical groups."
else
  pause_cron health
  pause_cron log-observer
  warn "PRODUCTION_URL not set — health and log jobs paused/skipped"
  echo "         Set it and re-run, or add manually after deploy:"
  echo "         hermes cron add '*/15 * * * *' 'Run health-check on https://yourapp.vercel.app'"
fi

if [ -n "$GITHUB_REPO" ]; then
  ensure_cron "oh-my-hermes-product-review" "0 * * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: review active product work and actionable GitHub issues for $GITHUB_REPO. Keep one product outcome active and do not treat issue volume as the roadmap."
else
  pause_cron product-review
  pause_cron security-daily
  pause_cron security-weekly
  warn "GITHUB_REPO not set — repository jobs paused/skipped"
fi

ensure_cron "oh-my-hermes-daily-report" "0 9 * * *" \
  "Use failure-recovery for project ${PROJECT_SLUG:-default}: send cto-status-report to founder." \
  "${OMH_NOTIFICATION_TARGET:-local}"

if [ -n "$GITHUB_REPO" ]; then
  ensure_cron "oh-my-hermes-security-daily" "30 8 * * *" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run security-review daily mode for $GITHUB_REPO: check tracked secret exposure and new Critical dependency advisories. Deduplicate known findings."
  ensure_cron "oh-my-hermes-security-weekly" "0 9 * * 1" \
    "Use failure-recovery for project ${PROJECT_SLUG:-default}: run security-review weekly mode for $GITHUB_REPO: full dependency, configuration, and supply-chain assessment."
else
  warn "GITHUB_REPO not set — skipping scheduled security assessments"
fi

echo ""
echo "[CHECK] Configure model/provider access for each profile before enabling unattended work."
echo "        Role/catalog setup does not verify credentials, model calls, or message delivery."
echo "[CHECK] Review legacy unscoped oh-my-hermes-* jobs manually; they are never deleted automatically."

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
  echo "CTO profiles and jobs configured; runtime access still needs verification. Start with:"
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
