---
name: project-switch
description: Use when the founder wants Hermes to work on a different product without mixing memory, crons, logs, or integration state
version: 1.0.0
tags: [project, memory, context, switch]
---

## When to Use

- The founder says `/switch`, "switch project", or names another app.
- A server manages more than one product.
- Project-specific repo, URL, logs, or approvals are being mixed.

## Prerequisites

- Oh My Hermes installed.
- `~/.hermes/scripts/project.sh` available.

## Procedure

1. Normalize the project name to a short slug.
2. If repo or production URL is known, include it.
3. Run:
   ```bash
   ~/.hermes/scripts/project.sh switch myapp --repo owner/repo --url https://app.example.com
   ```
4. Use the current project slug in memory keys, dead-letter paths, campaign
   logs, status reports, and cron names.
5. Continue the requested work in the selected project. Do not ask for more
   project details unless they materially change the next action.

## Pitfalls

- Do not mix production URLs or Buffer channels across projects.
- Do not overwrite an existing project env file with blank values.

## Verification

- `~/.hermes/scripts/project.sh current` prints the intended slug.
- `~/.hermes/projects/<slug>.env` exists with user-only permissions.
