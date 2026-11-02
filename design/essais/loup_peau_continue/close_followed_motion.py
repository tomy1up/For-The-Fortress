"""Author an explicitly periodic mesh path and audit interpolation constraints.

The closing displacement is distributed over the entire cycle and reported.
Adjacent phase keys share feasibility corrections; isolated pose repair is not
used. This is geometry authoring, not a statement of artistic approval.
"""
from pathlib import Path
import json,hashlib,argparse
import numpy as np

parser=argparse.ArgumentParser();parser.add_argument('--folder',type=Path)
folder=parser.parse_args().folder or Path(__file__).resolve().parent
input_path=folder/'captures/correctives_input.json'
source=json.loads(input_path.read_text(encoding='utf8'))
fixed=np.asarray(source['fixed_indices'],dtype=np.int32)
reports={}
followed_report=json.loads((folder/'controle_suivi.json').read_text(encoding='utf8'))

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

def minima(q,faces):
    # q is the unique cyclic key array; the last interval ends at q[0].
    other=np.roll(q,-1,axis=0)
    ab=q[:,faces[:,1]]-q[:,faces[:,0]];ac=q[:,faces[:,2]]-q[:,faces[:,0]]
    dab=other[:,faces[:,1]]-other[:,faces[:,0]]-ab
    dac=other[:,faces[:,2]]-other[:,faces[:,0]]-ac
    value=cross(ab,ac);linear=cross(dab,ac)+cross(ab,dac);quadratic=cross(dab,dac)
    t=np.zeros_like(value);np.divide(-linear,2*quadratic,out=t,where=quadratic>0)
    t=np.clip(t,0,1);middle=value+linear*t+quadratic*t*t
    end=cross(ab+dab,ac+dac)
    choose=np.argmin(np.stack((value,middle,end),axis=0),axis=0)
    return np.minimum(np.minimum(value,middle),end),np.where(choose==0,0,np.where(choose==2,1,t))

for layer,suffix in [('near',''),('far','_far')]:
    path=folder/'captures'/('followed_walk'+suffix+'.json')
    assert followed_report[layer]['complete_cycle']
    assert followed_report[layer]['output_sha256']==hashlib.sha256(path.read_bytes()).hexdigest()
    data=json.loads(path.read_text(encoding='utf8'))
    assert data['source_input_sha256']==hashlib.sha256(input_path.read_bytes()).hexdigest()
    assert data['source_builder_sha256']==hashlib.sha256((Path(__file__).resolve().parent/'bake_followed_motion.py').read_bytes()).hexdigest()
    q=np.asarray(data['frames'],dtype=float);phases=np.asarray(data['phases'])
    baseline=q.copy();faces=np.asarray(data['triangles'],dtype=np.int32);p=np.asarray(data['points'])
    rest=cross(p[faces[:,1]]-p[faces[:,0]],p[faces[:,2]]-p[faces[:,0]])
    drift=q[-1]-q[0]
    q+=(0.5-phases[:,None,None])*drift
    q=q[:-1].copy()  # one variable for the common first/last pose
    before=q.copy();movable=np.ones(len(p));movable[fixed]=0
    history=[]
    for iteration in range(200):
        values,times=minima(q,faces)
        bad=np.argwhere(values<rest*0.02)
        history.append({'iteration':iteration,'interval_face_constraints':len(bad),'minimum_ratio':float(np.min(values/rest))})
        if not len(bad):break
        for interval,index in bad:
            following=(interval+1)%len(q);face=faces[index];t=times[interval,index]
            a,b,c=q[interval,face]*(1-t)+q[following,face]*t
            value=cross(b-a,c-a)
            gradient=np.array([[b[1]-c[1],c[0]-b[0]],
                               [c[1]-a[1],a[0]-c[0]],
                               [a[1]-b[1],b[0]-a[0]]])*movable[face,None]
            norm=float(np.sum(gradient*gradient))*((1-t)**2+t*t)
            if norm<1e-15:continue
            delta=gradient*((rest[index]*0.03-value)/norm)
            q[interval,face]+=(1-t)*delta;q[following,face]+=t*delta
    values,_=minima(q,faces)
    frames=np.concatenate((q,q[:1]),axis=0).round(6)
    report={'raw_seam_source_pixels':float(np.max(np.linalg.norm(drift,axis=1))),
            'maximum_distributed_closing_displacement_source_pixels':float(np.max(np.linalg.norm(drift,axis=1)))*0.5,
            'maximum_shared_feasibility_correction_source_pixels':float(np.max(np.linalg.norm(q-before,axis=2))),
            'iterations':history,'minimum_interpolated_area_ratio_before_rounding':float(np.min(values/rest)),
            'artistically_approved':False,'scope':'explicit periodic authoring with exact interval constraints; no raster changes'}
    reports[layer]=report
    out={'schema':2,'points':data['points'],'triangles':data['triangles'],'stride':data['stride'],
         'frames':frames.tolist(),'phases':data['phases'],'artistically_approved':False,
         'source_input_sha256':hashlib.sha256(input_path.read_bytes()).hexdigest(),
         'source_followed_sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
    (folder/('periodic_walk'+suffix+'.json')).write_text(json.dumps(out,separators=(',',':'))+'\n',encoding='utf8')
    print('PERIODIC_MOTION',layer,json.dumps({k:v for k,v in report.items() if k!='iterations'}),flush=True)
(folder/'controle_fermeture.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf8')
