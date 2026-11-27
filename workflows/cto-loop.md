---
name: cto-loop
description: Build, launch, operate, and improve a product through a minimal seven-agent lifecycle with founder approval at irreversible boundaries
version: 3.0.0
tags: [product, build, design, launch, operations, growth, agents]
---

## Overview

The CTO coordinates one product loop:

```text
Understand -> Design -> Build -> Check -> Ship -> Learn
```

PRs and GitHub issues support this loop but do not define it. Work may begin
from a founder idea, customer feedback, production evidence, product analytics,
or an issue.

## Agents

| Agent | Owns |
|---|---|
| CTO | Lifecycle, roadmap, delegation, founder communication |
| Product (`pm`) | Brief, priorities, positioning, SEO, content strategy |
| Designer | UX, visual direction, design verification, launch media |
| Builder (`dev`) | Working product increments and implementation evidence |
| Reviewer (`qa`) | User journeys, visual/accessibility checks, PR review |
| Security | Release risk and recurring security assessment |
| Ops | Deployments, health, logs, incidents, rollback proposals |

Computer use is a guarded shared skill, not an agent.

## Loop

### 1. Understand

- Product reads the repository, current product, feedback, and memory.
- `clarify-requirements` asks at most three questions only if needed.
- Unanswered optional questions use documented defaults.
- `product-brief` writes the compact source of truth.

### 2. Design

- Skip only when no user-facing behavior or creative direction changes.
- Designer writes `DESIGN.md` and implementation-relevant guidance.
- Founder chooses only when alternatives have materially different outcomes.
- Silence accepts the recommended reversible direction.

### 3. Build

- CTO decomposes the approved outcome into dependent kanban tasks.
- Builder claims one ready task and implements the smallest complete increment.
- Parallel work is used only for independent tasks and isolated with worktrees.
- Completion includes acceptance-criteria, test, runtime, and change evidence.

### 4. Check

- Security reviews relevant trust boundaries and dependencies.
- Reviewer exercises acceptance criteria against a running preview or local app.
- Failures return to Builder with reproducible evidence.
- A PR may carry the review, but green PR checks alone do not complete the stage.

### 5. Ship

- CTO sends one founder summary with user outcome, evidence, preview, and known
  limitations.
- Founder chooses YES, NO, CLOSE, or LATER.
- On YES, Ops releases and runs post-deploy health plus log observation.
- Rollback, destructive actions, and production data changes require approval.

### 6. Learn

- Ops watches availability and deduplicated runtime errors.
- Product reviews customer, product, search, and campaign evidence.
- Product proposes the next smallest outcome or updates positioning.
- Designer and Product may create approved launch content from real shipped work.

## Task Model

Use the existing Hermes statuses: Triage, Todo, Ready, Running, Blocked, Done.
Represent lifecycle stage, acceptance criteria, dependencies, and evidence in the
task body and metadata. Do not create a second workflow database.

Each task includes:

- Product outcome and reason
- Stage and owner
- 2-5 acceptance criteria
- Assumptions and dependencies
- Required completion evidence

## Question Policy

- Read first and infer defaults.
- Ask at most three questions in one message.
- Give a recommended default for each.
- Continue when questions are skipped or unanswered.
- Stop only for credentials, payment, destructive action, legal/licensing risk,
  public publication, or irreversible production decisions.

## Scheduled Work

```bash
hermes cron add "0 * * * *"    "Review product work and actionable GitHub issues for [owner/repo]"
hermes cron add "*/15 * * * *" "Run health-check on [production-url]"
hermes cron add "15 * * * *"   "Run observe-logs for [production-url]"
hermes cron add "0 9 * * *"    "Send cto-status-report to founder"
hermes cron add "30 8 * * *"   "Run security-review daily mode for [owner/repo]"
hermes cron add "0 9 * * 1"    "Run security-review weekly mode for [owner/repo]"
```

## Setup

Run `scripts/setup-cto.sh`, or tell Hermes:

```text
Set up the CTO product loop for this project. Use sensible defaults and only ask
me about choices that materially change the product.
```

Then set persistent focus:

```text
/goal Build, launch, operate, and improve [product]. Keep one product outcome
active, verify before shipping, and ask me only at irreversible boundaries.
```

## Founder Experience

The founder gives direction, reviews meaningful product/design choices, approves
releases and public content, and receives concise outcome/incident reports. The
founder does not manage agent handoffs or routine implementation decisions.
