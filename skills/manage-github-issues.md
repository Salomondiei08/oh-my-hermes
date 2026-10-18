---
name: manage-github-issues
description: Use when GitHub issues need to be triaged, created, updated, labeled, or closed from the terminal
version: 1.0.1
tags: [github, issues, ops, triage]
---

## Overview

Hermes manages GitHub issues via the `gh` CLI — list, triage, create, label, comment, and close without leaving the terminal.

## When to Use

- Triage backlog of open issues
- User reports a bug or feature request via chat
- Need to close resolved issues after a deployment
- Assign issues before routing to a coding engine

## Prerequisites

- GitHub CLI: `npm install -g @github/cli` or `brew install gh`
- Authenticated: `echo "$GITHUB_TOKEN" | gh auth login --with-token`
- Project repo identified (from Hermes memory key `project:<slug>:github-repo` or current directory)

## Procedure

**List open issues:**
```bash
gh issue list --limit 20
gh issue list --label bug --limit 10
gh issue list --assignee @me
```

**View issue detail:**
```bash
gh issue view [number]
```

**Create issue:**
```bash
gh issue create --title "[title]" --body "[description]" --label "[label]"
```

**Label and assign:**
```bash
gh issue edit [number] --add-label "bug,priority:high" --assignee [username]
```

**Comment:**
```bash
gh issue comment [number] --body "[comment text]"
```

**Close (with reason):**
```bash
gh issue close [number] --comment "Fixed in [commit/PR reference]"
```

**Triage workflow (for backlog review):**
1. `gh issue list` — get open issues
2. For each: `gh issue view [n]` → label as `bug` / `feature` / `question` / `wontfix`
3. Assign priority: `priority:high` / `priority:low`
4. If actionable now: route via `choose-engine`
5. Save triage summary to Hermes memory: key `project:<slug>:issue-triage-[date]`

## Pitfalls

- `gh issue close` without a comment leaves no trace of why it was closed. Always add a reason.
- Labels must exist in the repo before assigning them — `gh label list` to check.
- Creating issues for bugs found during health checks: link to the failing deployment URL in the body.

## Verification

- `gh issue list` reflects updated state
- New issues have labels and assignee set
- Closed issues have a closing comment
