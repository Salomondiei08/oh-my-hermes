---
name: github-ops
description: Use GitHub issues and pull requests as delivery evidence inside the broader product-building lifecycle
version: 2.0.0
tags: [github, workflow, issues, pr]
---

## Overview

Supporting GitHub workflow: connect product work to an issue when useful, create
a reviewable PR, collect checks and reviews, then wait for founder release
approval. GitHub is not the roadmap or the top-level product loop.

## Steps

```
PRODUCT TASK / ISSUE / USER FEEDBACK
  ↓  product brief + acceptance criteria
  ↓  manage-github-issues   ← link or create issue when useful
  ↓  choose-engine          ← route to Hermes / Claude Code / Codex
  ↓  implement              ← build the fix or feature
  ↓  create-github-pr       ← PR from feature branch with memory context
  ↓  deploy-to-vercel       ← preview deployment auto-created by Vercel
  ↓  security + reviewer    ← verify behavior, risk, and preview
  ↓  founder YES / NO / CLOSE / LATER
  ↓  post-deploy-followup   ← production health check + notification
```

## Usage

Tell Hermes:
```
triage our GitHub issues
```
```
I fixed the auth bug in src/middleware.ts — create a PR
```
```
run the github-ops workflow for issue #42
```

## Notes

- Preview deployments are created automatically when a PR is opened (requires Vercel GitHub integration, set up via `deploy-to-vercel`)
- Merging to main triggers production deployment automatically
- `post-deploy-followup` runs after every production deploy
