# Oh My Hermes

[![Version](https://img.shields.io/badge/version-1.0.0-4ade80?style=flat-square)](https://github.com/salomondiei08/oh-my-hermes/releases)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Hermes](https://img.shields.io/badge/Hermes-v0.13%2B-orange?style=flat-square)](https://hermes-agent.nousresearch.com)
[![Skills](https://img.shields.io/badge/skills-21-brightgreen?style=flat-square)](#skills-included)
[![Agents](https://img.shields.io/badge/agents-5-blue?style=flat-square)](#agents)
[![Stack](https://img.shields.io/badge/stack-Markdown%20%2B%20Bash-zinc?style=flat-square)](#)
[![Deploy](https://img.shields.io/badge/deploy-Vercel-black?style=flat-square)](https://vercel.com)
[![DB](https://img.shields.io/badge/db-Supabase-3ecf8e?style=flat-square)](https://supabase.com)

**An opinionated workflow layer for building, shipping, and operating apps — delivered directly to Hermes.**

Like Oh My Zsh is to Zsh. You install it once, and Hermes becomes genuinely useful for real software projects. Not a chatbot wrapper. Not a prompt pack. A set of curated skills that Hermes loads and runs autonomously — on your VPS, on your laptop, wherever Hermes lives.

---

## The core idea

Hermes is the operator. It talks to you. It remembers. It deploys. It monitors. It notifies.

You describe what you want in plain language — on Telegram, Slack, Discord, your terminal, wherever you have Hermes configured. Hermes loads the right skill and runs the workflow. Claude Code and Codex are optional power tools Hermes can invoke when a task needs deep file editing — but Hermes handles the orchestration, the ops, the memory, and the lifecycle on its own.

```
YOU  ──  Telegram / Slack / Discord / terminal
          │
          ▼
       HERMES  (VPS or local, running 24/7)
          │  persistent memory across sessions
          │  skill-based workflow execution
          │  cron for recurring ops tasks
          │
          ├──▶  deploys to Vercel
          ├──▶  runs migrations on Supabase
          ├──▶  checks /api/health
          ├──▶  sends Slack notifications
          ├──▶  invokes Claude Code (optional, for deep coding)
          └──▶  invokes Codex (optional, for quick fixes)
```

**Hermes does not need Claude Code or Codex to be useful.** Those engines are optional. Hermes itself has a terminal backend and can write, edit, and run code directly. Oh My Hermes's skills are designed to work with Hermes alone — and to chain into Claude Code or Codex when the task benefits from it.

---

## How it all fits together

```
┌─────────────────────────────────────────────────────────────────┐
│                        YOU (founder)                            │
│         Telegram · Slack · Discord · WhatsApp · terminal        │
└──────────────────────────┬──────────────────────────────────────┘
                           │  plain-language messages
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   HERMES  (VPS / local, 24/7)                   │
│                                                                 │
│  ┌──────────┐   routes to   ┌─────────────────────────────────┐ │
│  │ Gateway  │ ────────────▶ │        CTO Agent                │ │
│  │(Telegram │               │  monitors kanban, orchestrates  │ │
│  │ /Slack…) │               └───────────┬─────────────────────┘ │
│  └──────────┘                           │  spawns sub-agents    │
│                           ┌─────────────┼──────────────────┐    │
│                           ▼             ▼                  ▼    │
│                     ┌─────────┐  ┌─────────┐  ┌─────────────┐  │
│                     │   PM    │  │   Dev   │  │  QA  · Ops  │  │
│                     │ triage  │  │ build   │  │ review·ship │  │
│                     │ tickets │  │ PRs     │  │ monitor     │  │
│                     └────┬────┘  └────┬────┘  └──────┬──────┘  │
│                          │            │               │         │
│                    ┌─────▼────────────▼───────────────▼──────┐  │
│                    │           Hermes Kanban                  │  │
│                    │  Backlog → In Progress → Review → Done   │  │
│                    └─────────────────────────────────────────┘  │
│                                                                 │
│  Persistent memory · 21 skills · 5 workflows · cron jobs        │
└──────┬─────────────────────────────────────────────────────────┘
       │
       │  invokes when needed
       ├──▶  Claude Code  (deep multi-file coding)
       ├──▶  Codex        (quick single-file fixes)
       │
       │  deploys & monitors
       ├──▶  Vercel       (hosting + preview URLs)
       ├──▶  Supabase     (database + auth + migrations)
       ├──▶  GitHub       (issues, PRs, merge)
       └──▶  Sentry / Uptime Kuma  (error tracking + uptime)
```

**The autonomous loop** — once configured, this runs every hour without you touching anything:

```
GitHub issue opens
       ↓
  PM scores & triages  →  kanban: Backlog
       ↓
  Dev picks top issue  →  kanban: In Progress
       ↓
  Dev implements, creates PR  →  kanban: Review
       ↓
  QA reviews diff, runs health check, writes plain-English summary
       ↓
  YOU get a Telegram message: "PR #12 ready — reply YES or NO"
       ↓
  YES → merges, deploys, health checks, confirms live URL
  NO  → Dev iterates based on your feedback
```

---

## What problem does this solve?

Hermes Agent has persistent memory, autonomous skill generation, 19+ messaging platforms, cron scheduling, and flexible deployment backends. But out of the box, it gives you no defaults for Vercel, no conventions for Supabase, no curated skills for the idea→deploy lifecycle, and no AGENTS.md template for real projects.

Oh My Hermes fills that gap with:

- **21 skills** — covering the full app lifecycle, GitHub ops, and autonomous CTO loop
- **5 specialized agents** — CTO, PM, Dev, QA, Ops — each with defined responsibilities and kanban ownership
- **Hermes-native framing** — designed for Hermes as the primary operator, not as a routing layer requiring human intervention
- **VPS-ready** — works with Hermes running on a $5/month server or your local machine
- **Conventions** — AGENTS.md templates and project structure standards
- **Deployment patterns** — opinionated defaults for Vercel + Supabase + monitoring
- **Templates** — health endpoints, `.env` examples, bootstrap scripts

---

## The mental model

```
YOU
  └─ "start a new app" (via Telegram, Slack, terminal — wherever Hermes is)

HERMES (running on VPS or local, 24/7)
  ├─ clarifies requirements (asks 7 questions, saves to memory)
  ├─ generates product brief (writes PRODUCT_BRIEF.md)
  ├─ runs design-handoff (converts your design notes to spec)
  ├─ implements (via terminal backend, or routes to Claude Code/Codex)
  ├─ deploys to Vercel
  ├─ runs Supabase migrations
  ├─ sends Slack notification with URL
  ├─ checks /api/health
  └─ sets up monitoring (Sentry + Uptime Kuma)

CLAUDE DESIGN (optional human step — no API)
  └─ UI/UX exploration → export notes → give to Hermes

CLAUDE CODE (optional, for complex multi-file coding)
  └─ Hermes invokes when task needs deep file editing

CODEX (optional, for quick targeted fixes)
  └─ Hermes invokes when task is a focused single-file change
```

---

## Lifecycle

```
IDEA
  ↓  clarify-requirements    ← Hermes asks 7 questions, saves to memory
  ↓  product-brief           ← Hermes writes the brief, saves to memory
  ↓  [human] Claude Design   ← You do UI/UX (optional, no API)
  ↓  design-handoff          ← Hermes converts design to implementation spec
  ↓  choose-engine           ← Hermes decides: self / Claude Code / Codex
  ↓  implement               ← Hermes or coding engine executes spec
  ↓  deploy-to-vercel        ← Hermes deploys, captures URL
  ↓  connect-supabase        ← Hermes wires DB, runs migrations
  ↓  send-notification       ← Hermes notifies via Slack / messaging platform
  ↓  setup-monitoring        ← Sentry + Uptime Kuma
  ↓  post-deploy-followup    ← Hermes verifies health, logs deployment
  ↓
RUNNING APP — Hermes watches it
```

---

## Installation

### For humans

**Requires:** [Hermes Agent](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart) v0.9+, running locally or on a VPS.

```bash
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Installs 21 skills and 5 workflows to `~/.hermes/skills/` and `~/.hermes/workflows/`.

### Bootstrap a new project

```bash
cd /your/project
bash /path/to/oh-my-hermes/scripts/bootstrap.sh
```

Creates `AGENTS.md`, `.env.example`, and `src/app/api/health/route.ts`.

### Verify

```bash
bash /path/to/oh-my-hermes/scripts/verify.sh
```

### Configure the CTO loop

After installing, run the CTO setup script once to create agent profiles, initialize the kanban board, and schedule cron jobs:

```bash
export GITHUB_TOKEN=your-fine-grained-token
export GITHUB_USERNAME=your-github-username
export GITHUB_REPO=owner/repo

bash /path/to/oh-my-hermes/scripts/setup-cto.sh
```

Safe to re-run. See [docs/setup-guide.md](docs/setup-guide.md) for the complete walkthrough.

### For Hermes (hand it directly)

Once Oh My Hermes is installed, tell Hermes in plain language:

```
start a new app
```
```
deploy this project to Vercel
```
```
set up monitoring for https://myapp.vercel.app
```
```
run the idea-to-deploy workflow
```

Hermes loads the matching skill and runs it. You do not need to manually invoke anything else.

### For LLM agents

```bash
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
bash /tmp/oh-my-hermes/install.sh
bash /tmp/oh-my-hermes/scripts/verify.sh
cd /path/to/target/project
bash /tmp/oh-my-hermes/scripts/bootstrap.sh
```

---

## Skills included

| Skill | What Hermes does |
|---|---|
| `clarify-requirements` | Asks 7 structured questions, saves answers to memory |
| `product-brief` | Generates brief from requirements, writes PRODUCT_BRIEF.md |
| `create-skill` | Creates a new skill in the correct format (meta-skill) |
| `design-handoff` | Converts design notes to an implementation spec |
| `choose-engine` | Decides: Hermes terminal / Claude Code / Codex |
| `implement-with-claude-code` | Scaffolds Claude Code session with full context |
| `implement-with-codex` | Scaffolds Codex invocation with full context |
| `deploy-to-vercel` | Pre-deploy checks → deploy → capture URL |
| `connect-supabase` | Links Supabase, pushes migrations, sets Vercel env vars |
| `setup-monitoring` | Configures Sentry + documents Uptime Kuma setup |
| `health-check` | Calls `/api/health`, validates response, reports status |
| `send-notification` | Sends Slack webhook with deployment or status info |
| `post-deploy-followup` | Health check + deployment log + notification + summary |
| `manage-github-issues` | Triage, create, label, assign, and close GitHub issues |
| `create-github-pr` | Creates PR from feature branch with memory-drawn description |
| `auto-issue-triage` | Cron-triggered: scores open issues, picks top priority, routes to implementation |
| `review-github-pr` | Self-reviews PR diff, runs build and health check, writes plain-English founder summary |
| `await-merge-approval` | Sends PR summary to founder via chat, blocks until YES/NO reply, merges or iterates |
| `kanban-task` | Creates and updates Hermes kanban cards — used by every agent at every stage |
| `cto-status-report` | Reads full kanban + health log, sends plain-English morning report to founder |
| `backup-hermes-data` | Tarballs `~/.hermes/` to S3, Dropbox, or local — run on cron before any upgrade |

---

## Agents

| Agent | Role | Kanban ownership |
|---|---|---|
| **CTO** | Orchestrates all agents, monitors kanban, escalates, reports to founder | Reads all columns |
| **PM** | Triages GitHub issues, writes tickets, prioritizes backlog | Backlog |
| **Dev** | Implements tickets, picks the right engine, creates PRs | In Progress |
| **QA** | Reviews PRs, runs health checks, writes founder summary | Review |
| **Ops** | Deploys, monitors production, handles incidents, sends notifications | Done + monitoring |

Role definitions live in `agents/` and are installed to `~/.hermes/agents/`. Running `scripts/setup-cto.sh` creates the actual Hermes profiles (`cto`, `pm`, `dev`, `qa`, `ops`) and injects each role definition — that is what makes the agents active, not the role files alone.

---

## Workflow examples

**Start a new app (via Telegram, Slack, or any Hermes platform):**
```
you: start a new app
hermes: What problem does this solve? Who experiences it?
you: [answer]
hermes: [6 more questions…]
hermes: Requirements saved. Generating product brief…
hermes: Brief written to PRODUCT_BRIEF.md. Ready to implement or do design first?
```

**Deploy after implementing:**
```
you: deploy this to Vercel
hermes: Running pre-deploy checklist…
hermes: [checks git status, .gitignore, /api/health]
hermes: Deploying… done. URL: https://myapp.vercel.app
hermes: Health check: PASS (200ms)
hermes: Notification sent to Slack.
```

**Quick fix:**
```
you: fix the auth redirect bug in src/middleware.ts
hermes: Loading context from memory… routing to Codex (single-file fix)
hermes: codex "In src/middleware.ts, fix auth redirect…"
hermes: Done. Running typecheck… pass. Deploying.
```

---

## Deployment defaults

| Layer | Default | Alternative |
|---|---|---|
| Frontend / full-stack | Vercel | Railway, Render |
| Database | Supabase PostgreSQL | PlanetScale, Neon |
| Auth | Supabase Auth | Clerk, Auth.js |
| Error tracking | Sentry | LogRocket |
| Uptime monitoring | Uptime Kuma (self-hosted) | Better Uptime |
| Notifications | Slack webhook | Email (SendGrid) |

All defaults are pluggable. Each skill documents how to substitute.

---

## Running Hermes on a VPS

The intended setup for production use:

```bash
# On a $5/month VPS (Ubuntu 22.04+)
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes model        # choose your provider
hermes tools        # enable Telegram/Slack/Discord gateway
hermes              # start Hermes

# Then install Oh My Hermes
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

After this, you talk to Hermes via your configured messaging platform (Telegram, Slack, Discord, etc.) and it runs skills on the VPS — deploying, monitoring, notifying — without you needing to touch a terminal.

For Docker deployment:
```bash
docker run -d --restart=always \
  -v hermes-data:/root/.hermes \
  nousresearch/hermes-agent
```

---

## Architecture

See [docs/architecture.md](docs/architecture.md).

```
oh-my-hermes/
├── skills/          ← Load into ~/.hermes/skills/
├── workflows/       ← Load into ~/.hermes/workflows/
├── templates/       ← AGENTS.md template, .env example, health endpoints
├── examples/        ← Starter app (Next.js + Supabase + Vercel)
├── scripts/         ← bootstrap.sh, verify.sh
└── docs/            ← Full documentation
```

---

## Proposed improvements to Hermes

See [docs/improvements-to-hermes.md](docs/improvements-to-hermes.md) — concrete proposals for what should be added to Hermes core, documented in Hermes docs, or deferred.

---

## Autonomous CTO loop

The goal of Oh My Hermes is a real CTO for non-technical founders — one that works around the clock and only interrupts you when a decision is needed.

Once configured, the loop runs every hour without you touching anything:

```
Hermes monitors GitHub → picks top issue → implements → creates PR →
self-reviews → messages you → YOU: reply YES or NO → ships or iterates
```

**What you actually do:**

You get a message on Telegram (or Slack, Discord, WhatsApp — wherever you are):

```
New update ready

PR #12: Fix login redirect for new users
──────────────────────────────────────────
What changed:
Users who signed up but hadn't verified their email were being
sent to a broken page. They now see a "Check your inbox" screen.

Files touched: 2 files
  src/middleware.ts — fixed the redirect condition
  src/app/verify/page.tsx — added the confirmation screen

Quality checks:
✓ Build: passing
✓ Preview: healthy (180ms)
✓ No secrets detected

Preview link: https://myapp-fix-login-salomondiei08.vercel.app

Reply YES to ship it. Reply NO to skip (tell me why).
```

You reply YES. It merges, deploys, health-checks, and notifies you when it's live. You never opened a terminal.

**To set it up:**
```
tell Hermes: set up the CTO loop for github.com/yourusername/yourrepo, send approvals to me on Telegram
```

See the `cto-loop` workflow and `auto-issue-triage`, `review-github-pr`, and `await-merge-approval` skills for full details.

---

## Requirements

| Requirement | Version |
|---|---|
| Hermes Agent | v0.13+ |
| Bash | 3.2+ |
| For deploy skills | Vercel CLI + account |
| For database skills | Supabase CLI + account |
| For notifications | Slack webhook URL |

Claude Code and Codex are optional. Hermes handles the full workflow without them.

---

## What this is not

- Not a replacement for Hermes
- Not a custom agent runtime or daemon
- Not a no-code tool
- Not Claude Design (there is no Claude Design API)
- Not a dashboard product
- Not useful without Hermes installed first

---

## Roadmap

**V1 — current**
21 skills, 5 agent profiles, 5 workflows, AGENTS.md conventions, one-command CTO setup, Vercel + Supabase + GitHub ops, scripts, full docs, example app.

**V2 — planned**
Cron-based health monitoring (Hermes watches production on a schedule), incident creation skill, post-deploy automated tests, staging → production promotion workflow.

**V3 — planned**
Multi-service orchestration, rollback skill, more example apps.

---

## Contributing

Read [docs/architecture.md](docs/architecture.md) before proposing features — it explains what belongs here versus in Hermes core. Open issues for wrong or missing skills, bugs in scripts, or Hermes improvement proposals.

---

## License

MIT
