"""Analyse appariée de survey_upgrades.gd, bibliothèque standard uniquement."""
from pathlib import Path
from collections import Counter, defaultdict
import argparse
import gzip
import hashlib
import itertools
import json
import statistics

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('input', type=Path)
parser.add_argument('--destination', required=True, type=Path)
args = parser.parse_args()
raw = args.input.read_bytes()
data = json.loads(gzip.decompress(raw) if raw[:2] == b'\x1f\x8b' else raw)
assert not data['failures'], data['failures'][:10]
bases = {item['id']: item for item in data['checkpoints']}
assert len(bases) == len(data['checkpoints']) == 96
assert len(data['immediate']) == 384 and len(data['campaigns']) == 768
immediate = defaultdict(dict)
campaigns = defaultdict(dict)
for item in data['immediate']:
    key, target = item['checkpoint'], item['target']
    assert target not in immediate[key]
    immediate[key][target] = item
    base = bases[key]
    assert len(item['deployed']) == 3
    assert item['phase'] in ['finished','defeat']
    assert item['spent'] == (0 if target == -1 else 50)
    for old, unit in zip(base['deployed'],item['deployed']):
        # deployment est trié par emplacement : retrouver le type, pas l'ordre des slots.
        assert old['type'] == unit['type'] and old['slot'] == unit['slot']
        upgraded = unit['type'] % 3 == target
        assert unit['level'] == (2 if upgraded else 1)
        assert unit['paid'] == old['paid'] + (50 if upgraded else 0)
    assert item['gold'] >= 0 # Conservation complète contrôlée par integrity côté moteur.
for key, group in immediate.items():
    assert set(group) == {-1,0,1,2}
    assert len({group[t]['spent'] for t in [0,1,2]}) == 1
for item in data['campaigns']:
    key = item['checkpoint']
    variant = (item['policy'],item['branch'])
    assert variant not in campaigns[key]
    campaigns[key][variant] = item
    assert item['phase'] in ['victory','defeat']
    assert item['gold'] == 150+item['income']-sum(u['paid'] for u in item['waves'][-1]['deployed'])
    for wave in item['waves']:
        assert len(wave['deployed']) == 3
        assert [(u['type'],u['slot']) for u in wave['deployed']] == [(u['type'],u['slot']) for u in bases[key]['deployed']]
for key, group in campaigns.items():
    assert len(group) == 8
    # La stratégie de choix est fixe ; les copies du RNG doivent conserver les offres.
    for wave in [6,9]:
        offers = [d for item in group.values() for d in item['decisions'] if d['wave'] == wave]
        assert len({json.dumps(d,sort_keys=True) for d in offers}) <= 1

def average(items, field):
    return round(statistics.mean(item[field] for item in items),6)

def campaign_summary(items):
    wins = [item for item in items if item['phase'] == 'victory']
    return {'runs':len(items),'wins':len(wins),'hp_mean_all':average(items,'hp'),
            'hp_mean_wins':average(wins,'hp') if wins else None,
            'defeats_by_wave':dict(sorted(Counter(i['last_wave'] for i in items if i['phase']=='defeat').items()))}

summary = {'schema':1,'engine':data['engine'],'checks':data['checks'],'checkpoints':len(bases),
           'immediate':{},'immediate_cells':[],'campaigns':{},'campaign_cells':[],
           'paired_policies':{},'paired_branches':{}}
summary['identical_reference_priority_runs'] = sum(
    {k:v for k,v in group[('reference',branch)].items() if k!='policy'} ==
    {k:v for k,v in group[('priorite_0',branch)].items() if k!='policy'}
    for group in campaigns.values() for branch in [0,1])
for target in [-1,0,1,2]:
    items = [group[target] for group in immediate.values()]
    summary['immediate'][str(target)] = {'runs':len(items),'kills_mean':average(items,'kills'),
        'escapes_mean':average(items,'escapes'),'hp_mean':average(items,'hp'),
        'improved_kills_vs_saving':sum(group[target]['kills']>group[-1]['kills'] for group in immediate.values())}
