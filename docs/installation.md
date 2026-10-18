# Installation

## Prerequisites

Install Hermes Agent first:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc   # or ~/.zshrc on macOS
hermes             # confirm it opens
```

Use a current Hermes Agent build with `profile`, `cron`, and `kanban` commands available. Check with:

```bash
hermes profile --help
hermes cron --help
hermes kanban --help
hermes skills search --help
hermes computer-use --help   # optional on macOS
```

---

## Install Oh My Hermes

```bash
git clone https://github.com/salomondiei08/oh-my-hermes.git
cd oh-my-hermes
bash install.sh
```

The installer supports `${HERMES_HOME:-$HOME/.hermes}` and requires a full checkout
and Python 3.9+. It installs skills as `skills/oh-my-hermes/<name>/SKILL.md`, copies
helpers/templates, and records owned-file hashes. Re-running updates unchanged owned
files; customized/unowned collisions are preserved and reported. Inspect those
messages before treating an upgrade as complete. Legacy flat files are retained for
manual comparison; do not delete customized files just to make verification pass.

---

## Verify

```bash
bash scripts/verify.sh
```

Missing files cause a nonzero exit. This verifies layout, not model/provider access.
After running setup, check runtime prerequisites separately:

```bash
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/verify.sh" --setup
```

Run repository regression checks with `python3 -m unittest discover -s tests -v`
and `bash scripts/validate-skills.sh`. The validator uses Ruby's standard-library
YAML parser and checks required sections and inline local links; remote URLs and
anchors require separate review.

---

## Bootstrap a new project

Inside an existing Next.js project with exactly one `app/` or `src/app/` directory:

```bash
bash /path/to/oh-my-hermes/scripts/bootstrap.sh
```

Creates:
- `AGENTS.md` — review and fill in the Architecture and Engine Guidance sections
- `.env.example` — all expected variables with placeholder values
- `app/api/health/route.ts` or `src/app/api/health/route.ts` — `/api/health`, matching the existing router

Bootstrap is idempotent. Existing files are not overwritten.

---

## Environment variables

Copy `.env.example` to `.env.local` and fill in real values.

Required for deployment:
```
VERCEL_TOKEN=
VERCEL_ORG_ID=
VERCEL_PROJECT_ID=
```

Required for database:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=
DATABASE_URL=
```

Required for notifications:
```
SLACK_WEBHOOK_URL=
```

Never commit `.env.local`. Only `.env.example` (with placeholder values) is committed.

---

## For LLM agents

```bash
git clone https://github.com/salomondiei08/oh-my-hermes.git
cd oh-my-hermes
bash install.sh
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/verify.sh" --install-only
cd /path/to/target/project
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/bootstrap.sh"
```

Common failures:
- Hermes not installed → install Hermes first
- `~/.hermes/skills/` missing → run `hermes` once to initialize
- Target project directory missing → create it first

---

## Updating

```bash
cd /path/to/oh-my-hermes && git pull && bash install.sh
```

Project `AGENTS.md` and `.env.local` are never modified by the installer.

---

## Uninstalling

```bash
bash scripts/uninstall.sh
```

The uninstaller removes only unchanged files recorded in the ownership manifest.
All profile directories, custom files and modified managed files are preserved.
Legacy unmanifested installs need manual review. Dependent cron jobs are listed
for review and never deleted automatically.
