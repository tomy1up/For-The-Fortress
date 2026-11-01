"""Independent numerical audit of baked frames and their linear interpolation.

This cannot approve anatomy, timing, perceived weight, or the drawn correction.
"""
from pathlib import Path
import json
import hashlib
import numpy as np

folder=Path(__file__).resolve().parent
source_path=folder/'captures/correctives_input.json'
source=json.loads(source_path.read_text(encoding='utf8'))
reports=json.loads((folder/'controle_correctifs.json').read_text(encoding='utf8'))
results={}

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

for layer,suffix in [('near',''),('far','_far')]:
    data=json.loads((folder/('correctives_walk'+suffix+'.json')).read_text(encoding='utf8'))
    vertices=np.asarray(data['points'],dtype=np.float64)
    faces=np.asarray(data['triangles'],dtype=np.int32)
    frames=np.asarray(data['frames'],dtype=np.float64)
    assert np.isfinite(frames).all()
    assert reports[layer]['input_sha256']==hashlib.sha256(source_path.read_bytes()).hexdigest()
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
    desired=np.asarray(source['frames' if layer=='near' else 'far_frames'])
    target_error=float(np.max(np.linalg.norm(frames[:,indices]-desired,axis=-1)))
    seam=float(np.max(np.linalg.norm(frames[0]-frames[-1],axis=1)))
    result={
        'frames':len(frames),'triangles':len(faces),
        'inverted_key_triangles':int(np.sum(areas<=0)),
        'inverted_interpolation_intervals':int(np.sum(minimum<=0)),
        'minimum_interpolated_area_ratio':float(np.min(minimum/rest)),
        'maximum_hard_target_error_source_pixels':target_error,
        'loop_seam_source_pixels':seam,
        'artistically_approved':False,
    }
    result['numerically_passed']=bool(result['inverted_key_triangles']==0 and result['inverted_interpolation_intervals']==0 and target_error<0.001 and seam<0.02)
    results[layer]=result

output={'schema':1,'scope':'baked geometry and exact linear interpolation; not anatomy, contact pixels, or animation approval','layers':results,'passed':all(r['numerically_passed'] for r in results.values())}
(folder/'controle_interpolation.json').write_text(json.dumps(output,indent=2)+'\n',encoding='utf8')
print(json.dumps(output,ensure_ascii=True))
raise SystemExit(0 if output['passed'] else 1)
