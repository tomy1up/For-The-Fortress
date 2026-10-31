"""Vérifie et analyse les copies d'essai du grenadier, sans modifier leur source."""
from pathlib import Path
from collections import defaultdict
import argparse,copy,gzip,hashlib,json
from analyse_shop import CARDS,FIELDS,validate,summary

POLICIES=['substitution','renfort','renfort_prioritaire']


def sha(content): return hashlib.sha256(content).hexdigest()


def load(path):
    raw=path.read_bytes()
    return json.loads(gzip.decompress(raw) if raw[:2]==b'\x1f\x8b' else raw)


def key(pair): return tuple(pair[field] for field in FIELDS)


def validate_changes(workspace,manifest):
    for variant,settings in manifest['variants'].items():
        changed=set()
        for relative,digest in manifest['canonical_source_sha256'].items():
            reference=(workspace/'reference'/relative).read_bytes()
            candidate=(workspace/variant/relative).read_bytes()
            assert sha(reference)==digest
            if reference==candidate: continue
            changed.add(relative)
            marker='{"name":"Grenadier gobelin",' if relative=='scripts/valley_model.gd' else '"id":"horde.grenadier"'
            assert relative in ['scripts/valley_model.gd','scripts/shop_catalogue.gd']
            before=reference.decode('utf-8').splitlines();after=candidate.decode('utf-8').splitlines()
            assert len(before)==len(after)
            differences=[(a,b) for a,b in zip(before,after) if a!=b]
            assert len(differences)==1 and marker in differences[0][0]
            original=json.loads(differences[0][0].strip().rstrip(','))
            actual=json.loads(differences[0][1].strip().rstrip(','))
            expected=copy.deepcopy(original)
            target=expected if relative=='scripts/valley_model.gd' else expected['stats']
            target['price']=settings['price'];target['range']=settings['range']
            assert actual==expected
            assert manifest['variant_changes'][variant][relative]=={'before':sha(reference),'after':sha(candidate)}
        assert changed==(set() if variant=='reference' else {'scripts/valley_model.gd','scripts/shop_catalogue.gd'})


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('workspace',type=Path)
    parser.add_argument('--destination',type=Path,required=True)
    args=parser.parse_args();workspace=args.workspace.resolve()
    manifest=load(workspace/'manifest.json');assert manifest['source_unchanged'] and not manifest['quick_only']
    assert manifest['variants']=={'reference':{'price':90,'range':2.7},'prix_75':{'price':75,'range':2.7},'portee_3':{'price':90,'range':3.0}}
    validate_changes(workspace,manifest)
    repo=Path(__file__).resolve().parents[2]
    for relative,digest in manifest['canonical_source_sha256'].items(): assert sha((repo/'prototype'/relative).read_bytes())==digest,relative
    initial=load(repo/'design/essais/boutique_v0991_releves.json.gz')
    priority=load(repo/'design/essais/boutique_priorite_v0991_releves.json.gz')
    historical={key(p):p for d in [initial,priority] for p in d['pairs'] if p['card']=='horde.grenadier'}
    assert len(historical)==1296
    variants={name:load(workspace/name/'results.json') for name in manifest['variants']}
    references={key(p):p for p in variants['reference']['pairs']}
    assert set(references)==set(historical)
    for k,pair in references.items():
        for field in ['base','alternative']: assert pair[field]==historical[k][field],(k,field,'témoin historique différent')
    result={'schema':1,'game_version':variants['reference']['game_version'],'reference_matches_prior_archives':True,
            'canonical_source_unchanged':True,'human_win_rate':False,'variants':{},'audit_checks':0,'runs':0,
            'canonical_source_sha256':manifest['canonical_source_sha256'],'variant_changes':manifest['variant_changes']}
    args.destination.mkdir(parents=True,exist_ok=True)
    for variant,data in variants.items():
        assert data['settings']==manifest['variants'][variant] and not data['quick']
        # Deux contrôles de concordance modèle/catalogue au début de chacun des deux lots.
        grid=copy.copy(data);grid['audit_checks']-=4
        validate(grid,policies=POLICIES,expected_pairs=1296,cards={'horde.grenadier':CARDS['horde.grenadier']})
        lookup={key(p):p for p in data['pairs']};assert set(lookup)==set(references)
        for k,pair in lookup.items(): assert pair['base']==references[k]['base'],(variant,k,'défenseur témoin modifié')
        quick=load(workspace/variant/'quick.json')
        assert quick['quick'] and not quick['failures'] and len(quick['pairs'])==6
        assert quick['audit_checks']==2+sum(p[field]['audit_checks'] for p in quick['pairs'] for field in ['base','alternative'])+36
        for pair in quick['pairs']: assert pair==lookup[key(pair)],'Rapport/contrôle rapide ayant modifié le résultat'
        groups=defaultdict(list)
        for pair in data['pairs']: groups[pair['policy']].append(pair)
        metrics={}
        for policy,pairs in groups.items():
            stats=summary(pairs)
            stats['loss_to_win_vs_reference_alternative']=sum(references[key(p)]['alternative']['result']=='defeat' and p['alternative']['result']=='victory' for p in pairs)
            stats['win_to_loss_vs_reference_alternative']=sum(references[key(p)]['alternative']['result']=='victory' and p['alternative']['result']=='defeat' for p in pairs)
            stats['specialized_by_branch']={str(branch):sum(p['branch']==branch and any(u['type']==9 and u['level']==4 for u in p['alternative']['units']) for p in pairs) for branch in range(2)}
            metrics[policy]=stats
        payload=gzip.compress(json.dumps(data,ensure_ascii=False,separators=(',',':')).encode(),mtime=0)
        (args.destination/('grenadier_'+variant+'_v0100_releves.json.gz')).write_bytes(payload)
        result['variants'][variant]={'settings':data['settings'],'runs':2592,'audit_checks':data['audit_checks'],
                                    'quick_runs':12,'quick_replay_checks':36,'groups':metrics,'releves_sha256':sha(payload)}
        result['audit_checks']+=data['audit_checks'];result['runs']+=2592
    result['analysis_sources_sha256']={p.name:sha(p.read_bytes()) for p in [Path(__file__),Path(__file__).with_name('analyse_shop.py'),Path(__file__).with_name('compare_grenadier_variants.py')]}
    (args.destination/'grenadier_variantes_v0100_resume.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'runs':result['runs'],'audit_checks':result['audit_checks'],'variants':{name:v['groups'] for name,v in result['variants'].items()}},ensure_ascii=False,indent=2))


if __name__=='__main__': main()
