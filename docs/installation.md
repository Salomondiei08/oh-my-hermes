# Installation

## Prerequisites

Install Hermes Agent first:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc   # or ~/.zshrc on macOS
hermes             # confirm it opens
```

Hermes v0.9+ required. Check version: `hermes --version`

---

## Install Oh My Hermes

**One-line:**

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/oh-my-hermes/main/install.sh | bash
```

**Clone and install:**

```bash
git clone https://github.com/yourusername/oh-my-hermes
cd oh-my-hermes
bash install.sh
```

The installer copies `skills/` to `~/.hermes/skills/` and `workflows/` to `~/.hermes/workflows/`. It is idempotent — running again updates existing files.

---

## Verify

```bash
bash scripts/verify.sh
```

Expected output:
```
[OK] Hermes found
[OK] Skills directory: ~/.hermes/skills/
[OK] 12 skills installed
[OK] Workflows directory: ~/.hermes/workflows/
[OK] 3 workflows installed
Next: cd into your project and run the bootstrap script.
```

---

## Bootstrap a new project

Inside your project directory:

```bash
bash /path/to/oh-my-hermes/scripts/bootstrap.sh
```

Creates:
- `AGENTS.md` — review and fill in the Architecture and Engine Guidance sections
- `.env.example` — all expected variables with placeholder values
- `src/app/api/health/route.ts` — working `/health` endpoint when the project is detected as Next.js App Router

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
git clone https://github.com/yourusername/oh-my-hermes /tmp/oh-my-hermes
bash /tmp/oh-my-hermes/install.sh
bash /tmp/oh-my-hermes/scripts/verify.sh
cd /path/to/target/project
bash /tmp/oh-my-hermes/scripts/bootstrap.sh
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
rm ~/.hermes/skills/clarify-requirements.md
rm ~/.hermes/skills/product-brief.md
# ... remove individual skill files
```

No dedicated uninstall command — skills are just files.
