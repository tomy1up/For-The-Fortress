"""Independent cubic-curve audit using Bernstein subdivision certificates.

No producer functions are imported. Unresolved intervals are rejected. This
certifies geometry and anchor accuracy, not anatomy or perceived fluidity.
"""
from pathlib import Path
from math import comb
import json,hashlib,argparse
import numpy as np

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

def certify(coefficients):
    active=coefficients.copy();ids=np.arange(len(active));bad=set();unresolved=set()
    lower=float('inf');depth=0
    while len(active):
        positive=active.min(axis=1)>0
        if np.any(positive):lower=min(lower,float(active[positive].min()))
        active=active[~positive];ids=ids[~positive]
        if not len(active):break
        negative=(active[:,0]<=0)|(active[:,-1]<=0)
        bad.update(ids[negative].tolist());active=active[~negative];ids=ids[~negative]
        if not len(active):break
        if depth>=20:
            unresolved.update(ids.tolist());break
        work=active.copy();left=np.empty_like(work);right=np.empty_like(work)
        left[:,0]=work[:,0];right[:,6]=work[:,6]
        for level in range(1,7):
            work=(work[:,:-1]+work[:,1:])*0.5
            left[:,level]=work[:,0];right[:,6-level]=work[:,-1]
        active=np.concatenate((left,right));ids=np.concatenate((ids,ids));depth+=1
    return {'failed_interval_faces':len(bad),'unresolved_interval_faces':len(unresolved),
            'maximum_subdivision_depth':depth,'certified_lower_area_ratio':lower if np.isfinite(lower) else None}

def self_check():
    # All have positive endpoints. One dips negative inside; a positive bowl
    # has negative Bernstein coefficients and must be resolved by subdivision.
    k=np.arange(7)
    quadratic=1-4*k/6+4*k*(k-1)/30
    assert certify(np.ones((1,7)))['failed_interval_faces']==0
    assert certify((quadratic-0.1)[None,:])['failed_interval_faces']==1
    positive=certify((quadratic+0.01)[None,:])
    assert positive['failed_interval_faces']==0 and positive['unresolved_interval_faces']==0 and positive['maximum_subdivision_depth']>0

def native_audit(folder):
    capture=folder/'captures/native_smooth_mesh.json'
    native=json.loads(capture.read_text(encoding='utf8'))
    assert native['renderer_sha256']==hashlib.sha256((Path(__file__).resolve().parent/'render_walk.gd').read_bytes()).hexdigest()
    results={}
    for layer,suffix in [('near',''),('far','_far')]:
        path=folder/('smooth_walk'+suffix+'.json')
        assert native[layer]['data_sha256']==hashlib.sha256(path.read_bytes()).hexdigest()
        data=json.loads(path.read_text(encoding='utf8'))
        q=np.asarray(data['frames']);m=np.asarray(data['tangents']);phases=np.asarray(data['phases'])
        fixed=np.asarray(data['fixed_indices']);worst=0.0;samples=0
        for sample in native[layer]['samples']:
            phase=sample['phase']%1.0
            index=min(int(np.searchsorted(phases,phase,side='right')-1),len(q)-2)
            dt=phases[index+1]-phases[index];t=(phase-phases[index])/dt
            # Evaluate the equivalent Bezier curve through de Casteljau, not
            # the Hermite expression used by the native renderer.
            controls=np.stack((q[index],q[index]+dt*m[index]/3,q[index+1]-dt*m[index+1]/3,q[index+1]),axis=1)
            controls[fixed,1]=(2*q[index,fixed]+q[index+1,fixed])/3
            controls[fixed,2]=(q[index,fixed]+2*q[index+1,fixed])/3
            for _ in range(3):controls=(1-t)*controls[:,:-1]+t*controls[:,1:]
            actual=np.asarray(sample['vertices'])
            assert actual.shape==controls[:,0].shape
            worst=max(worst,float(np.max(np.linalg.norm(actual-controls[:,0],axis=1))))
            samples+=len(actual)
        results[layer]={'mesh_vertices_compared':samples,'phases':len(native[layer]['samples']),
                        'maximum_rendered_coordinate_error_source_pixels':worst,'passed':worst<0.001}
    return {'readback_sha256':hashlib.sha256(capture.read_bytes()).hexdigest(),'renderer_sha256':native['renderer_sha256'],'layers':results,'passed':all(r['passed'] for r in results.values())}

