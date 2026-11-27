---
name: publish-with-buffer
description: Use when approved social content must be validated, scheduled, or published through the official Buffer CLI
version: 1.0.0
tags: [marketing, social, buffer, publishing]
---

## When to Use

- A founder approved a post or content schedule for external publication.
- Connected Buffer channels or scheduled posts must be inspected.

## Prerequisites

- Node.js 18 or later.
- A Buffer account with at least one connected channel.
- The official Buffer CLI: `npm install -g @bufferapp/cli`.
- `BUFFER_API_KEY` in `~/.hermes/.env`, or an authenticated `buffer init`.
- Explicit founder approval for the exact text, media, channels, and time.

## Procedure

1. If Buffer is not configured, stop at this credential boundary and direct the
   user to `bash ~/.hermes/scripts/setup-integrations.sh --buffer`. Never request the key
   in chat.
2. Run `buffer doctor` and `buffer channels list --output json`. Do not continue
   if authentication or the selected channel is invalid.
3. Save one JSON input per channel with the final text, channel ID, scheduling
   type, mode, UTC `dueAt` when applicable, and public media URLs.
4. Validate without making an API call:
   ```bash
   buffer posts create --input post.json --dry-run --output json
   ```
5. Show the founder the exact content, channels, local and UTC publication time,
   and whether the action queues, schedules, or publishes. Require approval.
6. Submit each approved channel separately:
   ```bash
   buffer posts create --input post.json --output json
   ```
7. Record returned post IDs and due times in the campaign log. Query the posts
   after submission and report API errors without exposing credentials.

## Pitfalls

- A content-calendar approval is not approval for every final post.
- Buffer media must remain available at its public URL until publication.
- Never put `BUFFER_API_KEY` in repo config, command arguments, logs, or memory.
- Do not silently reuse a channel ID from another project or brand.

## Verification

- `buffer doctor` passes and the intended channels are visible.
- The dry run matches the founder-approved content and schedule.
- Buffer returns a post ID for every submitted channel.
- Scheduled posts are visible with the expected due time.
