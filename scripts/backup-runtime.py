#!/usr/bin/env python3
"""Create a private portable snapshot, using SQLite's online API for WAL databases."""
import argparse
from contextlib import closing
from datetime import datetime, timezone
import os
from pathlib import Path
import sqlite3
import sys
import tarfile
import tempfile


def backup(home, destination):
    """Snapshot a Hermes home; return an archive whose SQLite databases passed integrity checks."""
    home, destination = home.resolve(), destination.resolve()
    if not home.is_dir() or destination.is_relative_to(home):
        raise ValueError('Hermes home must exist and backup destination must be outside it')
    destination.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, temporary = tempfile.mkstemp(dir=destination, prefix='.hermes-', suffix='.tar.gz')
    os.close(fd)
    archive = Path(temporary)
    try:
        with tempfile.TemporaryDirectory(prefix='omh-snapshot-') as staging, tarfile.open(archive, 'w:gz') as output:
            for directory, folders, files in os.walk(home, followlinks=False):
                folders[:] = sorted(name for name in folders if name not in ('cache', '.cache', 'hermes-agent', '.git', '__pycache__') and not name.startswith('reset-'))
                for name in sorted(folders + files):
                    source = Path(directory) / name
                    if name.endswith(('-wal', '-shm')):
                        continue
                    relative = source.relative_to(home)
                    info = output.gettarinfo(str(source), arcname=str(Path('hermes') / relative))
                    info.uid = info.gid = 0
                    info.uname = info.gname = ''
                    info.mode = 0o700 if source.is_dir() or source.stat().st_mode & 0o100 else 0o600
                    if source.is_symlink():
                        target = source.resolve()
                        if not target.is_relative_to(home):
                            raise ValueError(f'external symlink cannot be restored safely: {relative}')
                        info.linkname = os.path.relpath(target, source.parent)
                        output.addfile(info)
                    elif source.is_dir():
                        output.addfile(info)
                    elif source.is_file():
                        with source.open('rb') as handle:
                            sqlite = handle.read(16) == b'SQLite format 3\x00'
                        if sqlite:
                            snapshot = Path(staging) / 'database.sqlite'
                            with closing(sqlite3.connect(source.as_uri() + '?mode=ro', uri=True, timeout=10)) as original, closing(sqlite3.connect(snapshot)) as copy:
                                original.backup(copy)
                                if copy.execute('pragma integrity_check').fetchall() != [('ok',)]:
                                    raise ValueError(f'database integrity check failed: {relative}')
                            info.size = snapshot.stat().st_size
                            with snapshot.open('rb') as handle:
                                output.addfile(info, handle)
                            snapshot.unlink()
                        else:
                            with source.open('rb') as handle:
                                output.addfile(info, handle)
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        final = destination / f'hermes-runtime-{stamp}.tar.gz'
        os.replace(archive, final)
        return final
    except BaseException:
        archive.unlink(missing_ok=True)
        raise


def main():
    """Run the snapshot CLI without printing credential-bearing file contents."""
    os.umask(0o077)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--destination', required=True, type=Path)
    args = parser.parse_args()
    home = Path(os.environ.get('HERMES_HOME', str(Path.home() / '.hermes')))
    try:
        print(backup(home, args.destination))
    except (OSError, ValueError, sqlite3.Error, tarfile.TarError) as error:
        print(f'[ERROR] Backup failed: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
