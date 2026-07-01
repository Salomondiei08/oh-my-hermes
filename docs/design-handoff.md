# Design Contract

The Designer Agent owns design discovery, the implementation contract, and
rendered verification. External mockups, screenshots, and design-tool notes are
optional inputs.

## When Design Is Needed

- New user journey, page, navigation, or interaction
- Material redesign or new visual direction
- Responsive or accessibility behavior is unclear
- Launch media needs art direction

Skip a separate design stage for backend-only changes and tiny visual fixes that
already have clear acceptance criteria.

## Minimal Process

1. Read `PRODUCT_BRIEF.md`, the current UI, and existing design conventions.
2. Infer the recommended direction.
3. Ask at most three questions only if answers materially change the product.
4. Continue with defaults when skipped.
5. Write `DESIGN.md` with flow, hierarchy, states, responsive behavior,
   accessibility, visual direction, and observable acceptance criteria.
6. Give Builder only implementation-relevant guidance.
7. Inspect the real implemented product at mobile and desktop viewports.
8. Return concrete discrepancies and verify fixes.

## Required States

When relevant, define and inspect:

- Loading
- Empty
- Error
- Success
- Disabled or permission-limited
- Long text and large data
- Narrow mobile and wide desktop

## Launch Media

After the product is real, Designer may run `creative-production` to create
screenshots, diagrams, or a HyperFrames launch video. Product evidence comes
first. Third-party music requires license records and founder approval.

## Evidence

Design is complete when `DESIGN.md` exists, implementation criteria are mapped
to Reviewer checks, and real rendered screenshots have been inspected. A prose
description alone is not design verification.
