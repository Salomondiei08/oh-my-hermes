---
name: design-to-code
description: Turn product intent into a designed, implemented, and visually verified user experience without requiring a separate manual design tool
version: 2.0.0
tags: [design, ux, build, visual-verification]
---

## Steps

1. Read `PRODUCT_BRIEF.md`, current UI, design system, and supplied references.
2. Designer runs `design-handoff`, chooses a recommended direction, and writes
   `DESIGN.md` plus implementation guidance.
3. Ask the founder only if materially different directions cannot be changed
   cheaply later. Otherwise continue with the documented recommendation.
4. Builder implements the smallest complete experience.
5. Designer inspects mobile and desktop renders and returns discrepancies.
6. Builder fixes discrepancies.
7. Reviewer exercises user journeys, states, responsiveness, and accessibility.
8. For launch media, optionally run `creative-production` after the product is
   real and reviewable.

## Verification

- The implemented experience satisfies product and design criteria.
- Real screenshots were inspected at narrow and desktop viewports.
- Empty, loading, error, success, and long-content states are coherent.
- Launch assets, when requested, use verified product evidence.
