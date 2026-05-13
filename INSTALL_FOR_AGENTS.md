# Oh My Hermes — Agent Install Protocol

Canonical install reference for AI agents. Read and execute top to bottom.

---

## Prerequisites check

```bash
command -v hermes || echo "MISSING: install Hermes Agent first"
command -v git    || echo "MISSING: git required"
```

If `hermes` is missing, stop and tell the user to install Hermes Agent first:
https://hermes-agent.nousresearch.com/docs/getting-started/quickstart

---

## Step 1 — Install

```bash
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Installs 23 skills, 5 workflows, and 6 agent role definitions into `~/.hermes/`.

---

## Step 2 — Verify

```bash
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes 2>/dev/null || true
bash /tmp/oh-my-hermes/scripts/verify.sh
```

All items should show `[OK]`. If any show `[MISSING]`, re-run Step 1.

---

## Step 3 — Bootstrap the project

```bash
cd /path/to/project
bash /tmp/oh-my-hermes/scripts/bootstrap.sh
```

Creates `AGENTS.md`, `.env.example`, and `src/app/api/health/route.ts`.

---

## Step 4 — Configure the CTO loop

```bash
export GITHUB_TOKEN=<fine-grained-token>   # Permissions: Contents/Issues/PRs/Metadata R/W
export GITHUB_USERNAME=<github-username>
export GITHUB_REPO=<owner/repo>
export PRODUCTION_URL=<https://yourapp.vercel.app>   # optional

bash /tmp/oh-my-hermes/scripts/setup-cto.sh
```

Creates Hermes profiles (cto, pm, dev, qa, ops, security), initializes kanban, schedules 4 cron jobs.

---

## Step 5 — Lock persistent focus

In Hermes, run:

```
/goal Manage [owner/repo] as CTO. Triage issues hourly, implement top priority, get founder approval before merging. Never ship without YES.
```

---

## What gets installed

| Path | Contents |
|---|---|
| `~/.hermes/skills/` | 22 skills — full app lifecycle + CTO loop |
| `~/.hermes/workflows/` | 5 workflows |
| `~/.hermes/agents/` | 6 agent role definitions |
| `~/.hermes/profiles/` | 6 active profiles (after setup-cto.sh) |

---

## Uninstall

```bash
bash /tmp/oh-my-hermes/scripts/uninstall.sh
```

Removes all Oh My Hermes files. Hermes memory and gateway are untouched.
