#!/usr/bin/env bash
# Remove only unchanged files owned by this installation; retain all profile state.
set -euo pipefail
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
command -v python3 >/dev/null || { echo '[ERROR] python3 is required.'; exit 1; }
echo 'Oh My Hermes — uninstall unchanged owned files. Custom files and profiles are preserved.'
read -r -p 'Continue? [y/N] ' confirm
[[ "$confirm" = y || "$confirm" = Y ]] || { echo 'Cancelled.'; exit 0; }
python3 - "$HERMES_DIR" <<'PY'
import hashlib
import json
from pathlib import Path
import sys

home = Path(sys.argv[1]).resolve()
manifest = home / '.oh-my-hermes-manifest.json'
if manifest.is_symlink():
    sys.exit('[ERROR] Refusing symlinked ownership manifest.')
if not manifest.exists():
    print('[SKIP] No ownership manifest; no files removed. Legacy flat skills require manual review.')
else:
    owned = json.loads(manifest.read_text())
    retained = {}
    for relative, digest in owned.items():
        path = home / relative
        # An ownership manifest must never authorize deleting profiles or paths outside the install.
        if (Path(relative).is_absolute() or '..' in Path(relative).parts
                or Path(relative).parts[0] not in ('skills', 'workflows', 'agents', 'scripts', 'templates')
                or any(p.is_symlink() for p in (path, *path.parents) if p != home and home in p.parents)):
            print(f'[PRESERVED] Unsafe ownership path: {relative}')
            retained[relative] = digest
        elif path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest() == digest:
            path.unlink()
            print(f'[REMOVED] {relative}')
        elif path.exists():
            print(f'[PRESERVED] Modified: {relative}')
            retained[relative] = digest
    if retained:
        manifest.write_text(json.dumps(retained, indent=2) + '\n')
    else:
        manifest.unlink()
PY
echo 'Cron jobs for manual dependency review (no jobs are deleted):'
if command -v hermes >/dev/null; then
  hermes cron list || echo '[WARN] Could not list jobs; run hermes cron list manually.'
else
  echo 'Hermes CLI unavailable; run hermes cron list before removing dependent jobs manually.'
fi
