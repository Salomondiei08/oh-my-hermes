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
git clone https://github.com/salomondiei08/oh-my-hermes.git
cd oh-my-hermes
bash install.sh
```

Installs 39 skills, 6 workflows, 7 agent role definitions, and helper scripts
into `~/.hermes/`.

---

## Step 2 — Verify

```bash
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/verify.sh" --install-only
```

Install verification must exit 0. Missing/customized managed files require review; this does not verify models, notifications, or a live agent session. After setup, separately run `verify.sh --setup`.

---

## Step 3 — Bootstrap the project

```bash
cd /path/to/project
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/bootstrap.sh"
```

Requires an existing Next.js App Router project. Creates missing `AGENTS.md`, `.env.example`, `.gitignore` exclusions, and a health route in its existing `app/` or `src/app/` tree.

For a brand-new server, prefer the installed server bootstrap:

```bash
bash ~/.hermes/scripts/server-bootstrap.sh --project myapp --repo owner/repo --telegram
bash ~/.hermes/scripts/status.sh
```

---

## Step 4 — Configure the CTO loop

```bash
export GITHUB_TOKEN=<fine-grained-token>   # Permissions: Contents/Issues/PRs/Metadata R/W
export GITHUB_USERNAME=<github-username>
export GITHUB_REPO=<owner/repo>
export PRODUCTION_URL=<https://yourapp.vercel.app>   # optional
export PROJECT_SLUG=myapp  # stable product namespace

bash "${HERMES_HOME:-$HOME/.hermes}/scripts/setup-cto.sh"
```

Creates Hermes profiles (cto, pm, designer, dev, qa, security, ops), initializes
kanban, and schedules available product, health, logs, report, and security jobs
using project-scoped names. Existing scoped jobs are reconciled; clearing a target pauses its jobs. Verify each profile’s model/provider and founder delivery separately. Legacy unscoped jobs require manual review.

---

## Step 5 — Lock persistent focus

In Hermes, run:

```
/goal Build, launch, operate, and improve [product]. Keep one outcome active,
verify it before shipping, and ask only at irreversible boundaries.
```

---

## What gets installed

| Path | Contents |
|---|---|
| `~/.hermes/skills/oh-my-hermes/<name>/SKILL.md` | 39 skills — complete product lifecycle + CTO loop |
| `~/.hermes/workflows/` | 6 workflows |
| `~/.hermes/agents/` | 7 agent role definitions |
| `~/.hermes/scripts/` | setup, status, project switch, reset, dead-letter helpers |
| `~/.hermes/profiles/` | 7 profiles after setup; each still needs verified model access |

---

## Uninstall

```bash
bash "${HERMES_HOME:-$HOME/.hermes}/scripts/uninstall.sh"
```

Removes all Oh My Hermes files. Hermes memory and gateway are untouched.
