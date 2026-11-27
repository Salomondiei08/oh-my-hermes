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

## Installed state and profiles

Source skills remain `skills/<name>.md`; installation expands each to
`$HERMES_HOME/skills/oh-my-hermes/<name>/SKILL.md`. The ownership manifest hashes
only distributed files, never profile state. Customized files survive updates
and uninstall. Legacy flat skills require manual review.

Setup appends a managed role block to each profile's loaded `SOUL.md` and links
its owned OMH catalog. Existing identity is retained. Credentials are not cloned;
configure and verify each profile before relying on model calls or message delivery.

Project metadata is validated `.env`-shaped data. Read it only with
`project.sh get GITHUB_REPO <slug>` / `get PRODUCTION_URL <slug>`; never source it.
Named jobs use `oh-my-hermes-<slug>-<purpose>` and an explicit project workdir.
Setup edits existing scoped jobs, resumes desired jobs, and pauses jobs whose target
was explicitly cleared. Legacy unscoped jobs are preserved for manual review.
Daily delivery defaults to local; use `OMH_NOTIFICATION_TARGET` for an explicit
configured Hermes destination and verify receipt.

Failure wrappers retain only job/project/time/exit metadata. Arguments and tool
output are intentionally discarded; inspect failures locally and send a reviewed
summary through the notification skill. Snapshots include private configuration,
use SQLite online backups, and preserve executable bits. Close all runtime writers
before cross-file backup/reset; reset refuses unknown gateway state or open files.
The `lsof` prerequisite checks open runtime files; it cannot prevent a new process
starting afterward. Never start another session during reset.

## Memory Keys

All product state uses `project:<slug>:<key>`; the table lists key suffixes.
Resolve the slug at the start of a task and retain it for the task's duration.
Do not fall back to unscoped state from a different product.

| Key | Owner | Purpose |
|---|---|---|
| `github-repo` | setup/onboarding | Optional repository under management |
| `github-username` | setup/onboarding | Optional GitHub assignment identity |
| `current-task` | Product/CTO | Single active outcome |
| `task-id-issue-[n]` | GitHub skills | Issue-to-kanban mapping |
| `triage-last-run` | issue triage | Cost guard |
| `product-brief` | Product | Compact product context |
| `implementation-spec-[feature]` | Designer | Engineering handoff summary |
| `deployment:<env>` | deploy/followup/rollback | Current and previous healthy immutable deployment IDs, URLs, commits and health |
| `log-observer-state` | Ops | Cursor, fingerprints, and incident mapping |
| `pending-approval` | CTO | Reviewed release awaiting founder choice |
| `notification-log` | notification skill | Delivery history |
| `rollback-log` | rollback skill | Rollback history |
| `approval-platform` | onboarding | Founder message channel |
| `blueprint-run-[name]-[ts]` | automation-blueprint | Per-run step outputs and resume state |
| `health-failure-log` | health-check | Per-layer failure history |
| `ops-health-log` | health-check / Ops | 24-hour health window (read by cto-status-report) |

`deployment:<env>` stores `{repository, project, environment, current:
{id,url,commit,timestamp,healthStatus}, previousHealthy: {id,url,commit,timestamp,
healthStatus:"healthy"}|null}`. Persist the new unknown-health deployment before
followup. Preserve the previous known-good target on failure. Production approval
records also bind repository, project, environment and exact reviewed commit.

New persistent keys must be documented here to avoid silent cross-agent
collisions.

## Principles

- Product outcome over PR throughput
- Read before asking; defaults over blocked interviews
- One owner per concern; capabilities do not become agents
- Real product evidence over synthetic presentation
- Reversible autonomy with explicit irreversible gates
- Existing Hermes primitives over custom runtime machinery
