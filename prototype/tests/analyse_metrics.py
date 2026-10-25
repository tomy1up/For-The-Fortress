"""Compare la matrice v0.38 au relevé v0.19 et décrit le boss, sans régler le jeu."""
from pathlib import Path
from collections import Counter
import argparse
import gzip
import hashlib
import json
import math
import statistics

COUNTERS = ['attacks', 'secondary_hits', 'curse_ticks', 'direct_hp', 'secondary_hp', 'curse_hp', 'boss_hp']


def read(path):
    raw = path.read_bytes()
    return json.loads(gzip.decompress(raw) if raw[:2] == b'\x1f\x8b' else raw)


def same_fields(old, new, location):
    """Les champs historiques doivent rester identiques ; les mesures sont additives."""
    if isinstance(old, dict):
        assert isinstance(new, dict), location
        for key, value in old.items():
            assert key in new, location + '/' + key
            same_fields(value, new[key], location + '/' + key)
    elif isinstance(old, list):
        assert isinstance(new, list) and len(old) == len(new), location
        for index, (a, b) in enumerate(zip(old, new)):
            same_fields(a, b, location + '/' + str(index))
    elif isinstance(old, (float, int)) and not isinstance(old, bool):
        assert isinstance(new, (float, int)) and math.isclose(old, new, rel_tol=0.0, abs_tol=1e-7), (location, old, new)
    else:
        assert old == new, (location, old, new)


def median(values):
    return statistics.median(values) if values else None


