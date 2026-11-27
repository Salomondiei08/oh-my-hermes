---
name: rollback
description: Use when a health check fails after a deploy and the last deploy was under 2 hours ago, to roll back production to the previous working deployment
version: 1.0.1
tags: [ops, vercel, rollback, incident]
metadata:
  hermes:
    tags: [ops, deployment, incident, recovery]
    requires_toolsets: [terminal]
---

## When to Use

A recent release caused an incident, or the founder requests production rollback.

## Prerequisites

- Authenticated Vercel CLI and selected repository/project/environment.
- Hermes memory record `project:<slug>:deployment:<env>` from deploy-to-vercel.
- Incident evidence and founder notification.

## Procedure

1. Read that same deployment record. Select previousHealthy, requiring a distinct
   ID and URL from current, healthStatus=healthy, immutable commit and timestamp.
   If missing, inspect Vercel deployment history and independently verify an older
   known-good release before proposing it. If none can be verified, stop and escalate.
2. Use `vercel inspect <target-url>` to verify target belongs to this project and
   environment and matches the recorded commit. Probe its health and the relevant
   acceptance journey with bounded requests. Check installed `vercel rollback --help`
   and plan restrictions; preview recovery requires a fresh preview, not this production command.
3. Present repository, project, environment, broken current ID/URL/commit, exact
   known-good target ID/URL/commit, reason and evidence. Save these with timestamp
   in `project:<slug>:pending-approval`; wait for explicit founder approval of this
   concrete rollback. Silence is not approval.
4. Immediately re-read the record and inspect provider state. Invalidate approval
   if current, target, repository, project or environment changed. Execute only
   the approved target from the verified linked directory:
   ```bash
   vercel rollback <approved-target-id-or-url>
   ```
5. Inspect provider alias/deployment state and run health-check plus the acceptance
   journey against the production domain. Only after recovery is confirmed, set
   current to the verified restored release (id, url, commit, timestamp, healthStatus).
   Clear previousHealthy if it equals restored current; retain another target only
   when independently verified distinct and healthy. Never promote the broken release
   into previousHealthy as a side effect of swapping records.
6. Append from/to IDs, commits, reason, approval and outcome to
   `project:<slug>:rollback-log`. Notify founder and block the incident task until
   recovery evidence is complete. One rollback attempt, then escalate if unhealthy.

## Pitfalls

- Never fall back to the current broken URL or an unverified older release.
- Failed rollback health does not prove the incident is unrelated to deployment.
- Rollback CLI timeouts can leave provider work running; inspect state before retrying.

## Verification

Provider target and production journey match the approved known-good commit.
The shared deployment record and rollback log reflect observed health and founder was notified.

Reference: [Vercel rollback](https://vercel.com/docs/cli/rollback).
