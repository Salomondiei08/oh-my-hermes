---
name: send-notification
description: Use when a deployment completes, a health check fails, or an important status event needs to be reported to the founder
version: 1.2.1
tags: [notification, slack, telegram, ops, webhook, gateway]
---

## Overview

Sends a structured notification to the founder. The Hermes Gateway (v0.19+) is
the primary delivery path with durable ledger-based recovery. Slack webhook and
Telegram direct API are fallbacks for environments where the Gateway is not
running. Logs delivery to Hermes memory.

## When to Use

- After deployment (called by `post-deploy-followup`)
- After health check failure or recovery
- Approval requests (called by `await-merge-approval`)
- Any ops event that needs human awareness

## Prerequisites

One of:
- Hermes Gateway configured and running (primary — durable delivery in v0.19+)
- `SLACK_WEBHOOK_URL` in environment (fallback)
- `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` in environment (fallback)

## Procedure

**1. Compose message** — include:
- Event type: Deploy / Health Fail / Health Pass / Approval Request / Update
- Project name
- Environment: production or preview
- URL (if deployment)
- Timestamp
- Brief status note (plain English, no raw logs)

**2. Send via Hermes Gateway** (primary — if Gateway is running):

Use the Hermes messaging toolset to send directly to the founder's configured
platform. The Gateway's durable delivery ledger (v0.19+) ensures messages
survive a gateway crash and are re-delivered on restart.

```
send_message("founder", "[event] [project] → [environment]\n[url]\n[status]\n[timestamp]")
```

If the messaging toolset is unavailable or the Gateway is not running, continue
to the fallback backends.

**3. Fallback delivery** — only after the Gateway is known not to have accepted
this event. Resolve destination from this project's configuration, never another
project's channel. Use a serializer; do not interpolate text into JSON or HTML.
The example reads secrets from the environment inside the process, not argv:
```python
import json, os, urllib.request, urllib.error

# notification.txt contains the reviewed plain-text message with no raw secrets/logs.
with open("notification.txt") as source:
    message = source.read()
if len(message) > 4000:
    raise SystemExit("Notification exceeds 4000 characters; shorten it")
backend = None
url = os.environ.get("SLACK_WEBHOOK_URL")
payload = {"text": message}
if url:
    backend = "slack"
elif os.environ.get("TELEGRAM_BOT_TOKEN") and os.environ.get("TELEGRAM_CHAT_ID"):
    backend = "telegram"
    url = "https://api.telegram.org/bot" + os.environ["TELEGRAM_BOT_TOKEN"] + "/sendMessage"
    payload = {"chat_id": os.environ["TELEGRAM_CHAT_ID"], "text": message}
if not backend:
    raise SystemExit("No notification backend configured")
request = urllib.request.Request(url, data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json"})
try:
    with urllib.request.urlopen(request, timeout=15) as response:
        status = response.status
        body = response.read(65536)
    delivered = status == 200
    if backend == "telegram":
        delivered = delivered and json.loads(body).get("ok") is True
    print(json.dumps({"backend": backend, "delivered": delivered}))
    raise SystemExit(0 if delivered else 1)
except (urllib.error.URLError, ValueError):
    # Exception URLs/response bodies can contain tokens; report only the backend.
    raise SystemExit(backend + " delivery failed or unconfirmed; inspect privately")
```
Do not log request URLs, exception text, payloads or response bodies. A timeout is
unconfirmed delivery; reconcile receipt before trying a second backend to avoid
duplicates. HTTP 200 alone does not prove Telegram accepted the message.

**5. If no backend available:**
- Print notification content to console (do not fail silently)
- Print: "No notification backend configured. Run: hermes gateway setup"

**6. Save to Hermes memory:** key `project:<slug>:notification-log`, append `{ event, timestamp, backend, delivered: true/false }`.

## Pitfalls

- Slack webhook URLs expire or get revoked. Non-200 → verify URL in Slack app settings.
- Keep messages under 4000 characters — Slack truncates, Telegram rejects above 4096.
- Never include env var values or credentials in notification content.
- Telegram `TELEGRAM_CHAT_ID` for a personal chat is your numeric user ID — get it by messaging `@userinfobot`.
- On ambiguous delivery, reconcile before fallback or retry; do not duplicate approval messages.
- Gateway durable delivery retries on crash. Do not send via fallback AND Gateway at the same time.

## Verification

- Message received in founder's configured platform
- Entry appended to `project:<slug>:notification-log` in Hermes memory
