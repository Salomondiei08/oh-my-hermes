---
name: ship-this-idea
description: Use when the founder gives one sentence and wants Hermes to design, build, verify, and deploy the smallest useful product
version: 1.0.0
tags: [idea, build, launch, flagship]
---

## When to Use

- The founder says "ship this idea" or gives a short app idea.
- A demo should show the full product loop end to end.

## Prerequisites

- Hermes and Oh My Hermes installed.
- A project selected with `project-switch`.
- Deployment credentials only if a live URL is required.

## Procedure

1. Run:
   ```bash
   ~/.hermes/scripts/ship-this-idea.sh "waitlist page for families sharing passwords"
   ```
2. Ask at most three questions if they materially change the first release.
3. Continue with documented assumptions when the founder skips questions.
4. Produce `PRODUCT_BRIEF.md`, `DESIGN.md`, a working build, verification
   evidence, and a preview or production URL when credentials exist.
5. If deployment credentials are missing, finish the build and report the single
   credential or action needed.

## Pitfalls

- Do not promise ten minutes for every idea; scope the first release honestly.
- Do not publish publicly, spend money, or use licensed media without approval.

## Verification

- The founder receives either a working URL or one concrete blocker.
- Build and visual checks have evidence.
- The next action is clear.
