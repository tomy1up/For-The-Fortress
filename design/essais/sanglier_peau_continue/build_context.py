"""Render and audit the experimental boar on the actual valley path."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys,time
folder=Path(__file__).resolve().parent;repo=folder.parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine',type=Path,default=repo.parent/'.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe')
parser.add_argument('--ffmpeg',type=Path,default=repo.parent/'.tools/video_encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
parser.add_argument('--reuse-frames',action='store_true',help='Audit and encode existing native captures without rendering again.')
args=parser.parse_args();assert args.engine.is_file() and args.ffmpeg.is_file()
sys.path.insert(0,str(repo/'prototype/tests'))
from export_sources import verify_sources
manifest_path=repo/'dist/For_the_Fortress_v0.112_Windows_x64/VERSION.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8-sig'))
assert verify_sources(manifest,repo/'prototype')==75
exe=manifest_path.parent/'For_the_Fortress.exe'
assert hashlib.sha256(exe.read_bytes()).hexdigest()==manifest['executable_sha256']
records=[]
def run(name,command,marker=None,timeout=240):
    started=time.monotonic()
    result=subprocess.run([str(v) for v in command],cwd=repo,capture_output=True,text=True,encoding='utf8',errors='replace',timeout=timeout,creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    log=result.stdout+result.stderr
    (folder/'captures'/('context_'+name+'.log')).write_text(log,encoding='utf8')
    assert result.returncode==0 and 'ERROR:' not in log and 'SCRIPT ERROR' not in log,(name,log[-3000:])
    if marker: assert marker in log,(name,log[-1000:])
    records.append({'step':name,'exit_code':result.returncode,'seconds':round(time.monotonic()-started,3)})
    print('OK',name,flush=True);return result
run('engine',[args.engine,'--version'],'4.7.2.stable.official.ed1daf0bf')
for camp,name in enumerate(['alliance','horde']):
    if not args.reuse_frames:
        command=[args.engine,'--screen','1','--minimized','--path',repo/'prototype','--script',folder/'render_context.gd','--quit-after','3000']
        if camp: command+=['--','--horde']
        run('native_'+name,command,'BOAR_CONTEXT frames=720 profile_loaded=false faction='+str(camp))
    paths=sorted((folder/('captures/context_'+name)).glob('*.png'))
    assert len(paths)==720 and paths[0].name=='0000.png' and paths[-1].name=='0719.png'
run('audit',[sys.executable,folder/'check_context.py'],'BOAR_CONTEXT_AUDIT')
videos=[]
for name in ['alliance','horde']:
    video=folder/('sanglier_sur_le_gue_'+name+'.mp4')
    run('encode_'+name,[args.ffmpeg,'-y','-loglevel','error','-framerate','60','-i',folder/('captures/context_'+name+'/%04d.png'),'-frames:v','720','-c:v','libx264','-crf','18','-pix_fmt','yuv420p',video])
    decoded=run('decode_'+name,[args.ffmpeg,'-v','error','-i',video,'-progress','pipe:1','-nostats','-f','null','-'])
    frame_counts=[int(line.split('=',1)[1]) for line in decoded.stdout.splitlines() if line.startswith('frame=')]
    assert frame_counts and frame_counts[-1]==720 and 'progress=end' in decoded.stdout
    videos.append({'path':video.name,'frames':720,'fps':60,'seconds':12,'width':1280,'height':800,'decode_ok':True,'sha256':hashlib.sha256(video.read_bytes()).hexdigest()})
assert verify_sources(manifest,repo/'prototype')==75
assert hashlib.sha256(exe.read_bytes()).hexdigest()==manifest['executable_sha256']
report={'passed':True,'scope':'Isolated controlled traversal with the production valley renderer and experimental boar override; no campaign or profile','render_reused':args.reuse_frames,'videos':videos,'steps':records,'production_version':'0.112','production_sources_unchanged':75,'production_executable_sha256':manifest['executable_sha256'],'profile_loaded':False,'artistically_approved':False,'source_sha256':{p.relative_to(repo).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in [folder/'build_context.py',folder/'render_context.gd',folder/'check_context.py',folder/'render_routes.gd',folder/'render_study.gd',folder.parent/'loup_peau_continue/render_walk.gd',repo/'prototype/scripts/valley_model.gd',repo/'prototype/scripts/valley_view.gd']}}
(folder/'controle_contexte_pipeline.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_CONTEXT_PIPELINE passed=True',flush=True)
