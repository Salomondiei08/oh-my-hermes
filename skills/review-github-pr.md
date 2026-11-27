---
name: review-github-pr
description: Use when a built product increment has a pull request that needs independent behavioral, visual, and code review before release approval
version: 2.0.0
tags: [github, pr, review, product, quality]
metadata:
  hermes:
    tags: [github, pr, review, quality]
    requires_toolsets: [terminal, browser]
---

## Overview

Reviews the product increment represented by a PR. It verifies acceptance
criteria and the running preview, then submits an approve or request-changes
review and prepares a founder-facing release summary.

## When to Use

- Builder has completed an increment and opened a PR.
- A new push invalidates a prior review.
- Founder asks whether a PR is ready to ship or should be closed.

## Prerequisites

- PR number and linked task or product brief.
- Authenticated `gh` CLI.
- Preview or local runtime when user-facing behavior changed.
- Security result for security-relevant changes.

## Procedure

1. Read the brief, task acceptance criteria, Designer criteria, and Builder
   completion evidence.
2. Inspect PR metadata, diff, commits, and checks:
   ```bash
   gh pr view [number] --json number,title,body,url,headRefName,files,commits
   gh pr diff [number]
   gh pr checks [number]
   ```
3. Verify scope, error handling, environment changes, tests, and operational
   impact. Do not duplicate Security's specialized review.
4. Exercise each acceptance criterion on the preview or local runtime. For UI,
   inspect narrow and desktop viewports plus loading, empty, error, and success
   states.
5. Choose one outcome:
   - PASS: `gh pr review [number] --approve --body "[evidence summary]"`
   - REQUEST CHANGES: `gh pr review [number] --request-changes --body "[specific reproducible findings]"`
   - BLOCKED: comment with the missing access or environment and block the task.
6. On PASS, send a short founder summary: user outcome, checks, security status,
   preview, limitations, and `YES / NO / CLOSE / LATER` choices.
7. Load `await-merge-approval`. Never merge directly from review.

## Pitfalls

- A green CI run is not evidence that the user journey works.
- A prior approval becomes stale after behavior-changing pushes; review again.
- Do not close a PR because the founder replied NO. NO means request changes;
  CLOSE must be explicit.
- Do not expose raw logs, secrets, or internal reasoning in the review.

## Verification

- Every acceptance criterion has evidence or a named blocker.
- GitHub contains an approve or request-changes review.
- Founder received the release summary only after PASS.
