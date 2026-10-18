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
Pre-deploy checklist → preview deployment → capture immutable ID/URL/commit.
Production requires Security/Reviewer evidence and explicit approval of repository,
project, environment and exact reviewed SHA before the release command/merge.
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

If the deployment is unhealthy after deploying, load the `rollback` skill:

```
tell hermes: run rollback
```

The `rollback` skill health-checks the current deployment, confirms with the
founder before acting, verifies and names a distinct known-good previousHealthy ID/URL/commit from
`project:<slug>:deployment:<env>`, rolls back to that exact target, then
re-runs `post-deploy-followup` to verify recovery. Rollback requires founder
YES — it does not happen automatically.

## Setting up GitHub auto-deploy

After the first successful manual deploy:
```bash
vercel link
# Vercel dashboard → Project Settings → Git → Connect GitHub Repository
```

Connecting a production branch can release on push/merge. Enable it only with a
gate that requires repository/project/environment/exact deployment-SHA approval.
Push to any other branch = preview deployment with unique URL.