def describe(runs):
    reached = [run for run in runs if run['last_wave'] == 10]
    killed = [run for run in reached if run['waves'][-1]['boss']['result'] == 'killed']
    losses9, losses10 = [], []
    for run in reached:
        waves = run['waves']
        heal = 4 if any(choice['wave'] == 9 and choice['selected'] == 8 for choice in run['decisions']) else 0
        losses9.append(waves[7]['hp'] - waves[8]['hp'])
        losses10.append(waves[8]['hp'] + heal - waves[9]['hp'])
    return {
        'runs': len(runs), 'wins': sum(run['phase'] == 'victory' for run in runs),
        'reached_wave10': len(reached),
        'boss_outcomes': dict(Counter(run['waves'][-1]['boss']['result'] for run in reached)),
        'boss_kill_seconds_median': median([run['waves'][-1]['boss']['seconds'] for run in killed]),
        'fortress_loss_wave9_median_reached10': median(losses9),
        'fortress_loss_wave10_median_reached10': median(losses10),
        'fewer_fortress_losses_wave10': sum(b < a for a, b in zip(losses9, losses10)),
        'equal_fortress_losses_wave10': sum(a == b for a, b in zip(losses9, losses10)),
        'more_fortress_losses_wave10': sum(b > a for a, b in zip(losses9, losses10)),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--destination', type=Path, required=True)
    args = parser.parse_args()
    data, baseline = read(args.input), read(args.baseline)
    assert data['schema'] == 2 and not data['failures']
    assert data['engine'] == baseline['engine'] and data['seeds'] == baseline['seeds']
    runs, old_runs = data['runs'], {run['id']: run for run in baseline['runs']}
    assert len(runs) == len({run['id'] for run in runs}) == len(old_runs) == 1728
    for run in runs:
        same_fields(old_runs[run['id']], run, run['id'])
        assert len(run['waves']) == run['last_wave'] and run['gold'] >= 0
        totals = {}
        for wave in run['waves']:
            units = wave['performance']
            assert len(units) == len(wave['deployed']) == len({unit['instance_id'] for unit in units})
            for unit, deployed in zip(units, wave['deployed']):
                assert unit['slot'] + 1 == deployed['slot']
                assert all(unit[field] == deployed[field] for field in ['type', 'level', 'branch', 'paid'])
                assert unit['type'] // 3 == run['faction']
                assert all(math.isfinite(unit[field]) and unit[field] >= 0 for field in COUNTERS)
                total = totals.setdefault(unit['instance_id'], dict.fromkeys(COUNTERS, 0))
                for field in COUNTERS:
                    total[field] += unit[field]
        assert len(totals) == len(run['performance'])
        for unit in run['performance']:
            for field in COUNTERS:
                assert math.isclose(unit[field], totals[unit['instance_id']][field], abs_tol=1e-7), (run['id'], field)
        if run['last_wave'] == 10:
            boss = run['waves'][-1]['boss']
            assert boss['result'] in ['killed', 'escaped', 'present']
            assert 0 <= boss['removed_hp'] <= 600 + 1e-6
            if boss['result'] == 'killed':
                assert abs(boss['removed_hp'] - 600) < 1e-6
            if run['phase'] == 'victory':
                assert boss['result'] != 'present'

    repo = Path(__file__).resolve().parents[2]
    escaped_wins = [run['id'] for run in runs if run['last_wave'] == 10 and run['phase'] == 'victory' and run['waves'][-1]['boss']['result'] == 'escaped']
    summary = {
        'schema': 1, 'game_version': data['game_version'], 'engine': data['engine'],
        'seeds': data['seeds'], 'audit_checks': data['audit_checks'],
        'baseline_cases_matched': len(runs), 'overall': describe(runs),
        'cells': [{'faction': faction, 'policy': policy, **describe([run for run in runs if run['faction'] == faction and run['policy'] == policy])}
                  for faction in range(2) for policy in ['reference', 'renforts', 'specialisation']],
        'victory_with_escaped_boss_ids': escaped_wins,
        'source_sha256': {name: hashlib.sha256((repo / name).read_bytes()).hexdigest() for name in [
            'prototype/project.godot', 'prototype/scripts/valley_model.gd', 'prototype/scripts/combat_metrics.gd',
            'prototype/scripts/campaign_data.gd', 'prototype/scripts/progression_data.gd',
            'prototype/tests/survey_balance.gd', 'prototype/tests/survey_metrics.gd',
            'prototype/tests/analyse_metrics.py', 'For_the_Fortress_GDD.md']},
        'baseline_sha256': hashlib.sha256(args.baseline.read_bytes()).hexdigest(),
    }
    destination = args.destination
    destination.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(data, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
    compressed = gzip.compress(payload, mtime=0)
    (destination / 'v038_metrics_releves.json.gz').write_bytes(compressed)
    summary['records_sha256'] = hashlib.sha256(compressed).hexdigest()
    (destination / 'v038_metrics_synthese.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')

    def number(value):
        return '—' if value is None else str(round(value, 3)).replace('.', ',')

    lines = ['# Matrice d’activité et de finale — v0.38', '',
             '1 728 scénarios de politiques fixes ; tous les champs historiques concordent avec le relevé v0.19.',
             'Les cas ne représentent ni des joueurs humains ni des observations indépendantes.', '',
             '| Faction | Politique | Victoires / essais | Vague 10 atteinte | Boss éliminé | Boss passé | Boss encore présent à la défaite | Temps médian d’élimination du boss |',
             '| --- | --- | --- | --- | --- | --- | --- | --- |']
    for cell in summary['cells']:
        boss = cell['boss_outcomes']
        lines.append(f"| {['Alliance','Horde'][cell['faction']]} | {cell['policy']} | {cell['wins']} / {cell['runs']} | {cell['reached_wave10']} | {boss.get('killed',0)} | {boss.get('escaped',0)} | {boss.get('present',0)} | {number(cell['boss_kill_seconds_median'])} s |")
    lines += ['', 'Le temps est mesuré depuis l’apparition du boss, à t = 0 de la vague 10. Sa médiane ne concerne que les cas où il est éliminé. Les bonus peuvent ajouter des PV après la vague 9 ; cette hausse est déduite de la comparaison des pertes.', '',
              '| Faction | Politique | Pertes médianes vague 9, parmi les cas atteignant 10 | Pertes médianes vague 10, mêmes cas | Moins / autant / plus de pertes en vague 10 |',
              '| --- | --- | --- | --- | --- |']
    for cell in summary['cells']:
        lines.append(f"| {['Alliance','Horde'][cell['faction']]} | {cell['policy']} | {number(cell['fortress_loss_wave9_median_reached10'])} | {number(cell['fortress_loss_wave10_median_reached10'])} | {cell['fewer_fortress_losses_wave10']} / {cell['equal_fortress_losses_wave10']} / {cell['more_fortress_losses_wave10']} |")
    lines += ['', 'Ces comparaisons sont conditionnées à la survie jusqu’à la vague 10. Un bonus supplémentaire a pu être choisi après la vague 9. Elles ne mesurent pas la tension ressentie ni la difficulté pour un joueur et ne justifient aucun changement automatique.', '']
    (destination / 'v038_metrics_tableaux.md').write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    print(json.dumps({key: summary[key] for key in ['baseline_cases_matched', 'audit_checks', 'overall', 'cells', 'victory_with_escaped_boss_ids']}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
