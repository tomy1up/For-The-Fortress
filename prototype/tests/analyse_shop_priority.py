"""Compare le renfort prioritaire au relevé historique, sans le réécrire."""
from pathlib import Path
from collections import defaultdict
import argparse,gzip,hashlib,json
from analyse_shop import CARDS, FIELDS, validate, summary


def load(path):
    raw=path.read_bytes()
    return json.loads(gzip.decompress(raw) if raw[:2]==b'\x1f\x8b' else raw)


def key(pair): return tuple(pair[field] for field in FIELDS if field!='policy')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input',type=Path)
    parser.add_argument('--baseline',type=Path,required=True)
    parser.add_argument('--regression',type=Path,required=True)
    parser.add_argument('--destination',type=Path,required=True)
    args=parser.parse_args()
    data=load(args.input);baseline=load(args.baseline)
    validate(data,policies=['renfort_prioritaire'],expected_pairs=1872);validate(baseline)
    assert data['layouts']==baseline['layouts']
    baseline_summary_path=args.baseline.with_name(args.baseline.name.replace('_releves.json.gz','_resume.json'))
    baseline_summary=json.loads(baseline_summary_path.read_text(encoding='utf-8'))
    assert baseline_summary['releves_sha256']==hashlib.sha256(args.baseline.read_bytes()).hexdigest()
    references={key(pair):pair for pair in baseline['pairs'] if pair['policy']=='renfort'}
    assert set(references)=={key(pair) for pair in data['pairs']}
    groups=defaultdict(list);coverage=defaultdict(int)
    for pair in data['pairs']:
        old=references[key(pair)]
        for variant in ['base','alternative']:
            assert pair[variant]['talent_ranks']==old[variant]['talent_ranks']
            assert pair[variant]['po_before_purchase']==old[variant]['po_before_purchase']
            slot=data['layouts'][pair['layout']][3]
            target=next((u for u in pair[variant]['units'] if u['slot']==slot),None)
            if target and target['level']==4:
                assert target['branch']==pair['branch']
                coverage[(pair['card'],pair['branch'],variant)]+=1
        groups[pair['card']].append(pair)
    # Ne pas annoncer les branches couvertes si le plan n'atteint pas réellement les deux.
    for card in CARDS:
        for branch in range(2):
            assert coverage[(card,branch,'alternative')]>0,(card,branch,'spécialisation jamais atteinte')
    report={}
    for card,pairs in groups.items():
        old=[references[key(p)] for p in pairs]
        effects={}
        for variant in ['base','alternative']:
            effects[variant]={
                'loss_to_win':sum(references[key(p)][variant]['result']=='defeat' and p[variant]['result']=='victory' for p in pairs),
                'win_to_loss':sum(references[key(p)][variant]['result']=='victory' and p[variant]['result']=='defeat' for p in pairs),
                'fourth_specialized_by_branch':{str(branch):coverage[(card,branch,variant)] for branch in range(2)}}
        report[card]={'previous':summary(old),'priority':summary(pairs),'allocation_effect':effects}
    regression=json.loads(args.regression.read_text(encoding='utf-8'))
    assert regression['ok'] and any(s['script']=='test_shop_priority.gd' and s['ok'] for s in regression['suites'])
    repo=Path(__file__).resolve().parents[2]
    selected=['prototype/tests/survey_shop.gd','prototype/tests/survey_shop_priority.gd','prototype/project.godot']
    sources={}
    for relative,digest in regression['source_sha256'].items():
        if relative.startswith('prototype/scripts/') or relative in selected:
            assert hashlib.sha256((repo/relative).read_bytes()).hexdigest()==digest,relative
            sources[relative]=digest
    for name in ['analyse_shop.py','analyse_shop_priority.py']:
        path=Path(__file__).with_name(name);sources[str(path.relative_to(repo)).replace('\\','/')]=hashlib.sha256(path.read_bytes()).hexdigest()
    # Une correction de présentation peut changer le numéro de version ; les règles
    # de combat, talents, cartes et statistiques doivent rester celles du témoin.
    combat_files=['valley_model.gd','campaign_data.gd','progression_data.gd','combat_metrics.gd',
                  'shop_catalogue.gd','campaign_catalogue.gd','map_definition.gd','run_report.gd',
                  'meta_talents.gd','meta_talents_linked.gd','meta_talents_expanded.gd',
                  'meta_talents_v067.gd','meta_talents_v068.gd']
    for name in combat_files:
        relative='prototype/scripts/'+name
        assert sources[relative]==baseline_summary['source_sha256'][relative],relative+' différent de la référence'
    payload=gzip.compress(json.dumps(data,ensure_ascii=False,separators=(',',':')).encode(),mtime=0)
    result={'schema':1,'game_version':data['game_version'],'baseline_game_version':baseline['game_version'],'engine':data['engine'],'pairs':1872,'runs':3744,
            'audit_checks':data['audit_checks'],'failures':data['failures'],'human_win_rate':False,
            'baseline_sha256':hashlib.sha256(args.baseline.read_bytes()).hexdigest(),
            'source_sha256':sources,'releves_sha256':hashlib.sha256(payload).hexdigest(),'groups':report}
    args.destination.mkdir(parents=True,exist_ok=True)
    (args.destination/'boutique_priorite_v0991_releves.json.gz').write_bytes(payload)
    (args.destination/'boutique_priorite_v0991_resume.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:result[k] for k in ['runs','audit_checks','failures','groups']},ensure_ascii=False,indent=2))


if __name__=='__main__': main()
