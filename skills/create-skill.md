---
name: create-skill
description: Use when adding a new capability to Hermes that does not exist in the current skill pack
version: 1.0.1
tags: [meta, skills, creation]
---

## Overview

Meta-skill. Guides creation of a new SKILL.md file in the correct format and installs it to ~/.hermes/skills/ so Hermes loads it immediately.

## When to Use

- A workflow keeps recurring that has no matching skill
- User asks "can Hermes learn to do X automatically?"
- Extending Oh My Hermes with project-specific skills

## Prerequisites

- Oh My Hermes installed (`~/.hermes/skills/` exists)
- Clear idea of what the skill should do

## Procedure

Collect from user before generating:

1. **Skill name** — lowercase, hyphenated (`create-github-pr`)
2. **Trigger description** — "Use when..." (this is what Hermes uses for matching)
3. **When to use** — specific conditions that fire the skill
4. **Procedure** — step-by-step, concrete and testable
5. **Prerequisites** — tools, credentials, prior state
6. **Known pitfalls** — only real failure modes

Generate the skill file:

```markdown
---
name: [skill-name]
description: Use when [specific triggering conditions — not workflow summary]
version: 1.0.0
tags: [tag1, tag2]
---

## Overview
[1-2 sentences: what this skill is]

## When to Use
[bullet list of specific triggers]

## Prerequisites
[everything required before running]

## Procedure
[numbered, concrete, testable steps]

## Pitfalls
[only observed failure modes]

## Verification
[concrete check that skill completed successfully]
```

Write to:
1. `${HERMES_HOME:-$HOME/.hermes}/skills/oh-my-hermes/<name>/SKILL.md` — immediate catalog discovery
2. `[oh-my-hermes-repo]/skills/[skill-name].md` — repo persistence (if accessible)

Save to Hermes memory: key `project:<slug>:skill-created-[skill-name]`, value `{ name, description, date }`.

Offer to test the new skill immediately.

## Pitfalls

- The `description` field drives Hermes matching. It MUST start "Use when..." and describe ONLY triggering conditions — never the skill's workflow.
- Procedure steps must be concrete and testable. Remove aspirational steps.
- Pitfalls section: only failures that have actually occurred, not hypotheticals.
- Always confirm the file was written to `~/.hermes/skills/` — not just the repo.

## Verification

- `${HERMES_HOME:-$HOME/.hermes}/skills/oh-my-hermes/<name>/SKILL.md` exists
- Tell Hermes "load skill [skill-name]" — it responds correctly
- Skill saved to Hermes memory
