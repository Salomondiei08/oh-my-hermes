---
name: automation-blueprint
description: Use when a multi-step recurring task should be saved as a reusable parameterized blueprint that runs across sessions without manual prompting
version: 1.0.1
tags: [automation, blueprint, workflow, recurring, schedule]
metadata:
  hermes:
    tags: [automation, blueprint, recurring]
    requires_toolsets: [terminal]
    min_version: "0.17.0"
---

## Overview

Hermes Automation Blueprints (v0.17+) let you define a named, parameterized
sequence of steps that Hermes can repeat across sessions — like a macro, but
with LLM reasoning at each step. They complement cron (which runs a single
prompt) by supporting multi-step branching sequences with inputs and conditions.

## When to Use

- A sequence of 3+ steps is done manually and repeatedly.
- A cron job is too simple — the task branches or needs parameters.
- You want to delegate a routine but complex flow permanently.

Common uses:
- Weekly SEO audit → report → draft social post → await approval → schedule
- Nightly backup → verify → notify on failure
- New GitHub issue received → triage → brief → assign
- Deploy → health check → notify → rollback on failure

## Prerequisites

- Hermes Agent v0.17+.
- Steps are repeatable and do not require fresh judgment each time.
- Sensitive steps (publish, spend, destroy) use approval gates.

## Procedure

**Define a blueprint:**
```bash
hermes blueprint create weekly-seo-audit \
  --description "Audit SEO, draft content, schedule with approval" \
  --param PROJECT_SLUG \
  --param TARGET_URL
```

**Add steps interactively or by editing the generated YAML:**
```yaml
# ~/.hermes/blueprints/weekly-seo-audit.yaml
name: weekly-seo-audit
description: Weekly SEO audit, content draft, and scheduled post
params:
  - PROJECT_SLUG
  - TARGET_URL
steps:
  - name: audit
    prompt: "Run product-marketing skill for {PROJECT_SLUG}: audit SEO at {TARGET_URL}"
  - name: draft
    prompt: "Draft two social posts from the audit findings. Save to memory: project:{PROJECT_SLUG}:seo-draft"
    depends_on: audit
  - name: approve
    type: approval
    message: "SEO audit done. Review drafts in memory key project:{PROJECT_SLUG}:seo-draft. Reply YES to schedule."
    depends_on: draft
  - name: schedule
    prompt: "Use publish-with-buffer to schedule the approved posts for {PROJECT_SLUG}"
    depends_on: approve
    condition: approved
```

**Run a blueprint manually:**
```bash
hermes blueprint run weekly-seo-audit --PROJECT_SLUG myapp --TARGET_URL https://myapp.com
```

**Schedule a blueprint via cron:**
```bash
hermes cron add "0 9 * * 1" \
  "Run blueprint weekly-seo-audit for PROJECT_SLUG=myapp TARGET_URL=https://myapp.com"
```

**List and manage blueprints:**
```bash
hermes blueprint list
hermes blueprint status weekly-seo-audit
hermes blueprint history weekly-seo-audit   # run history with outcomes
```

## Design Rules

- Each step prompt should be self-contained and skill-based.
- Use `depends_on` to sequence steps; parallel steps have no dependency.
- Add an `approval` step before any publish, spend, or destructive step.
- Keep blueprints under 8 steps — anything larger should be a workflow.
- Store state between steps in Hermes memory using a namespaced key
  (`project:<slug>:blueprint-run-[name]-[timestamp]`).

## Pitfalls

- Blueprints run with Hermes's current model — a slow model slows every step.
- Do not hard-code credentials in blueprint YAML; use env vars or vault secrets.
- A failed step stops the run and marks it `blocked`; the run can be resumed
  from the last successful step with `hermes blueprint resume [run-id]`.
- Do not use blueprints for one-off tasks — skills and workflows are the right
  tool for that.

## Verification

- `hermes blueprint list` shows the blueprint with correct params.
- A test run completes with expected step outputs.
- `hermes blueprint history [name]` records the run with outcomes.
