---
name: server-bootstrap
description: Use when setting up a brand new server with Hermes, Telegram gateway, Oh My Hermes, project context, and the CTO loop
version: 1.0.0
tags: [setup, server, telegram, bootstrap, first-run]
---

## When to Use

- A fresh VPS or SSH host should become a Hermes product-building server.
- The founder wants a new Telegram-connected Hermes agent.
- Old runtime state needs to be backed up and replaced.

## Prerequisites

- SSH access to the server.
- A Telegram bot token or permission to prompt for it securely on the server.
- Optional repo and production URL.

## Procedure

1. If replacing an existing agent, first run `reset-runtime` with backup.
2. Run:
   ```bash
   ~/.hermes/scripts/server-bootstrap.sh --project myapp --repo owner/repo --telegram
   ```
3. If the script prompts for a token, enter it in the terminal only. Never paste
   tokens into chat.
4. Send a Telegram message to the bot: `status`.
5. Run `project-status` and then start from the current product outcome or use
   `ship-this-idea`.

## Pitfalls

- Do not assume editing `config.yaml` clears stale Telegram sessions.
- Do not start two gateways with the same Telegram bot token.
- Rotate any token that was pasted into chat.

## Verification

- `~/.hermes/scripts/status.sh` reports Hermes and gateway state.
- The Telegram bot responds to a message.
- Seven product-loop profiles are present or setup reports the exact missing
  Hermes capability.
