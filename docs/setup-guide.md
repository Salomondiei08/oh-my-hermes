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
gh auth login        # follow the OAuth flow

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
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Verify:
```bash
bash ~/.hermes/verify.sh    # or the path where you cloned the repo
```

All items should show [OK].

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
- `src/app/api/health/route.ts` — the `/api/health` endpoint Hermes checks after every deploy

**Fill in AGENTS.md.** This is important — it tells the Dev Agent what stack to use and what conventions to follow.

---

## Step 7 — Set your environment variables

Required minimum:
```bash
# In your .env.local
VERCEL_TOKEN=             # Vercel dashboard → Account Settings → Tokens
SLACK_WEBHOOK_URL=        # or leave empty if using Telegram for notifications
GITHUB_TOKEN=             # gh auth token (gh auth token)
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
