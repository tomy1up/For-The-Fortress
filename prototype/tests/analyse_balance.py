"""Analyse locale, sans dépendance externe, des relevés de survey_balance.gd."""
from pathlib import Path
from collections import Counter
import argparse
import gzip
import hashlib
import json
import statistics

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('input', type=Path)
parser.add_argument('--destination', type=Path, required=True)
args = parser.parse_args()
raw = args.input.read_bytes()
data = json.loads(gzip.decompress(raw) if raw[:2] == b'\x1f\x8b' else raw)
runs = data['runs']
assert not data['failures'], data['failures'][:10]
assert len(runs) == len({run['id'] for run in runs}) == 1728
assert data['seeds'] == [1,2,3,4,5,6,7,8,9,10,11,42]
for run in runs:
    assert run['phase'] in ('victory', 'defeat')
    assert run['gold'] == 150 + run['income'] - run['waves'][-1]['paid']
    assert run['gold'] >= 0
    assert len({item['selected'] for item in run['decisions']}) == len(run['bonuses'])
    for item in run['decisions']:
        assert len(set(item['offer'])) == 3 and item['selected'] in item['offer']

destination = args.destination
destination.mkdir(parents=True, exist_ok=True)
payload = json.dumps(data, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
(destination/'v019_releves.json.gz').write_bytes(gzip.compress(payload, mtime=0))

def group_summary(items):
    victories = [r for r in items if r['phase'] == 'victory']
    losses = [r for r in items if r['phase'] == 'defeat']
    return {
        'runs': len(items), 'wins': len(victories),
        'win_percent': round(100*len(victories)/len(items), 3),
        'hp_mean_wins': round(statistics.mean(r['hp'] for r in victories), 3) if victories else None,
        'combat_seconds_mean_wins': round(statistics.mean(r['combat_seconds'] for r in victories), 3) if victories else None,
        'defeats_by_wave': dict(sorted(Counter(r['last_wave'] for r in losses).items())),
        'specialisation_link_runs': sum(any(w['specialised_links'] for w in r['waves']) for r in items),
    }

summary = {'schema': 1, 'engine': data['engine'], 'seeds': data['seeds'],
           'audit_checks': data['audit_checks'], 'overall': group_summary(runs),
           'factions': {}, 'layouts': {}, 'policies': {}, 'priorities': {}, 'cells': []}
for field in ['faction', 'layout', 'policy', 'priority']:
    target = {'faction': 'factions', 'layout': 'layouts', 'policy': 'policies', 'priority': 'priorities'}[field]
    for value in sorted({r[field] for r in runs}):
        summary[target][str(value)] = group_summary([r for r in runs if r[field] == value])
for faction in range(2):
    for layout in ['triangle', 'milieu', 'reparti', 'aval']:
        for policy in ['reference', 'renforts', 'specialisation']:
            items = [r for r in runs if r['faction'] == faction and r['layout'] == layout and r['policy'] == policy]
            summary['cells'].append({'faction': faction, 'layout': layout, 'policy': policy, **group_summary(items)})

pairs = {}
for run in runs:
    key = (run['layout'],run['policy'],run['priority'],run['branches'],run['seed'])
    pairs.setdefault(key, {})[run['faction']] = run
summary['paired_outcomes'] = dict(Counter(
    ('A gagne' if p[0]['phase'] == 'victory' else 'A perd') + ' / ' +
    ('H gagne' if p[1]['phase'] == 'victory' else 'H perd') for p in pairs.values()))

# Relever les associations N4 financées au lancement d'un combat, vague 10 incluse.
links = [r for r in runs if any(w['specialised_links'] for w in r['waves'])]
summary['specialisation_links'] = group_summary(links) if links else {'runs': 0, 'wins': 0}
summary['link_examples'] = [r['id'] for r in links if r['phase'] == 'victory'][:6]
repo = Path(__file__).resolve().parents[2]
summary['source_sha256'] = {name: hashlib.sha256((repo/name).read_bytes()).hexdigest() for name in [
    'prototype/scripts/valley_model.gd','prototype/scripts/campaign_data.gd',
    'prototype/scripts/progression_data.gd','prototype/tests/survey_balance.gd',
    'prototype/tests/analyse_balance.py','For_the_Fortress_GDD.md']}
summary['records_sha256'] = hashlib.sha256((destination/'v019_releves.json.gz').read_bytes()).hexdigest()
(destination/'v019_synthese.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')

def number(value):
    return '—' if value is None else str(value).replace('.', ',')

lines = ['# Relevé chiffré des essais automatisés v0.19', '',
         'Généré par analyse_balance.py. Les victoires sont celles de politiques fixes, pas celles de joueurs humains.', '',
         f"{len(runs)} parties ; {data['audit_checks']} vérifications d’intégrité ; aucune anomalie d’intégrité.", '',
         '| Faction | Placement | Politique | Victoires / essais | PV moyens des victoires | Défaites par vague |',
         '| --- | --- | --- | --- | --- | --- |']
for cell in summary['cells']:
    losses = ', '.join(f"V{wave} : {count}" for wave, count in cell['defeats_by_wave'].items()) or 'Aucune'
    lines.append(f"| {['Alliance','Horde'][cell['faction']]} | {cell['layout']} | {cell['policy']} | {cell['wins']} / {cell['runs']} | {number(cell['hp_mean_wins'])} | {losses} |")
for title, field in [('Placements', 'layouts'), ('Politiques de dépenses', 'policies'), ('Priorités roguelite', 'priorities')]:
    lines += ['', f'## {title}', '', '| Cas | Victoires / essais | Part de victoires observée |', '| --- | --- | --- |']
    for label, group in summary[field].items():
        lines.append(f"| {label} | {group['wins']} / {group['runs']} | {number(group['win_percent'])} % |")
lines += ['', 'Ces agrégations donnent le même poids à chaque combinaison testée. Elles ne représentent pas la fréquence de ces choix chez des joueurs.', '']
(destination/'v019_tableaux.md').write_text('\n'.join(lines),encoding='utf-8',newline='\n')
print(json.dumps(summary, ensure_ascii=True, indent=2))
