#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(pwd -P)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMH_DIR="$(dirname "$SCRIPT_DIR")"
command -v python3 >/dev/null || { echo '[ERROR] python3 is required.'; exit 1; }
[ "$PROJECT_DIR" != "$OMH_DIR" ] || { echo '[ERROR] Run bootstrap.sh from your application directory.'; exit 1; }
python3 - "$PROJECT_DIR" "$OMH_DIR/templates" <<'PY'
import json
from pathlib import Path
import sys

project, templates = map(Path, sys.argv[1:])
try:
    package = json.loads((project / 'package.json').read_text())
except (OSError, ValueError) as error:
    sys.exit(f'[ERROR] A Next.js App Router project with package.json is required: {error}')
dependencies = {**package.get('dependencies', {}), **package.get('devDependencies', {})}
routers = [path for path in (project / 'app', project / 'src/app') if path.is_dir()]
if 'next' not in dependencies or len(routers) != 1:
    sys.exit('[ERROR] Unsupported or ambiguous framework. Require Next.js and exactly one existing app/ or src/app/ directory.')
required = [templates / 'AGENTS.md.template', templates / 'healthcheck/nextjs-health-route.ts']
if not all(path.is_file() for path in required):
    sys.exit('[ERROR] Bootstrap templates are missing; reinstall from the full checkout.')
files = {
    project / 'AGENTS.md': required[0].read_text(),
    routers[0] / 'api/health/route.ts': required[1].read_text(),
    project / '.env.example': '# App\nNEXT_PUBLIC_APP_URL=http://localhost:3000\nNODE_ENV=development\n\n# Supabase\nSUPABASE_URL=your-supabase-project-url\nSUPABASE_ANON_KEY=your-supabase-anon-key\nSUPABASE_SERVICE_KEY=your-supabase-service-role-key\nDATABASE_URL=postgresql://postgres:[password]@[host]:5432/postgres\n\n# Vercel (for deployment skills)\nVERCEL_TOKEN=your-vercel-token\nVERCEL_ORG_ID=your-vercel-org-id\nVERCEL_PROJECT_ID=your-vercel-project-id\n\n# Notifications — at least one required for CTO loop alerts\nSLACK_WEBHOOK_URL=your-slack-webhook-url\n# Telegram: create bot via @BotFather, get chat ID by messaging @userinfobot\nTELEGRAM_BOT_TOKEN=your-telegram-bot-token\nTELEGRAM_CHAT_ID=your-telegram-chat-id\n\n# Monitoring\nSENTRY_DSN=your-sentry-dsn\n',
}
# Validate all destinations before writing; do not follow symlinks into another project.
for path in (*files, project / '.gitignore'):
    if any(parent.is_symlink() for parent in (path, *path.parents) if parent != project and project in parent.parents):
        sys.exit(f'[ERROR] Refusing symlinked bootstrap destination: {path}')
for path, content in files.items():
    if path.exists():
        print(f'[SKIP] {path.relative_to(project)} already exists')
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        print(f'[CREATED] {path.relative_to(project)}')
ignore = project / '.gitignore'
existing = ignore.read_text() if ignore.exists() else ''
rules = ['.env*', '!.env.example', 'node_modules/', '.next/', '*.pem', '*.key']
missing = [rule for rule in rules if rule not in existing.splitlines()]
if missing:
    with ignore.open('a') as handle:
        handle.write(('\n' if existing and not existing.endswith('\n') else '') + '\n'.join(missing) + '\n')
    print('[UPDATED] .gitignore secret and build exclusions')
print('[OK] Bootstrap complete. Fill in AGENTS.md and .env.example.')
PY
