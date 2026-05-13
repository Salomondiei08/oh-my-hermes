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

Preferred install. Clone first so the installer has access to the repo-local `skills/`, `workflows/`, `agents/`, and `scripts/` directories:

```bash
git clone https://github.com/salomondiei08/oh-my-hermes /tmp/oh-my-hermes
cd /tmp/oh-my-hermes
bash install.sh
```

Non-interactive install is also supported. The installer will clone a temporary copy if it is run through `curl | bash`:

```bash
curl -fsSL https://raw.githubusercontent.com/salomondiei08/oh-my-hermes/main/install.sh | bash
```

Installs 23 skills, 5 workflows, and 6 agent role definitions into `~/.hermes/` or `$HERMES_HOME` when set.

---

## Step 2 — Verify

```bash
bash /tmp/oh-my-hermes/scripts/verify.sh
```

All required items should show `[OK]`. If any show `[MISSING]`, re-run Step 1 from a fresh clone.

---

## Step 3 — Bootstrap the project

```bash
cd /path/to/project
bash /tmp/oh-my-hermes/scripts/bootstrap.sh
```

Creates `AGENTS.md` and `.env.example` if they do not already exist.

If the project is detected as a Next.js App Router app, it also creates `src/app/api/health/route.ts`. For non-Next.js projects, the health endpoint is skipped instead of creating framework-specific files in the wrong stack.

---

## Step 4 — Configure the CTO loop

This step has side effects: it creates Hermes profiles, touches GitHub auth, writes Hermes memory, and schedules cron jobs. Run it only when you are ready for those automations.

```bash
export GITHUB_TOKEN=<fine-grained-token>   # Permissions: Contents/Issues/PRs/Metadata R/W
export GITHUB_USERNAME=<github-username>
export GITHUB_REPO=<owner/repo>
export PRODUCTION_URL=<https://yourapp.vercel.app>   # optional

bash /tmp/oh-my-hermes/scripts/setup-cto.sh
```

For unattended setup, pass explicit confirmation:

```bash
OH_MY_HERMES_SETUP_CTO_CONFIRM=1 bash /tmp/oh-my-hermes/scripts/setup-cto.sh
```

Creates Hermes profiles (`cto`, `pm`, `dev`, `qa`, `ops`, `security`), initializes kanban, and schedules up to 4 cron jobs.

---

## Step 5 — Lock persistent focus

In Hermes v0.13+ environments that support `/goal`, run:

```
/goal Manage [owner/repo] as CTO. Triage issues hourly, implement top priority, get founder approval before merging. Never ship without YES.
```

If `/goal` is not available in your Hermes version, save this intent in your project `AGENTS.md` and/or Hermes memory instead.

---

## What gets installed

| Path | Contents |
|---|---|
| `~/.hermes/skills/` | 23 skills — full app lifecycle + CTO loop |
| `~/.hermes/workflows/` | 5 workflows |
| `~/.hermes/agents/` | 6 agent role definitions |
| `~/.hermes/profiles/` | 6 active profiles (after setup-cto.sh) |

---

## Uninstall

```bash
bash /tmp/oh-my-hermes/scripts/uninstall.sh
```

Removes all Oh My Hermes files. Hermes memory and gateway are untouched.
