---
name: onboarding
description: Use when a user first installs Oh My Hermes or asks to set up the product-building loop for a project
version: 2.0.0
tags: [setup, onboarding, product-loop, guided]
---

## Overview

Configures the Product Loop with minimal questions. It infers project settings,
offers defaults, and leaves unavailable integrations as non-blocking follow-up
work.

## When to Use

- User says "set up the product loop", "set up the CTO loop", or "get started".
- Required agent profiles or kanban are missing.
- A project has not saved its repository and production context.

## Prerequisites

- Hermes Agent with profiles, Kanban, cron, and memory support.
- Oh My Hermes files installed.
- Optional: authenticated `gh` and a production URL.

## Procedure

1. Inspect the current git remote, package files, deployment config, existing
   Hermes memory, and authenticated CLI state.
2. Infer repository, production URL, and preferred report time where possible.
3. Ask at most one message with up to three unresolved settings. Include
   recommended defaults and: "Skip any question and I will continue with the
   defaults."
4. Never ask the user to paste a token into chat. If GitHub is not authenticated,
   provide `gh auth login` as a follow-up; continue configuring local profiles.
5. Create or verify profiles: `cto`, `pm` (Product), `designer`, `dev`, `qa`,
   `security`, and `ops`.
6. Initialize Kanban and save available project context to memory.
7. Create missing cron jobs only:
   - hourly product/backlog review when a repository exists
   - 15-minute health check when a production URL exists
   - hourly log observation when a production URL exists
   - daily status report
   - daily lightweight security check when a repository exists
   - weekly full security assessment when a repository exists
8. Confirm what works now and list missing credentials or URLs as optional next
   steps. Start from the user's product idea or current highest-priority outcome,
   not automatically from GitHub issues.
9. Run `bash ~/.hermes/scripts/setup-integrations.sh --check`. Request OpenAI only when it
   is the selected model or creative provider, Buffer at the first approved
   scheduling action, and Ark/Seedance at the first approved generated-video
   action. Never require all three during initial onboarding.

## Question Policy

- Read first, ask second.
- Maximum three questions in one message.
- Every question has a recommended default.
- Silence means continue with the defaults.
- Stop only when the requested next action itself requires credentials,
  payment, destructive access, licensing, or publication approval.

## Pitfalls

- Do not create duplicate cron jobs on repeated setup.
- Do not require GitHub or production deployment to begin product discovery.
- Do not reveal credentials in chat, logs, memory, or command output.
- Do not start multiple gateways for the same messaging account.
- Do not use sudo when a user-level install path exists.

## Verification

- Seven profiles and their role files exist.
- Kanban is accessible.
- Existing cron jobs were reused rather than duplicated.
- Available project context is saved and missing integrations are explicit.
- The user can begin with a product outcome even without GitHub or deployment.
