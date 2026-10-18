---
name: health-check
description: Use when a deployed app needs to be verified as running, after every deployment, or on-demand to confirm availability
version: 1.1.1
tags: [health, monitoring, ops, supabase, vercel]
metadata:
  hermes:
    tags: [health, monitoring, supabase, vercel-logs]
    requires_toolsets: [terminal, web]
---

## When to Use

After deployment, during an incident, or for a scheduled availability check.

## Prerequisites

- Selected project/environment and configured URL. Read current from
  `project:<slug>:deployment:<env>` or verify an explicitly provided target.
- curl and Python 3; credentials and provider CLI only for dependencies this app uses.
- Read actual stack/config before choosing checks. Absent Supabase/Vercel is N/A,
  never a failure and never a reason to add a dependency or database.

## Procedure

1. Probe the existing configured health endpoint with bounded retries and a private
   response file. On missing endpoint, report missing coverage; do not bootstrap
   or mutate application code during a health check.
   ```bash
   umask 077
   HEALTH_BODY=$(mktemp)
   curl --silent --show-error --connect-timeout 5 --max-time 15 \
     --retry 1 --retry-max-time 35 --output "$HEALTH_BODY" \
     --write-out '%{http_code} %{time_total}' "$APP_URL/api/health"
   ```
   Check curl exit status, HTTP 200 and parsed JSON status=ok. Warn on >1s, fail
   the latency check on >3s; report availability and latency separately. Remove
   the temporary response file after parsing without dumping raw sensitive content.
2. If Supabase is a real dependency, test a safe application data-access journey
   through its normal identity/RLS path, including an expected denied request.
   A bounded REST reachability probe may supplement this but proves only reachability;
   SELECT 1 proves only a connection. Never label either as an app/RLS pass.
   Use the same connection/overall deadline and one-retry limit for HTTP checks;
   use PGCONNECT_TIMEOUT=5 and a 10-second statement_timeout for any SQL probe.
3. If deployed on Vercel, verify installed `vercel logs --help`, request a finite
   recent deployment-specific log window (no follow/stream), and impose a 30-second
   terminal deadline. Use observe-logs for cursor/deduplication. Redact credential
   content before summaries and retain raw provider output only owner-accessibly.
4. Report app availability, latency, dependency journeys and logs separately as
   PASS / FAIL / N/A / UNVERIFIED with evidence and timestamp. Persist the window
   under `project:<slug>:ops-health-log`. Append sanitized failures to
   `project:<slug>:health-failure-log`, then send-notification. External outages
   require investigation, not automatic DB mutation or unapproved rollback.

## Pitfalls

- A reachable endpoint does not establish database access or user-journey correctness.
- Optional provider checks must not block a static app's health report.
- A curl exit code alone is insufficient; inspect HTTP status and parsed body.

## Verification

Every applicable layer has bounded observed evidence. Missing credentials/tests
are UNVERIFIED; optional unused layers are N/A. Failures are logged and notified.
