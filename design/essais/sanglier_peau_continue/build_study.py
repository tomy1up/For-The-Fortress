"""Rebuild and verify the isolated animation study, including its native video."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,sys,time
folder=Path(__file__).resolve().parent;repo=folder.parents[2]
shared=folder.parent/'loup_peau_continue'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine',type=Path,default=repo.parent/'.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe')
parser.add_argument('--ffmpeg',type=Path,default=repo.parent/'.tools/video_encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
args=parser.parse_args()
assert args.engine.is_file() and args.ffmpeg.is_file()
(folder/'captures').mkdir(exist_ok=True)
records=[]
def run(name,command,marker=None):
    started=time.monotonic()
    result=subprocess.run([str(arg) for arg in command],cwd=repo,capture_output=True,text=True,encoding='utf8',errors='replace',timeout=120,
                          creationflags=subprocess.CREATE_NO_WINDOW if os.name=='nt' else 0)
    log=result.stdout+result.stderr
    (folder/'captures'/('build_'+name+'.log')).write_text(log,encoding='utf8')
    assert result.returncode==0 and 'ERROR:' not in log and 'SCRIPT ERROR' not in log,(name,log[-4000:])
    if marker:assert marker in log,(name,'Expected completion marker missing',log[-1000:])
    records.append({'step':name,'seconds':round(time.monotonic()-started,3),'exit_code':result.returncode})
    print('OK',name,flush=True)
    return log
def native(script,graphical=False,extra=()):
    return [args.engine,*(['--screen','1','--minimized'] if graphical else ['--headless']),
            '--path',repo/'prototype','--script',folder/script,'--quit-after','400',*extra]
engine_version=run('engine_version',[args.engine,'--version'],'4.7.2.stable.official.ed1daf0bf').strip()
run('export',native('export_motion.gd'),'BOAR_MOTION_INPUT')
run('initial', [sys.executable,folder/'initialize_mesh.py'],'BOAR_INITIAL far')
for name in ['bake_followed_motion','close_followed_motion','smooth_motion']:
    run(name,[sys.executable,shared/(name+'.py'),'--folder',folder])
run('visible_metrics',[sys.executable,folder/'audit_visible_metrics.py'],'BOAR_VISIBILITY_METRICS')
run('geometry',[sys.executable,shared/'check_smooth_motion.py','--folder',folder])
run('native_readback',native('readback_study.gd',True),'BOAR_NATIVE_READBACK')
run('independent_audit',[sys.executable,folder/'audit_study.py'],'BOAR_RENDERER_AND_CURVE_AUDIT passed=True')
run('movie',native('render_study.gd',True,('--','--movie')),'BOAR_STUDY frames=144')
run('contacts',[sys.executable,folder/'check_ground_motion.py'],'BOAR_GROUND_AUDIT')
video=folder/'sanglier_allure_rapide_essai.mp4'
run('encode',[args.ffmpeg,'-y','-loglevel','error','-framerate','60','-i',folder/'captures/rapide_frames/%04d.png','-c:v','libx264','-crf','18','-pix_fmt','yuv420p',video])
assert video.is_file() and video.stat().st_size>0
for name in ['controle_interpolation_lissee.json','controle_appuis_rendu.json']:
    assert json.loads((folder/name).read_text(encoding='utf8'))['passed']
production=json.loads((repo/'dist/For_the_Fortress_v0.109_Windows_x64/VERSION.json').read_text(encoding='utf-8-sig')) if (repo/'dist/For_the_Fortress_v0.109_Windows_x64/VERSION.json').is_file() else None
if production:
    assert all(hashlib.sha256((repo/'prototype'/name).read_bytes()).hexdigest()==digest for name,digest in production['source_sha256'].items())
result={'scope':'isolated boar authoring, not a game release or artistic approval','passed':True,'steps':records,
        'video':{'path':video.name,'sha256':hashlib.sha256(video.read_bytes()).hexdigest(),'frames':144,'fps':60,'seconds':2.4},
        'production_v0109_sources_unchanged':production is not None,'artistically_approved':False}
dependencies=list(folder.glob('*.gd'))+list(folder.glob('*.py'))+[folder/'sanglier_proche_source_v001.png',folder/'smooth_walk.json',folder/'smooth_walk_far.json']
dependencies += [shared/name for name in ['bake_followed_motion.py','close_followed_motion.py','smooth_motion.py','check_smooth_motion.py','render_walk.gd','walk_skin.gd','continuous_skin.gd']]
dependencies += [folder.parent/'animation_loup_appuis/grounded_foot.gd']
result['engine_version']=engine_version
result['source_sha256']={path.relative_to(repo).as_posix():hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(set(path.resolve() for path in dependencies))}
(folder/'controle_pipeline.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
print('BOAR_STUDY_PIPELINE passed=True',flush=True)
