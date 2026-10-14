# Repository audit — 2026-10-14

## Assessment and scope

Oh My Hermes has a clear intended architecture: reuse Hermes for orchestration,
Kanban, profiles, memory, and scheduling; distribute procedures and conventions.
The seven role definitions and newer lifecycle/security/log-observation documents
are useful starting points. However, the distribution and operational scripts do
not reliably implement several promises in those documents. I would not yet rely
on this checkout for unattended production operation or multiple products.

This review covers the skills pack at commit `1356c37` and the separate nested
Next.js landing-page repository at `8f1777f`. The parent reports that nested
directory as untracked; the landing page itself is already a Git repository.
It is a static marketing site with one health API, not an application dashboard.
There is no need to add authentication or a database merely to serve this site.

Evidence comes from source review, isolated script reproductions, official
upstream source/docs, dependency auditing, a production build, and local browser
checks. No production deployment, real messaging, real credential configuration,
or live Hermes profile mutation was performed. No implementation was changed.

## Verification results

| Check | Result | Interpretation |
|---|---|---|
| Syntax for installer and 13 helper scripts | Pass | Syntax alone does not establish behavior |
| Skill validation | 392 passes, 62 warnings, 0 failures | Format checks are shallow; many warnings are command names |
| Fake-root install and TEST_MODE smoke tests | Pass | All 39 flat skill files copied; discovery not tested |
| Local `bash scripts/verify.sh` | 7 passes, 69 failures, **exit 0** | Local Hermes home is absent; erroneous success status is a script defect |
| Next.js TypeScript check | Pass | `npx tsc --noEmit --incremental false` |
| Next.js lint | Fail | 1 error, 2 warnings |
| Next.js production build | Pass with network access | Initial sandbox attempt could not fetch Google Fonts |
| Local production page and health endpoint | HTTP 200 | No browser page errors in tested flow |
| Widths 320, 375, 480, 1280 | No page-wide overflow | Code blocks intentionally scroll internally |
| Theme, font, interaction checks | Failures confirmed | See findings below |
| `npm audit --json` | 27 package findings | 2 Critical, 19 High, 4 Moderate, 2 Low; reachability not established |

Script reproductions used temporary directories. Scripts that hardcode the
installation path were copied and only that path was redirected to the fake
root; HOME was not changed. Hermes was stubbed for setup tests so no real jobs,
profiles, messages, or external account operations could occur. Security
reproductions used made-up canaries and a harmless temporary marker.

## High-priority findings

### 1. Skill installation does not match current discovery

**Evidence:** `install.sh:44-49`, `skills/create-skill.md`, official Hermes
`tools/skills_tool.py` and `agent/skill_utils.py`.

The installer copies `skills/<name>.md` to the skills root. The isolated install
contains 39 such files and zero `SKILL.md` files. Current Hermes catalog
discovery walks for `SKILL.md`; direct lookup still contains a legacy flat-file
fallback. Therefore the current catalog will not discover these installed files
through the normal index. This is narrower than saying the files can never be
loaded: explicit legacy lookup may still work.

**Impact:** Installation and the local smoke suite can pass while normal
skill discovery and description-based selection omit the pack. New skill
creation perpetuates the same layout.

**Fix:** Install each skill into an owned directory such as
`skills/oh-my-hermes/<name>/SKILL.md`, update creation/uninstall conventions, and
test actual catalog discovery and loading on explicitly supported Hermes
versions. This finding is based on current upstream source, not a live Hermes
integration run or a complete historical version matrix.

