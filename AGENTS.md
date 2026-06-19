# AGENTS — Oh My Hermes

This file is for AI agents working inside the oh-my-hermes repository itself.
For the AGENTS.md template to use in projects built with oh-my-hermes, see `templates/AGENTS.md.template`.

---

## What this repo is

Oh My Hermes is a curated skills pack, conventions library, workflow documentation, and bootstrap tooling for Hermes Agent. It is not a runtime, not a server, not a CLI tool beyond shell scripts. It is a collection of files that extend Hermes for real app-building workflows.

## Repository structure

```
skills/          ← SKILL.md files (agentskills.io standard format)
workflows/       ← Composite workflow documents linking multiple skills
templates/       ← Starter files for new projects
scripts/         ← install.sh, bootstrap.sh, verify.sh
docs/            ← Full documentation
```

## Build commands

There is no build step. This is a documentation and file distribution project.

Validation:
```bash
bash scripts/verify.sh
```

## Skill file format

Every file in `skills/` must follow the agentskills.io standard:

```markdown
---
name: skill-name
description: One-line description used by Hermes to decide when to load this skill
version: 1.0.0
tags: [tag1, tag2]
---

## When to Use
## Prerequisites
## Procedure
## Pitfalls
## Verification
```

## Conventions for editing skills

- Procedures must be specific and testable, not aspirational
- Pitfalls must come from real failure modes, not hypotheticals
- Prerequisites must list every credential and tool required
- Verification must be a concrete check, not "confirm it looks right"

## Conventions for editing docs

- No marketing language in technical docs
- No aspirational descriptions of unbuilt features
- Roadmap items must be clearly labeled as V2 or V3

## Conventions for editing scripts

- install.sh and bootstrap.sh must be idempotent (safe to run multiple times)
- Scripts must print clear success/failure messages
- Scripts must check prerequisites before running

## Security baseline

- Never hardcode credentials in skills or templates
- .env.example must use placeholder values only
- Skills that require credentials must check for their presence before proceeding
- No secrets in any committed file

## Commit conventions

One commit per meaningful change. Never bundle skill changes with doc changes.

## Architecture decisions

Engine routing recommendations are in `docs/engines.md`. Do not modify them without reading that document — decisions are research-based. Vercel + Supabase defaults are in `docs/architecture.md`. Alternatives are documented but the defaults are opinionated by design.
