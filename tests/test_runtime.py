"""Behavioral checks for state boundaries; all data and commands are disposable."""
from contextlib import closing
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RuntimeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='omh-runtime-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / 'hermes'
        self.home.mkdir()
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.env = dict(os.environ, HERMES_HOME=str(self.home), PATH=f'{self.bin}:/usr/bin:/bin:/usr/sbin:/sbin')
        for key in ('GITHUB_TOKEN', 'GITHUB_USERNAME', 'GITHUB_REPO', 'PRODUCTION_URL', 'PROJECT_SLUG'):
            self.env.pop(key, None)

    def run_script(self, name, *args):
        return subprocess.run(['bash', str(ROOT / 'scripts' / name), *args], env=self.env, text=True, capture_output=True, timeout=15)

    def stub_hermes(self):
        stub = self.bin / 'hermes'
        stub.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys
home=pathlib.Path(os.environ['HERMES_HOME']); a=sys.argv[1:]
if '--help' in a: sys.exit(0)
if a[:2]==['profile','list']: print('Profiles\\n--------\\n'+'\\n'.join(p.name for p in (home/'profiles').glob('*')))
elif a[:2]==['profile','create']:
 p=home/'profiles'/a[2];p.mkdir(parents=True);(p/'SOUL.md').write_text('Custom identity\\n')
elif a[:2]==['cron','list']:
 f=home/'jobs.json'; jobs=json.loads(f.read_text()) if f.exists() else []; print(json.dumps(jobs) if '--json' in a else '\\n'.join(j['name'] for j in jobs))
elif a[:2] in (['cron','pause'],['cron','resume']):
 f=home/'jobs.json';jobs=json.loads(f.read_text())
 for j in jobs:
  if j['name']==a[2]:j['enabled']=(a[1]=='resume')
 f.write_text(json.dumps(jobs))
elif a[:2] in (['cron','create'],['cron','add'],['cron','edit']):
 f=home/'jobs.json';jobs=json.loads(f.read_text()) if f.exists() else []
 name=a[a.index('--name')+1] if '--name' in a else a[2]
 jobs=[j for j in jobs if j['name']!=name];jobs.append({'name':name,'args':a});f.write_text(json.dumps(jobs))
''')
        stub.chmod(0o700)

    def install_setup_files(self):
        (self.home / 'agents').mkdir()
        for source in (ROOT / 'agents').glob('*.md'):
            (self.home / 'agents' / source.name).write_text(source.read_text())
        (self.home / 'skills' / 'oh-my-hermes').mkdir(parents=True)

    def test_project_updates_only_provided_values(self):
        self.assertEqual(self.run_script('project.sh', 'switch', 'app', '--repo', 'owner/old', '--url', 'https://old.example').returncode, 0)
        self.assertEqual(self.run_script('project.sh', 'switch', 'app', '--url', 'https://new.example').returncode, 0)
        self.assertEqual(self.run_script('project.sh', 'get', 'PRODUCTION_URL', 'app').stdout.strip(), 'https://new.example')
        self.assertEqual(self.run_script('project.sh', 'get', 'GITHUB_REPO', 'app').stdout.strip(), 'owner/old')
        self.assertEqual((self.home / 'projects/app.env').stat().st_mode & 0o777, 0o600)

    def test_untrusted_metadata_rejected_without_writes(self):
        result = self.run_script('project.sh', 'switch', 'app', '--repo', "owner/repo'; false; #")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home / 'projects/current').exists())
        self.assertNotEqual(self.run_script('project.sh', 'switch', '..').returncode, 0)

    def test_status_never_sources_legacy_metadata(self):
        project_dir = self.home / 'projects'; project_dir.mkdir()
        (project_dir / 'current').write_text('app\n')
        marker = self.base / 'executed'
        (project_dir / 'app.env').write_text(f"GITHUB_REPO='owner/repo'; touch '{marker}'\n")
        self.run_script('status.sh')
        self.assertFalse(marker.exists())

    def test_status_recognizes_saved_configuration_without_exposing_it(self):
        (self.home / '.env').write_text("OPENAI_API_KEY='FAKE_PRIVATE_CANARY'\n")
        result = self.run_script('status.sh')
        self.assertIn('configured (unverified)', result.stdout)
        self.assertNotIn('FAKE_PRIVATE_CANARY', result.stdout + result.stderr)

    def test_status_parses_multiline_hermes_version_and_hex_cron_headers(self):
        stub = self.bin / 'hermes'
        stub.write_text('''#!/usr/bin/env python3
