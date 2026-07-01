---
name: product-marketing
description: Use when a product needs positioning, customer-focused website copy, SEO priorities, a launch strategy, or a practical content schedule
version: 1.0.0
tags: [product, marketing, seo, content, strategy]
metadata:
  hermes:
    tags: [product-marketing, seo, content, growth]
    requires_toolsets: [web]
---

## Overview

Creates a focused product and growth strategy from real product evidence. It
supports strategy, website, SEO, launch, and content-calendar modes without
turning the Product Agent into an automatic publishing system.

## When to Use

- Positioning or target audience is unclear.
- Website messaging or SEO needs improvement.
- A launch or ongoing content plan is needed.
- A shipped feature should become useful public content.

## Prerequisites

- Access to the product, repository, documentation, or existing website.
- A known business goal, or permission to use the recommended default.
- Web research for current competitors, channels, and search behavior.

## Procedure

### 1. Build context before asking

Read `PRODUCT_BRIEF.md`, README, website copy, analytics summaries, customer
feedback, release notes, and prior posts. Create or update
`.agents/product-marketing-context.md` with:

- Product and problem
- Audience and triggering situation
- Alternatives and differentiation
- Proof available
- Objections and claims to avoid
- Founder voice examples and exact customer language
- Primary goal, channel, and call to action

### 2. Discover only the specialist needed

Before substantial strategy, SEO, or campaign work, check installed skills and
search the current Hermes registry for the specific capability:

```bash
hermes skills list
hermes skills search "[specific capability]" --limit 10 --json
hermes skills inspect [candidate-identifier]
```

Prefer focused, well-maintained skills with clear prerequisites and passing
security audits. Useful capability names include product marketing context,
customer research, SEO audit, copywriting, copy editing, content strategy,
social content, launch strategy, schema markup, and analytics tracking.

Load only the one or two skills needed for the current deliverable. Installing a
third-party skill requires explicit approval after showing its source and audit
status. If approval is skipped or no trusted candidate exists, continue with
this skill; discovery must not block the work.

### 3. Ask minimally

Ask only what cannot be inferred and materially changes the strategy. Ask at
most three questions in one message, each with a recommended default. State:
"Skip any question and I will continue with the recommended assumptions."

If no answer arrives, record the assumptions and continue.

### 4. Select one mode

- **Strategy:** audience, positioning, offer, proof, channels, and measures.
- **Website:** page goal, hierarchy, concrete copy, CTA, and objection handling.
- **SEO:** crawl/index basics, search intent, page opportunities, internal links,
  metadata, structured data, and a prioritized implementation list.
- **Launch:** message, channel sequence, assets, dates, owner, and approval gates.
- **Content:** 2-4 content pillars and a realistic weekly calendar.

Do not produce every mode unless the user requested a complete plan.

### 5. Write like the product is real

- Lead with a specific problem or observation, not a generic hook.
- Use founder and customer phrasing where available.
- Include concrete product behavior, proof, limitations, and tradeoffs.
- Vary structure by platform instead of cross-posting identical text.
- Remove inflated claims, filler conclusions, fake urgency, and repetitive lists.
- Prefer a useful first-person note over a polished corporate announcement.

### 6. Plan visuals and publishing

Use real screenshots, results, diagrams, or founder media before generated
images. Hand visual work to the Designer. Create drafts and a schedule. After
founder approval, use `publish-with-buffer` to dry-run and submit each approved
channel separately. If Buffer is unavailable, preserve the approved schedule
for manual posting.

### 7. Learn

After publication, compare reach, qualified responses, clicks, conversions, and
customer language. Update context with evidence, not vanity metrics alone.

## Pitfalls

- Do not install or load a large marketing skill collection for every task.
- Do not install an unaudited third-party skill or use popularity as proof of
  quality.
- Do not invent testimonials, metrics, customers, or search demand.
- Do not use an "AI humanizer" or deliberately add errors to mimic a person.
- Do not optimize for keywords at the expense of a useful page.
- Do not auto-post identical promotional copy across communities.

## Verification

- `.agents/product-marketing-context.md` contains assumptions and source evidence.
- The deliverable has one audience, one goal, and one primary call to action.
- Claims are supported by the product, research, or clearly labeled assumptions.
- Public content remains a draft until founder approval.
