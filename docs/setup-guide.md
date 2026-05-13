# Complete Setup Guide

Everything you need before the CTO loop runs autonomously.

---

## What you need before starting

| Requirement | Why |
|---|---|
| A VPS or always-on machine | Hermes must run 24/7 for cron and monitoring |
| Hermes Agent v0.9+ | The runtime |
| A model provider (Anthropic, OpenAI, OpenRouter…) | Hermes needs an LLM |
| A messaging platform (Telegram recommended) | How you receive approval requests |
| GitHub account + repo | Where your project lives |
| GitHub CLI (`gh`) | How Hermes manages issues and PRs |
| Vercel account + CLI | For deployment |
| Node.js 18+ | For Vercel and Supabase CLIs |

---

## Step 1 — Get a VPS

Cheapest option that works: $5/month Ubuntu 22.04 on DigitalOcean, Hetzner, or Vultr.

```bash
# After SSH into your VPS:
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl unzip
```

---

## Step 2 — Install Hermes Agent

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
hermes --version   # should print v0.9+
```

Configure a model provider:
```bash
hermes model       # interactive wizard — choose Anthropic or OpenAI
```

Test it works:
```bash
hermes chat -q "say hello"
```

---

## Step 3 — Connect your messaging platform

Telegram is the most reliable for approvals (always-on, works on any phone).

```bash
hermes gateway setup     # interactive — choose Telegram
hermes gateway start     # start as background service
hermes gateway status    # confirm it's running
```

For Telegram: the wizard will give you a bot link to open on your phone. Open it, start the bot, send a message — Hermes responds. That's your approval channel.

For Slack:
```bash
hermes gateway setup     # choose Slack, follow OAuth flow
```

---

## Step 4 — Install CLIs

```bash
# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh -y

# GitHub authentication — VPS has no browser, use a token instead of gh auth login
# 1. Go to github.com → Settings → Developer settings → Personal access tokens → Fine-grained tokens
# 2. Create a token with these permissions on your repo:
#    - Contents: Read & Write      (push code)
#    - Issues: Read & Write        (triage, comment, close)
#    - Pull requests: Read & Write (create, merge PRs)
#    - Metadata: Read              (required base permission)
# 3. Copy the token, then on your VPS:
echo "YOUR_GITHUB_TOKEN" | gh auth login --with-token
gh auth status   # confirm: Logged in to github.com as [your-username]

# Also set it as an env var so skills can use it directly:
echo 'export GITHUB_TOKEN="YOUR_GITHUB_TOKEN"' >> ~/.bashrc
source ~/.bashrc

# Vercel CLI
npm install -g vercel
vercel login

# Supabase CLI (if using Supabase)
npm install -g supabase
supabase login
```

---

## Step 5 — Install Oh My Hermes

```bash
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
cd /tmp/oh-my-hermes
bash install.sh
```

Verify:
```bash
bash ~/.hermes/verify.sh    # or the path where you cloned the repo
```

All items should show [OK].

## Step 5b — Configure the CTO loop agents

This creates real Hermes profiles for each agent, initializes the kanban board, and sets up cron jobs. Run it after `install.sh`:

```bash
# Set these first (see Step 7 for details):
export GITHUB_TOKEN=your-fine-grained-token
export GITHUB_USERNAME=your-github-username
export GITHUB_REPO=owner/repo
export PRODUCTION_URL=https://yourapp.vercel.app   # optional but recommended

OH_MY_HERMES_SETUP_CTO_CONFIRM=1 bash /path/to/oh-my-hermes/scripts/setup-cto.sh
```

The script:
- Creates Hermes profiles: `cto`, `pm`, `dev`, `qa`, `ops`
- Injects each agent's role definition into its profile
- Initializes the kanban board
- Authenticates `gh` CLI using your token (no browser needed)
- Warns if a gateway is already running (do not start duplicate gateways with the same bot token)
- Saves your repo and username to Hermes memory
- Sets up three cron jobs: hourly issue triage, 15-min health check, 9am daily report

Safe to re-run — it is idempotent.

---

## Step 6 — Bootstrap your project

In your project directory:
```bash
cd /path/to/your/project
bash /path/to/oh-my-hermes/scripts/bootstrap.sh
```

This creates:
- `AGENTS.md` — fill in your project name, stack, and any constraints
- `.env.example` — fill in and copy to `.env.local`
- `src/app/api/health/route.ts` — the `/api/health` endpoint Hermes checks after every deploy (created only when Next.js is detected)

**Fill in AGENTS.md.** This is important — it tells the Dev Agent what stack to use and what conventions to follow.

---

## Step 7 — Set your environment variables

Required minimum:
```bash
# In your .env.local

# GitHub — required for all CTO loop skills (issues, PRs, kanban)
# Create at: github.com → Settings → Developer settings → Personal access tokens → Fine-grained
# Permissions needed: Contents (R/W), Issues (R/W), Pull requests (R/W), Metadata (R)
GITHUB_TOKEN=your-fine-grained-token
GITHUB_USERNAME=your-github-username     # used when Hermes assigns issues to itself
GITHUB_REPO=owner/repo                   # the repo the CTO loop manages

# Vercel
VERCEL_TOKEN=             # vercel.com → Account Settings → Tokens
SLACK_WEBHOOK_URL=        # leave empty if using Telegram only
```

Add to Vercel for production:
```bash
vercel env add SENTRY_DSN production        # after setup-monitoring
vercel env add SUPABASE_URL production      # after connect-supabase
```

---

## Step 8 — Start the CTO loop

Tell Hermes (via Telegram, Slack, or terminal):

```
Set up the CTO loop for [owner/repo].
Send approvals to me on Telegram.
```

Hermes will:
1. Save your repo and approval platform to memory
2. Set up three cron jobs:
   - Hourly issue triage
   - 15-minute production health check
   - 9am daily status report
3. Confirm and show you the kanban board

---

## What happens next (no action needed from you)

- Every hour: Hermes checks GitHub for new issues, scores them, picks the top one
- When an issue is picked: Dev Agent implements it, creates a PR, QA Agent reviews it
- When QA passes: you get a Telegram/Slack message with a plain-English summary and a YES/NO prompt
- You reply YES → it merges, deploys, health checks, and confirms back to you
- You reply NO → tell it what to change, it iterates

---

## Troubleshooting

**Hermes gateway not responding on Telegram:**
```bash
hermes gateway status
hermes gateway restart
hermes logs gateway
```

**Kanban not showing tasks:**
```bash
hermes kanban list
hermes kanban stats
```

**Cron jobs not firing:**
```bash
hermes cron list
hermes cron status
```

**Health check always failing:**
- Check that `/api/health` returns `{ "status": "ok" }` with HTTP 200
- Check Vercel function logs in the dashboard
- Check the URL saved in memory: retrieve `last-deployment`

**Build failing on Vercel but passing locally:**
- Compare Node.js version: `node --version` vs Vercel project settings
- Check Vercel env vars match your `.env.local`

---

## Minimum viable setup (just to test)

If you want to try the approval loop without the full CTO automation:

1. Steps 1–5 (Hermes + messaging + CLIs + Oh My Hermes)
2. Tell Hermes: `deploy this project to Vercel` — it runs `deploy-to-vercel`
3. After deploy: tell Hermes: `run post-deploy-followup` — it health checks and notifies you
4. Create a GitHub issue manually — tell Hermes: `implement issue #1` — it picks it up, implements, creates PR, reviews, and asks for your approval
