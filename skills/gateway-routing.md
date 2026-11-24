---
name: gateway-routing
description: Use when you want to route specific Telegram chats, Discord channels, or Slack workspaces to specific Hermes profiles so each agent receives only relevant messages
version: 1.0.2
tags: [gateway, profiles, routing, telegram, discord, slack, messaging]
metadata:
  hermes:
    tags: [gateway, profiles, routing]
    requires_toolsets: [terminal]
    min_version: "0.19.0"
---

## Overview

Hermes gateway multi-profile routing (v0.19+) lets you assign individual
Telegram chats, Discord channels/guilds, Slack channels/workspaces, or specific
threads and senders to specific Hermes profiles. Each route receives full
isolation — separate config, skills, memory, credentials, and session namespace.

For an Oh My Hermes 7-profile setup this means the ops agent watches monitoring
channels, the dev agent lives in code-review threads, and the CTO agent handles
everything else — without manual `/profile use` switching.

## When to Use

- You run multiple profiles (cto, ops, dev, etc.) and want messages routed
  automatically rather than switching profiles manually.
- You want a dedicated Telegram group for ops alerts and a separate DM thread
  for founder communication.
- Different Discord or Slack channels should be handled by different specialists
  (e.g. #deployments → ops, #design → designer).

## Prerequisites

- Hermes Agent v0.19+.
- Gateway configured and running (`hermes gateway setup`).
- One bot token per polling platform bot if running dedicated per-profile bots
  (or use the default profile's shared bot with `gateway.profile_routes`).
- Profile names match exactly what `hermes profile list` returns.

## Procedure

**Edit `~/.hermes/config.yaml` and define routes:**

```bash
hermes config path   # confirm active config.yaml location
hermes config edit   # open config.yaml in your editor
```

Add `gateway.profile_routes` (set `multiplex_profiles: true` explicitly on
Hermes v0.19–v0.20; it is the default on Hermes v0.21+):

```yaml
gateway:
  multiplex_profiles: true
  profile_routes:
    # Telegram: route an ops group to the ops profile
    - name: telegram-ops
      platform: telegram
      chat_id: "-1001234567890"    # quote numeric IDs as strings
      profile: ops

    # Telegram: security alerts topic inside a supergroup → security profile
    - name: telegram-security-topic
      platform: telegram
      chat_id: "-1009876543210"
      thread_id: "42"
      profile: security

    # Discord: route entire server to cto by default
    - name: discord-cto
      platform: discord
      guild_id: "123456789012345678"
      profile: cto

    # Discord: override #dev-deploys channel to ops (chat_id beats guild_id)
    # Threads/forum posts under this channel also inherit its parent chat_id
    - name: discord-dev-deploys
      platform: discord
      guild_id: "123456789012345678"
      chat_id: "987654321098765432"
      profile: ops

    # Slack: route a workspace (guild_id) or channel (chat_id) to pm profile
    - name: slack-pm
      platform: slack
      guild_id: "T01234ABCDE"
      profile: pm
```

Supported route fields in Hermes: `name`, `platform`, `profile`, `guild_id`,
`chat_id`, `thread_id`, `user_id`, `bot_profile` (optional; defaults to the
default profile's shared bot), and `enabled` (default `true`).

**Restart the gateway so updated routing takes effect:**
```bash
hermes gateway restart
```

**Verify routing is live:**
```bash
hermes gateway status
hermes gateway list
```

Output shows the active gateway service, platform bindings, and profile status.

**Recommended routing for Oh My Hermes 7-profile setup:**

| Profile | Route |
|---|---|
| `cto` | Default (DMs, general channels, unmatched messages) |
| `ops` | #deployments, #monitoring, #alerts, #incidents |
| `dev` | #dev, #code-review, #prs |
| `qa` | #testing, #qa |
| `security` | #security, #advisories |
| `pm` | #product, #roadmap, #feedback |
| `designer` | #design, #ux |

## Design Rules

- Routes are sorted by additive specificity: `user_id` (16) > `thread_id` (8) >
  `chat_id` (4) > `guild_id` (2). A more specific rule always wins.
- All declared fields in a route entry use AND logic — every declared field must
  match, and `bot_profile` must match the bot receiving the message.
- Messages that match no route go to the current default/active profile.
- Each routed profile's sessions live under an `agent:<profile>:…` namespace so
  two profiles on the same platform never collide in the session store.
- A single shared default-profile bot multiplexes routed chats across profiles
  via `gateway.profile_routes`; if configuring separate per-profile bots, never
  reuse the same bot token across two profiles on polling platforms.

## Pitfalls

- Always quote numeric `guild_id`, `chat_id`, `thread_id`, and `user_id` values
  as strings in `config.yaml` — unquoted floats or mismatched types fail exact
  ID comparison.
- On Hermes v0.19–v0.20, if `multiplex_profiles` is `false`, routing rules are
  ignored and all messages go to the active profile.
- Misconfigured `chat_id` or `guild_id` values silently fall through to the
  default profile. Run `hermes gateway status` and check logs to confirm.
- Memory is per-profile and not shared between routed profiles. If ops needs
  context from cto's session, pass an explicit `project:<slug>:<key>` handoff
  through the existing task/tool boundary; memory scoping does not make profiles
  share storage automatically.
- On Telegram, bot tokens require the bot to be a member of the group with
  message read permission before routing to that chat works.

## Verification

- `hermes gateway status` and `hermes gateway list` show the gateway running
  with active platform bindings.
- Send a test message to a routed chat and verify the routed profile handles it
  under its own isolated session/memory.
- `hermes profile list` confirms all seven profiles exist.
