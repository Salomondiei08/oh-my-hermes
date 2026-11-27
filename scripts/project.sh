#!/usr/bin/env bash
# Keep metadata as validated data; never source project files as shell code.
set -euo pipefail
command -v python3 >/dev/null || { echo '[ERROR] python3 is required' >&2; exit 1; }
exec python3 - "$@" <<'PY'
import argparse
import os
from pathlib import Path
import re
import sys
import tempfile
from urllib.parse import urlsplit

home = Path(os.environ.get('HERMES_HOME', str(Path.home() / '.hermes'))).resolve()
projects = home / 'projects'
keys = ('GITHUB_REPO', 'PRODUCTION_URL')


def slug(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', value) or value in ('.', '..'):
        raise ValueError('project slug must start with a letter or digit and contain only letters, digits, dot, underscore or dash')
    return value


def current():
    path = projects / 'current'
    if projects.is_symlink() or path.is_symlink():
        raise ValueError('refusing symlinked project metadata')
    return slug(path.read_text().strip()) if path.exists() else 'default'


def validate(key, value):
    if not value:
        return
    if key == 'GITHUB_REPO':
        if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', value):
            raise ValueError('repo must be owner/repo')
    else:
        parsed = urlsplit(value)
        if (parsed.scheme not in ('https', 'http') or not parsed.hostname or parsed.username
                or parsed.password or any(c.isspace() or c in "'\"`$\\" for c in value)):
            raise ValueError('production URL must be an http(s) URL without credentials, whitespace or shell metacharacters')
        parsed.port  # Reject malformed ports before persisting anything.


def load(name):
    path = projects / f'{slug(name)}.env'
    if projects.is_symlink() or path.is_symlink():
        raise ValueError('refusing symlinked project metadata')
    values = {}
    if path.exists():
        for line in path.read_text().splitlines():
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            match = re.fullmatch(r"(GITHUB_REPO|PRODUCTION_URL)=(?:'([^']*)'|\"([^\"]*)\"|([^'\"]*))", line)
            if not match or match[1] in values:
                raise ValueError(f'invalid project metadata in {path}; inspect it as text, never source it')
            value = next(v for v in match.groups()[1:] if v is not None)
            validate(match[1], value)
            values[match[1]] = value
    return values


def write(path, text):
    if projects.is_symlink() or path.is_symlink():
        raise ValueError(f'refusing symlink metadata: {path}')
    projects.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, temporary = tempfile.mkstemp(dir=projects, prefix='.project-')
    try:
        with os.fdopen(fd, 'w') as handle:
            handle.write(text)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


parser = argparse.ArgumentParser(description='Select a product and read its validated metadata.')
commands = parser.add_subparsers(dest='command', required=True)
switch = commands.add_parser('switch'); switch.add_argument('slug'); switch.add_argument('--repo'); switch.add_argument('--url', '--production-url', dest='url')
commands.add_parser('current'); commands.add_parser('list')
for name in ('env-path', 'get'):
    command = commands.add_parser(name)
    if name == 'get':
        command.add_argument('key', choices=keys)
    command.add_argument('slug', nargs='?')
args = parser.parse_args()
try:
    if args.command == 'switch':
        name = slug(args.slug)
        if (projects / 'current').is_symlink():
            raise ValueError('refusing symlinked project metadata')
        values = load(name)
        for key, value in zip(keys, (args.repo, args.url)):
            if value is not None:
                validate(key, value)
                values[key] = value
        write(projects / f'{name}.env', ''.join(f"{key}='{value}'\n" for key, value in values.items()))
        write(projects / 'current', name + '\n')
        print(f'[OK] Current project: {name}')
    elif args.command == 'current':
        print(current())
    elif args.command == 'list':
        for path in sorted(projects.glob('*.env')):
            print(slug(path.stem))
    else:
        name = slug(args.slug) if args.slug else current()
        if args.command == 'env-path':
            print(projects / f'{name}.env')
        else:
            print(load(name).get(args.key, ''))
except (OSError, ValueError) as error:
    print(f'[ERROR] {error}', file=sys.stderr)
    sys.exit(2)
PY
