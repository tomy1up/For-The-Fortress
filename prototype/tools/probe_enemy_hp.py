"""Teste des coefficients de PV dans des copies isolées ; ne modifie jamais le projet."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--destination',type=Path,required=True)
    a=p.parse_args();project=a.project.resolve();destination=a.destination.resolve()
    if destination.exists() or destination.is_relative_to(project): raise ValueError('Choisir un nouveau dossier hors du projet.')
    sources={path.name:path.read_bytes() for path in (project/'scripts').glob('*.gd')}
    survey=(project/'tools/survey_meta_progression.gd').read_bytes()
    baseline=json.loads((project.parent/'design/essais/v078_meta_progression.json').read_text(encoding='utf-8'))
    version=re.search(r'config/version="([^"]+)"',(project/'project.godot').read_text(encoding='utf-8'))[1]
    snapshot={name:hashlib.sha256(data).hexdigest() for name,data in sources.items()}
    destination.mkdir(parents=True)
    records=[]
    for factor in [1.0,1.15,1.3,1.45]:
        root=destination/('hp_'+str(factor).replace('.','_'));(root/'scripts').mkdir(parents=True)
        for name,data in sources.items(): (root/'scripts'/name).write_bytes(data)
        model=(root/'scripts/valley_model.gd').read_text(encoding='utf-8')
        start=model.index('const ENEMY_TYPES:');end=model.index('\n]',start)+2
        block,count=re.subn(r'("hp":\s*)(\d+(?:\.\d+)?)',lambda m:m[1]+f'{float(m[2])*factor:.6f}',model[start:end])
        assert count==8,'Les huit profils statistiques doivent être reconnus.'
        (root/'scripts/valley_model.gd').write_text(model[:start]+block+model[end:],encoding='utf-8')
        (root/'project.godot').write_text(f'config_version=5\n[application]\nconfig/name="Fortress Balance Probe"\nconfig/version="{version}"\n',encoding='utf-8')
        (root/'survey.gd').write_bytes(survey);output=root/'results.json'
        run=subprocess.run([str(a.engine.resolve()),'--headless','--path',str(root),'--script','res://survey.gd','--','--output='+str(output)],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120)
        (root/'run.log').write_text(run.stdout+run.stderr,encoding='utf-8')
        if run.returncode or 'ERROR:' in run.stdout+run.stderr: raise RuntimeError(run.stdout+run.stderr)
        data=json.loads(output.read_text(encoding='utf-8'));assert data['scenarios']==data['budget_checks']==512
        if factor==1.0: assert data['rows']==baseline['rows'],'La référence copiée doit reproduire l’audit initial.'
        for row in data['rows']: records.append({'enemy_hp_factor':factor,**row})
        print(f'HP_PROBE factor={factor} scenarios=512',flush=True)
    assert snapshot=={name:hashlib.sha256((project/'scripts'/name).read_bytes()).hexdigest() for name in sources}
    result={'schema':1,'game_version':version,'scenarios':len(records),'budget_checks':len(records),'baseline_identical':True,'project_unchanged':True,'human_test':False,'production_change':False,'source_sha256':snapshot,'rows':records}
    (destination/'probe.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('HP_PROBE_COMPLETE='+str(len(records)),flush=True)

if __name__=='__main__': main()
