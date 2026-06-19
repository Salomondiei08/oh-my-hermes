# Workflow: Deploy and Monitor

For deploying an existing codebase and setting up production monitoring.

## Invoke

```
tell hermes: deploy this app and set up monitoring
tell hermes: run the deploy-and-monitor workflow
```

## Prerequisites

- Codebase exists and build passes locally
- Vercel account and CLI installed
- `/api/health` endpoint exists (run bootstrap.sh if missing)

## Steps

### 1. deploy-to-vercel
Pre-deploy checklist → deploy → capture URL.
Stop if any pre-deploy check fails.

### 2. connect-supabase (conditional)
Run only if:
- Project uses Supabase and it is not yet connected, OR
- New migrations need to be pushed

### 3. setup-monitoring
Sentry SDK + Uptime Kuma documentation.
Save monitoring config to Hermes memory.

### 4. send-notification
Slack notification with deployment URL and monitoring status.

### 5. post-deploy-followup
Health check → deployment log → summary.

### 6. observe-logs
Scan the first post-release window, deduplicate new failures, and correlate any
regression with the release. Alert only on actionable new High/Critical groups.

## Rollback

If deployment is unhealthy after deploying:

```bash
# In Vercel dashboard: Deployments → select last known good → Promote to Production
# Or via CLI:
vercel rollback
```

Then run `post-deploy-followup` again on the rolled-back URL.

## Setting up GitHub auto-deploy

After the first successful manual deploy:
```bash
vercel link
# Vercel dashboard → Project Settings → Git → Connect GitHub Repository
```

Push to main = automatic production deploy.
Push to any other branch = preview deployment with unique URL.
