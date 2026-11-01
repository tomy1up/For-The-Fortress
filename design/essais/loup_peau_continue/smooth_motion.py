"""Periodic smoothing of free skin trajectories, with shared cubic tangents.

Hard anchors retain their original linear paths exactly. This does not claim
that the entire skin is C1, nor does it approve the resulting anatomy.
"""
from pathlib import Path
from math import comb
import json,hashlib
import numpy as np

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

def curve_coefficients(q,u,fixed):
    following=np.roll(q,-1,axis=0);next_u=np.roll(u,-1,axis=0)
    difference=following-q
    coefficients=np.stack((q,u,3*difference-2*u-next_u,-2*difference+u+next_u),axis=2)
    coefficients[:,fixed,1]=difference[:,fixed]
    coefficients[:,fixed,2:]=0
    return coefficients

def area_polynomials(coefficients,faces):
    ab=coefficients[:,faces[:,1]]-coefficients[:,faces[:,0]]
    ac=coefficients[:,faces[:,2]]-coefficients[:,faces[:,0]]
    area=np.zeros((*ab.shape[:2],7))
    for a in range(4):
        for b in range(4):area[:,:,a+b]+=cross(ab[:,:,a],ac[:,:,b])
    return area

def low_areas(q,u,fixed,faces,rest):
    polynomials=area_polynomials(curve_coefficients(q,u,fixed),faces)
    bernstein=np.zeros_like(polynomials)
    for k in range(7):
        for j in range(k+1):bernstein[:,:,k]+=polynomials[:,:,j]*comb(k,j)/comb(6,j)
    candidates=np.argwhere(bernstein.min(axis=2)<rest*0.025)
    bad=[]
    for interval,face in candidates:
        coefficients=polynomials[interval,face]
        derivative=np.arange(1,7)*coefficients[1:]
        roots=np.polynomial.polynomial.polyroots(np.trim_zeros(derivative,'b')) if np.any(derivative) else []
        times=[0.0,1.0]+[float(r.real) for r in roots if abs(r.imag)<1e-7 and 0<r.real<1]
        values=np.polynomial.polynomial.polyval(times,coefficients)
        best=int(np.argmin(values))
        if values[best]<rest[face]*0.025:bad.append((interval,face,times[best],float(values[best])))
    return bad

