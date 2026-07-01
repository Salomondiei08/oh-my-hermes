# Architecture

## Boundary

Oh My Hermes is a curated workflow layer for Hermes Agent. It distributes
skills, role definitions, workflows, templates, and setup scripts. It is not a
runtime, daemon, model router, event store, or second task database.

Hermes provides profiles, Kanban, memory, cron, tools, approvals, computer use,
and subagents. Oh My Hermes composes those primitives into a product-building
lifecycle.

## Product Lifecycle

```text
Understand -> Design -> Build -> Check -> Ship -> Learn
```

The CTO coordinates seven profiles:

| Profile | Responsibility |
|---|---|
| `cto` | Lifecycle, roadmap, delegation, founder communication |
| `pm` | Product clarity, priorities, positioning, SEO, content strategy |
| `designer` | UX, visual verification, launch media |
| `dev` | Working product increments |
| `qa` | User behavior, visual/accessibility checks, PR review |
| `security` | Release risk and scheduled assessments |
| `ops` | Release, health, logs, incidents |

Computer Use is a shared guarded skill. GitHub is a delivery surface. Neither is
a separate agent or the center of the architecture.

## State

Hermes Kanban remains the task source of truth using Triage, Todo, Ready,
Running, Blocked, and Done. Lifecycle stage, dependencies, acceptance criteria,
and completion evidence live in task bodies and metadata.

Project-local artifacts stay intentionally small:

- `PRODUCT_BRIEF.md`: outcome, scope, criteria, assumptions
- `DESIGN.md`: flow, states, responsive/accessibility behavior
- `IMPLEMENTATION_SPEC.md`: only when engineering handoff needs more detail
- `.agents/product-marketing-context.md`: audience, positioning, voice, evidence
- `music-license.json`: only when third-party music is used

## Approval Boundary

Agents continue through reversible work with documented defaults. Founder
approval is required for production release/rollback, public publication,
licensed media selection, payment, credentials, destructive actions, and
materially different irreversible product directions.

Hermes smart approvals are the recommended host default. Approval checks may be
disabled only when a disposable or appropriately isolated environment is the
safety boundary.

## Execution

- Hermes handles orchestration, product/design work, routine edits, tools, ops,
  and memory.
- Codex handles targeted code changes.
- Claude Code handles broad or architecturally complex implementation.
- HyperFrames handles requested deterministic launch video.
- Browser tools precede CUA; CUA is reserved for native/authenticated GUI work.

## Reliability

Completion requires evidence tied to acceptance criteria. Security and Reviewer
independently check relevant changes. Ops pairs active health checks with
deduplicated log observation. Two materially similar failed attempts block the
task and request a decision instead of continuing busywork.

## Memory Keys

| Key | Owner | Purpose |
|---|---|---|
| `github-repo` | setup/onboarding | Optional repository under management |
| `github-username` | setup/onboarding | Optional GitHub assignment identity |
| `current-task` | Product/CTO | Single active outcome |
| `task-id-issue-[n]` | GitHub skills | Issue-to-kanban mapping |
| `triage-last-run` | issue triage | Cost guard |
| `product-brief-[project]` | Product | Compact product context |
| `implementation-spec-[feature]` | Designer | Engineering handoff summary |
| `last-deployment-url` | deploy skill | Current release target |
| `log-observer-state` | Ops | Cursor, fingerprints, and incident mapping |
| `pending-approval` | CTO | Reviewed release awaiting founder choice |
| `notification-log` | notification skill | Delivery history |
| `rollback-log` | rollback skill | Rollback history |
| `approval-platform` | onboarding | Founder message channel |

<<<<<<< HEAD
| Key | Written by | Read by | Format | Description |
|---|---|---|---|---|
| `github-repo` | `setup-cto.sh`, `onboarding` | `auto-issue-triage`, `security-review`, `create-github-pr` | `owner/repo` string | GitHub repository under management |
| `github-username` | `setup-cto.sh`, `onboarding` | `auto-issue-triage` | string | GitHub username for issue self-assignment |
| `current-task` | `auto-issue-triage` | `auto-issue-triage`, CTO Agent | `{ issueNumber, taskId, title, assignedAt }` JSON | Currently in-progress issue; prevents parallel work |
| `task-id-issue-[n]` | `auto-issue-triage` | `kanban-task` | string (kanban card ID) | Maps GitHub issue number to kanban card ID |
| `triage-last-run` | `auto-issue-triage` | `auto-issue-triage` | ISO 8601 timestamp | Guards against over-frequent triage runs (cost control) |
|| `last-deployment-url` | `deploy-to-vercel` | `rollback`, `post-deploy-followup`, `health-check` | URL string | Most recent Vercel deployment URL |
| `notification-log` | `send-notification` | CTO Agent (reporting) | Array of `{ event, timestamp, backend, delivered }` | Audit log of notifications sent |
| `rollback-log` | `rollback` | CTO Agent (reporting) | Array of `{ rolledBackAt, fromUrl, reason, healthStatus }` | Audit log of production rollbacks |
| `approval-platform` | `onboarding`, `setup-cto.sh` | `await-merge-approval`, `send-notification` | `telegram` \| `slack` \| `discord` | Where to send founder approval requests |
=======
New persistent keys must be documented here to avoid silent cross-agent
collisions.
>>>>>>> origin/product-loop-integrations-cleanup

## Principles

- Product outcome over PR throughput
- Read before asking; defaults over blocked interviews
- One owner per concern; capabilities do not become agents
- Real product evidence over synthetic presentation
- Reversible autonomy with explicit irreversible gates
- Existing Hermes primitives over custom runtime machinery
