"""Crée trois copies d'essai et compare prix/portée sans modifier le projet source."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse,hashlib,json,os,subprocess,time

VARIANTS={'reference':{'price':90,'range':2.7},'prix_75':{'price':75,'range':2.7},'portee_3':{'price':90,'range':3.0}}
TESTS=['survey_shop.gd','survey_grenadier_variants.gd','report_replay.gd']


def sha(content): return hashlib.sha256(content).hexdigest()


def variant_content(relative,content,settings):
    marker={'scripts/valley_model.gd':'{"name":"Grenadier gobelin",','scripts/shop_catalogue.gd':'"id":"horde.grenadier"'}.get(relative)
    if marker is None: return content
    lines=content.decode('utf-8').splitlines(keepends=True)
    indexes=[i for i,line in enumerate(lines) if marker in line]
    assert len(indexes)==1,(relative,indexes)
    index=indexes[0];line=lines[index]
    assert '"price":90' in line and '"range":2.7' in line
    lines[index]=line.replace('"price":90','"price":'+str(settings['price'])).replace('"range":2.7','"range":'+str(settings['range']))
    return ''.join(lines).encode('utf-8')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace',type=Path,required=True,help='Nouveau dossier réservé à ces copies ; doit être absent.')
    parser.add_argument('--engine',type=Path,required=True)
    parser.add_argument('--quick-only',action='store_true')
    args=parser.parse_args()
    project=Path(__file__).resolve().parents[1];workspace=args.workspace.resolve()
    assert not workspace.exists(),'Choisir un nouveau dossier pour conserver les preuves antérieures.'
    assert not workspace.is_relative_to(project) and not project.is_relative_to(workspace),'Copies hors du projet et sans remplacement de sa racine.'
    engine=args.engine.resolve();assert engine.is_file()
    files=[project/'project.godot']+sorted((project/'scripts').glob('*.gd'))+[project/'tests'/name for name in TESTS]
    frozen={p.relative_to(project).as_posix():p.read_bytes() for p in files}
    workspace.mkdir(parents=True)
    manifest={'schema':1,'variants':VARIANTS,'canonical_source_sha256':{name:sha(content) for name,content in frozen.items()},'variant_changes':{}}
    for name,settings in VARIANTS.items():
        changes={}
        for relative,content in frozen.items():
            changed=variant_content(relative,content,settings)
            target=workspace/name/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(changed)
            if changed!=content:
                changes[relative]={'before':sha(content),'after':sha(changed)}
        assert set(changes)==(set() if name=='reference' else {'scripts/valley_model.gd','scripts/shop_catalogue.gd'})
        manifest['variant_changes'][name]=changes
    start=time.monotonic()
    def run(task):
        name,parity,quick=task;folder=workspace/name
        output=folder/('quick.json' if quick else 'parity_'+str(parity)+'.json')
        log=output.with_suffix('.log')
        command=[str(engine),'--headless','--path',str(folder),'--script','res://tests/survey_grenadier_variants.gd','--','--output='+str(output)]
        command+=['--quick'] if quick else ['--parity='+str(parity)]
        with log.open('wb') as stream:
            process=subprocess.Popen(command,stdout=stream,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
            print('GRENADIER_STARTED',name,'quick' if quick else parity,'pid='+str(process.pid),flush=True)
            try: code=process.wait(timeout=1800)
            except subprocess.TimeoutExpired:
                process.kill();process.wait();raise RuntimeError('Délai dépassé : '+str(output))
        text=log.read_text(encoding='utf-8',errors='replace')
        assert code==0 and 'ERROR:' not in text and 'GRENADIER_SURVEY pairs=' in text,(output,text[-3000:])
        data=json.loads(output.read_text(encoding='utf-8'))
        assert not data['failures'] and data['settings']==VARIANTS[name]
        assert len(data['pairs'])==(6 if quick else 648)
        print('GRENADIER_FINISHED',name,'quick' if quick else parity,'pairs='+str(len(data['pairs'])),flush=True)
        return name,data
    with ThreadPoolExecutor(max_workers=6) as pool:
        for job in as_completed([pool.submit(run,(name,-1,True)) for name in VARIANTS]): job.result()
        if not args.quick_only:
            results={name:[] for name in VARIANTS}
            for job in as_completed([pool.submit(run,(name,parity,False)) for name in VARIANTS for parity in [0,1]]):
                name,data=job.result();results[name].append(data)
            fields=['card','mission','layout','policy','branch','talent_mode','seed']
            for name,parts in results.items():
                data={key:parts[0][key] for key in ['schema','game_version','engine','layouts','seeds','settings','quick']}
                data.update(pairs=sorted([p for d in parts for p in d['pairs']],key=lambda p:tuple(p[k] for k in fields)),audit_checks=sum(p['audit_checks'] for p in parts),failures=[])
                assert len(data['pairs'])==1296
                (workspace/name/'results.json').write_text(json.dumps(data,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
    for relative,content in frozen.items(): assert (project/relative).read_bytes()==content,relative+' a changé pendant les essais'
    manifest.update(seconds=round(time.monotonic()-start),quick_only=args.quick_only,source_unchanged=True)
    (workspace/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('GRENADIER_BATCH_OK seconds='+str(manifest['seconds']),flush=True)


if __name__=='__main__': main()
