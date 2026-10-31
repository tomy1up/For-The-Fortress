"""Analyse des comparaisons appariées de survey_shop.gd, sans profil joueur."""
from pathlib import Path
from collections import defaultdict
import argparse
import gzip
import hashlib
import itertools
import json
import statistics

CARDS = {'alliance.scout': (0, 6, 0, 180, 4),
         'alliance.musketeer': (0, 7, 1, 240, 5),
         'horde.tracker': (1, 8, 3, 180, 4),
         'horde.grenadier': (1, 9, 4, 240, 5)}
FIELDS = ['card', 'mission', 'layout', 'policy', 'branch', 'talent_mode', 'seed']


def validate(data, policies=('substitution', 'renfort'), expected_pairs=3744):
    assert data['schema'] == 1 and not data['failures'], data.get('failures', [])[:5]
    assert data['seeds'] == [1, 42, 77] and len(data['layouts']) == 6
    for layout in data['layouts']:
        assert len(layout) == len(set(layout)) == 4 and all(0 <= s < 6 for s in layout)
    expected = set()
    for card, (_, _, _, _, first) in CARDS.items():
        expected.update(itertools.product([card], range(first, 11), range(6),
                                          policies, range(2),
                                          ['aucun', 'famille'], [1, 42, 77]))
    keys = [tuple(pair[f] for f in FIELDS) for pair in data['pairs']]
    assert len(keys) == len(set(keys)) == len(expected) == expected_pairs
    assert set(keys) == expected, 'Grille de comparaisons incomplète.'
    checks = 0
    for pair in data['pairs']:
        faction, kind, family, price, _ = CARDS[pair['card']]
        assert pair['faction'] == faction
        base, alternative = pair['base'], pair['alternative']
        assert base['talent_ranks'] == alternative['talent_ranks']
        assert base['max_hp'] == alternative['max_hp']
        for is_alternative, run in [(False, base), (True, alternative)]:
            assert run['alternative'] is is_alternative and not run['failures']
            assert run['result'] in ['victory', 'defeat']
            assert len(run['waves']) == run['wave'] <= 10
            assert (run['hp'] > 0) == (run['result'] == 'victory')
            assert run['po_before_purchase'] == 60 * (pair['mission'] - 1) >= price
            points = min(51, (pair['mission'] - 1) * 100 * 51 // 10000)
            assert run['talent_points_available'] == points
            assert len(run['talent_ranks']) == 63
            assert sum(run['talent_ranks']) <= points
            if pair['talent_mode'] == 'aucun': assert sum(run['talent_ranks']) == 0
            assert run['gold'] == 150 + run['income'] - run['waves'][-1]['paid'] >= 0
            assert sum(unit['paid'] for unit in run['units']) == run['waves'][-1]['paid']
            allowed = {faction*3, faction*3+1, faction*3+2}
            if is_alternative: allowed.add(kind)
            assert all(unit['type'] in allowed for unit in run['units'])
            assert all(sum(unit['type'] == t for unit in run['units']) <= 2 for t in allowed)
            if not is_alternative:
                assert not run['deployed_auxiliary'] and run['first_auxiliary_wave'] == 0
            if is_alternative and pair['policy'] == 'substitution':
                assert run['deployed_auxiliary'] and run['first_auxiliary_wave'] == 1
            checks += run['audit_checks']
    assert checks == data['audit_checks']
    return checks


def summary(pairs):
    both_won = [p for p in pairs if p['base']['result'] == p['alternative']['result'] == 'victory']
    hp_delta = [p['alternative']['hp'] - p['base']['hp'] for p in both_won]
    return {
        'pairs': len(pairs), 'missions': sorted({p['mission'] for p in pairs}),
        'base_wins': sum(p['base']['result'] == 'victory' for p in pairs),
        'alternative_wins': sum(p['alternative']['result'] == 'victory' for p in pairs),
        'loss_to_win': sum(p['base']['result'] == 'defeat' and p['alternative']['result'] == 'victory' for p in pairs),
        'win_to_loss': sum(p['base']['result'] == 'victory' and p['alternative']['result'] == 'defeat' for p in pairs),
        'alternative_not_recruited': sum(not p['alternative']['deployed_auxiliary'] for p in pairs),
        'alternative_specialized': sum(any(u['type'] >= 6 and u['level'] == 4 for u in p['alternative']['units']) for p in pairs),
        'both_won': len(both_won),
        'hp_delta_mean_both_won': round(statistics.mean(hp_delta), 3) if hp_delta else None,
        'hp_delta_min_both_won': min(hp_delta) if hp_delta else None,
        'hp_delta_max_both_won': max(hp_delta) if hp_delta else None,
        'talent_points_available': sorted({p['base']['talent_points_available'] for p in pairs})
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--destination', type=Path, required=True)
    parser.add_argument('--regression', type=Path, required=True)
    args = parser.parse_args()
    raw = args.input.read_bytes()
    data = json.loads(gzip.decompress(raw) if raw[:2] == b'\x1f\x8b' else raw)
    validate(data)
    repo = Path(__file__).resolve().parents[2]
    regression = json.loads(args.regression.read_text(encoding='utf-8'))
    assert regression['ok'] and any(t['script'] == 'test_shop_survey.gd' and t['ok'] for t in regression['suites'])
    sources = {}
    for relative, digest in regression['source_sha256'].items():
        if relative.startswith('prototype/scripts/') or relative in ['prototype/project.godot', 'prototype/tests/survey_shop.gd']:
            assert hashlib.sha256((repo/relative).read_bytes()).hexdigest() == digest, relative
            sources[relative] = digest
    sources['prototype/tests/analyse_shop.py'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    groups = defaultdict(list)
    for pair in data['pairs']:
        groups[pair['card']+' / '+pair['policy']].append(pair)
    by_mission = defaultdict(list)
    for pair in data['pairs']:
        by_mission[(pair['card'], pair['mission'])].append(pair)
    result = {'schema': 1, 'game_version': data['game_version'], 'engine': data['engine'],
              'pairs': len(data['pairs']), 'runs': len(data['pairs'])*2,
              'audit_checks': data['audit_checks'], 'failures': data['failures'],
              'human_win_rate': False, 'source_sha256': sources,
              'groups': {name: summary(rows) for name, rows in groups.items()},
              'by_mission': [{'card': key[0], 'mission': key[1], **summary(rows)} for key, rows in by_mission.items()]}
    args.destination.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(data, ensure_ascii=False, separators=(',', ':')).encode()
    archive = gzip.compress(payload, mtime=0)
    result['releves_sha256'] = hashlib.sha256(archive).hexdigest()
    (args.destination/'boutique_v0991_releves.json.gz').write_bytes(archive)
    (args.destination/'boutique_v0991_resume.json').write_text(json.dumps(result, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({key: result[key] for key in ['pairs', 'runs', 'audit_checks', 'failures', 'groups']}, ensure_ascii=False, indent=2))


if __name__ == '__main__': main()
