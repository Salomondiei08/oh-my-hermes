---
name: setup-monitoring
description: Use when a newly deployed app has no error tracking or uptime monitoring configured
version: 1.0.1
tags: [monitoring, sentry, uptime, ops]
---

## Overview

Installs Sentry for error tracking and documents Uptime Kuma setup. Run once per project after first deploy.

## When to Use

- First deployment to Vercel is complete
- App has no Sentry DSN configured
- `project:<slug>:monitoring-config` not in Hermes memory

## Prerequisites

- App deployed to Vercel with working `/api/health` endpoint
- Sentry account at sentry.io
- `SLACK_WEBHOOK_URL` available

## Procedure

**Sentry (error tracking):**
```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

The wizard creates `sentry.client.config.ts`, `sentry.server.config.ts`, `sentry.edge.config.ts`, and patches `next.config.js`. Review diff before committing.

Add to `.env.local`:
```
SENTRY_DSN=your-dsn-from-sentry-dashboard
SENTRY_AUTH_TOKEN=your-auth-token
```

Add to Vercel:
```bash
vercel env add SENTRY_DSN production
vercel env add SENTRY_AUTH_TOKEN production
```

**Uptime Kuma (if VPS available):**
```bash
docker run -d --restart=always -p 3001:3001 \
  -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:1
```

In Uptime Kuma UI:
1. Add monitor → HTTP(s)
2. URL: `https://[your-app].vercel.app/api/health`
3. Heartbeat interval: 60 seconds
4. Add Slack notification with `SLACK_WEBHOOK_URL`

No VPS: use Better Uptime (betteruptime.com) free tier.

Save to Hermes memory: key `project:<slug>:monitoring-config`, value `{ sentry: true, uptimeKuma: [url-or-null], slackAlert: true }`.

## Pitfalls

- The Sentry wizard modifies `next.config.js` with `withSentryConfig` wrapper. Review before committing.
- Test Sentry in dev before deploying — trigger a deliberate error, confirm it appears in the dashboard.
- Uptime Kuma alerts fire after the first failed poll (60s interval), not immediately.

## Verification

- `SENTRY_DSN` in Vercel env vars
- Test error appears in Sentry dashboard
- Uptime Kuma shows monitor as "Up"
- `project:<slug>:monitoring-config` saved to Hermes memory
