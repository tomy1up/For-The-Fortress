"""Render, audit and encode the isolated boar placement study on monitor 2."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys,time

folder=Path(__file__).resolve().parent;repo=folder.parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine',type=Path,default=repo.parent/'.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe')
parser.add_argument('--ffmpeg',type=Path,default=repo.parent/'.tools/video_encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
args=parser.parse_args();assert args.engine.is_file() and args.ffmpeg.is_file()
(folder/'captures').mkdir(exist_ok=True)
sys.path.insert(0,str(repo/'prototype/tests'))
from export_sources import verify_sources
manifest=json.loads((repo/'dist/For_the_Fortress_v0.109_Windows_x64/VERSION.json').read_text(encoding='utf8'))
assert verify_sources(manifest,repo/'prototype')==74
records=[]

def run(name,command,marker=None):
    started=time.monotonic()
    result=subprocess.run([str(v) for v in command],cwd=repo,capture_output=True,text=True,encoding='utf8',errors='replace',timeout=180,
                          creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    log=result.stdout+result.stderr
    (folder/'captures'/('routes_'+name+'.log')).write_text(log,encoding='utf8')
    assert result.returncode==0 and 'ERROR:' not in log and 'SCRIPT ERROR' not in log,(name,log[-3000:])
    if marker: assert marker in log,(name,log[-1000:])
    records.append({'step':name,'exit_code':result.returncode,'seconds':round(time.monotonic()-started,3)})
    print('OK',name,flush=True)

run('engine',[args.engine,'--version'],'4.7.2.stable.official.ed1daf0bf')
run('native',[args.engine,'--screen','1','--minimized','--path',repo/'prototype','--script',folder/'render_routes.gd','--quit-after','700'],'BOAR_ROUTES frames=240 profile_loaded=false')
run('audit',[sys.executable,folder/'check_routes.py'],'BOAR_ROUTES_AUDIT')
video=folder/'sanglier_routes_essai.mp4'
run('encode',[args.ffmpeg,'-y','-loglevel','error','-framerate','60','-i',folder/'captures/routes_frames/%04d.png','-c:v','libx264','-crf','18','-pix_fmt','yuv420p',video])
run('decode',[args.ffmpeg,'-v','error','-i',video,'-f','null','-'])
from PIL import Image
assert len(list((folder/'captures/routes_frames').glob('*.png')))==240
assert Image.open(folder/'captures/routes_frames/0000.png').size==(1280,840)
assert verify_sources(manifest,repo/'prototype')==74
assert hashlib.sha256((repo/'dist/For_the_Fortress_v0.109_Windows_x64/For_the_Fortress.exe').read_bytes()).hexdigest()==manifest['executable_sha256']
for frame in [0,90,174,239]:
    source=folder/f'captures/routes_frames/{frame:04d}.png'
    (folder/f'Apercu_routes_{frame:04d}.png').write_bytes(source.read_bytes())
report={'passed':True,'scope':'Isolated boar on straight diagnostic lanes; no campaign or profile access',
        'steps':records,'frames':240,'fps':60,'seconds':4,'width':1280,'height':840,'decode_ok':True,
        'video':video.name,'video_sha256':hashlib.sha256(video.read_bytes()).hexdigest(),
        'production_v0109_sources_unchanged':74,'executable_unchanged':True,'artistically_approved':False,
        'source_sha256':{p.relative_to(repo).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in [folder/'build_routes.py',folder/'render_routes.gd',folder/'check_routes.py',folder/'render_study.gd',folder.parent/'loup_peau_continue/render_walk.gd',repo/'prototype/scripts/valley_view.gd',repo/'prototype/scripts/enemy_walk_art.gd']}}
(folder/'controle_routes_pipeline.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_ROUTES_PIPELINE passed=True',flush=True)
