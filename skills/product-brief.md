---
name: product-brief
description: Use when a product idea or feature needs a compact source of truth before design and implementation
version: 2.0.0
tags: [product, brief, scope, acceptance-criteria]
---

## Overview

Writes the smallest brief that keeps Product, Designer, Builder, Reviewer, and
Security aligned. The brief records assumptions instead of waiting for perfect
information.

## When to Use

- Starting a new product or meaningful increment.
- Existing requirements are scattered across chat, memory, issues, or docs.
- Design and implementation need shared acceptance criteria.

## Prerequisites

- Requirements from project evidence, conversation, or `clarify-requirements`.

## Procedure

1. Gather the best available requirements and assumptions.
2. Write `PRODUCT_BRIEF.md` with:
   - **Problem and Audience**
   - **Desired User Outcome**
   - **V1 Scope** (maximum five items)
   - **Primary Journey**
   - **Acceptance Criteria** (2-5 observable checks)
   - **Non-Goals**
   - **Constraints and Assumptions**
   - **Success Signal**
3. Mark each unresolved item as an assumption with the recommended default.
4. Save a compact copy to memory as `product-brief-[project-name]`.
5. Route UI or creative work to Designer; otherwise route the brief to Builder.

## Pitfalls

- Do not turn the brief into a roadmap, architecture document, or feature dump.
- Do not invent evidence or treat an assumption as a confirmed fact.
- Do not block design or building on an optional open preference.
- Do not exceed five V1 scope items.

## Verification

- `PRODUCT_BRIEF.md` exists and remains concise.
- Each acceptance criterion is externally observable or mechanically testable.
- Assumptions are explicit and downstream ownership is clear.
