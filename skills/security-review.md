---
name: security-review
description: Use when a change affects product security, a release needs an independent risk gate, or a scheduled security assessment is due
version: 2.0.0
tags: [security, owasp, secrets, dependencies, supply-chain]
metadata:
  hermes:
    tags: [security, owasp, supply-chain]
    requires_toolsets: [terminal]
---

## Overview

Runs focused security review in PR, daily, and weekly modes. It prefers proven
scanners, verifies findings in context, and blocks release only on actionable
Critical or High risk.

## When to Use

- A change touches auth, authorization, payments, uploads, secrets, APIs,
  dependencies, database access, RLS, logging, or infrastructure.
- Reviewer requests the release security gate.
- Daily or weekly security cron fires.
- An incident suggests abuse, exposure, or compromised dependencies.

## Prerequisites

- Repository and target branch or PR diff.
- Authenticated `gh` for PR comments when applicable.
- Available scanners from: Gitleaks, Semgrep, OSV-Scanner, package-manager audit.
  Missing optional tools must be reported but do not prevent manual review.

## Procedure

### 1. Select scope

- **PR:** changed files, changed dependencies, and affected trust boundaries.
- **Daily:** tracked files plus newly published Critical dependency advisories.
- **Weekly:** full source, lockfiles, configuration, and deployment surface.

Record scope, commit, tools available, and tools not run.

### 2. Secret exposure

Prefer Gitleaks with redacted output. Otherwise inspect tracked files and the
target diff for credential assignments and committed environment files. Never
print a detected secret; report file, line, and secret type only.

### 3. Dependency risk

Prefer OSV-Scanner against source and lockfiles. Use `npm audit`, `pip-audit`, or
the ecosystem equivalent as a fallback. In PR mode, distinguish newly
introduced findings from existing debt.

### 4. Static and manual review

Run Semgrep with trusted rules when available, then review relevant changes for:

- Missing authentication or object-level authorization
- User-controlled input reaching SQL, shell, templates, paths, or redirects
- Unsafe HTML rendering or file uploads
- Secrets or personal data in clients, logs, errors, or analytics
- Weak session, cookie, CORS, CSRF, rate-limit, or security-header behavior
- Service/admin credentials in client code
- Missing Supabase RLS or policies not scoped to the authenticated owner
- Payment amount, role, tenant, or ownership trusted from client input

### 5. Validate and deduplicate

Confirm the affected code path and existing controls. Group repeated scanner
output by root issue. Do not create a finding solely because a keyword matched.

### 6. Report and route

Each finding includes severity, behavior, evidence location, impact,
remediation, re-test, and owner.

- Critical/High: block task, request changes, alert founder.
- Medium: create tracked remediation with due milestone.
- Low: include in weekly maintenance summary.
- Clean: record tools, scope, commit, and result; hand off to Reviewer.

### 7. Re-test

Run the original reproducer and relevant scanner after the fix. Clear the block
only when evidence passes on the current commit.

## Pitfalls

- Do not call a release clean when required tooling failed without saying so.
- Do not paste secrets, session data, or weaponized payloads into comments.
- Do not silently add scanner ignores. Exceptions require reason, owner, and
  expiration date.
- Do not treat all dependency CVEs as reachable or all Medium findings as
  release blockers.
- Do not run destructive tests against production.

## Verification

- Scope, commit, tools, and unavailable checks are recorded.
- Findings are deduplicated and include reproducible evidence.
- Critical/High findings block release and have an owner.
- Re-tested fixes pass on the commit presented to Reviewer.