for faction in range(2):
    for layout in ['triangle','milieu','reparti','aval']:
        keys = [key for key,b in bases.items() if b['faction']==faction and b['layout']==layout]
        for target in [-1,0,1,2]:
            items = [immediate[key][target] for key in keys]
            summary['immediate_cells'].append({'faction':faction,'layout':layout,'target':target,
                'runs':len(items),'kills_mean':average(items,'kills'),'hp_mean':average(items,'hp')})
        for policy in ['reference','equilibre','priorite_0','priorite_groupe']:
            items = [item for key in keys for (p,b),item in campaigns[key].items() if p==policy]
            summary['campaign_cells'].append({'faction':faction,'layout':layout,'policy':policy,**campaign_summary(items)})
for policy in ['reference','equilibre','priorite_0','priorite_groupe']:
    items = [item for group in campaigns.values() for (p,b),item in group.items() if p==policy]
    summary['campaigns'][policy] = campaign_summary(items)
    delta = Counter()
    for group in campaigns.values():
        a,b = group[(policy,0)],group[(policy,1)]
        delta['A gagne, B perd' if a['phase']=='victory' and b['phase']=='defeat' else
              'B gagne, A perd' if b['phase']=='victory' and a['phase']=='defeat' else
              'deux victoires' if a['phase']=='victory' else 'deux défaites'] += 1
    summary['paired_branches'][policy] = dict(delta)
for first,second in itertools.combinations(summary['campaigns'],2):
    outcome = Counter()
    for group in campaigns.values():
        for branch in [0,1]:
            a,b = group[(first,branch)],group[(second,branch)]
            outcome['première seule' if a['phase']=='victory' and b['phase']=='defeat' else
                    'seconde seule' if b['phase']=='victory' and a['phase']=='defeat' else
                    'deux victoires' if a['phase']=='victory' else 'deux défaites'] += 1
    summary['paired_policies'][first+' / '+second] = dict(outcome)

destination = args.destination
destination.mkdir(parents=True,exist_ok=True)
archive = destination/'v020_releves.json.gz'
archive.write_bytes(gzip.compress(json.dumps(data,ensure_ascii=False,separators=(',',':')).encode(),mtime=0))
repo = Path(__file__).resolve().parents[2]
summary['source_sha256'] = {name:hashlib.sha256((repo/name).read_bytes()).hexdigest() for name in [
    'prototype/scripts/valley_model.gd','prototype/scripts/campaign_data.gd','prototype/scripts/progression_data.gd',
    'prototype/tests/survey_balance.gd','prototype/tests/survey_upgrades.gd','prototype/tests/analyse_upgrades.py','For_the_Fortress_GDD.md']}
summary['records_sha256'] = hashlib.sha256(archive.read_bytes()).hexdigest()
(destination/'v020_synthese.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')

def num(value):
    return '—' if value is None else str(round(value,3)).replace('.',',')

lines = ['# Comparaisons appariées des améliorations — v0.20','',
    '96 préparations communes, 384 essais isolés de vague 5 et 768 continuations. Les joueurs humains ne sont pas mesurés.','',
    '## Une amélioration de 50 or avant la vague 5','',
    '| Faction | Placement | Cible du N2 | Éliminations moyennes / 18 | PV moyens après vague |',
    '| --- | --- | --- | --- | --- |']
for cell in summary['immediate_cells']:
    lines.append(f"| {['Alliance','Horde'][cell['faction']]} | {cell['layout']} | {['Épargne','Premier type','Deuxième type','Troisième type'][cell['target']+1]} | {num(cell['kills_mean'])} | {num(cell['hp_mean'])} |")
lines += ['', '## Continuations : trois types conservés','',
    '| Faction | Placement | Politique | Victoires / essais | PV moyens des victoires |',
    '| --- | --- | --- | --- | --- |']
for cell in summary['campaign_cells']:
    lines.append(f"| {['Alliance','Horde'][cell['faction']]} | {cell['layout']} | {cell['policy']} | {cell['wins']} / {cell['runs']} | {num(cell['hp_mean_wins'])} |")
lines += ['', 'Les trois traitements N2 paient le même montant ; le contrôle épargne ne paie rien. Les continuations partent du même état, mais leurs revenus futurs peuvent diverger.','']
(destination/'v020_tableaux.md').write_text('\n'.join(lines),encoding='utf-8',newline='\n')
print(json.dumps(summary,ensure_ascii=True,indent=2))
