"""Exercise the test command with a fake Codex process, without model calls."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


COMMAND = Path(__file__).resolve().parents[1] / 'scripts/test-as-prose'
FAKE_CODEX = '''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
root = pathlib.Path(args[args.index('--cd') + 1])
prompt = sys.stdin.read()
(root / 'capture.json').write_text(json.dumps({'args': args, 'prompt': prompt}))
if os.environ.get('FAKE_OUTSIDE'):
    (root / 'AGENTS.md').write_text('unexpected edit')
elif not os.environ.get('FAKE_FAIL'):
    (root / 'projects/sample/main.py').write_text('"""Generated explanation."""\\nprint(1)\\n')
if not os.environ.get('FAKE_NO_MESSAGE'):
    pathlib.Path(args[args.index('--output-last-message') + 1]).write_text('Generated explanation; checks passed.')
print('INTERNAL REVIEW TRANSCRIPT')
sys.exit(7 if os.environ.get('FAKE_FAIL') else 0)
'''


class TestCommand(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        for folder in ['scripts', 'projects/sample', 'bin']:
            (self.root / folder).mkdir(parents=True)
        shutil.copy2(COMMAND, self.root / 'scripts/test-as-prose')
        (self.root / 'projects/sample/main.py').write_text('print(1)\n')
        (self.root / 'AGENTS.md').write_text('existing instructions\n')
        (self.root / '.gitignore').write_text('capture.json\n')
        fake = self.root / 'bin/codex'
        fake.write_text(FAKE_CODEX)
        fake.chmod(0o755)
        self.env = dict(os.environ, PATH=str(fake.parent) + os.pathsep + os.environ['PATH'])
        self.env.pop('PROSE_BENCH_RUNNER', None)
        for args in [
            ['init', '-q'], ['add', '.'],
            ['-c', 'user.name=Test', '-c', 'user.email=test@example.com', 'commit', '-qm', 'baseline'],
        ]:
            subprocess.run(['git', *args], cwd=self.root, check=True, capture_output=True)
        self.runs = []

    def tearDown(self):
        for run in self.runs:
            shutil.rmtree(run)
        self.temp.cleanup()

    def invoke(self, *targets, **settings):
        result = subprocess.run(
            [sys.executable, str(self.root / 'scripts/test-as-prose'), *targets],
            cwd=self.root, env=dict(self.env, **settings), text=True, capture_output=True,
        )
        if result.stdout:
            report = json.loads(result.stdout)
            self.runs.append(report['run_directory'])
            return result, report
        return result, None

    def test_fresh_runs_return_output_and_actual_changes(self):
        result, report = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        captured = json.loads((self.root / 'capture.json').read_text())
        self.assertEqual(captured['args'][0], 'exec')
        self.assertIn('--ephemeral', captured['args'])
        self.assertNotIn('resume', captured['args'])
        self.assertEqual(captured['args'][-1], '-')
        self.assertIn('["projects"]', captured['prompt'])
        self.assertEqual(report['changed_paths'], ['projects/sample/main.py'])
        self.assertIn('Generated explanation', Path(report['changes_patch']).read_text())
        self.assertNotIn('INTERNAL REVIEW TRANSCRIPT', result.stdout)
        self.assertIn('INTERNAL REVIEW TRANSCRIPT', (Path(report['run_directory']) / 'events.jsonl').read_text())
        again, second = self.invoke()
        self.assertEqual(again.returncode, 0)
        self.assertNotEqual(report['run_directory'], second['run_directory'])
        self.assertEqual(second['changed_paths'], [])

    def test_explicit_file_target(self):
        result, report = self.invoke('projects/sample/main.py')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(report['out_of_scope_changes'], [])

    def test_outside_target_rejected_before_start(self):
        result, report = self.invoke('AGENTS.md')
        self.assertEqual(result.returncode, 2)
        self.assertIsNone(report)
        self.assertFalse((self.root / 'capture.json').exists())

    def test_runner_failure_remains_failure(self):
        result, report = self.invoke(FAKE_FAIL='1')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(report['exit_code'], 7)
        self.assertEqual(report['status'], 'failed')

    def test_missing_result_is_not_success(self):
        result, report = self.invoke(FAKE_NO_MESSAGE='1')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(report['status'], 'failed')

    def test_out_of_scope_changes_are_reported_and_not_discarded(self):
        result, report = self.invoke(FAKE_OUTSIDE='1')
        self.assertEqual(result.returncode, 1)
        self.assertEqual(report['out_of_scope_changes'], ['AGENTS.md'])
        self.assertEqual((self.root / 'AGENTS.md').read_text(), 'unexpected edit')

    def test_runner_cannot_recursively_launch_itself(self):
        result, report = self.invoke(PROSE_BENCH_RUNNER='1')
        self.assertEqual(result.returncode, 2)
        self.assertIsNone(report)
        self.assertFalse((self.root / 'capture.json').exists())


if __name__ == '__main__':
    unittest.main()
