<img src="banner.png" alt="Oh My Hermes" width="100%" />

# OMH — Oh My Hermes

[![Stars](https://img.shields.io/github/stars/salomondiei08/oh-my-hermes?style=flat-square)](https://github.com/salomondiei08/oh-my-hermes/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Hermes](https://img.shields.io/badge/Hermes-v0.16%2B-orange?style=flat-square)](https://hermes-agent.nousresearch.com)
[![Skills](https://img.shields.io/badge/skills-30-brightgreen?style=flat-square)](#skills)
[![Agents](https://img.shields.io/badge/agents-7-blue?style=flat-square)](#agents)

**An opinionated workflow layer for building, shipping, and operating apps — delivered directly to Hermes.**

Like Oh My Zsh is to Zsh. You install it once and Hermes becomes genuinely useful for real software projects. Not a chatbot wrapper. Not a prompt pack. A curated set of skills that Hermes loads and runs autonomously — on your VPS, on your laptop, wherever Hermes lives.

---

## Use with your coding agent

Copy this and paste it into Claude, Cursor, Copilot, or any coding assistant:

```
Install Oh My Hermes by running this command:
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
bash /tmp/oh-my-hermes/install.sh

Then read the full workflow documentation at:
https://github.com/salomondiei08/oh-my-hermes

And follow the instructions in INSTALL_FOR_AGENTS.md in that repo.
```

---

## The core idea

Tell Hermes what you want to build. It helps understand it, designs it, builds
it, checks it, ships it, watches it, and learns from real use.

```text
Understand -> Design -> Build -> Check -> Ship -> Learn
```

The CTO coordinates seven focused agents through Hermes Kanban. GitHub issues
and PRs are useful delivery evidence, but they are not the roadmap or the goal.
Work can start from an idea, customer feedback, production logs, analytics, or an
issue.

Hermes reads the project before asking anything. It asks at most three useful
questions, supplies recommended defaults, and continues when you skip them.
Only irreversible actions such as production release, rollback, public posting,
licensed media, payment, or destructive account changes require your approval.

```text
Founder
  |
  v
CTO: lifecycle, roadmap, delegation, decisions
  |
  +-- Product: brief, priorities, positioning, SEO, content
  +-- Designer: UX, visual verification, launch assets and video
  +-- Builder: working product increments
  +-- Reviewer: journeys, visual/accessibility checks, PR review
  +-- Security: release risk plus daily/weekly assessment
  +-- Ops: deploy, health, deduplicated logs, incidents
  |
  v
Hermes Kanban + memory + cron + completion evidence
```

Claude Code and Codex remain optional implementation engines. Computer Use is a
guarded shared skill for native or authenticated GUI tasks, not another agent.
HyperFrames launch videos and licensed music activate only when requested.

---

## Get started

**Step 1 — Install Hermes Agent**

Follow the [Hermes quickstart](https://hermes-agent.nousresearch.com/docs/getting-started/quickstart). At the end you have a bot you can message on Telegram (or Slack, Discord, WhatsApp).

**Step 2 — Install Oh My Hermes**

```bash
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
bash /tmp/oh-my-hermes/install.sh
```

**Step 3 — Message your bot**

```
set up the CTO loop
```

The bot inspects the project, asks only for missing settings that matter, and
continues with sensible defaults when you skip them. GitHub and a production URL
can be connected later; they do not block product discovery and building.

**What you unlock at each step:**

| Step | What to do | What you get |
|---|---|---|
| 1 | Install Hermes + connect Telegram | A bot you can message |
| 2 | Run install.sh | 30 skills and 5 workflows loaded |
| 3 | Message: "set up the CTO loop" | Bot guides the full setup in chat |
| 4 | Connect GitHub when useful | Issues and PR delivery enabled |
| 5 | Add production URL after deploy | Health and log observation enabled |
| 6 | `/goal` command | Agent stays focused across long sessions |
| — | Autonomous from here | Product review, daily report, recurring security and logs |

---

## Skills

| Skill | What Hermes does |
|---|---|
| `onboarding` | Infers setup, asks at most three optional questions, avoids duplicate crons |
| `clarify-requirements` | Reads first, asks only material questions, continues with defaults |
| `product-brief` | Writes the compact product source of truth and acceptance criteria |
| `design-handoff` | Designer creates `DESIGN.md` and verifies implemented UI |
| `computer-use` | Safely operates native/authenticated GUI only when simpler tools cannot |
| `product-marketing` | Positioning, website copy, SEO, launch strategy, and content schedule |
| `creative-production` | Product assets and HyperFrames launch video with licensed music evidence |
| `generate-with-seedance` | Approved paid video shots through the official Volcengine Ark API |
| `publish-with-buffer` | Dry-runs and schedules approved posts with the official Buffer CLI |
| `create-skill` | Creates a new skill in the correct format (meta-skill) |
| `choose-engine` | Routes tasks to Hermes, Claude Code, or Codex |
| `implement-with-claude-code` | Scaffolds Claude Code with full context + scope constraints |
| `implement-with-codex` | Scaffolds Codex for targeted single-file fixes |
| `deploy-to-vercel` | Pre-deploy checks → deploy → capture URL |
| `connect-supabase` | Links Supabase, pushes migrations, sets Vercel env vars |
| `setup-monitoring` | Configures Sentry + Uptime Kuma |
| `health-check` | Calls `/api/health`, validates response, checks Supabase + Vercel logs |
| `send-notification` | Sends Slack webhook with deployment or status info |
| `post-deploy-followup` | Health check + deployment log + notification + summary |
| `manage-github-issues` | Triage, create, label, assign, and close GitHub issues |
| `create-github-pr` | Creates PR with secret scan before opening |
| `auto-issue-triage` | Hourly: scores open issues, picks top priority, starts work |
| `review-github-pr` | Verifies the product increment, then approves or requests changes |
| `security-review` | Tool-backed release gate plus daily and weekly assessments |
| `await-merge-approval` | Founder chooses YES, NO, CLOSE, or LATER |
| `observe-logs` | Deduplicates runtime errors and escalates only actionable changes |
| `kanban-task` | Creates and updates Hermes kanban cards at every stage |
| `cto-status-report` | Daily morning report: what's in progress, done, blocked |
| `backup-hermes-data` | Tarballs `~/.hermes/` to S3, Dropbox, or local |
| `rollback` | Rolls back Vercel production to previous deploy after health check failure — requires founder YES |

---

## Agents

Seven agents cover the product lifecycle without creating a profile for every
tool. Role definitions live in `agents/`. Running `scripts/setup-cto.sh` (or
messaging "set up the CTO loop") creates all seven profiles.

---

### CTO — Product Lifecycle

The main Hermes session owns the roadmap loop from understanding through
learning. It delegates specialists and is the only agent that summarizes
decisions to you.

**What triggers it:** Every hour via cron, or when you send a message.

**What it does:**
- Watches the kanban continuously (`hermes kanban watch`)
- Spawns Product, Designer, Builder, Reviewer, Security, or Ops as needed
- Sends you a daily morning report (what shipped, what's stuck, what needs your input)
- Escalates to you only when a human decision is needed — health check failure, task blocked twice, secret found in a diff, scope change
- Makes the call when two sub-agents conflict

**What it does NOT do:** Replace specialist work or ask for routine decisions.

---

### Product (`pm`) — Product and Growth

Owns product clarity, priorities, positioning, SEO, launch strategy, and growth
learning. The profile ID remains `pm` for compatibility.

**What triggers it:** When new issues appear on GitHub or when the CTO spawns it for triage.

**What it does:**
- Reads product evidence, customer feedback, analytics, and issues
- Writes compact briefs and testable outcome tasks
- Asks at most three questions and uses recommended defaults when skipped
- Creates website, SEO, launch, and content plans from real product evidence
- Pings you after 24h if a blocked or approval-waiting card has gone stale

**What it does NOT do:** Implement code, design assets, invent evidence, or
publish externally without approval.

---

### Designer — Product and Creative Design

Owns UX, visual direction, responsive behavior, design verification, and launch
media.

**What it does:**
- Writes `DESIGN.md` from the product brief and existing interface
- Provides a recommended reversible direction instead of blocking on preferences
- Inspects real mobile and desktop renders
- Uses browser tools first and guarded Computer Use only for native/authenticated UI
- Produces restrained HyperFrames launch videos when requested
- Shortlists licensed music and records license coverage before use

**What it does NOT do:** Hide the product behind synthetic visuals, use
unlicensed music, or publish assets without approval.

---

### Builder (`dev`) — Software Builder

Builds the smallest complete product increment and reports acceptance-criteria,
test, runtime, and change evidence.

**What triggers it:** When the PM Agent creates a ready card assigned to `dev` and the dispatcher starts work.

**What it does:**
- Claims the highest-priority ready ticket assigned to `dev`
- Chooses the right engine for the task: Hermes terminal for ops/config, Codex for single-file bug fixes, Claude Code for multi-file features
- Implements the change, commits after every logical unit of work
- Never commits `.env` files, API keys, tokens, or credentials — scans `git diff --staged` before every commit
- Creates a PR when the repository uses that delivery workflow
- Completes the implementation task with PR summary and metadata for Security/QA handoff

**What it does NOT do:** Merge PRs, deploy to production, start a second ticket while one is in progress, or make product decisions.

---

### Security — Product Security

Independently reviews relevant release risk and runs recurring assessment.

**What triggers it:** Security-relevant changes, daily lightweight cron, and
weekly deeper assessment.

**What it does on every PR:**
- Uses available Gitleaks, Semgrep, OSV-Scanner, and ecosystem audits
- Reviews auth, authorization, input, uploads, payments, logs, and RLS in context
- Deduplicates findings and requires evidence plus a re-test

**What it does regularly:** Daily secret/Critical advisory checks and a weekly
full dependency, configuration, and supply-chain assessment.

**Severity table:**

| Level | Action |
|---|---|
| Critical | Block merge. Alert you immediately via Telegram. |
| High | Block merge. Comment on PR with fix instructions for Dev. |
| Medium | Comment on PR. Fix before next sprint. Does not block. |
| Low | Log to memory. Include in weekly report. |

**What it does NOT do:** Run destructive tests on production, silently accept
risk, or claim an unavailable scanner passed.

---

### Reviewer (`qa`) — Product Quality

Verifies the intended user experience. PR review is one mechanism, not the goal.

**What triggers it:** When the Security Agent passes a PR and hands off for QA.

**What it does:**
- Reviews the brief, design criteria, implementation evidence, and diff
- Runs `gh pr checks` to verify the build passes
- Runs a health check on the Vercel preview URL — HTTP 200, `status: ok`, under 3000ms
- Exercises acceptance criteria plus responsive, loading, empty, error, and success states
- Submits APPROVE or REQUEST CHANGES when a PR exists
- Writes a plain-English founder summary: what the user experiences differently, which functions changed (not filenames), build status, response time, preview link
- Sends back to Dev with specific feedback if anything fails

**What it does NOT do:** Merge PRs, implement fixes, or approve without running the health check.

---

### Ops — Release and Reliability

Owns Done + active monitoring. Handles everything infrastructure.

**What triggers it:** After QA approval, and on a 15-minute health-check cron.

**What it does:**
- Deploys to Vercel (production and preview)
- Runs a three-layer health check after every deploy: app endpoint (`/api/health`), Supabase connection, Vercel logs scan
- Monitors production every 15 minutes — checks HTTP status, response time, Supabase query latency, log errors
- Runs `observe-logs` hourly, groups duplicate failures, and correlates regressions with releases
- Sends you a Slack/Telegram notification after every deploy and on any incident
- On incident: retries once after 60 seconds, identifies which layer failed, pulls logs for context, alerts you in plain language — never pastes raw logs or stack traces
- Offers to roll back if the last deploy was less than 2 hours ago; confirms with you before doing it
- Holds all DB-touching operations during active Supabase incidents and resumes when the status page clears

**What it does NOT do:** Write product features, make product decisions, or
roll back without approval.

---

## Workflow examples

**Start a new project:**
```
you: start a new app
hermes: I found the stack and existing project context. I have two choices that
        materially affect V1, with recommended defaults. Skip them and I will
        continue with those defaults.
you: use the defaults
hermes: PRODUCT_BRIEF.md and DESIGN.md are ready. Starting the first complete
        build increment now.
```

**Deploy after implementing:**
```
you: deploy this to Vercel
hermes: Running pre-deploy checklist…
hermes: Deploying… done. URL: https://myapp.vercel.app
hermes: Health check: PASS (200ms)
hermes: Notification sent to Slack.
```

**Quick fix:**
```
you: fix the auth redirect bug in src/middleware.ts
hermes: Loading context… routing to Codex (single-file fix)
hermes: Done. Typecheck passes. Creating PR…
hermes: The auth flow works on preview and the review is approved. Reply YES to
        ship, NO with feedback, CLOSE, or LATER.
```

**Steer mid-session (Hermes v0.13+):**
```
you: /steer prioritize the payment bug above everything else
hermes: Understood. Switching Dev Agent to issue #38.
```

---

## Default stack

| Layer | Default | Alternative |
|---|---|---|
| Frontend / full-stack | Vercel | Railway, Render |
| Database | Supabase PostgreSQL | PlanetScale, Neon |
| Auth | Supabase Auth | Clerk, Auth.js |
| Error tracking | Sentry | LogRocket |
| Uptime monitoring | Uptime Kuma | Better Uptime |
| Notifications | Slack webhook | Telegram, Email |

All pluggable. Each skill documents how to substitute.

---

## Running on a VPS

The intended setup for production use — Hermes runs 24/7, crons fire automatically, you interact from your phone:

```bash
# On a $5/month VPS (Ubuntu 22.04+)
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes model        # choose your provider (Anthropic, OpenAI, etc.)
hermes gateway setup && hermes gateway start   # connect Telegram or Slack

# Then install Oh My Hermes
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
bash /tmp/oh-my-hermes/install.sh

# Message your bot: "set up the CTO loop"
```

Oh My Hermes itself is not deployed as an app. It installs skills, workflows,
agents, and scripts into Hermes. Your product deploys through its own platform
such as Vercel; Docker is not part of the default production path.

### Optional credentials, only when needed

Oh My Hermes does not ask for every service during onboarding. Credentials are
stored in `~/.hermes/.env` with user-only permissions and are requested at the
first action that requires them:

- OpenAI: when selected as the Hermes model or creative provider.
- Buffer: when the founder first approves scheduling a social post.
- Seedance: when the founder first approves a paid generated-video shot.

```bash
bash ~/.hermes/scripts/setup-integrations.sh --check
bash ~/.hermes/scripts/setup-integrations.sh --buffer
bash ~/.hermes/scripts/setup-integrations.sh --seedance
bash ~/.hermes/scripts/setup-integrations.sh --openai
```

Never paste credentials into chat. Buffer submissions are dry-run first;
Seedance requests show the payload and estimated cost before approval.

---

## Installation scripts

| Script | What it does |
|---|---|
| `install.sh` | Installs all skills, workflows, and agent definitions |
| `scripts/bootstrap.sh` | Creates `AGENTS.md`, `.env.example`, health endpoint in a project |
| `scripts/setup-cto.sh` | Creates profiles, initializes kanban, schedules crons |
| `scripts/setup-integrations.sh` | Securely configures optional OpenAI, Buffer, and Seedance credentials |
| `scripts/verify.sh` | Checks everything is installed correctly |
| `scripts/uninstall.sh` | Removes all Oh My Hermes files from `~/.hermes/` |

---

## Optional: GBrain memory backbone

[GBrain](https://github.com/garrytan/gbrain) gives Hermes a richer, self-updating knowledge graph — people, companies, decisions, deployment history — queryable across sessions.

```bash
git clone https://github.com/garrytan/gbrain.git ~/gbrain && cd ~/gbrain
curl -fsSL https://bun.sh/install | bash && export PATH="$HOME/.bun/bin:$PATH"
bun install && bun link && gbrain init
```

Do not use `npm install -g gbrain` — a squatter package exists on npm under that name.

---

## Architecture

```
oh-my-hermes/
├── skills/          ← 30 skill files → ~/.hermes/skills/
├── workflows/       ← 5 workflow files → ~/.hermes/workflows/
├── agents/          ← 7 agent role definitions → ~/.hermes/agents/
├── templates/       ← AGENTS.md template, .env example, health endpoint
├── scripts/         ← install, bootstrap, verify, setup-cto, integrations, uninstall
└── docs/            ← Full documentation
```

See [docs/architecture.md](docs/architecture.md) for detail.

---

## Roadmap

**V1 — current**
30 skills, 7 agents, 5 workflows, optional-question onboarding, product design,
computer use policy, recurring security and log observation, creative launch
production, one-command CTO setup, Vercel + Supabase + GitHub delivery.

**V2 — planned**
Staging-to-production promotion, broader provider adapters, and more complete
post-deploy journey tests.

**V3 — planned**
Multi-service orchestration, more example apps, hosted setup wizard.

---

## Star history

[![Star History Chart](https://api.star-history.com/svg?repos=salomondiei08/oh-my-hermes&type=Date)](https://star-history.com/#salomondiei08/oh-my-hermes&Date)

---

## Contributing

Read [docs/architecture.md](docs/architecture.md) before proposing features. Open issues for wrong or missing skills, bugs in scripts, or Hermes improvement proposals.

---

## License

MIT
