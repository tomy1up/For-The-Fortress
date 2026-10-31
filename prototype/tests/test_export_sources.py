from pathlib import Path
import hashlib
import json
import re
import os
import shutil
import subprocess
import tempfile
import unittest
from export_sources import SOURCE_PATHS, verify_sources


class PackageSourcesTests(unittest.TestCase):
    def test_runtime_resources_are_selected_for_export(self):
        project = Path(__file__).resolve().parents[1]
        preset = (project / 'export_presets.cfg').read_text(encoding='utf-8')
        selected = set(re.findall(r'"res://([^"\n]+)"', preset.split('include_filter=')[0]))
        required = {name for name in SOURCE_PATHS if Path(name).suffix in {'.gd', '.tscn', '.png'}}
        self.assertFalse(required - selected, 'Ressources absentes du programme exporté : ' + str(required - selected))

    def fixture(self, root):
        sources = {}
        for relative in SOURCE_PATHS:
            source = root / relative
            source.parent.mkdir(parents=True, exist_ok=True)
            source.write_text(relative, encoding='utf-8')
            sources[relative] = hashlib.sha256(source.read_bytes()).hexdigest()
        return {'source_sha256': sources}

    def test_matching_sources_and_stale_copy(self):
        with tempfile.TemporaryDirectory(prefix='fortress-package-') as directory:
            root = Path(directory)
            manifest = self.fixture(root)
            self.assertEqual(verify_sources(manifest, root), len(SOURCE_PATHS))
            (root / 'scripts/main.gd').write_text('changed', encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'différente'):
                verify_sources(manifest, root)

    def test_missing_source(self):
        with tempfile.TemporaryDirectory(prefix='fortress-package-') as directory:
            root = Path(directory)
            manifest = self.fixture(root)
            (root / 'scripts/main.gd').unlink()
            with self.assertRaisesRegex(ValueError, 'absente'):
                verify_sources(manifest, root)

    def test_changed_artwork_or_import_settings(self):
        for relative in ['assets/units/horde/troll_v001.png', 'assets/units/horde/troll_v001.png.import',
                         'assets/units/alliance/archer_v001.png', 'assets/units/alliance/archer_v001.png.import',
                         'assets/enemies/rosters/alliance_v002.png', 'assets/enemies/rosters/alliance_v002.png.import']:
            with self.subTest(relative=relative), tempfile.TemporaryDirectory(prefix='fortress-art-') as directory:
                root = Path(directory)
                manifest = self.fixture(root)
                (root / relative).write_bytes(b'changed asset or import')
                with self.assertRaisesRegex(ValueError, 'différente'):
                    verify_sources(manifest, root)

    def test_manifest_rejects_unexpected_paths_and_bad_hashes(self):
        manifest = {'source_sha256': {key: 'a' * 64 for key in SOURCE_PATHS}}
        self.assertEqual(verify_sources(manifest), len(SOURCE_PATHS))
        for invalid in [None, {}, {'../outside.gd': 'a' * 64}, dict(manifest['source_sha256'], **{'scripts/main.gd': 'bad'})]:
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                verify_sources({'source_sha256': invalid})


@unittest.skipUnless(os.name == 'nt', 'Exporteur PowerShell destiné à Windows')
class ExportSnapshotTests(unittest.TestCase):
    def probe(self, operation, success):
        module = Path(__file__).resolve().parents[1] / 'build/SourceSnapshot.ps1'
        with tempfile.TemporaryDirectory(prefix='fortress-snapshot-') as directory:
            root = Path(directory)
            (root / 'source.gd').write_text('before', encoding='utf-8')
            script = root / 'probe.ps1'
            script.write_text("""param($Module,$Project,$Operation)
$ErrorActionPreference='Stop'
. $Module
$paths=@('source.gd')
$before=Get-FortressSourceSnapshot -ProjectRoot $Project -RelativePaths $paths
switch ($Operation) {
    'changed' { [IO.File]::WriteAllText((Join-Path $Project 'source.gd'),'after') }
    'missing' { Remove-Item -LiteralPath (Join-Path $Project 'source.gd') }
    'outside' { $paths=@('..\\outside.gd') }
    'duplicate' { $paths=@('source.gd','source.gd') }
}
$after=Get-FortressSourceSnapshot -ProjectRoot $Project -RelativePaths $paths
Assert-FortressSourceSnapshot -Expected $before -Actual $after
$after | ConvertTo-Json -Compress
""", encoding='utf-8-sig')
            shell = shutil.which('pwsh') or shutil.which('powershell.exe')
            self.assertIsNotNone(shell, 'PowerShell requis pour vérifier l’exporteur Windows')
            result = subprocess.run([shell, '-NoProfile', '-NonInteractive', '-File', str(script), str(module), str(root), operation], capture_output=True, text=True, timeout=15)
            self.assertEqual(result.returncode == 0, success, result.stderr)
            if success:
                self.assertEqual(json.loads(result.stdout)['source.gd'], hashlib.sha256(b'before').hexdigest())
            else:
                marker = {'changed':'SOURCE_CHANGED','missing':'SOURCE_MISSING','outside':'SOURCE_OUTSIDE','duplicate':'SOURCE_DUPLICATE'}[operation]
                self.assertIn(marker, result.stderr)

    def test_stable_sources(self):
        self.probe('stable', True)

    def test_changes_and_missing_files_block_export(self):
        for operation in ['changed', 'missing']:
            with self.subTest(operation=operation): self.probe(operation, False)

    def test_paths_stay_inside_project_and_are_unique(self):
        for operation in ['outside', 'duplicate']:
            with self.subTest(operation=operation): self.probe(operation, False)


if __name__ == '__main__':
    unittest.main()
