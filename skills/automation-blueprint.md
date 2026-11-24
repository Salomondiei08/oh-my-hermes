---
name: automation-blueprint
description: Use when a multi-step recurring task should be saved as a reusable parameterized blueprint that runs across sessions without manual prompting
version: 1.0.2
tags: [automation, blueprint, workflow, recurring, schedule]
metadata:
  hermes:
    tags: [automation, blueprint, recurring]
    requires_toolsets: [terminal]
    min_version: "0.17.0"
---

## Overview

Hermes Automation Blueprints let you reuse parameterized multi-step
automations across sessions without rewriting prompts from scratch. In Hermes
Agent, blueprints work in two ways: built-in/plugin blueprints invoked with the
`/blueprint` slash command, and custom reusable skills that declare a
`metadata.hermes.blueprint` schedule block and run through `hermes cron`.

## When to Use

- A sequence of 3+ steps is done manually and repeatedly.
- A cron job needs reusable structure, parameters, or skill steps.
- You want to delegate a routine but complex flow permanently.

Common uses:
- Weekly SEO audit → report → draft social post → await approval → schedule
- Nightly backup → verify → notify on failure
- New GitHub issue received → triage → brief → assign
- Deploy → health check → notify → rollback on failure

## Prerequisites

- Hermes Agent v0.17+ (v0.19+ recommended for Oh My Hermes).
- Steps are repeatable and do not require fresh judgment each time.
- Sensitive steps (publish, spend, destroy) use approval gates.

## Procedure

**Option A — Run a built-in or plugin blueprint via `/blueprint` (CLI, TUI, or gateway chat):**
```text
/blueprint                                        # list catalog & plugin blueprints
/blueprint <name>                                 # fill parameters conversationally via cronjob tool
/blueprint <name> time=08:00 deliver=origin       # pass slot=value pairs inline
```

**Option B — Define a reusable custom blueprint skill in `~/.hermes/skills/<name>/SKILL.md`:**
```markdown
---
name: weekly-seo-audit
description: Weekly SEO audit, social draft, and founder-approved scheduling
version: 1.0.0
tags: [seo, marketing, blueprint]
metadata:
  hermes:
    blueprint:
      schedule: "0 9 * * 1"
      deliver: origin
      prompt: "Run weekly-seo-audit for PROJECT_SLUG=<slug> TARGET_URL=<url>"
---

## Steps
1. Run `product-marketing` skill for `{PROJECT_SLUG}`: audit SEO at `{TARGET_URL}`.
2. Draft two social posts from the audit findings and save to memory key `project:{PROJECT_SLUG}:seo-draft`.
3. Ask the founder for approval via `send-notification` or active chat before scheduling.
4. Only after explicit approval, run `publish-with-buffer` to schedule the approved posts.
```

`metadata.hermes.blueprint` accepts required `schedule` plus optional `deliver`
(default `"origin"`), `prompt`, `no_agent`, `model`, `provider`, and
`enabled_toolsets`.

**Schedule a custom blueprint skill explicitly via `hermes cron create`:**
```bash
hermes cron create --name weekly-seo-audit --deliver origin \
  "0 9 * * 1" \
  "Run weekly-seo-audit for PROJECT_SLUG=myapp TARGET_URL=https://myapp.com"
```

**Inspect and manage scheduled blueprint jobs:**
Blueprints instantiate standard Hermes cron jobs (there is no separate
`hermes blueprint` shell CLI):
```bash
hermes cron list                   # show job IDs, schedules, and last-run status
hermes cron runs <job-id>          # run history with outcomes (alias: hermes cron history <job-id>)
hermes cron incidents              # inspect durable cron failure incidents
hermes cron pause <job-id>         # pause a blueprint job
hermes cron resume <job-id>        # resume a paused blueprint job
hermes cron remove <job-id>        # delete a blueprint job (or manage via /cron in CLI chat)
```

## Design Rules

- Each step in the skill prompt should be self-contained and reference concrete skills.
- Include an explicit founder approval step before any publish, spend, or destructive step.
- Keep blueprint skills focused (under 8 steps) — larger flows belong in `workflows/`.
- Store state between steps in Hermes memory using a namespaced key
  (`project:<slug>:blueprint-run-[name]-[timestamp]`).

## Pitfalls

- There is no `hermes blueprint` shell subcommand or `~/.hermes/blueprints/*.yaml` directory; use `/blueprint` in chat/CLI or `metadata.hermes.blueprint` inside a skill plus `hermes cron`.
- Blueprints run with Hermes's configured model — a slow model slows every step.
- Do not hard-code credentials in skill files or cron prompts; use env vars or secret references.
- A failed step stops the scheduled run; inspect `hermes cron runs <job-id>` and `hermes cron incidents` instead of looking for a separate blueprint resume command.
- Do not use scheduled blueprints for one-off tasks — interactive skills and workflows are the right tool for that.

## Verification

- `/blueprint` lists built-in/plugin blueprints (or `hermes skills list` shows your custom blueprint skill).
- `hermes cron list` shows the scheduled blueprint job with the expected schedule and delivery target.
- `hermes cron runs <job-id>` records test/scheduled run execution and outcomes.
