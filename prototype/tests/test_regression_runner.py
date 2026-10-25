from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from run_regression import classify, discover, find_engine
from gdd_contracts import check_contracts


class RunnerTests(unittest.TestCase):
    def test_valid_summary(self):
        self.assertEqual(classify(0, 'Godot\nEXAMPLE_TESTS checks=7 failures=0\n'), (True, 7, ''))

    def test_engine_error_with_success_code(self):
        self.assertFalse(classify(0, 'EXAMPLE_TESTS checks=7 failures=0\nSCRIPT ERROR: boom')[0])

    def test_process_failed(self):
        self.assertFalse(classify(1, 'EXAMPLE_TESTS checks=7 failures=0')[0])

    def test_missing_or_ambiguous_summary(self):
        for text in ['Godot démarre', 'A_TESTS checks=1 failures=0\nB_TESTS checks=1 failures=0']:
            self.assertFalse(classify(0, text)[0])

    def test_failed_or_empty_checks(self):
        for text in ['A_TESTS checks=3 failures=1', 'A_TESTS checks=0 failures=0']:
            self.assertFalse(classify(0, text)[0])

    def test_discovery_and_filter(self):
        project = Path(__file__).resolve().parents[1]
        scripts, available = discover(project)
        self.assertGreater(available, 0)
        self.assertEqual(scripts, sorted(set(scripts)))
        self.assertEqual(discover(project, [scripts[0], scripts[0]])[0], [scripts[0]])
        with self.assertRaises(ValueError):
            discover(project, ['introuvable.gd'])

    def test_invalid_engine_is_not_silently_replaced(self):
        project = Path(__file__).resolve().parents[1]
        with self.assertRaises(ValueError):
            find_engine(str(project / '__absent_engine__.exe'), project)

    def test_cli_rejects_bad_configuration(self):
        runner = Path(__file__).with_name('run_regression.py')
        result = subprocess.run([sys.executable, str(runner), '--timeout', '0'], capture_output=True)
        self.assertEqual(result.returncode, 2)

    def test_contract_rejects_a_changed_stat(self):
        repo = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory(prefix='fortress-contract-') as directory:
            target = Path(directory).resolve()
            self.assertEqual(target.parent, Path(tempfile.gettempdir()).resolve())
            names = ['For_the_Fortress_GDD.md', 'prototype/scripts/valley_model.gd',
                     'prototype/scripts/campaign_data.gd', 'prototype/scripts/progression_data.gd']
            for name in names:
                path = target / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes((repo / name).read_bytes())
            path = target / 'prototype/scripts/valley_model.gd'
            source = re.sub(r'("damage":\s*)(\d+(?:\.\d+)?)', lambda match: match[1] + str(float(match[2]) + 1), path.read_text(encoding='utf-8'), count=1)
            path.write_text(source, encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'GDD : .*damage'):
                check_contracts(target)


if __name__ == '__main__':
    unittest.main()
