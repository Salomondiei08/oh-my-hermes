---
name: deploy-to-vercel
description: Use when implementation is complete and the project needs to be deployed or redeployed to Vercel
version: 1.0.1
tags: [deployment, vercel, ops]
---

## When to Use

Implementation is ready for a Vercel preview, or an explicitly approved production release.

## Prerequisites

- Installed authenticated Vercel CLI; check `vercel --version` and `vercel deploy --help`.
- Selected project slug, repository, working directory, Vercel team/project and environment.
- Clean committed source, ignored secrets, passing build and acceptance checks.

## Procedure

1. Resolve slug using `${HERMES_HOME:-$HOME/.hermes}/scripts/project.sh current`.
   Read metadata with `project.sh get GITHUB_REPO <slug>` and `project.sh get PRODUCTION_URL <slug>`;
   never source the project metadata file. Inspect `.vercel/project.json` and
   `git remote get-url origin` to verify the selected repository and project.
2. Record immutable commit with `git rev-parse HEAD`; ensure `git status --porcelain`
   is empty. Run the project's build and required checks.
3. Preview is the default. Link the intended project if needed, inspect its identity,
   then run from the verified directory:
   ```bash
   vercel deploy
   ```
   Capture the returned immutable deployment URL and run `vercel inspect <url>`.
   Verify project, environment, deployment ID and source commit; never infer them
   from an alias. Persist the deployment record in step 5 before health checks.
4. Production requires Security/Reviewer evidence and explicit founder approval
   identifying repository, project, environment=production and exact reviewed SHA.
   Persist that approval in `project:<slug>:pending-approval`. Immediately before
   release, compare HEAD and clean-tree state with the approved commit, re-check
   the linked Vercel target and required checks. Any mismatch invalidates approval.
   Only then run `vercel deploy --prod`. Never enable production Git auto-deploy
   as a shortcut around the same approval gate; approve the exact merge result
   before any merge or push that triggers production.
5. Save a record in Hermes memory at `project:<slug>:deployment:<env>`:
   `{ repository, project, environment, current: { id, url, commit, timestamp,
   healthStatus }, previousHealthy: { id, url, commit, timestamp,
   healthStatus: "healthy" } | null }`. Preserve the prior healthy current as
   previousHealthy when replacing current. If prior current is unhealthy, retain
   the existing previousHealthy. A new deployment starts with healthStatus=unknown;
   do not claim it is known-good until followup passes. Preserve the record before
   health checks so incident recovery can identify a failed new release.
6. Run `post-deploy-followup` for the captured ID/URL and environment.

## Pitfalls

- CLI success is not application health. Failed health must not erase previousHealthy.
- A deployment URL or branch name alone does not establish the approved commit.
- Git integration can release on merge: gate that trigger before executing it.

## Verification

Preview is healthy; production has exact-SHA approval and verified target metadata.
The environment record retains distinct current and previousHealthy IDs where available.

Command references: [deploy](https://vercel.com/docs/cli/deploying-from-cli),
[inspect](https://vercel.com/docs/cli/inspect). Verify installed CLI help before use.
