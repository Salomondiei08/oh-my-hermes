---
name: learn-skill
description: Use when you want to distill a workflow, session, directory, or URL into a reusable Hermes slash command without hand-writing a skill file
version: 1.0.1
tags: [skills, learning, distillation, workflow, automation]
metadata:
  hermes:
    tags: [skills, distillation]
    requires_toolsets: [terminal]
    min_version: "0.18.0"
---

## Overview

`/learn` watches what happened in a session — or reads whatever source material
you point it at — and authors a reusable skill that Hermes can invoke later with
a single slash command. The output is a standard `SKILL.md` written under
`~/.hermes/skills/` and immediately available.

This is the fastest way to grow Oh My Hermes with skills tailored to your
specific stack, team process, or product.

## When to Use

- You just walked through a workflow and want to repeat it without re-explaining.
- A team process exists in a doc, URL, or script and you want Hermes to own it.
- You want to extend Oh My Hermes without writing `SKILL.md` by hand.
- A skill you ran produced a better procedure than the written one — capture it.

## Prerequisites

- Hermes Agent v0.18+.
- The workflow or source material is complete and correct before you learn from it
  (Hermes distills what it sees, including mistakes).

## Procedure

**Learn from the current session (most common):**

After completing a workflow in Hermes chat, run:
```
/learn <descriptive-name>
```

Hermes replays the session, extracts the repeatable steps, and drafts a skill.
Review the preview, then confirm to save.

**Learn from a URL:**
```
/learn https://docs.yourapi.com/quickstart
```
Hermes fetches the page, distills authentication, common call patterns, and
gotchas into a skill.

**Learn from a local directory or file:**
```
/learn ./scripts/deploy.sh
/learn ./docs/runbooks/
```
Hermes reads the files and produces a skill covering the procedure.

**Learn from a description of what just happened:**
```
/learn how I just set up the Stripe webhook and verified it end to end
```
Prose descriptions are fine — Hermes will match them against the current session
context.

**After confirming:**
The skill is saved to `~/.hermes/skills/<name>/SKILL.md` (with optional relative
`references/` files for larger knowledge-base topics) and is immediately invokable:
```
/<name>
```

**Review or edit a learned skill:**
```bash
cat ~/.hermes/skills/<name>/SKILL.md
# edit ~/.hermes/skills/<name>/SKILL.md directly or via Hermes skill_manage,
# then verify discovery with (Hermes reads updated SKILL.md files on load / next session):
hermes skills list
```

## Design Rules

- Learn after a successful run, not a failed one — the agent captures the path
  it took, including any wrong turns.
- Use a short, hyphenated slug as the name. Prose descriptions work but Hermes
  will slug-ify them, so verify the output name.
- Learned skills use the agentskills.io format. Edit the frontmatter
  (`tags`, `min_version`) after saving if needed.
- For skills that involve secrets (tokens, keys), review the learned SKILL.md
  before sharing — Hermes should reference env vars, not inline values.

## Pitfalls

- A learned skill mirrors what the agent did in the session, including
  session-specific values (repo names, URLs, IDs). Parameterize those before
  treating the skill as general-purpose.
- `/learn` from a URL captures the page at that moment. Re-learn if the upstream
  docs change significantly.
- If the skill name conflicts with an existing skill, Hermes will ask before
  overwriting. Say no and pick a different name.

## Verification

- `hermes skills list` shows the new skill by name.
- `/<name> --help` (or asking Hermes "what does /<name> do?") returns the
  distilled procedure correctly.
- A dry run of the skill on a test input produces the expected steps.
