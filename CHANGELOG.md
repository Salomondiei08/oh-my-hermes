# Changelog

## 2.0.0 - 2026-06-19

### Product-building lifecycle

- Reworked `cto-loop` around Understand, Design, Build, Check, Ship, and Learn.
- Added a seventh permanent profile: Designer.
- Expanded Product (`pm`) to own positioning, SEO, launch strategy, and content
  planning while preserving the profile ID.
- Reframed Dev as Builder and QA as Reviewer without breaking profile names.

### New skills

- `computer-use`: guarded Hermes CUA workflow for native/authenticated GUI work.
- `product-marketing`: context, positioning, website, SEO, launch, and content.
- `creative-production`: restrained assets and HyperFrames launch video with
  music-license evidence.
- `observe-logs`: recurring, redacted, deduplicated production log review.
- `publish-with-buffer`: founder-approved scheduling through Buffer's official
  CLI, including dry runs and post-ID verification.
- `generate-with-seedance`: budget-gated video generation through the official
  Volcengine Ark asynchronous task API.
- `project-switch`, `project-status`, `failure-recovery`, `server-bootstrap`,
  `ship-this-idea`, and `reset-runtime`: first-run operating layer for fresh
  servers and multi-project work.
- `scripts/setup-integrations.sh`: just-in-time secret setup for OpenAI, Buffer,
  and Seedance in the Hermes environment without requesting keys in chat.
- Installed helper scripts now include project switching, founder status,
  dead-letter cron wrapping, safe runtime reset, fresh server bootstrap, and the
  flagship ship-this-idea launcher.

### Workflow behavior

- Replaced fixed questionnaires with read-first, maximum-three-question intake
  that continues with documented defaults.
- Made Designer responsible for `DESIGN.md` and rendered visual verification;
  external design tools are optional inputs.
- Added evidence-based Security and Reviewer gates plus YES/NO/CLOSE/LATER
  founder release choices.
- Added idempotent named crons for product review, health, logs, reporting, and
  daily/weekly security.
- Removed the incomplete tracked `examples/starter-app` because it claimed to be
  a runnable Next.js starter without the files needed to run.
- Removed the README Docker production snippet; Oh My Hermes is a Hermes skills
  pack, not an application container.

---

## 1.4.0 — 2026-05-09

### Added — CTO setup script and README corrections

**scripts/setup-cto.sh** (new)
- Creates real Hermes profiles (`hermes profile create cto/pm/dev/qa/ops`)
- Injects agent role definitions into `~/.hermes/profiles/$agent/agent-role.md`
- Initializes the Hermes kanban board (`hermes kanban init`)
- Authenticates `gh` CLI headlessly: `echo "$GITHUB_TOKEN" | gh auth login --with-token`
- Warns prominently if a gateway is already running (duplicate gateway = message conflicts)
- Saves `github-repo` and `github-username` to Hermes memory via `hermes chat -q`
- Sets up 3 cron jobs: hourly triage, 15-min health check, 9am status report
- Idempotent — safe to re-run; prints Pass/Warn/Fail summary

**docs/setup-guide.md**
- Added Step 5b: explains `setup-cto.sh` and its env var requirements

**README.md**
- Fixed stale "18 skills" count to "20 skills" in two locations
- Added "Configure the CTO loop" install step referencing `setup-cto.sh`

**scripts/verify.sh**
- Now checks that `setup-cto.sh` exists alongside `bootstrap.sh` and `verify.sh`

---

## 1.3.0 — 2026-05-09

### Added — Multi-agent architecture with Hermes kanban

**Agents** (`agents/` → installed to `~/.hermes/agents/`)
- `cto.md` — CTO Agent: orchestrates all agents, monitors kanban, reports to founder
- `pm.md` — PM Agent: triages issues, writes tickets, prioritizes backlog
- `dev.md` — Dev Agent: implements tickets, chooses engine, creates PRs
- `qa.md` — QA Agent: reviews PRs, runs health checks, writes founder summaries
- `ops.md` — Ops Agent: deploys, monitors production every 15min, handles incidents

**Skills**
- `kanban-task` — creates/updates Hermes kanban cards at every stage; used by all agents
- `cto-status-report` — reads full kanban + health log, sends plain-English morning report

**Workflows**
- `cto-loop` (v2) — rewritten with full multi-agent architecture and kanban column flow

**install.sh**
- Now installs `agents/` to `~/.hermes/agents/` alongside skills and workflows

---

## 1.2.0 — 2026-05-09

### Added — Autonomous CTO loop

**Skills**
- `auto-issue-triage` — cron-triggered hourly triage: scores issues by impact, picks top priority, routes to implementation
- `review-github-pr` — self-reviews PR diff, runs build + health check on preview URL, writes plain-English founder summary
- `await-merge-approval` — sends PR summary to founder via chat platform, blocks until YES/NO, merges or feeds back into the loop

**Workflows**
- `cto-loop` — full autonomous CTO workflow: cron → triage → implement → PR → review → approval → ship

**README**
- Added "Autonomous CTO loop" section with real example of the founder Telegram experience

---

## 1.1.0 — 2026-05-09

### Added

**Skills**
- `manage-github-issues` — triage, create, label, assign, and close GitHub issues via `gh` CLI
- `create-github-pr` — creates PR from feature branch with description drawn from Hermes memory

**Workflows**
- `github-ops` — full GitHub ops loop: triage issues → implement → PR → preview deploy → merge

### Changed

- All 13 existing skills rewritten with CSO-optimized descriptions (all start "Use when...")
- Descriptions now describe triggering conditions only — no workflow summaries
- All skills under 350 words for Hermes memory efficiency

---

## 1.0.0 — 2026-05-09

### Added

**Skills**
- `create-skill` — create new skills in the correct format (meta-skill)
- `clarify-requirements` — structured requirement clarification, stores answers to Hermes memory
- `product-brief` — generates product brief from clarified requirements, writes PRODUCT_BRIEF.md
- `design-handoff` — converts Claude Design output to an implementation spec
- `choose-engine` — routes a task to Claude Code, Codex, or Hermes based on task type
- `implement-with-claude-code` — scaffolds Claude Code session with full project context
- `implement-with-codex` — scaffolds Codex invocation with full context in command string
- `deploy-to-vercel` — deploys to Vercel with pre-deploy checks and post-deploy URL capture
- `connect-supabase` — wires Supabase project, runs migrations, sets Vercel env vars
- `setup-monitoring` — configures Sentry SDK and documents Uptime Kuma setup
- `health-check` — calls /health endpoint, validates response, reports status
- `send-notification` — sends Slack webhook notification with deployment or status info
- `post-deploy-followup` — runs health-check, logs deployment to memory, sends notification

**Workflows**
- `idea-to-deploy` — full lifecycle from idea to deployed app
- `design-to-code` — design output to implemented code
- `deploy-and-monitor` — deploy existing codebase with monitoring setup

**Templates**
- `templates/AGENTS.md.template` — AGENTS.md template for new projects
- `templates/.env.example` — environment variables template for new projects
- `templates/healthcheck/nextjs-health-route.ts` — /health endpoint for Next.js App Router
- `templates/healthcheck/express-health.js` — /health endpoint for Express

**Scripts**
- `install.sh` — installs skills and workflows to ~/.hermes/
- `scripts/bootstrap.sh` — bootstraps new projects with AGENTS.md, .env.example, health endpoint
- `scripts/verify.sh` — validates install completeness

**Documentation**
- `README.md`, `docs/architecture.md`, `docs/installation.md`, `docs/engines.md`
- `docs/workflows.md`, `docs/design-handoff.md`, `docs/improvements-to-hermes.md`
