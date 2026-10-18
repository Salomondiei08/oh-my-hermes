---
name: gateway-routing
description: Use when you want to route specific Telegram chats, Discord channels, or Slack workspaces to specific Hermes profiles so each agent receives only relevant messages
version: 1.0.1
tags: [gateway, profiles, routing, telegram, discord, slack, messaging]
metadata:
  hermes:
    tags: [gateway, profiles, routing]
    requires_toolsets: [terminal]
    min_version: "0.19.0"
---

## Overview

Hermes gateway multi-profile routing (v0.19+) lets you assign individual
Telegram chats, Discord channels/guilds, or Slack workspaces to specific
Hermes profiles. Each route receives full isolation — separate config, skills,
memory, credentials, and session namespace.

For an Oh My Hermes 7-profile setup this means the ops agent watches monitoring
channels, the dev agent lives in code-review threads, and the CTO agent handles
everything else — without manual `/profile use` switching.

## When to Use

- You run multiple profiles (cto, ops, dev, etc.) and want messages routed
  automatically rather than switching profiles manually.
- You want a dedicated Telegram group for ops alerts and a separate DM thread
  for founder communication.
- Different Discord channels should be handled by different specialists
  (e.g. #deployments → ops, #design → designer).

## Prerequisites

- Hermes Agent v0.19+.
- Gateway configured and running (`hermes gateway setup`).
- One bot token per profile — polling platforms (Telegram, Discord, Slack) cannot
  share a single token across two profiles simultaneously.
- Profile names match exactly what `hermes profile list` returns.

## Procedure

**Enable multiplex mode and define routes:**

```bash
hermes gateway config
```

This opens the gateway config file. Add the `multiplex_profiles` block:

```yaml
gateway:
  multiplex_profiles: true
  profile_routes:
    # Telegram: route an ops group to the ops profile
    - platform: telegram
      chat_id: "-1001234567890"    # group chat ID (negative for groups)
      profile: ops

    # Telegram: security alerts channel → security profile
    - platform: telegram
      chat_id: "-1009876543210"
      profile: security

    # Discord: route entire server to cto by default
    - platform: discord
      guild_id: "123456789012345678"
      profile: cto

    # Discord: override #dev-deploys channel to ops (more specific wins)
    - platform: discord
      guild_id: "123456789012345678"
      channel_id: "987654321098765432"
      profile: ops

    # Slack: route a workspace to pm profile
    - platform: slack
      workspace_id: "T01234ABCDE"
      profile: pm
```

**Reload routing without restarting the gateway:**
```bash
hermes gateway reload
```

**Verify routing is live:**
```bash
hermes gateway status
```

Output shows each profile, its platform bindings, and whether it is active.

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

- Routes are matched most-specific-first: `thread_id` > `channel_id`/`chat_id` > `guild_id`/`workspace_id`. A more specific rule always wins.
- All fields in a route entry use AND logic — every declared field must match.
- Messages that match no route go to the current default/active profile.
- Each routed profile's sessions live under an `agent:<profile>:…` namespace so
  two profiles on the same platform never collide in the session store.
- Never reuse the same bot token across two profiles — set up one bot per profile
  on polling platforms.

## Pitfalls

- If `multiplex_profiles` is false (the default), all messages go to the active
  profile regardless of chat source — routing rules are ignored.
- Misconfigured `chat_id` or `guild_id` values silently fall through to the
  default profile. Run `hermes gateway status` to confirm bindings are live.
- Memory is per-profile and not shared between routed profiles. If ops needs
  context from cto's session, pass an explicit `project:<slug>:<key>` handoff
  through the existing task/tool boundary; memory scoping does not make profiles
  share storage automatically.
- On Telegram, bot tokens require the bot to be a member of the group with
  message read permission before routing to that chat works.

## Verification

- `hermes gateway status` lists all active profile bindings and their platform
  sources.
- Send a test message to a routed chat — `hermes gateway status` should show
  the message was handled by the expected profile.
- `hermes profile list` confirms all seven profiles are active.
