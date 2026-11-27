---
name: choose-engine
description: Use when starting a coding task and unsure whether Hermes, Claude Code, or Codex should execute it
version: 2.0.0
tags: [routing, orchestration, engine]
---

## Overview

Routes work to the smallest capable execution surface. The decision should take
seconds and should not become another interview.

## When to Use

- Starting any coding or ops task
- After `design-handoff` or `product-brief` completes
- User asks "who should do this?"

## Prerequisites

- Task description available (from user, memory, or implementation spec)

## Procedure

**Before routing — state assumptions (30 seconds, always):**

Inspect the project and state any material assumption. Choose the recommended
reversible path and continue. Ask only when the engine changes cost,
credentials, irreversible state, or a material product outcome.

**Route in order — stop at the first match:**

1. **Product design or visual verification?**
   → Hermes Designer Agent. Load `design-handoff`; external design tools are
   optional inputs.

2. **Native or authenticated GUI with no better interface?**
   → Hermes with `computer-use`.

3. **Operational task?** (deploy, monitor, notify, health check, schedule, run migration)
   → Hermes handles directly. Load the matching skill.

4. **Complex multi-file change?** (new feature across files, architectural refactor, new subsystem, test suite from scratch)
   → Claude Code. Load `implement-with-claude-code`.

5. **Targeted single-file change?** (known bug in specific file, adding one field, quick prototype)
   → Codex. Load `implement-with-codex`.

6. **Still unsure?** Use Hermes directly for a bounded exploration, then route
   based on the evidence. Do not ask the user to estimate file count.

State the recommendation and rationale in one sentence. Offer to immediately load the implement skill.

## Pitfalls

- The choice between Claude Code and Codex is recoverable. Do not overthink — speed matters more than perfection.
- Do not route operational tasks to coding engines. Deploy, monitor, notify → Hermes only.
- If a Codex task expands to 3+ files during execution, stop and switch to Claude Code.
- Unanswered routing preferences are not blockers; use the recommended path.

## Verification

Recommendation stated with rationale. Next skill loaded and running.
