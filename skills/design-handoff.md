---
name: design-handoff
description: Use when a product or feature has user-facing behavior that should be designed and made testable before implementation
version: 2.0.0
tags: [design, ux, responsive, implementation, verification]
---

## Overview

Lets the Designer create or refine a compact design contract and translate it
into implementation-ready behavior. External design notes are optional input,
not a prerequisite.

## When to Use

- A feature adds or changes user-facing screens or interactions.
- A new product needs a visual direction.
- Existing UI needs a coherent redesign or responsive behavior.

## Prerequisites

- `PRODUCT_BRIEF.md` or equivalent product context.
- Access to the existing product when modifying a live design.

## Procedure

1. Read the brief, existing interface, design system, and supplied references.
2. If a material visual choice remains, propose one recommended direction and
   at most two alternatives. Continue with the recommendation if skipped.
3. Write `DESIGN.md` with:
   - User flow and information hierarchy
   - Screen/component responsibilities
   - Interaction and navigation behavior
   - Loading, empty, error, success, and long-content states
   - Mobile and desktop behavior
   - Accessibility requirements
   - Visual direction and asset requirements
   - Observable design acceptance criteria
   - Assumptions
4. Write or update `IMPLEMENTATION_SPEC.md` only with engineering-relevant
   routes, components, data, interactions, and implementation order.
5. Save the implementation summary to Hermes memory.
6. After implementation, inspect the rendered product with browser tools. Use
   `computer-use` only when native or authenticated GUI operation is required.
7. Return concrete discrepancies to Builder and re-check the corrected output.

## Pitfalls

- Do not require Claude Design or another external design session.
- Do not invent backend architecture as a design decision.
- Do not approve static code without inspecting rendered behavior.
- Do not apply a generic visual style that ignores the product domain.

## Verification

- `DESIGN.md` and required implementation guidance exist.
- Mobile and desktop screenshots were inspected for implemented UI.
- Design acceptance criteria map to Reviewer checks.
- Unanswered optional preferences are documented assumptions, not blockers.
