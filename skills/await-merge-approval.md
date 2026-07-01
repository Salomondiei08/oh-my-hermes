---
name: await-merge-approval
description: Use when a reviewed product increment is ready and the founder must choose whether to ship, revise, close, or defer it
version: 2.0.0
tags: [release, github, approval, human-in-loop]
metadata:
  hermes:
    tags: [approval, release, github]
    requires_toolsets: [terminal, messaging]
---

## Overview

Keeps the irreversible release decision with the founder while making the
response small and actionable.

## When to Use

- Reviewer passed the increment and Security is clear or accepted.
- The preview is healthy and the PR is mergeable.

## Prerequisites

- PR number, preview URL, and founder summary.
- Passing required checks and current reviews.
- A configured Hermes messaging platform.

## Procedure

1. Send one message with the user outcome, evidence, preview, known limitation,
   and choices:
   ```text
   YES   ship it
   NO    request changes; include feedback if you can
   CLOSE stop this work and close the PR
   LATER remind me in two hours
   ```
2. Save `pending-approval` with PR, task, timestamp, and status.
3. On **YES**, re-check mergeability and required checks, merge with the
   repository's configured strategy, then load `post-deploy-followup`.
4. On **NO**, save any supplied feedback, request changes on the PR, return the
   task to Builder, and continue even if the founder gives only a short reason.
5. On **CLOSE**, confirm that closing is intended if the wording was ambiguous,
   then close the PR without deleting unrelated work or branches.
6. On **LATER**, schedule one reminder in two hours.
7. If no answer arrives, leave the PR open and send at most one reminder after
   24 hours. Never treat silence as approval.

## Pitfalls

- YES applies only to the reviewed commit. New pushes require fresh review.
- NO is not permission to close or delete the branch.
- Do not ask multiple follow-up questions about feedback; record the available
  direction and let Builder produce a new reviewable version.
- Do not merge while required checks are pending or failing.

## Verification

- Approval state and reviewed commit are recorded.
- YES resulted in merge and post-deploy verification.
- NO returned the task to Builder without closing the PR.
- CLOSE closed only the explicitly named PR.
