# Audit repairs — 2026-10-18

This records repairs to `repository-audit-2026-10-14.md`. The historical report is
unchanged. These are source repairs and disposable-environment checks, not a
production deployment or proof of an autonomous paid build/release cycle.

## Changes

| Audit area | Repair and evidence |
|---|---|
| Skill discovery | Install expands 39 flat source files into namespaced `SKILL.md` directories; real upstream catalog/load check passes |
| Optional GitHub setup | Unset variables have defaults; setup performs no model calls; existing project metadata is read as data |
| Metadata command execution | Strict repo/URL parsing, no shell sourcing, atomic metadata writes; malicious/symlink cases rejected |
| Multiple projects | Project-scoped cron names/workdirs; reruns edit/resume jobs, cleared targets pause them; memory procedures use scoped keys |
| Unsafe uninstall | Ownership hashes remove only unchanged installed files; all profiles/customizations retained; jobs listed for review |
| Release approval | Preview default; production requires approved repository/project/environment/exact SHA; merge trigger is gated too |
| Rollback state | One environment-specific record keeps current and distinct previous healthy immutable deployment targets |
| Failure logs | Unique owner-only failure metadata; raw arguments/output deliberately discarded rather than incompletely redacted |
| Recovery | SQLite online backup/integrity checks, private archive, restored executable bits; reset checks stopped status/open writers and moves WAL/SHM with DB |
| Installer/CI validation | Nonzero verification failure; install-only vs setup checks; real YAML parsing; behavior tests replace file-only confidence |
| Profiles/handoffs | Managed role section in loaded SOUL.md preserves custom identity; catalog linked per profile; noninteractive engine snippets have deadlines/outcome evidence |
| Bootstrap | Existing Next.js app/src-app layout detected; unsupported/ambiguous projects refused; gitignore protects secrets; shipped templates used |
| Provider checks | Supabase installation/migration commands corrected; optional stack checks and bounded HTTP checks; JSON-safe notifications |
| Website content | One web release manifest drives 39 skills, seven roles, version, compatibility, metadata, health and checkout-based install snippet |
| Website UI | Geist token corrected; semantic light/dark tokens; 44 px targets; single-interactive CTAs; lint and browser regressions |
| Dependencies | Production audit has zero findings after compatible updates; five high findings remain in one development-only lint/glob chain |
| Documentation | Installation, state/approval contracts, release notes, and missing MIT license updated |

## Verification

- `python3 -m unittest discover -s tests -v`: **33 tests pass**. All data,
  credentials, Hermes commands and account calls in these tests are disposable or
  stubbed. Tests cover install/customization/uninstall, metadata injection and
  updates, cron scope/clear/resume, profile safety, notification encoding, engine
  deadlines, SQLite WAL restore/integrity/modes, failed/unknown reset stops, omitted
  bootstrap metadata and bot-identity mismatch.
- `bash scripts/validate-skills.sh`: **39 skills, zero failures**. Uses Ruby's
  standard-library safe YAML parser. Local inline file links are checked; remote
  URLs, anchors and reference-style links are explicitly outside this validator.
- All **14 shell entrypoints** pass `bash -n`.
- Disposable `python:3.12-slim` container installed upstream Hermes at
  `e6cf2a9b1e8f98d40408b09a9a55993c8459b4b4`, installed this pack in a temporary
  HERMES_HOME, and passed install verification (**68 checks, zero failures**).
  Upstream `_find_all_skills` discovered all **39** skills, and `skill_view` loaded
  each successfully. No credentials, model calls, live gateway or external
  messages were used. Reusable assertion: `tests/check_hermes_catalog.py`.
- Separate website repository commit `ca6567d`: lint and TypeScript pass,
  production webpack build passes, Chrome regression passes in both themes at
  **320/375/480/1280 px**, including computed fonts, contrast, 44 px targets,
  nested controls, overflow, theme persistence and release facts.

## Operational boundaries

- Pack install requires Python 3.9+; restore rehearsal/tests use Python 3.12+.
  Source validation requires Ruby/YAML. Reset requires `lsof` and known stopped
  gateway state. CLI sessions must also be closed; the open-file check cannot
  prevent someone starting another writer afterward.
- Existing unmanifested installs and legacy unscoped cron jobs require manual
  comparison. The installer preserves unowned files rather than guessing they are
  safe to overwrite. Inspect preserved collisions before relying on an upgrade.
- Profile model credentials, actual model execution, cron delivery, hosted
  migrations/RLS, remote encrypted restore and a real preview/production rollback
  remain unverified. Each requires the applicable account configuration and gates.
- Dead letters deliberately omit command/output content. Inspect failures locally
  and send a reviewed summary through the notification skill.
- Website default Turbopack build hit the Mac host's internal port restriction;
  supported webpack production build and served-browser verification succeeded.
  Hosted CI is added but has not run because no Git push was authorized.
- Five remaining website high dependency findings are development-only,
  inherited through the lint/glob chain; see the nested `DEPENDENCY_REVIEW.md`.
  No website request path was identified for those findings. They remain debt.
- The website is an independent nested Git repository; it is not silently added
  to the parent repository or published by this change.