Sources: [Hermes skill catalog implementation](https://github.com/NousResearch/hermes-agent/blob/main/tools/skills_tool.py),
[Hermes skill traversal](https://github.com/NousResearch/hermes-agent/blob/main/agent/skill_utils.py).

### 2. Setup crashes when an optional GitHub variable is unset

**Evidence:** `scripts/setup-cto.sh:6`, `:182`, `:209`, `:213`, `:312`.

With `set -u`, accesses such as `$GITHUB_TOKEN` abort when the variable is
unset. In a stubbed successful runtime preflight, setup exited 1 at line 182:
`GITHUB_TOKEN: unbound variable`. It had already reached profile/role setup.
Other optional variables have the same pattern.

**Impact:** The advertised GitHub-optional onboarding fails on a fresh shell.
`server-bootstrap.sh:80` then suppresses the setup error with `|| true`.

**Fix:** Read optional values with `${VARIABLE:-}`, validate required values
before mutation, and propagate setup failures with a clear partial-setup status.
Test both unset and explicitly empty environments.

### 3. Project metadata can execute shell commands

**Evidence:** `scripts/project.sh:54-58`, `scripts/status.sh:22-30`.

Repo/URL arguments are written into single-quoted shell assignments without
escaping or validation. `status.sh` later sources that file. A quote-containing
repo argument caused a harmless test marker to be created during status reading.

**Impact:** If untrusted metadata reaches this helper through an agent or other
caller, reading status can execute commands with the operator's permissions.
This is a local input-validation defect; no remote exploitation was demonstrated.

**Fix:** Treat project metadata as data, preferably JSON with an allowlisted
parser, and validate repo/URL formats. Do not source project metadata as code.
Escaping alone is less robust than eliminating executable configuration.

### 4. Multi-project scheduling retains the first project's jobs

**Evidence:** `scripts/setup-cto.sh:282-338`, `skills/project-switch.md`.

All job names are global (`oh-my-hermes-health`, etc.). Existing-name checks
skip jobs without checking their target, prompt, or schedule. A stubbed setup for
`alpha` created six jobs. Setup for `beta` exited 0 and skipped all six; no beta
target appeared in the saved job definitions.

Several memory keys are also global (`github-repo`, `current-task`,
`pending-approval`, `log-observer-state`, `task-id-issue-[n]`), despite the
project-switch skill instructing agents to namespace state.

**Impact:** Health checks and security review can continue targeting an old app.
State may be mixed unless agents manually apply conventions consistently.

**Fix:** Include a stable project ID in cron names and state keys, reconcile job
configuration on rerun, and explicitly bind working directory, repo, profile,
and notification destination. Test two products concurrently.

### 5. Uninstall destroys profile-owned state

**Evidence:** `scripts/uninstall.sh:74-82`.

The script recursively deletes seven entire profile directories and then claims
memory is intact. A fake profile containing a custom user note lost that note.
Hermes profiles own configuration, credentials, memory, sessions, and other state;
names such as `dev` and `cto` do not establish that OMH owns all their contents.

**Impact:** Uninstall can erase existing or customized profile state after a
generic confirmation. It also leaves scheduled jobs referring to removed skills.

**Fix:** Keep an install ownership manifest, remove only owned artifacts, and
offer a separately reviewed backup-and-remove operation for whole profiles.

Source: [Hermes profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles).

### 6. Preview and production deployment instructions conflict

**Evidence:** `workflows/github-ops.md`, `skills/deploy-to-vercel.md:34-42`.

The GitHub workflow places `deploy-to-vercel` before security/reviewer checks and
founder approval, labeling it as preview delivery. That skill's executable
examples use `vercel --prod`. Its own procedure does not require release approval.
The broader architecture requires founder approval for production.

**Impact:** An agent following the narrower skill can deploy production during
the intended preview stage. This is a documented execution path conflict, not
evidence that an unauthorized deployment has happened.

**Fix:** Make preview the default; production requires explicit environment,
approved commit, and target. Align every workflow that calls the skill.

### 7. Rollback does not identify a known-good target

**Evidence:** `skills/deploy-to-vercel.md:55`, `skills/rollback.md:28-55`,
`docs/architecture.md` memory registry.

Deploy writes `last-deployment`; rollback reads `last-deployment-url`. Even if
that key were populated with the latest deployment, rollback would target that
latest URL, while the user is told it will restore the previous deployment.
The procedure never retrieves and verifies a distinct previous healthy target.

**Impact:** Incident recovery can block on missing state or select the broken
release again. The approval description does not concretely identify its target.

**Fix:** Track current and previous healthy deployment IDs per project and
environment. Verify the selected target and describe it before approval. Add a
mocked deployment/rollback integration test.

Source: [Vercel rollback command](https://vercel.com/docs/cli/rollback).

### 8. Operational logs and backups have confidentiality/consistency gaps

**Evidence:** `scripts/run-cron-safe.sh:28-55`, `scripts/reset-runtime.sh:33-43`,
`skills/backup-hermes-data.md`.

The failure logger redacts assignment patterns only. A fabricated
`Authorization: Bearer ...` credential remained in the command and output logs.
Raw temporary output is written before restrictive permissions are applied, and
paths/job names are not validated or made collision-resistant.

Reset archives runtime files before stopping writers, ignores stop failures,
and moves `state.db` without handling its SQLite WAL/SHM siblings. The backup
skill archives the full credential-bearing Hermes directory into `/tmp` without
setting restrictive permissions or providing a tested restore procedure.

**Impact:** Dead letters can retain credentials; recovery snapshots may be
inconsistent while processes are active. The SQLite risk is from source review,
not a demonstrated database-loss incident.

**Fix:** Apply `umask 077` before creating files, use unique safe paths, avoid
logging sensitive arguments, redact supported credential formats, and stop/verify
writers or use SQLite's backup API. Test restore of memory, tasks, and sessions.

### 9. Website installation path is guaranteed to fail

**Evidence:** `oh-my-hermes-web/components/landing/Hero.tsx`, `Install.tsx`,
`install.sh:23-39`.

The site advertises fetching only `install.sh` and piping it to Bash. The
installer explicitly requires sibling skills/workflows/agents/scripts from a
full checkout. The README has already moved to clone-and-run, but the site has not.

**Fix:** Use one canonical checkout-based installation snippet across all surfaces
and test that exact snippet in a clean environment.

### 10. Dependency advisories need review before another web release

**Evidence:** Landing-page package manifest/lockfile and live npm audit on this date.

Audit reports 27 package findings, including 2 Critical and 19 High. Direct
`next` is pinned to `16.2.6` and classified Critical; npm reports `16.4.0` as an
available fix. Other findings include the `shadcn` tooling dependency and its
transitive packages. These counts include tooling and aggregate effects, not 27
independently verified exploitable vulnerabilities in the website.

The site has no auth middleware, application database, payment API, or authored
Server Actions. That limits relevance of several advisory paths, but does not
replace review of applicable framework/image/server paths and hosting behavior.

**Fix:** Review advisories against actual usage, upgrade compatible framework and
tooling versions, and repeat build/browser checks. Do not blindly apply
`npm audit fix --force`: suggestions include major downgrades of tooling.

## Reliability and UX findings

### 11. Validation can report success without validating operation

`scripts/verify.sh:140-150` prints failures but never exits nonzero. Confirmed:
69 failures and exit 0. The CI workflow only installs into a fake home and runs
file-existence/description smoke checks. It does not run setup, switching,
uninstall, skill discovery, recovery, the skill validator, or the web checks.

The skill validator checks field presence using regex rather than parsing YAML,
does not require Pitfalls despite the repository format contract, and does not
actually validate Markdown links despite claiming it does.

**Missing:** Behavioral tests for the scripts and a real Hermes compatibility
contract. Reproductions in this report are examples of meaningful regression tests.

### 12. Profiles and autonomous handoffs are not fully wired

`setup-cto.sh:151-157` copies definitions to `agent-role.md`; it does not bind
them to a documented system-prompt or role-loading mechanism. Current Hermes
documents SOUL/AGENTS for persona/project guidance. The setup's verification
checks file presence rather than asking each profile to demonstrate its role.
New profiles also do not explicitly receive the OMH skill pack or configured
model credentials. Exact behavior requires a live integration check.

`implement-with-claude-code.md:49-51` instructs the founder to open Claude Code,
paste a prompt, and confirm the result. This is a manual handoff in the main
build path, despite the site's claim of no manual steps. Codex's example likewise
does not specify a noninteractive execution contract.

**Missing:** Proven role loading, profile skill/credential visibility, and
bounded coding-engine invocation with working directory, result artifacts,
timeout, exit status, and independent acceptance checks. Implement these through
Hermes's supported facilities rather than inventing a second orchestration runtime.

### 13. Project updates and status can mislead the operator

`project.sh:54-58` writes repo/URL values only when absent. Repeating switch with
a new URL/repo preserves old values; the isolated test confirmed this.
`status.sh` loads the project file but not the saved integration file. A configured
fake OpenAI key in `HERMES_HOME/.env` still displayed “not connected” when not
exported. That label only establishes environment presence even when it succeeds;
it does not establish provider authentication.

**Fix:** Atomically update provided project values, preserve omitted values,
and distinguish configured, authenticated, reachable, and unverified integration
status. Standardize HERMES_HOME support across all scripts.

### 14. Bootstrap can create an unused route and omit secret protection

`bootstrap.sh` always creates `src/app/api/health/route.ts`, even in an existing
root `app/` project. The isolated root-app test created an extra src route despite
an existing root health route. Next.js root-app projects will not use that new
src tree. The script creates no `.gitignore` if one is absent, while recommending
that the user create `.env.local` next.

The distributed `templates/` are not installed, and bootstrap duplicates
their content with embedded heredocs. This creates another place for drift.

**Fix:** Detect supported framework/layout before generating files, create a
secret-safe gitignore, and generate from the shipped templates.

### 15. Several integration instructions are stale or incomplete

`connect-supabase.md` recommends unsupported global npm installation and uses
local-stack status/diff commands as hosted-link/migration verification. It also
pushes migrations without an explicit destructive-change approval step, despite
acknowledging that destructive changes are irreversible.

`health-check.md` claims a timeout/retry policy but its curl examples have no
connection or overall timeout. A reachability endpoint and `SELECT 1` are not
application data-access or RLS journey tests. Supabase and Vercel are assumed
even when an app has no such dependencies.

`await-merge-approval.md` states approval applies to the reviewed commit, but its
saved state/procedure does not explicitly capture and compare the head SHA
immediately before merging. Global approval state also conflicts with multiple apps.

**Fix:** Verify real CLI examples against pinned versions, make checks depend on
the actual stack, enforce deadlines, and persist repo/project/commit-bound approval.

Source: [Supabase CLI installation](https://supabase.com/docs/guides/local-development/cli/getting-started).

### 16. Website facts have drifted in several independent places

The visible site says 13 skills, v1.0.0, Hermes v0.9+, seven clarification
questions, and a required human Claude Design step. SEO/JSON-LD says 24 skills
and software v1.4.0. Health returns v1.0.0. The web package is v0.1.0; the pack's
VERSION is v2.1.0 with 39 skills, seven agents, and Hermes v0.19+.

The site does not show the newer seven-agent CTO lifecycle. Its README is still
the generated Next.js starter document. The root advertises MIT but has no
LICENSE file, so its badge points to a missing file.

**Missing:** One versioned content manifest driving website counts, compatibility,
install snippets, metadata, and documentation; a license file; and documentation
of how the independent website repo follows pack releases.

### 17. Rendered fonts, theme, and interaction semantics need correction

Production browser evidence:

- `globals.css:10` defines `--font-sans: var(--font-sans)`, a self-reference.
  The computed sans variable is empty; html/body/h1/paragraphs use **Times**,
  despite Geist loading successfully. Code uses Geist Mono correctly.
- Clicking the theme toggle changes html to `light`, but the body background
  remains the same. Hardcoded dark zinc classes override the theme; some token
  components become light, producing inconsistent colors and weak text contrast.
- The theme button measures approximately **34.8 × 28 px**, below the project's
  required 44 × 44 touch target.
- Two CTAs render buttons inside links, creating nested interactive elements.
- `npm run lint` fails on synchronous setState in ThemeToggle's effect and warns
  about unused imports in Hero and Nav.
- Next.js infers `/Users/user` as the workspace root from an unrelated lockfile.
  The production build still passes, but explicit project-root configuration is
  missing.

**Fix:** Bind sans to the actual Geist variable, use semantic theme tokens or
remove the toggle, render CTAs as single links, enlarge touch targets, address
lint, and configure the build root. Preserve the mobile layout that already fits.

## Recommended delivery order

1. **Make installation trustworthy:** fix discovery layout, optional-env setup,
   canonical install instructions, failure exit codes, and add behavior tests.
2. **Protect operator state:** eliminate shell-sourced metadata, fix update and
   cron scoping, preserve user profile data, and secure recovery/logging.
3. **Make shipping reviewable:** distinguish preview/production, bind approvals
   to commits and projects, record known-good rollback targets, verify CLI recipes.
4. **Prove the lifecycle:** run an inexpensive end-to-end sample through actual
   Hermes discovery, configured roles, bounded build delegation, preview review,
   an explicit release gate, notification receipt, and a tested restore.
5. **Synchronize and repair the website:** update its content, dependencies,
   font/theme/accessibility behavior, and give its own CI build/lint/browser checks.

Do not add more roles, skills, a custom database, or a dashboard until these
paths work. The main missing capability is verified integration between the
existing pieces, rather than another set of instructions.

## Limits and artifacts

Live Hermes execution, deployment authorization, notification receipt, paid
creative providers, hosted database migrations/RLS, and backup restoration remain
unverified. Dependency findings need reachability review. Upstream source was
read from current main on the audit date and can change.

Temporary diagnostic scripts: `/tmp/omh-audit-checks.py`,
`/tmp/omh-extra-checks.py`, `/tmp/omh-browser-check.py`, `/tmp/omh-font-check.py`.
Temporary audit output: `/tmp/omh-skill-validation.log`,
`/tmp/omh-npm-audit.json`. Browser captures: `/tmp/omh-mobile-dark.png` and
`/tmp/omh-mobile-light.png`. These are local diagnostic artifacts and are not
required to read the findings above.
