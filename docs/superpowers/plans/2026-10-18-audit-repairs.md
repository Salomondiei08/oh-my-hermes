# Audit repairs implementation plan

**Goal:** Repair the reproducible failures in the October 14 audit without adding a second runtime or deploying changes.
**Spec:** `docs/repository-audit-2026-10-14.md` and the user's approval to proceed.
**Architecture:** Keep shell entrypoints, Hermes state, the flat source skill files, and the separate website repository. Use Python's standard library only where safe parsing, atomic writes, SQLite backup, or subprocess deadlines require it.

## Scope and ownership

- Distribution: installer, verifier, smoke/format checks, bootstrap, uninstall, templates, CI; ownership hashes protect user edits.
- Operations: project metadata/status, profile setup, project-specific cron jobs, failure logging, backup/reset.
- Procedures: skills and workflows for scoped state, preview/release approval, rollback, bounded coding handoff, provider checks.
- Website: canonical content, existing brand tokens, two accessible themes, font/touch/link fixes, dependency upgrades, build/lint/browser validation.
- Docs: installation and state contracts, release notes, license, audit-resolution ledger. Keep documentation commits separate from skill changes.

## Review focus

1. Malformed metadata must fail before writes and must never execute as shell.
2. Existing user files, profile credentials, custom instructions, and unknown cron jobs survive install/update/uninstall.
3. Two products have independent jobs and records; a changed target must not silently keep an old prompt.
4. Backup includes committed WAL data; reset refuses failed stops and preserves the backup before moving state.
5. Website correctness is verified from rendered output in both themes at 320–480 px, not only source/build.

## Execution and checks

- [x] Add failing `unittest` reproductions for distribution and operations; run each before fixing its root cause.
- [x] Install into temporary HERMES_HOME; verify catalog layout and custom-file preservation across reruns/uninstall.
- [x] Validate metadata and read it as data; atomically update only supplied values.
- [x] Configure profile roles through the documented loaded identity surface, preserve custom content, link the owned catalog, and explicitly report model setup still needed.
- [x] Scope named jobs by project. Use the current Hermes CLI's supported edit/create commands; fail clearly if it cannot reconcile targets.
- [x] Make dead-letter files private and unique and never persist raw arguments or unredacted output.
- [x] Use SQLite online backups for snapshots, verify database integrity, rehearse restore in an empty directory; stop and verify writers before reset.
- [x] Repair procedural contracts and verify them with focused tests and official CLI docs.
- [x] Repair the website, run typecheck/lint/build/browser checks and audit dependencies without force updates.
- [x] Run the combined local suite, inspect staged diffs for unintended files, commit meaningful changes separately, and mirror with rsync --update after inspecting server layout.

No push, live gateway change, production release, paid generation, or external message is part of this repair.

Live provider/deployment checks remain outside this approved source repair; see the audit-resolution ledger for limits.
