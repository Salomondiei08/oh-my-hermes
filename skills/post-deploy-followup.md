---
name: post-deploy-followup
description: Use when a deployment has just completed and health verification, logging, and notification need to run
version: 1.0.1
tags: [deployment, ops, health, notification]
---

## When to Use

Immediately after a deployment, including deployments initiated outside this pack.

## Prerequisites

- Selected slug/environment and immutable deployment ID/URL/commit.
- `project:<slug>:deployment:<env>` record, health-check and send-notification.

## Procedure

1. Read current from `project:<slug>:deployment:<env>` and verify it matches the
   deployment being checked. Inspect provider metadata for deployments made elsewhere;
   use deploy-to-vercel's record contract without overwriting previousHealthy.
2. Run health-check and the release's acceptance journey. Update current.healthStatus
   only if its ID still matches. A later deployment must not inherit this result.
3. Append ID, URL, commit, environment, timestamp and observed health to
   `project:<slug>:deployment-log`, including failures. Never rotate previousHealthy
   during this followup; deployment owns rotation. A failed release keeps its recovery target.
4. Send outcome via send-notification. On failure, report failure and load rollback
   only for a production incident; rollback still needs its own concrete approval.
5. Read `project:<slug>:monitoring-config`; report missing monitoring or delivery
   evidence explicitly. Print deployment identity, health, acceptance and notification result.

## Pitfalls

- HTTP health alone does not prove user journeys work.
- A failed deployment must not be recorded as healthy or replace the recovery target.

## Verification

Matching current record and deployment history contain observed results, acceptance
checks are attached, and notification delivery or failure is reported.
