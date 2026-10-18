#!/usr/bin/env bash
set -euo pipefail
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo '[ERROR] python3 is required.'; exit 1; }
[ -d "$HERMES_DIR" ] || { echo "[ERROR] Hermes home missing: $HERMES_DIR. Install Hermes Agent first."; exit 1; }
for directory in skills workflows agents scripts templates; do
  [ -d "$SCRIPT_DIR/$directory" ] || { echo '[ERROR] Run install.sh from a full Oh My Hermes checkout.'; exit 1; }
done
python3 - "$SCRIPT_DIR" "$HERMES_DIR" <<'PY'
import hashlib
import json
from pathlib import Path
import shutil
import sys

source, home = (Path(arg).resolve() for arg in sys.argv[1:])
manifest = home / '.oh-my-hermes-manifest.json'
if manifest.is_symlink():
    sys.exit('[ERROR] Refusing symlinked ownership manifest.')
owned = json.loads(manifest.read_text()) if manifest.exists() else {}
files = [(p, Path('skills/oh-my-hermes') / p.stem / 'SKILL.md') for p in sorted((source / 'skills').glob('*.md'))]
for directory in ('workflows', 'agents', 'scripts', 'templates'):
    files.extend((p, p.relative_to(source)) for p in sorted((source / directory).rglob('*'))
                 if p.is_file() and (directory != 'scripts' or p.suffix in ('.sh', '.py')))
installed = 0
for src, relative in files:
    dest = home / relative
    key = relative.as_posix()
    # Never follow a user-owned symlink while installing managed files.
    if any(p.is_symlink() for p in (dest, *dest.parents) if p != home and home in p.parents):
        print(f'[PRESERVED] {relative}: symlink')
        continue
    if dest.exists() and (not dest.is_file() or hashlib.sha256(dest.read_bytes()).hexdigest() != owned.get(key)):
        print(f'[PRESERVED] {relative}: customized or unowned')
        continue
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)
    dest.chmod(0o700 if relative.parts[0] == 'scripts' else 0o600)
    owned[key] = hashlib.sha256(dest.read_bytes()).hexdigest()
    installed += 1
manifest.write_text(json.dumps(owned, indent=2) + '\n')
manifest.chmod(0o600)
print(f'[OK] Installed {installed} files in {home}. Existing custom files were preserved.')
print(f'Verify: bash {home}/scripts/verify.sh')
print(f'Bootstrap: cd YOUR_NEXTJS_PROJECT && bash {home}/scripts/bootstrap.sh')
PY
