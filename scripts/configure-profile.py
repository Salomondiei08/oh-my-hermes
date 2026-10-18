#!/usr/bin/env python3
"""Bind an OMH role to Hermes's loaded identity without replacing custom identity."""
import os
from pathlib import Path
import sys
import tempfile

if len(sys.argv) != 3 or sys.argv[2] not in ('cto', 'pm', 'designer', 'dev', 'qa', 'ops', 'security'):
    raise SystemExit('[ERROR] Expected Hermes home and a supported OMH role')
home, agent = Path(sys.argv[1]).resolve(), sys.argv[2]
profile = home / 'profiles' / agent
if any(path.is_symlink() for path in (home / 'profiles', profile, profile / 'skills')):
    raise SystemExit('[ERROR] Refusing symlinked profile directories')
if not profile.is_dir():
    raise SystemExit(f'[ERROR] Profile directory missing: {profile}')
soul = profile / 'SOUL.md'
if soul.is_symlink():
    raise SystemExit('[ERROR] Refusing to modify a symlinked SOUL.md')
text = soul.read_text() if soul.exists() else ''
begin, end = '<!-- BEGIN OH MY HERMES ROLE -->', '<!-- END OH MY HERMES ROLE -->'
if text.count(begin) != text.count(end) or text.count(begin) > 1:
    raise SystemExit('[ERROR] Ambiguous OMH role markers; preserve and inspect SOUL.md manually')
block = begin + '\n' + (home / 'agents' / f'{agent}.md').read_text().strip() + '\n' + end
if begin in text:
    start, stop = text.index(begin), text.index(end) + len(end)
    text = text[:start] + block + text[stop:]
else:
    text = text.rstrip() + '\n\n' + block + '\n'
skills = profile / 'skills'; skills.mkdir(exist_ok=True)
link = skills / 'oh-my-hermes'
target = (home / 'skills' / 'oh-my-hermes').resolve()
if not target.is_dir() or not target.is_relative_to(home):
    raise SystemExit('[ERROR] OMH catalog missing; run install.sh first')
if link.is_symlink():
    if link.resolve() != target:
        raise SystemExit('[ERROR] Existing profile catalog link has a different target; preserving it')
elif link.exists():
    raise SystemExit('[ERROR] Existing profile catalog is not an OMH link; preserving it')
else:
    link.symlink_to(target, target_is_directory=True)

fd, temporary = tempfile.mkstemp(dir=profile, prefix='.soul-')
with os.fdopen(fd, 'w') as handle:
    handle.write(text)
os.replace(temporary, soul)
