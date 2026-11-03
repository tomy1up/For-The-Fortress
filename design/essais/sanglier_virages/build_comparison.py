"""Reproduce the static boar direction comparison without changing the game."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys,time
import numpy as np
from PIL import Image
folder=Path(__file__).resolve().parent;repo=folder.parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine',type=Path,default=repo.parent/'.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe')
args=parser.parse_args();assert args.engine.is_file()
sys.path.insert(0,str(repo/'prototype/tests'))
from export_sources import verify_sources
manifest_path=repo/'dist/For_the_Fortress_v0.112_Windows_x64/VERSION.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8-sig'));assert verify_sources(manifest,repo/'prototype')==75
exe=manifest_path.parent/'For_the_Fortress.exe';assert hashlib.sha256(exe.read_bytes()).hexdigest()==manifest['executable_sha256']
(folder/'captures').mkdir(exist_ok=True);steps=[]
def run(name,command,marker):
    start=time.monotonic();r=subprocess.run([str(x) for x in command],cwd=repo,capture_output=True,text=True,encoding='utf8',errors='replace',timeout=60,creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    log=r.stdout+r.stderr;(folder/'captures'/(name+'.log')).write_text(log,encoding='utf8')
    assert r.returncode==0 and 'ERROR:' not in log and 'SCRIPT ERROR' not in log and marker in log,(name,log[-3000:])
    steps.append({'step':name,'seconds':round(time.monotonic()-start,3),'exit_code':r.returncode});print('OK',name,flush=True)
run('sources',[sys.executable,folder/'preflight.py'],'BOAR_FRONT_PREFLIGHT')
run('native',[args.engine,'--screen','1','--minimized','--path',repo/'prototype','--script',folder/'render_comparison.gd','--quit-after','60'],'BOAR_FRONT_COMPARISON static=true profile_loaded=false')
data=json.loads((folder/'placements_natifs.json').read_text(encoding='utf8'));assert data['profile_loaded']==False and data['static_drawing'] and len(data['transforms'])==8
geometry_error=0.
for row in data['transforms']:
    basis=np.array(row['basis']).T;error=float(np.max(np.abs(basis.T@basis-np.eye(2)*row['scale']**2)));geometry_error=max(geometry_error,error)
    assert error<1e-7 and np.linalg.det(basis)>0
    assert row['view'] in [0,1,2,3] and row['factor'] in [1,5]
assert Image.open(folder/'Apercu_directions.png').size==(1280,800)
assert verify_sources(manifest,repo/'prototype')==75 and hashlib.sha256(exe.read_bytes()).hexdigest()==manifest['executable_sha256']
report={'passed':True,'scope':'Static direction artwork preflight and native sizing, not a turn animation or artistic approval','steps':steps,'uniform_transforms':8,'maximum_rigid_basis_error':geometry_error,'profile_loaded':False,'artistically_approved':False,'production_version':'0.112','production_sources_unchanged':75,'production_executable_sha256':manifest['executable_sha256'],'source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [folder/'preflight.py',folder/'build_comparison.py',folder/'render_comparison.gd',folder/'sanglier_face_source_v001.png',folder/'sanglier_trois_quarts_source_v001.png',folder/'sanglier_arriere_trois_quarts_source_v001.png',folder/'hoof_regions.py',folder/'Apercu_directions.png']}}
(folder/'controle_pipeline.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8');print('BOAR_DIRECTIONS_PIPELINE passed=True',flush=True)
