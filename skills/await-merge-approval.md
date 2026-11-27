---
name: await-merge-approval
description: Use when a reviewed product increment is ready and the founder must choose whether to ship, revise, close, or defer it
version: 2.1.1
tags: [release, github, approval, human-in-loop]
metadata:
  hermes:
    tags: [approval, release, github]
    requires_toolsets: [terminal, messaging]
---

## Overview

Keeps the irreversible release decision with the founder while making the
response small and actionable. Smart Approvals (v0.19+ default) handles routine
command review autonomously — only the production ship/rollback/close decision
is a founder gate.

The approval message is delivered through the Hermes Gateway with durable
ledger-based recovery: the message survives a gateway crash and is re-delivered
on restart. If the founder's response arrives while the Gateway was down, it is
processed when the Gateway comes back.

## When to Use

- Reviewer passed the increment and Security is clear or accepted.
- The preview is healthy and the PR is mergeable.

## Prerequisites

- PR number, preview URL, and founder summary.
- Passing required checks and current reviews.
- A configured Hermes messaging platform (Gateway recommended for durable delivery).

## Procedure

1. Send one message with the user outcome, evidence, preview, known limitation,
   and choices:
   ```text
   YES   ship it
   NO    request changes; include feedback if you can
   CLOSE stop this work and close the PR
   LATER remind me in two hours
   ```
2. Read `gh pr view <number> --repo <owner/repo> --json headRefOid,baseRefName,url`.
   Save `project:<slug>:pending-approval` with repository, project, environment,
   PR, exact reviewed headRefOid, task, preview, checks, timestamp and status.
   Include those concrete targets and the reviewed SHA in the approval message.
   If merging triggers production, approval must also cover the exact resulting
   deployment SHA; use a gated release workflow when the merge SHA is not yet known.
3. On **YES**, re-fetch headRefOid and compare with the saved reviewed SHA.
   Verify repository, project, environment, reviews and required checks still match.
   Any mismatch requires renewed review and approval. Merge using
   `gh pr merge <number> --repo <owner/repo> --match-head-commit <reviewed-sha>`
   with the configured merge strategy. Never let a production auto-deploy bypass
   the exact deployment-SHA gate. Run deploy-to-vercel for an approved release,
   then post-deploy-followup against the observed deployment.
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