import sys

args = sys.argv[1:]
if args == ['--version']:
    print('Hermes Agent v0.23.4 (2026.11.24)')
    print('Install directory: /tmp/hermes')
    print('Python: 3.14.7')
elif args == ['gateway', 'status']:
    print('✓ User gateway service is running')
elif args == ['config', 'show']:
    print('◆ Model')
    print("  Model:        {'default': 'gpt-5.6', 'provider': 'openai'}")
elif args == ['cron', 'list']:
    print('  a90e5409f105 [active]')
    print('    Name:      daily-digest')
    print('  1eb023350df1 [active]')
    print('    Name:      oh-my-hermes-daily-report')
    print('    Workdir:   /tmp/cron-work/oh-my-hermes-daily-report')
    print('  b089efa74ba0 [active]')
    print('    Name:      oh-my-hermes-security-weekly')
    print('    Workdir:   /tmp/cron-work/oh-my-hermes-security-weekly')
    print('  755751593750 [paused]')
    print('    Name:      paused-job')
''')
        stub.chmod(0o700)
        result = self.run_script('status.sh')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('Hermes         Hermes Agent v0.23.4 (2026.11.24)\n', result.stdout)
        self.assertNotIn('Install directory:', result.stdout)
        self.assertIn('Gateway        running\n', result.stdout)
        self.assertIn("Model          'default': 'gpt-5.6', 'provider': 'openai'\n", result.stdout)
        self.assertIn('Crons          4 visible (3 active, 1 paused)\n', result.stdout)

    def test_setup_optional_environment_and_two_projects(self):
        self.stub_hermes(); self.install_setup_files()
        for project in ('alpha', 'beta'):
            self.env.update(PROJECT_SLUG=project, GITHUB_REPO=f'owner/{project}', PRODUCTION_URL=f'https://{project}.example')
            result = self.run_script('setup-cto.sh')
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        jobs = json.loads((self.home / 'jobs.json').read_text())
        self.assertEqual(len(jobs), 12)
        for project in ('alpha', 'beta'):
            self.assertEqual(sum(f'oh-my-hermes-{project}-' in job['name'] for job in jobs), 6)
        soul = (self.home / 'profiles/cto/SOUL.md').read_text()
        self.assertIn('Custom identity', soul)
        self.assertIn('CTO', soul)
        self.assertTrue((self.home / 'profiles/cto/skills/oh-my-hermes').exists())

    def test_setup_rerun_reconciles_changed_url(self):
        self.stub_hermes(); self.install_setup_files()
        self.env.update(PROJECT_SLUG='app', PRODUCTION_URL='https://old.example')
        self.assertEqual(self.run_script('setup-cto.sh').returncode, 0)
        self.env['PRODUCTION_URL'] = 'https://new.example'
        self.assertEqual(self.run_script('setup-cto.sh').returncode, 0)
        jobs = json.loads((self.home / 'jobs.json').read_text())
        self.assertEqual(len(jobs), 3)
        self.assertIn('https://new.example', json.dumps(jobs))
        self.assertNotIn('https://old.example', json.dumps(jobs))

    def test_cleared_targets_pause_existing_jobs(self):
        self.stub_hermes(); self.install_setup_files()
        self.env.update(PROJECT_SLUG='app', GITHUB_REPO='owner/app', PRODUCTION_URL='https://old.example')
        self.assertEqual(self.run_script('setup-cto.sh').returncode, 0)
        self.env.update(GITHUB_REPO='', PRODUCTION_URL='')
        self.assertEqual(self.run_script('setup-cto.sh').returncode, 0)
        jobs = json.loads((self.home / 'jobs.json').read_text())
        self.assertEqual(sum(j.get('enabled', True) for j in jobs), 1)
        self.env.update(GITHUB_REPO='owner/app', PRODUCTION_URL='https://new.example')
        self.assertEqual(self.run_script('setup-cto.sh').returncode, 0)
        self.assertEqual(sum(j.get('enabled', True) for j in json.loads((self.home / 'jobs.json').read_text())), 6)

    def test_metadata_and_profile_parent_symlinks_are_refused(self):
        outside = self.base / 'outside'; outside.mkdir()
        (self.home / 'projects').symlink_to(outside)
        self.assertNotEqual(self.run_script('project.sh', 'switch', 'app').returncode, 0)
        self.assertEqual(list(outside.iterdir()), [])
        (self.home / 'profiles').mkdir()
        (self.home / 'profiles/cto').symlink_to(outside)
        result = subprocess.run(['python3', str(ROOT / 'scripts/configure-profile.py'), str(self.home), 'cto'], env=self.env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(outside.iterdir()), [])

    def test_failure_logs_are_private_unique_and_redacted(self):
        self.stub_hermes()
        for _ in range(2):
            result = self.run_script('run-cron-safe.sh', '--project', 'app', '--name', 'check', '--', 'bash', '-c', 'echo "Authorization: Bearer FAKE_PRIVATE_CANARY"; echo "api_key=FAKE_PRIVATE_CANARY"; exit 7')
            self.assertEqual(result.returncode, 7)
        logs = list((self.home / 'oh-my-hermes/dead-letter/app').glob('*.log'))
        self.assertEqual(len(logs), 2)
        for log in logs:
            self.assertNotIn('FAKE_PRIVATE_CANARY', log.read_text())
            self.assertEqual(log.stat().st_mode & 0o777, 0o600)
        self.assertNotEqual(self.run_script('run-cron-safe.sh', '--project', '../escape', '--', 'false').returncode, 0)

    def test_sqlite_backup_contains_wal_and_can_be_restored(self):
        database = sqlite3.connect(self.home / 'state.db')
        self.addCleanup(database.close)
        database.execute('pragma journal_mode=wal')
        database.execute('create table sample (value text)')
        database.execute("insert into sample values ('committed-wal')")
        database.commit()
        (self.home / '.env').write_text('FAKE_CREDENTIAL=placeholder\n')
        executable = self.home / 'scripts/tool.sh'; executable.parent.mkdir(); executable.write_text('#!/bin/sh\nexit 0\n'); executable.chmod(0o700)
        destination = self.base / 'backups'
        result = subprocess.run(['python3', str(ROOT / 'scripts/backup-runtime.py'), '--destination', str(destination)], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        import tarfile
        archive = next(destination.glob('*.tar.gz'))
        restored = self.base / 'restored'
        with tarfile.open(archive) as handle:
            handle.extractall(restored, filter='data')
        self.assertEqual((restored / 'hermes/scripts/tool.sh').stat().st_mode & 0o777, 0o700)
        restored_db = next(restored.rglob('state.db'))
        with closing(sqlite3.connect(restored_db)) as check:
            self.assertEqual(check.execute('pragma integrity_check').fetchone()[0], 'ok')
            self.assertEqual(check.execute('select value from sample').fetchone()[0], 'committed-wal')
        self.assertEqual(archive.stat().st_mode & 0o777, 0o600)

    def test_server_bootstrap_preserves_omitted_project_targets(self):
        import shutil
        self.stub_hermes()
        self.run_script('project.sh', 'switch', 'app', '--repo', 'owner/app', '--url', 'https://keep.example')
        checkout = self.base / 'checkout'; checkout.mkdir()
        (checkout / '.git').mkdir()
        for folder in ('scripts', 'skills', 'workflows', 'agents', 'templates'):
            shutil.copytree(ROOT / folder, checkout / folder)
        shutil.copy2(ROOT / 'install.sh', checkout / 'install.sh')
        git = self.bin / 'git'
        git.write_text('#!/bin/bash\nif [ "$3 $4" = "remote get-url" ]; then echo https://github.com/salomondiei08/oh-my-hermes; fi\nexit 0\n')
        git.chmod(0o700)
        self.env['OH_MY_HERMES_DIR'] = str(checkout)
        result = self.run_script('server-bootstrap.sh', '--project', 'app')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.run_script('project.sh', 'get', 'PRODUCTION_URL', 'app').stdout.strip(), 'https://keep.example')

    def test_telegram_identity_mismatch_preserves_credentials(self):
        import shutil
        self.stub_hermes()
        checkout = self.base / 'checkout'; checkout.mkdir(); (checkout / '.git').mkdir()
        for folder in ('scripts', 'skills', 'workflows', 'agents', 'templates'):
            shutil.copytree(ROOT / folder, checkout / folder)
        shutil.copy2(ROOT / 'install.sh', checkout / 'install.sh')
        git = self.bin / 'git'; git.write_text('#!/bin/bash\nif [ "$3 $4" = "remote get-url" ]; then echo https://github.com/salomondiei08/oh-my-hermes; fi\nexit 0\n'); git.chmod(0o700)
        mocks = self.base / 'mocks'; mocks.mkdir()
        (mocks / 'sitecustomize.py').write_text(
            'import io, urllib.request\n'
            'urllib.request.urlopen=lambda *a,**k: io.StringIO(\'{"ok":true,"result":{"username":"different_bot"}}\')\n'
        )
        self.env.update(OH_MY_HERMES_DIR=str(checkout), PYTHONPATH=str(mocks), TELEGRAM_BOT_TOKEN='FAKE_CANARY_TOKEN')
        (self.home / '.env').write_text('PRESERVE=existing\n')
        result = self.run_script('server-bootstrap.sh', '--telegram', '--telegram-bot', 'expected_bot')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.home / '.env').read_text(), 'PRESERVE=existing\n')
        self.assertNotIn('FAKE_CANARY_TOKEN', result.stdout + result.stderr)

    def test_reset_refuses_unknown_gateway_status(self):
        stub = self.bin / 'hermes'
        stub.write_text('#!/bin/bash\nif [ "$1 $2" = "gateway status" ]; then exit 1; fi\nexit 0\n')
        stub.chmod(0o700)
        (self.home / 'state.db').write_text('preserve me')
        self.env['HERMES_BACKUP_DIR'] = str(self.base / 'backups')
        self.assertNotEqual(self.run_script('reset-runtime.sh', '--yes').returncode, 0)
        self.assertTrue((self.home / 'state.db').exists())

    def test_reset_snapshots_before_moving_stopped_state_and_sidecars(self):
        stub = self.bin / 'hermes'
        stub.write_text('#!/bin/bash\necho "Gateway is not running"\nexit 0\n')
        stub.chmod(0o700)
        # Stub writer inventory only: the fixture has no real runtime processes.
        lsof = self.bin / 'lsof'; lsof.write_text('#!/bin/bash\nexit 1\n'); lsof.chmod(0o700)
        with closing(sqlite3.connect(self.home / 'state.db')) as db:
            db.execute('create table tasks (id integer)')
            db.execute('insert into tasks values (1)')
            db.commit()
        (self.home / 'state.db-wal').write_text('stale sidecar')
        (self.home / 'state.db-shm').write_text('stale sidecar')
        self.env['HERMES_BACKUP_DIR'] = str(self.base / 'backups')
        result = self.run_script('reset-runtime.sh', '--yes')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse((self.home / 'state.db').exists())
        moved = next(self.home.glob('reset-*'))
        self.assertTrue((moved / 'state.db-wal').exists())
        self.assertTrue((moved / 'state.db-shm').exists())
        self.assertTrue(list((self.base / 'backups').glob('*.tar.gz')))

    def test_reset_aborts_before_moving_data_when_stop_fails(self):
        stub = self.bin / 'hermes'; stub.write_text('#!/bin/bash\nexit 1\n'); stub.chmod(0o700)
        (self.home / 'state.db').write_text('preserve me')
        self.env['HERMES_BACKUP_DIR'] = str(self.base / 'backups')
        result = self.run_script('reset-runtime.sh', '--yes')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.home / 'state.db').read_text(), 'preserve me')


if __name__ == '__main__':
    unittest.main()
