---
name: project-status
description: Use when the founder asks for status, visibility, connected services, blocked work, or what Hermes is doing now
version: 1.0.0
tags: [status, visibility, operations, founder]
---

## When to Use

- The founder says `/status`, "status", "what is running", or "what is blocked".
- A setup or deploy flow needs a concise readiness report.

## Prerequisites

- Oh My Hermes installed.
- `~/.hermes/scripts/status.sh` available.

## Procedure

1. Run:
   ```bash
   ~/.hermes/scripts/status.sh
   ```
2. Summarize the output without exposing secret values.
3. If a required integration is missing, state when it is needed rather than
   forcing setup immediately.
4. If dead letters exist, make the newest actionable failure the next task.

## Pitfalls

- Do not print `.env` contents.
- Do not treat optional Buffer or Seedance credentials as setup failures.

## Verification

- Status includes project, repo, production URL, gateway/model visibility,
  crons, OpenAI, Buffer, Seedance, and dead-letter count.