def bake():
    folder=Path(__file__).resolve().parent
    source_path=folder/'captures/correctives_input.json'
    source=json.loads(source_path.read_text(encoding='utf8'))
    fixed=np.asarray(source['fixed_indices'],dtype=np.int32)
    reports={};count=128
    for layer,suffix in [('near',''),('far','_far')]:
        path=folder/('periodic_walk'+suffix+'.json')
        data=json.loads(path.read_text(encoding='utf8'))
        frames=np.asarray(data['frames']);phases=np.asarray(data['phases'])
        p=np.asarray(data['points']);faces=np.asarray(data['triangles'],dtype=np.int32)
        free=np.setdiff1d(np.arange(len(p)),fixed);mask=np.ones(len(p));mask[fixed]=0
        rest=cross(p[faces[:,1]]-p[faces[:,0]],p[faces[:,2]]-p[faces[:,0]])
        uniform=np.arange(count)/count
        q=np.empty((count,len(p),2))
        for vertex in range(len(p)):
            for axis in range(2):q[:,vertex,axis]=np.interp(uniform,phases,frames[:,vertex,axis])
        baseline=q.copy()
        # Smooth only skin vertices. All feet and other hard targets stay put.
        for _ in range(2):
            filtered=(np.roll(q,1,axis=0)+2*q+np.roll(q,-1,axis=0))*0.25
            q[:,free]=filtered[:,free]
        smoothed=q.copy()
        u=(np.roll(q,-1,axis=0)-np.roll(q,1,axis=0))*0.5
        u[:,fixed]=0
        history=[]
        for iteration in range(160):
            bad=low_areas(q,u,fixed,faces,rest)
            history.append({'iteration':iteration,'violating_interval_faces':len(bad)})
            if iteration%10==0 or not bad:print('SMOOTH_CURVE',layer,history[-1],flush=True)
            if not bad:break
            for interval,index,t,_ in bad:
                following=(interval+1)%count;face=faces[index]
                h00=2*t**3-3*t*t+1;h01=-2*t**3+3*t*t
                h10=t**3-2*t*t+t;h11=t**3-t*t
                sample=h00*q[interval,face]+h01*q[following,face]+h10*u[interval,face]+h11*u[following,face]
                # Hard vertices use the same linear path as the baseline.
                selected=mask[face]==0
                sample[selected]=(1-t)*q[interval,face[selected]]+t*q[following,face[selected]]
                a,b,c=sample;value=cross(b-a,c-a)
                if value>=rest[index]*0.025:continue
                gradient=np.array([[b[1]-c[1],c[0]-b[0]],
                                   [c[1]-a[1],a[0]-c[0]],
                                   [a[1]-b[1],b[0]-a[0]]])*mask[face,None]
                tangent_weight=16.0
                denominator=float(np.sum(gradient*gradient))*(h00*h00+h01*h01+tangent_weight*(h10*h10+h11*h11))
                if denominator<1e-15:continue
                delta=gradient*((rest[index]*0.04-value)/denominator)
                q[interval,face]+=h00*delta;q[following,face]+=h01*delta
                u[interval,face]+=tangent_weight*h10*delta;u[following,face]+=tangent_weight*h11*delta
        assert np.max(np.abs(q[:,fixed]-baseline[:,fixed]))==0
        result={'schema':3,'interpolation':'cubic_free_linear_anchors','points':data['points'],'triangles':data['triangles'],
                'frames':np.concatenate((q,q[:1])).round(9).tolist(),
                'tangents':(np.concatenate((u,u[:1]))*count).round(9).tolist(),
                'phases':np.linspace(0,1,count+1).tolist(),'fixed_indices':fixed.tolist(),
                'stride':data['stride'],'artistically_approved':False,
                'source_input_sha256':hashlib.sha256(source_path.read_bytes()).hexdigest(),
                'source_periodic_sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        (folder/('smooth_walk'+suffix+'.json')).write_text(json.dumps(result,separators=(',',':'))+'\n',encoding='utf8')
        before=np.roll(baseline,1,axis=0)-2*baseline+np.roll(baseline,-1,axis=0)
        after=np.roll(q,1,axis=0)-2*q+np.roll(q,-1,axis=0)
        if layer=='far':
            centers=p[faces].mean(axis=1)
            visible_faces=((centers[:,1]>575)&(centers[:,0]>880))|((centers[:,1]>560)&(centers[:,0]>330)&(centers[:,0]<700)&((centers[:,0]>450)|(centers[:,1]>680)))
            visible_free=np.intersect1d(np.unique(faces[visible_faces]),free)
        else:visible_free=free
        reports[layer]={'iterations':history,'remaining_violations':len(bad),'artistically_approved':False,
                        'maximum_free_position_change_source_pixels':float(np.max(np.linalg.norm(q[:,free]-baseline[:,free],axis=2))),
                        'maximum_feasibility_position_change_source_pixels':float(np.max(np.linalg.norm(q-smoothed,axis=2))),
                        'free_second_difference_rms_before':float(np.sqrt(np.mean(before[:,free]**2))),
                        'free_second_difference_rms_after':float(np.sqrt(np.mean(after[:,free]**2))),
                        'visible_free_vertices':len(visible_free),
                        'visible_free_second_difference_rms_before':float(np.sqrt(np.mean(before[:,visible_free]**2))),
                        'visible_free_second_difference_rms_after':float(np.sqrt(np.mean(after[:,visible_free]**2)))}
        print('SMOOTH_FINISHED',layer,json.dumps({k:v for k,v in reports[layer].items() if k!='iterations'}),flush=True)
    (folder/'controle_lissage.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf8')

if __name__=='__main__':bake()
