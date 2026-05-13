#!/usr/bin/env bash
set -e

PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMH_DIR="$(dirname "$SCRIPT_DIR")"

echo "Oh My Hermes — project bootstrap"
echo "================================="
echo "Project: $PROJECT_DIR"
echo ""

# Guard: don't bootstrap oh-my-hermes itself
if [ "$PROJECT_DIR" = "$OMH_DIR" ]; then
  echo "[ERROR] Run bootstrap.sh from your project directory, not from oh-my-hermes."
  exit 1
fi

CREATED=0

# ── AGENTS.md ────────────────────────────────────────────────────────────────
if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
  cat > "$PROJECT_DIR/AGENTS.md" << 'AGENTS_EOF'
# AGENTS

This file is for AI agents (Hermes, Claude Code, Codex) working in this project.

## Project Overview

TODO: Describe what this project does, who it is for, and what problem it solves.

## Build Commands

```bash
npm install
npm run dev
npm run build
npm run typecheck
```

## Architecture

TODO: Describe data flow and service ownership.

## Security Baseline

- Validate all input server-side
- Never trust client-provided identity, scope, or permissions
- Use Supabase RLS for row-level data isolation
- Store secrets in .env.local — never commit credentials
- No secrets in logs or error messages
- Follow OWASP Top 10

## Engine Guidance

- Complex multi-file changes, new features → Claude Code
- Quick targeted fixes, single-file changes → Codex
- Deploy, monitor, notify, schedule → Hermes
- UI/UX exploration before coding → Claude Design (human step)
- Not sure? Tell Hermes: run choose-engine

## Monitoring

- Health endpoint: /api/health
- Error tracking: Sentry
- Uptime: Uptime Kuma polling /api/health every 60s

## Deployment

- Platform: Vercel
- Production: main branch → automatic deploy
- Preview: feature branches → preview deployment

## Commit Conventions

- One commit per meaningful change
- Never commit .env.local or credentials
AGENTS_EOF
  echo "[CREATED] AGENTS.md"
  CREATED=$((CREATED + 1))
else
  echo "[SKIP]    AGENTS.md already exists"
fi

# ── .env.example ─────────────────────────────────────────────────────────────
if [ ! -f "$PROJECT_DIR/.env.example" ]; then
  cat > "$PROJECT_DIR/.env.example" << 'ENV_EOF'
# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
NODE_ENV=development

# Supabase
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_KEY=your-supabase-service-role-key
DATABASE_URL=postgresql://postgres:[password]@[host]:5432/postgres

# Vercel (for deployment skills)
VERCEL_TOKEN=your-vercel-token
VERCEL_ORG_ID=your-vercel-org-id
VERCEL_PROJECT_ID=your-vercel-project-id

# Notifications
SLACK_WEBHOOK_URL=your-slack-webhook-url

# Monitoring
SENTRY_DSN=your-sentry-dsn
ENV_EOF
  echo "[CREATED] .env.example"
  CREATED=$((CREATED + 1))
else
  echo "[SKIP]    .env.example already exists"
fi

# ── Health endpoint ──────────────────────────────────────────────────────────
# Only create the Next.js App Router health endpoint when the project actually
# looks like a Next.js app. Otherwise bootstrap should stay framework-neutral.
IS_NEXT_APP=0
if [ -f "$PROJECT_DIR/next.config.js" ] || [ -f "$PROJECT_DIR/next.config.mjs" ] || [ -f "$PROJECT_DIR/next.config.ts" ]; then
  IS_NEXT_APP=1
elif [ -f "$PROJECT_DIR/package.json" ] && grep -Eq '"next"[[:space:]]*:' "$PROJECT_DIR/package.json"; then
  IS_NEXT_APP=1
elif [ -d "$PROJECT_DIR/src/app" ] || [ -d "$PROJECT_DIR/app" ]; then
  IS_NEXT_APP=1
fi

if [ "$IS_NEXT_APP" -eq 1 ]; then
  HEALTH_PATH="$PROJECT_DIR/src/app/api/health/route.ts"
  if [ ! -f "$HEALTH_PATH" ]; then
    mkdir -p "$(dirname "$HEALTH_PATH")"
    cat > "$HEALTH_PATH" << 'HEALTH_EOF'
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    status: "ok",
    version: process.env.npm_package_version ?? "1.0.0",
    timestamp: new Date().toISOString(),
  });
}
HEALTH_EOF
    echo "[CREATED] src/app/api/health/route.ts"
    CREATED=$((CREATED + 1))
  else
    echo "[SKIP]    src/app/api/health/route.ts already exists"
  fi
else
  echo "[SKIP]    Next.js app not detected — health endpoint not created"
fi

# ── .gitignore guard ─────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/.gitignore" ] && ! grep -q "\.env\.local" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
  printf "\n.env.local\n" >> "$PROJECT_DIR/.gitignore"
  echo "[UPDATED] .gitignore — added .env.local"
fi

echo ""
echo "Created $CREATED file(s)."
echo ""
echo "Next steps:"
echo "  1. Edit AGENTS.md — fill in Project Overview and Architecture"
echo "  2. cp .env.example .env.local && add real values"
echo "  3. Tell Hermes: 'start a new app'"
