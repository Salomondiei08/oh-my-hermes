---
name: implement-with-codex
description: Use when choose-engine has routed to Codex for a targeted single-file or quick-fix task
version: 1.0.1
tags: [implementation, codex, coding]
---

## When to Use

choose-engine routed this task to Codex. Preserve docs/engines.md routing defaults.

## Prerequisites

- Authenticated installed CLI; Python 3 for a portable process deadline.
- Trusted project directory, AGENTS.md, selected slug and specific acceptance criteria.
- Inspect `codex exec --help` and CLI version without making a model call. Verify every
  flag below exists in that installed version; if not, stop with the capability
  mismatch rather than silently invoking interactive mode or removing safeguards.

## Procedure

1. Retrieve only relevant non-secret project memory using `project:<slug>:<key>`,
   including requirements, product brief, design and implementation spec.
   Write a self-contained prompt to an owner-only file outside tracked source.
   Include task, allowed paths, acceptance checks and expected artifacts; require
   reading AGENTS.md, preserving unrelated work, and never pushing/deploying or
   disclosing credentials. Record the starting HEAD and working-tree diff.
2. Use the existing Hermes terminal/tool permission boundary. Preconfigure narrowly
   authorized tools for unattended editing in the trusted checkout; denied tools
   are a blocked handoff, never permission to bypass approvals or sandboxing.
   Run noninteractively with a deadline and owner-only artifacts. Example launch
   from the verified project directory, with `handoff.txt` already prepared:
   ```python
   import json, os, pathlib, signal, subprocess, tempfile
   os.umask(0o077)
   project_dir = pathlib.Path.cwd().resolve()
   run = pathlib.Path(tempfile.mkdtemp(prefix="omh-handoff-"))
   # codex exec reads the prompt from stdin.
   command = ["codex", "exec", "--sandbox", "workspace-write", "--json", "--output-last-message", str(run / "result.md"), "-"]
   with open("handoff.txt") as prompt, (run / "stdout").open("w") as out, (run / "stderr").open("w") as err:
       proc = subprocess.Popen(command, cwd=project_dir, stdin=prompt,
                               stdout=out, stderr=err, start_new_session=True)
       timed_out = False
       try:
           returncode = proc.wait(timeout=900)
       except subprocess.TimeoutExpired:
           timed_out = True
           os.killpg(proc.pid, signal.SIGTERM)
           try:
               proc.wait(timeout=10)
           except subprocess.TimeoutExpired:
               os.killpg(proc.pid, signal.SIGKILL)
               proc.wait()
           # A child may survive after the CLI leader exits.
           try:
               os.killpg(proc.pid, signal.SIGKILL)
           except ProcessLookupError:
               pass
           returncode = 124
   (run / "status.json").write_text(json.dumps({"returncode": returncode, "timed_out": timed_out}))
   print(run)
   raise SystemExit(returncode)
   ```
   Keep raw artifacts private; do not paste stdout/stderr or credentials into memory
   or notifications. A timeout/nonzero exit is failure, even if some files changed.
3. Inspect the artifact and diff; require nonempty result.md and valid JSONL events.
   Run independent acceptance tests, build/type checks appropriate to the actual
   stack, and verify requested behavior. CLI success and its narrative are not proof.
4. Review changed paths and staged diff for secrets and unrelated changes. Commit
   only the reviewed scoped result when authorized by project conventions. Record
   commit, artifact location, exit status and independent evidence in
   `project:<slug>:implementation-[feature-name]` and the existing Hermes task.
   On failure attach a sanitized summary and mark blocked; do not ask the founder
   to paste the handoff manually or claim completion from a confirmation alone.

## Pitfalls

- Engine context does not include Hermes memory; explicitly pass relevant context.
- Authentication can be subscription or API-key based; do not print credentials.
- Noninteractive permission failures require configuration or a narrower task.

## Verification

Bounded invocation exited zero, a result artifact exists, independent acceptance
checks pass, and the reviewed diff is scoped and credential-free.

Reference: [Codex noninteractive execution](https://github.com/openai/codex/blob/main/docs/exec.md).
