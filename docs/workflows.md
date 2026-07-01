# Workflows

Workflows chain skills into outcomes. Hermes owns orchestration; these documents
do not introduce another runtime or state database.

## CTO Loop

The canonical lifecycle:

```text
Understand -> Design -> Build -> Check -> Ship -> Learn
```

- Product writes the brief and priorities.
- Designer defines and verifies the user experience.
- Builder delivers a working increment.
- Security and Reviewer independently check it.
- Founder approves irreversible release and publication choices.
- Ops deploys, observes health/logs, and reports incidents.
- Product turns runtime, customer, and growth evidence into the next outcome.

Invoke:

```text
Set up the CTO product loop. Use defaults and only ask me questions that
materially change the result.
```

## Idea To Deploy

```text
clarify-requirements (only if needed)
-> product-brief
-> design-handoff (user-facing work)
-> choose-engine + implement
-> security-review + Reviewer
-> founder approval
-> deploy-to-vercel
-> post-deploy-followup + observe-logs
```

## Design To Code

Designer reads the product and existing interface, writes `DESIGN.md`, hands
testable behavior to Builder, then inspects mobile and desktop renders. External
design notes may be supplied but are not required.

## Deploy And Monitor

Deploy, connect required services, configure monitoring, run the health check,
then observe the first log window. Availability and logs remain separate signals.

## GitHub Ops

GitHub issues and PRs carry task context, diffs, CI, reviews, and release
approval. They support the product loop; they do not replace product strategy.

## Question Policy

Every workflow reads existing context first, asks at most three questions in one
message, gives recommended defaults, and continues when the user skips them.
Only irreversible, paid, credentialed, licensed, destructive, or public actions
must stop for approval.

## Resuming

Resume from the current kanban task, `PRODUCT_BRIEF.md`, `DESIGN.md`, completion
evidence, and Hermes memory. Do not repeat a completed interview.
