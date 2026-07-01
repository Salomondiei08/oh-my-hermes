---
name: idea-to-deploy
description: Move a product idea from minimal clarification through design, a working build, independent checks, deployment, and initial learning
version: 2.0.0
tags: [product, design, build, deploy, learn]
---

## Overview

Build a reviewable first version quickly while preserving the few human choices
that matter.

## Steps

1. **Understand:** inspect context, run `clarify-requirements` only for material
   unknowns, then write `PRODUCT_BRIEF.md` with `product-brief`.
2. **Design:** for user-facing work, Designer runs `design-handoff` and writes
   `DESIGN.md`. Continue with its recommended reversible direction if skipped.
3. **Build:** choose an engine and implement the smallest complete V1 increment.
4. **Check:** run Security for relevant risk and Reviewer against the actual
   acceptance criteria and rendered product.
5. **Preview:** deploy a preview and resolve failed behavior or checks.
6. **Approve:** founder chooses YES, NO, CLOSE, or LATER.
7. **Ship:** Ops deploys, runs `post-deploy-followup`, and observes initial logs.
8. **Learn:** Product records initial user/runtime evidence and recommends the
   next smallest outcome. Growth work is optional, not a release requirement.

## Question Rule

Ask no more than three questions in one message, provide defaults, and continue
when the user skips them. Stop only at irreversible or credentialed boundaries.

## Resume

Use the current kanban task, `PRODUCT_BRIEF.md`, `DESIGN.md`, implementation
evidence, and memory to resume at the first incomplete stage. Do not repeat the
intake interview.

## Verification

- V1 acceptance criteria pass in a running environment.
- Required Security and Reviewer evidence exists.
- Founder approved the reviewed release commit.
- Production health and initial log observation pass.