def check(with_native=False,folder=None):
    self_check()
    folder=folder or Path(__file__).resolve().parent
    source_path=folder/'captures/correctives_input.json'
    source=json.loads(source_path.read_text(encoding='utf8'))
    fixed=np.asarray(source['fixed_indices'],dtype=int)
    results={}
    for layer,suffix in [('near',''),('far','_far')]:
        path=folder/('smooth_walk'+suffix+'.json')
        data=json.loads(path.read_text(encoding='utf8'))
        assert data['interpolation']=='cubic_free_linear_anchors'
        assert data['fixed_indices']==source['fixed_indices']
        assert data['source_input_sha256']==hashlib.sha256(source_path.read_bytes()).hexdigest()
        assert data['source_periodic_sha256']==hashlib.sha256((folder/('periodic_walk'+suffix+'.json')).read_bytes()).hexdigest()
        q=np.asarray(data['frames']);m=np.asarray(data['tangents']);phases=np.asarray(data['phases'])
        assert q.shape==m.shape and np.isfinite(q).all() and np.isfinite(m).all()
        assert phases[0]==0 and phases[-1]==1 and np.all(np.diff(phases)>0)
        assert q.shape[0]==len(phases)
        p=np.asarray(data['points']);f=np.asarray(data['triangles'],dtype=int)
        rest=cross(p[f[:,1]]-p[f[:,0]],p[f[:,2]]-p[f[:,0]])
        assert np.all(rest>0)
        dt=np.diff(phases)[:,None,None]
        controls=np.stack((q[:-1],q[:-1]+dt*m[:-1]/3,q[1:]-dt*m[1:]/3,q[1:]),axis=2)
        controls[:,fixed,1]=(2*q[:-1,fixed]+q[1:,fixed])/3
        controls[:,fixed,2]=(q[:-1,fixed]+2*q[1:,fixed])/3
        ab=controls[:,f[:,1]]-controls[:,f[:,0]]
        ac=controls[:,f[:,2]]-controls[:,f[:,0]]
        bernstein=np.zeros((*ab.shape[:2],7))
        for a in range(4):
            for b in range(4):bernstein[:,:,a+b]+=cross(ab[:,:,a],ac[:,:,b])*comb(3,a)*comb(3,b)/comb(6,a+b)
        certificate=certify((bernstein/rest[None,:,None]).reshape(-1,7))
        targets=np.asarray(source['frames' if layer=='near' else 'far_frames'])
        expected=np.empty((len(q),len(fixed),2))
        for vertex in range(len(fixed)):
            for axis in range(2):expected[:,vertex,axis]=np.interp(phases,np.linspace(0,1,65),targets[:,vertex,axis])
        target_error=float(np.max(np.linalg.norm(q[:,fixed]-expected,axis=2)))
        seam=float(np.max(np.linalg.norm(q[0]-q[-1],axis=1)))
        free=np.setdiff1d(np.arange(len(p)),fixed)
        free_seam_velocity=float(np.max(np.linalg.norm(m[0,free]-m[-1,free],axis=1)))
        linear_velocity=np.diff(q,axis=0)/dt
        fixed_jumps=np.linalg.norm(np.roll(linear_velocity[:,fixed],-1,axis=0)-linear_velocity[:,fixed],axis=2)
        result={'keys':len(q),'triangles':len(f),'cubic_intervals':len(q)-1,**certificate,
                'maximum_anchor_error_source_pixels':target_error,'loop_position_error_source_pixels':seam,
                'free_loop_velocity_error_source_pixels_per_cycle':free_seam_velocity,
                'free_knots_velocity_continuity':'shared cubic tangents at every knot',
                'remaining_linear_anchor_velocity_jump_source_pixels_per_cycle':float(fixed_jumps.max()),
                'data_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'artistically_approved':False}
        result['numerically_passed']=bool(not certificate['failed_interval_faces'] and not certificate['unresolved_interval_faces'] and target_error<0.001 and seam<0.02 and free_seam_velocity<0.001)
        results[layer]=result
    out={'schema':1,'variant':'smooth','scope':'cubic free trajectories and linear fixed anchors; not art approval',
         'certificate_self_checks':3,'layers':results,'passed':all(r['numerically_passed'] for r in results.values())}
    if with_native:
        out['native_readback']=native_audit(folder)
        out['passed']=out['passed'] and out['native_readback']['passed']
    (folder/'controle_interpolation_lissee.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf8')
    print(json.dumps(out))
    return out['passed']

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--native',action='store_true');parser.add_argument('--folder',type=Path)
    arguments=parser.parse_args()
    raise SystemExit(0 if check(arguments.native,arguments.folder) else 1)
