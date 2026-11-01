"""Independent numerical audit of baked frames and their linear interpolation.

This cannot approve anatomy, timing, perceived weight, or the drawn correction.
"""
from pathlib import Path
import json
import hashlib
import argparse
import numpy as np

parser=argparse.ArgumentParser()
parser.add_argument('--variant',choices=['baseline','periodic'],default='baseline')
variant=parser.parse_args().variant
folder=Path(__file__).resolve().parent
source_path=folder/'captures/correctives_input.json'
source=json.loads(source_path.read_text(encoding='utf8'))
reports=json.loads((folder/'controle_correctifs.json').read_text(encoding='utf8'))
results={}

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

for layer,suffix in [('near',''),('far','_far')]:
    prefix='periodic_walk' if variant=='periodic' else 'correctives_walk'
    data_path=folder/(prefix+suffix+'.json')
    data=json.loads(data_path.read_text(encoding='utf8'))
    vertices=np.asarray(data['points'],dtype=np.float64)
    faces=np.asarray(data['triangles'],dtype=np.int32)
    frames=np.asarray(data['frames'],dtype=np.float64)
    assert np.isfinite(frames).all()
    assert reports[layer]['input_sha256']==hashlib.sha256(source_path.read_bytes()).hexdigest()
    if variant=='periodic':assert data['source_input_sha256']==hashlib.sha256(source_path.read_bytes()).hexdigest()
    phases=np.asarray(data.get('phases',np.linspace(0,1,len(frames))),dtype=float)
    assert len(phases)==len(frames) and phases[0]==0 and phases[-1]==1 and np.all(np.diff(phases)>0)
    rest=cross(vertices[faces[:,1]]-vertices[faces[:,0]],vertices[faces[:,2]]-vertices[faces[:,0]])
    assert np.all(rest>0)
    ab=frames[:,faces[:,1]]-frames[:,faces[:,0]]
    ac=frames[:,faces[:,2]]-frames[:,faces[:,0]]
    areas=cross(ab,ac)
    # Exact quadratic minimum over EVERY interpolation interval, not a few
    # sampled midpoints. Positive end frames alone do not ensure this.
    a0=areas[:-1]
    dab=np.diff(ab,axis=0);dac=np.diff(ac,axis=0)
    linear=cross(dab,ac[:-1])+cross(ab[:-1],dac)
    quadratic=cross(dab,dac)
    t=np.zeros_like(quadratic)
    np.divide(-linear,2*quadratic,out=t,where=quadratic>0)
    t=np.clip(t,0,1)
    minimum=np.minimum(np.minimum(areas[:-1],areas[1:]),a0+linear*t+quadratic*t*t)
    indices=np.asarray(source['fixed_indices'])
    source_targets=np.asarray(source['frames' if layer=='near' else 'far_frames'])
    desired=np.empty((len(phases),len(indices),2))
    for index in range(len(indices)):
        for axis in range(2):desired[:,index,axis]=np.interp(phases,np.linspace(0,1,65),source_targets[:,index,axis])
    target_error=float(np.max(np.linalg.norm(frames[:,indices]-desired,axis=-1)))
    seam=float(np.max(np.linalg.norm(frames[0]-frames[-1],axis=1)))
    velocities=np.diff(frames,axis=0)/np.diff(phases)[:,None,None]
    velocity_jumps=np.linalg.norm(np.roll(velocities,-1,axis=0)-velocities,axis=2)
    result={
        'frames':len(frames),'triangles':len(faces),
        'inverted_key_triangles':int(np.sum(areas<=0)),
        'inverted_interpolation_intervals':int(np.sum(minimum<=0)),
        'minimum_interpolated_area_ratio':float(np.min(minimum/rest)),
        'maximum_interpolated_endpoint_area_ratio':float(np.max(areas/rest)),
        'maximum_hard_target_error_source_pixels':target_error,
        'loop_seam_source_pixels':seam,
        'maximum_piecewise_velocity_jump_source_pixels_per_cycle':float(np.max(velocity_jumps)),
        'loop_velocity_jump_source_pixels_per_cycle':float(np.max(np.linalg.norm(velocities[0]-velocities[-1],axis=1))),
        'artistically_approved':False,
        'data_sha256':hashlib.sha256(data_path.read_bytes()).hexdigest(),
    }
    result['numerically_passed']=bool(result['inverted_key_triangles']==0 and result['inverted_interpolation_intervals']==0 and target_error<0.001 and seam<0.02)
    results[layer]=result

output={'schema':2,'variant':variant,'scope':'baked geometry and exact linear interpolation; not anatomy, contact pixels, or animation approval','layers':results,'passed':all(r['numerically_passed'] for r in results.values())}
(folder/('controle_interpolation_periodique.json' if variant=='periodic' else 'controle_interpolation.json')).write_text(json.dumps(output,indent=2)+'\n',encoding='utf8')
print(json.dumps(output,ensure_ascii=True))
raise SystemExit(0 if output['passed'] else 1)
