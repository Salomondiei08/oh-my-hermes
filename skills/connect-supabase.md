---
name: connect-supabase
description: Use when a Supabase project needs to be linked to the app for the first time, or when new migrations need to be pushed
version: 1.0.1
tags: [supabase, database, setup, migrations]
---

## When to Use

Only when the project actually uses Supabase and needs linking or migrations.

## Prerequisites

- Node.js 20+, npm and Supabase account/project; no global npm installation.
- Install CLI as a pinned project dev dependency: `npm install --save-dev --save-exact supabase`.
- Authenticated `npx supabase login`, intended project ref and securely available
  database credentials. Inspect `npx supabase --version` and command `--help`.

## Procedure

1. Run `npx supabase init` only if uninitialized, then
   `npx supabase link --project-ref <approved-project-ref>`. Verify the linked
   remote is the intended project/environment before any database mutation.
2. Add only variables this app uses to ignored owner-only `.env.local`, through
   secure input. Public URL/anon key do not grant elevated access; service-role
   key and DATABASE_URL stay server-only. Configure matching Vercel preview or
   production variables only for an approved target; never print secret values.
3. Create migrations with `npx supabase migration new <name>` and review SQL.
   Run `npx supabase db push --dry-run` and inspect the exact pending migration
   list. Test changes in a disposable/local database first. For destructive changes
   get explicit founder approval identifying project, environment, migration files,
   reviewed commit and recovery plan before pushing. Production changes require
   the project's production approval gate even when additive.
4. Only after the required approval, run `npx supabase db push` against the verified
   linked project. Capture exit status without logging credentials.
5. Verify hosted migration history with `npx supabase migration list --linked`:
   expected migration timestamps must appear in both local and remote columns.
   A matching list proves migration history, not schema correctness or RLS.
   Independently check the affected application flow and permitted/denied RLS cases
   with test identities. Save non-secret `{ projectRef, url, environment, commit,
   migrations, evidence }` under `project:<slug>:supabase-config`.

## Pitfalls

- Local status/diff does not verify hosted migrations.
- Never expose service-role credentials or put passwords in command-line URLs.
- History repair does not apply missing SQL; investigate discrepancies first.

## Verification

Hosted migration history matches reviewed migrations and the affected app/RLS
journey passes. Record checks not performed and stop on any failed push.

References: [CLI installation](https://supabase.com/docs/guides/local-development/cli/getting-started),
[migration history](https://supabase.com/docs/reference/cli/supabase-migration-list).
