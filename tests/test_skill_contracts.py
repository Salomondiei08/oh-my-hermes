"""Guard operational instructions at release and handoff trust boundaries."""
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class SkillContracts(unittest.TestCase):
    def skill(self, name):
        return (ROOT / 'skills' / f'{name}.md').read_text()

    def test_deploy_and_rollback_share_environment_record(self):
        for name in ('deploy-to-vercel', 'rollback', 'post-deploy-followup', 'health-check'):
            self.assertIn('project:<slug>:deployment:<env>', self.skill(name), name)
        for name in ('deploy-to-vercel', 'rollback'):
            for field in ('previousHealthy', 'commit', 'project', 'environment'):
                self.assertIn(field, self.skill(name), name)
        self.assertIn('vercel deploy\n', self.skill('deploy-to-vercel'))
        deploy = self.skill('deploy-to-vercel')
        self.assertEqual(1, deploy.count('Run `post-deploy-followup`'))
        self.assertLess(deploy.index('5. Save a record'), deploy.index('6. Run `post-deploy-followup`'))
        self.assertIn('distinct', self.skill('rollback'))
        self.assertIn('Never promote the broken release', self.skill('rollback'))

    def test_merge_is_bound_to_current_sha(self):
        text = self.skill('await-merge-approval')
        self.assertIn('headRefOid', text)
        self.assertIn('--match-head-commit', text)
        self.assertIn('project:<slug>:pending-approval', text)

    def test_handoffs_are_bounded_noninteractive(self):
        for name, command in (('implement-with-codex', 'codex exec'), ('implement-with-claude-code', 'claude -p')):
            text = self.skill(name)
            for token in (command, '--help', 'timeout=900', 'returncode', 'independent'):
                self.assertIn(token, text, name)
            self.assertNotIn('ask user to confirm expected output exists', text)

    def test_discovery_backup_and_hosted_checks(self):
        self.assertIn('skills/oh-my-hermes/<name>/SKILL.md', self.skill('create-skill'))
        self.assertIn('backup-runtime.py', self.skill('backup-hermes-data'))
        self.assertIn('restore rehearsal', self.skill('backup-hermes-data'))
        self.assertIn('filter="data"', self.skill('backup-hermes-data'))
        self.assertIn('root `hermes/`', self.skill('backup-hermes-data'))
        self.assertIn('no automatic redaction guarantee or automatic notification', self.skill('failure-recovery'))
        text = self.skill('connect-supabase')
        self.assertNotIn('npm install -g supabase', text)
        self.assertIn('migration list --linked', text)
        self.assertIn('db push --dry-run', text)
        self.assertIn('--max-time', self.skill('health-check'))

    def test_no_legacy_global_project_keys(self):
        import re
        keys = ('github-repo', 'current-task', 'pending-approval', 'log-observer-state',
                'notification-log', 'monitoring-config', 'deployment-log', 'ops-health-log',
                'last-deployment', 'last-deployment-url', 'triage-last-run')
        for folder in ('skills', 'workflows'):
            for path in (ROOT / folder).glob('*.md'):
                for key in keys:
                    self.assertNotRegex(path.read_text(), rf'`{re.escape(key)}`', str(path))



class ProcedureExamples(unittest.TestCase):
    """Execute handoff and notification examples against local fakes, never providers."""

    def python_example(self, name):
        import re
        text = (ROOT / 'skills' / f'{name}.md').read_text()
        import textwrap
        return textwrap.dedent(re.search(r'```python\n(.*?)\n *```', text, re.S).group(1))

    def test_handoffs_capture_success_and_nonzero_exit(self):
        import os
        import subprocess
        import tempfile
        for skill, cli in (('implement-with-codex', 'codex'), ('implement-with-claude-code', 'claude')):
            for status in (0, 7):
                with self.subTest(skill=skill, status=status), tempfile.TemporaryDirectory() as temp:
                    directory = pathlib.Path(temp)
                    (directory / 'handoff.txt').write_text('A bounded local fake task')
                    fake = directory / cli
                    fake.write_text('#!/usr/bin/env python3\nimport sys\nsys.stdin.read()\n'
                                    'if "--output-last-message" in sys.argv:\n'
                                    '    open(sys.argv[sys.argv.index("--output-last-message") + 1], "w").write("done")\n'
                                    'print(\'{"is_error": false, "result": "done"}\')\n'
                                    f'raise SystemExit({status})\n')
                    fake.chmod(0o700)
                    env = dict(os.environ, PATH=str(directory) + os.pathsep + os.environ['PATH'], TMPDIR=temp)
                    result = subprocess.run(['python3', '-c', self.python_example(skill)], cwd=temp,
                                            env=env, capture_output=True, text=True, timeout=10)
                    self.assertEqual(status, result.returncode, result.stderr)
                    artifact = pathlib.Path(result.stdout.strip())
                    import json
                    self.assertEqual(status, json.loads((artifact / 'status.json').read_text())['returncode'])
                    self.assertEqual(0, (artifact.stat().st_mode & 0o077))

    def test_handoff_deadline_records_timeout(self):
        import json
        import os
        import subprocess
        import tempfile
        for skill, cli in (('implement-with-codex', 'codex'), ('implement-with-claude-code', 'claude')):
            with self.subTest(skill=skill), tempfile.TemporaryDirectory() as temp:
                directory = pathlib.Path(temp)
                (directory / 'handoff.txt').write_text('A fake hung task')
                fake = directory / cli
                fake.write_text('#!/usr/bin/env python3\nimport time\ntime.sleep(60)\n')
                fake.chmod(0o700)
                env = dict(os.environ, PATH=str(directory) + os.pathsep + os.environ['PATH'], TMPDIR=temp)
                code = self.python_example(skill).replace('timeout=900', 'timeout=0.1')
                result = subprocess.run(['python3', '-c', code], cwd=temp, env=env,
                                        capture_output=True, text=True, timeout=5)
                self.assertEqual(124, result.returncode, result.stderr)
                artifact = pathlib.Path(result.stdout.strip())
                self.assertEqual({'returncode': 124, 'timed_out': True},
                                 json.loads((artifact / 'status.json').read_text()))

    def test_notification_serializes_plain_text_and_checks_telegram_result(self):
        import builtins
        import io
        import json
        from unittest.mock import mock_open, patch, MagicMock
        message = 'quoted "message"\n<tag> & backslash \\'
        for accepted in (True, False):
            response = MagicMock()
            response.__enter__.return_value = response
            response.status = 200
            response.read.return_value = json.dumps({'ok': accepted}).encode()
            with patch.dict('os.environ', {'TELEGRAM_BOT_TOKEN': 'fake-token', 'TELEGRAM_CHAT_ID': '123'}, clear=True), \
                 patch.object(builtins, 'open', mock_open(read_data=message)), \
                 patch('urllib.request.urlopen', return_value=response) as send, \
                 patch('sys.stdout', new_callable=io.StringIO), self.assertRaises(SystemExit) as result:
                exec(self.python_example('send-notification'), {})
            self.assertEqual(0 if accepted else 1, result.exception.code)
            payload = json.loads(send.call_args.args[0].data)
            self.assertEqual(message, payload['text'])
            self.assertNotIn('parse_mode', payload)


if __name__ == '__main__':
    unittest.main()
