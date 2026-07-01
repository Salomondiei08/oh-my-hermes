---
name: clarify-requirements
description: Use when a new project or significant feature has enough ambiguity to risk building the wrong outcome
version: 2.0.0
tags: [requirements, planning, assumptions, product]
---

## Overview

Creates buildable requirements with minimal interruption. It reads available
evidence first, asks at most three high-value questions, and continues with
recommended assumptions when the user skips them.

## When to Use

- A new product or major feature begins.
- Audience, outcome, scope, or constraints are materially unclear.
- Different reasonable assumptions would produce different products.

Do not use for small fixes or choices already documented in the project.

## Prerequisites

- Access to the current project, conversation, and Hermes memory.

## Procedure

1. Read README, AGENTS.md, existing briefs, issues, product UI, and relevant
   memory before asking anything.
2. Draft inferred answers for: problem, audience, desired outcome, V1 scope,
   constraints, non-goals, and success signal.
3. Identify only unknowns that materially change architecture, user experience,
   cost, legal risk, or scope.
4. If needed, ask at most three short questions in one message. For each, give a
   recommended default. End with: "Skip any question and I will continue with
   these defaults."
5. If the user answers partially, use those answers and default the rest. If the
   user does not answer, continue with all recommended defaults.
6. Save structured requirements and assumptions to Hermes memory under
   `requirements-[project-name]`.
7. Continue directly to `product-brief` unless an irreversible or credentialed
   decision is genuinely blocking.

## Pitfalls

- Do not conduct a fixed questionnaire.
- Do not ask for preferences that a reviewable prototype can resolve.
- Do not repeat questions answered in the repository or conversation.
- Do not hide assumptions; make them easy to correct later.

## Verification

- Requirements identify audience, outcome, V1 scope, acceptance criteria, and
  assumptions.
- No more than three questions were asked in one message.
- Unanswered optional questions did not block progress.
