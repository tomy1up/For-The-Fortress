"""Lance les tests Godot et Python et les contrats du GDD, depuis tout répertoire."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from gdd_contracts import check_contracts


def discover(project, selected=None):
    available = sorted(path.name for path in (project / 'tests').glob('test_*.gd'))
    if not available:
        raise ValueError('Aucune suite Godot trouvée.')
    if selected:
        unknown = sorted(set(selected) - set(available))
        if unknown:
            raise ValueError('Suite inconnue : ' + ', '.join(unknown))
        return sorted(set(selected)), len(available)
    return available, len(available)


def classify(returncode, log):
    markers = re.findall(r'TESTS checks=(\d+) failures=(\d+)', log)
    if returncode != 0:
        return False, 0, 'Le moteur a renvoyé un code d’échec.'
    if 'ERROR:' in log or 'SCRIPT ERROR' in log:
        return False, 0, 'Erreur du moteur ou du script dans le journal.'
    if len(markers) != 1:
        return False, 0, 'Résumé de tests absent ou ambigu.'
    checks, failures = map(int, markers[0])
    if checks <= 0 or failures != 0:
        return False, checks, 'Contrôles absents ou en échec.'
    return True, checks, ''


def find_engine(explicit, project):
    configured = explicit or os.environ.get('FORTRESS_GODOT')
    if configured:
        path = Path(configured).expanduser().resolve()
        if not path.is_file():
            raise ValueError('Moteur introuvable. Indiquer son exécutable avec --engine.')
        return path
    local = project.parent.parent / '.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe'
    if local.is_file():
        return local
    for name in ['godot4', 'godot']:
        found = shutil.which(name)
        if found:
            return Path(found).resolve()
    raise ValueError('Moteur introuvable. Utiliser --engine ou FORTRESS_GODOT ; sous Windows, choisir le binaire _console.exe.')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine', help='Chemin du moteur Godot, de préférence _console.exe sous Windows.')
    parser.add_argument('--report', type=Path, help='Rapport JSON local ; les journaux sont enregistrés à côté.')
    parser.add_argument('--test', action='append', help='Nom exact d’une suite .gd ; répétable. Sans filtre : toutes les suites.')
    parser.add_argument('--timeout', type=float, default=30, help='Secondes maximales par suite (défaut : 30).')
    parser.add_argument('--jobs', type=int, default=max(1, min(6, (os.cpu_count() or 2) // 3)), help='Suites Godot lancées en parallèle (défaut : un tiers des cœurs, 6 au plus ; 1 pour l’ancien mode séquentiel).')
    args = parser.parse_args(argv)
    project = Path(__file__).resolve().parents[1]
    try:
        if args.timeout <= 0:
            raise ValueError('Le délai maximal doit être strictement positif.')
        scripts, available = discover(project, args.test)
        engine = find_engine(args.engine, project)
    except ValueError as error:
        parser.error(str(error))
    report = {'schema': 1, 'scope': 'selected' if args.test else 'all', 'python_version': sys.version.split()[0],
              'game_version': re.search(r'config/version="([^"]+)"', (project / 'project.godot').read_text(encoding='utf-8'))[1],
              'available_suites': available, 'suites': [], 'godot_checks': 0, 'ok': False}
    repo = project.parent
    sources = sorted(set([project / 'project.godot', project / 'export_presets.cfg', project / 'Exporter_Windows.ps1', repo / 'For_the_Fortress_GDD.md'] +
                         list((project / 'build').glob('*.ps1')) +
                         list((project / 'scripts').glob('*.gd')) + list((project / 'tests').glob('*.gd')) +
                         list((project / 'tests').glob('*.py')) + list((project / 'tests' / 'fixtures').glob('*.json')) + list((project / 'assets').rglob('*.png')) +
                         list((project / 'assets').rglob('*.bin')) + list((project / 'assets').rglob('*.import'))))
    report['source_sha256'] = {path.relative_to(repo).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources}
    logs = None
    if args.report:
        args.report = args.report.resolve()
        logs = args.report.parent / (args.report.stem + '_logs')
        logs.mkdir(parents=True, exist_ok=True)
    try:
        version = subprocess.run([str(engine), '--version'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=10)
        if version.returncode != 0 or not version.stdout.strip():
            raise ValueError('Impossible de lire la version du moteur ; utiliser le binaire console sous Windows.')
        report['engine_version'] = version.stdout.strip()
        def run_suite(script):
            start = time.monotonic()
            try:
                result = subprocess.run([str(engine), '--headless', '--path', str(project), '--quit-after', '120', '--script', 'res://tests/' + script],
                                        capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=args.timeout)
                log = result.stdout + result.stderr
                ok, checks, error = classify(result.returncode, log)
                code = result.returncode
            except subprocess.TimeoutExpired:
                ok, checks, error, code = False, 0, 'Délai maximal dépassé.', None
                log = error
            if logs:
                (logs / (script + '.log')).write_text(log, encoding='utf-8')
            print(('OK ' if ok else 'ÉCHEC ') + script + ' : ' + str(checks), flush=True)
            if not ok:
                print(error + chr(10) + log[-3000:], file=sys.stderr, flush=True)
            return {'script': script, 'ok': ok, 'checks': checks, 'error': error,
                    'exit_code': code, 'seconds': round(time.monotonic() - start, 3)}
        # Suites indépendantes (chacune a son processus et ses fichiers temporaires uniques) : lancées en parallèle, rapport dans l'ordre alphabétique.
        with ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
            results = list(pool.map(run_suite, scripts))
        for entry in results:
            report['suites'].append(entry)
            report['godot_checks'] += entry['checks']
        python = subprocess.run([sys.executable, '-m', 'unittest', 'discover', '-s', str(project / 'tests'), '-p', 'test_*.py'],
                                cwd=project.parent, capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=args.timeout)
        python_log = python.stdout + python.stderr
        count = re.search(r'Ran (\d+) tests?', python_log)
        python_ok = python.returncode == 0 and count is not None and int(count[1]) > 0 and re.search(r'^OK\s*$', python_log, re.MULTILINE) is not None
        report['python'] = {'ok': python_ok, 'tests': int(count[1]) if count else 0, 'exit_code': python.returncode}
        if logs:
            (logs / 'python.log').write_text(python_log, encoding='utf-8')
        if not python_ok:
            print(python_log[-3000:], file=sys.stderr)
        report['gdd_contracts'] = check_contracts(project.parent)
        if any(hashlib.sha256((repo / name).read_bytes()).hexdigest() != digest for name, digest in report['source_sha256'].items()):
            raise ValueError('Des sources ont changé pendant les tests ; relancer la vérification.')
        report['ok'] = all(suite['ok'] for suite in report['suites']) and python_ok
    except (OSError, ValueError, IndexError, KeyError, StopIteration, subprocess.TimeoutExpired) as error:
        report['error'] = str(error) or type(error).__name__
        print('ÉCHEC : ' + report['error'], file=sys.stderr)
    if args.report:
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f"REGRESSION ok={report['ok']} suites={len(report['suites'])}/{available} godot_checks={report['godot_checks']} python_tests={report.get('python', {}).get('tests', 0)}", flush=True)
    return 0 if report['ok'] else 1


if __name__ == '__main__':
    sys.exit(main())
