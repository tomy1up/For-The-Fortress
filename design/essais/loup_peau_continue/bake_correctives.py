"""Author pose-space vertex corrections. Reads geometry; never edits raster pixels."""
import os
os.environ['OPENBLAS_NUM_THREADS']='2'
from pathlib import Path
import json,hashlib,time,argparse
import numpy as np

parser=argparse.ArgumentParser();parser.add_argument('--folder',type=Path)
folder=parser.parse_args().folder or Path(__file__).resolve().parent
input_file=folder/'captures/correctives_input.json'
data=json.loads(input_file.read_text(encoding='utf8'))
p=np.asarray(data['points'],dtype=np.float64)
faces=np.asarray(data['triangles'],dtype=np.int32)
def cross(a,b):return a[0]*b[1]-a[1]*b[0]
def orient(face):
    a,b,c=face
    return [a,b,c] if cross(p[b]-p[a],p[c]-p[a])>0 else [b,a,c]
faces=np.asarray([orient(face) for face in faces],dtype=np.int32)
source_area_before=float(np.sum([cross(p[b]-p[a],p[c]-p[a]) for a,b,c in faces]))
flips=0
for sweep in range(100):
    neighbors={}
    for number,face in enumerate(faces):
        for k in range(3):neighbors.setdefault(tuple(sorted((int(face[k]),int(face[(k+1)%3])))),[]).append(number)
    changed=0;used=set()
    for (a,b),pair in neighbors.items():
        if len(pair)!=2 or any(number in used for number in pair):continue
        first,second=pair
        c=next(int(x) for x in faces[first] if x not in (a,b))
        d=next(int(x) for x in faces[second] if x not in (a,b))
        if cross(p[c]-p[d],p[a]-p[d])*cross(p[c]-p[d],p[b]-p[d])>=0:continue
        ac,bc=p[a]-p[c],p[b]-p[c]
        ad,bd=p[a]-p[d],p[b]-p[d]
        cot=np.dot(ac,bc)/max(abs(cross(ac,bc)),1e-12)+np.dot(ad,bd)/max(abs(cross(ad,bd)),1e-12)
        if cot>=-1e-7:continue
        faces[first]=orient([c,d,a]);faces[second]=orient([d,c,b])
        used.update(pair);changed+=1
    flips+=changed
    if not changed:break
source_area_after=float(np.sum([cross(p[b]-p[a],p[c]-p[a]) for a,b,c in faces]))
assert abs(source_area_after-source_area_before)<1e-4,(source_area_before,source_area_after)
data['triangles']=faces.tolist()
print('CONSTRAINED_DELAUNAY edge_flips=',flips,'area_error=',source_area_after-source_area_before,flush=True)
fixed=np.asarray(data['fixed_indices'],dtype=np.int32)
free=np.setdiff1d(np.arange(len(p)),fixed)
def matrix(values):
    a,b,c,d,x,y=values
    return np.array([[a,c,x],[b,d,y],[0.0,0.0,1.0]],dtype=np.float64)
rest_matrices={name:np.linalg.inv(matrix(value)) for name,value in data['rest_matrices'].items()}
precise_near=[];precise_far=[]
for frame in data['pose_matrices']:
    transforms={name:matrix(value) for name,value in frame.items()}
    near=[];far=[]
    for index,spec in zip(fixed,data['fixed_specs']):
        point=np.array([*p[index],1.0]);label=spec['label']
        if label=='SurfaceBlend':
            shoulder,pelvis,head,tail=spec['surface_weights']
            body=(transforms['Torso']@rest_matrices['Torso']@point)*(1.0-shoulder-pelvis)
            body+=(transforms['Shoulder']@rest_matrices['Shoulder']@point)*shoulder
            body+=(transforms['Pelvis']@rest_matrices['Pelvis']@point)*pelvis
            value=body*(1.0-head)+(transforms['Head']@rest_matrices['Head']@point)*head
            value=value*(1.0-tail)+(transforms['Tail']@rest_matrices['Tail']@point)*tail
            far_value=value+transforms['Torso']@np.array([20.0,-35.0,0.0])
        else:
            value=transforms[label]@rest_matrices[label]@point
            other=label.replace('FrontNear','FrontFar').replace('HindNear','HindFar')
            far_value=transforms[other]@rest_matrices[other]@(point+np.array([20.0,-35.0,0.0])) if other!=label else value+transforms['Torso']@np.array([20.0,-35.0,0.0])
        near.append(value[:2]);far.append(far_value[:2])
    precise_near.append(near);precise_far.append(far)
conversion_error=max(float(np.max(np.abs(np.asarray(data['frames'])-precise_near))),float(np.max(np.abs(np.asarray(data['far_frames'])-precise_far))))
assert conversion_error<0.001,conversion_error
data['frames']=np.asarray(precise_near);data['far_frames']=np.asarray(precise_far)
print('PRECISE_CONSTRAINTS native_conversion_error=',conversion_error,flush=True)
rest_edges=np.stack((p[faces[:,1]]-p[faces[:,0]],p[faces[:,2]]-p[faces[:,0]]),axis=-1)
rest_inverse=np.linalg.inv(rest_edges)
areas=np.abs(np.linalg.det(rest_edges))*0.5
gradients=np.stack((-rest_inverse[:,0,:]-rest_inverse[:,1,:],rest_inverse[:,0,:],rest_inverse[:,1,:]),axis=1)
stiffness=areas[:,None,None]*np.einsum('tik,tjk->tij',gradients,gradients)
laplacian=np.zeros((len(p),len(p)))
for a in range(3):
    for b in range(3):np.add.at(laplacian,(faces[:,a],faces[:,b]),stiffness[:,a,b])
inverse=np.linalg.inv(laplacian[np.ix_(free,free)])
boundary=laplacian[np.ix_(free,fixed)]

def solve(q,target,iterations=40):
    q=q.copy();q[fixed]=target
    for _ in range(iterations):
        current_edges=np.stack((q[faces[:,1]]-q[faces[:,0]],q[faces[:,2]]-q[faces[:,0]]),axis=-1)
        deformation=current_edges@rest_inverse
        angle=np.arctan2(deformation[:,1,0]-deformation[:,0,1],deformation[:,0,0]+deformation[:,1,1])
        co,si=np.cos(angle),np.sin(angle)
        rotated=np.stack((co[:,None]*gradients[:,:,0]-si[:,None]*gradients[:,:,1],si[:,None]*gradients[:,:,0]+co[:,None]*gradients[:,:,1]),axis=-1)*areas[:,None,None]
        rhs=np.zeros_like(q)
        np.add.at(rhs,faces.reshape(-1),rotated.reshape(-1,2))
        new=inverse@(rhs[free]-boundary@target)
        difference=np.max(np.abs(new-q[free]));q[free]=new
        if difference<0.005:break
    return q

def area(points):
    ab=points[faces[:,1]]-points[faces[:,0]]
    ac=points[faces[:,2]]-points[faces[:,0]]
    return ab[:,0]*ac[:,1]-ab[:,1]*ac[:,0]

def untangle(points,rest_area):
    """Repair flipped geometry while preserving every hard target exactly.

    This is a geometric feasibility projection, NOT an artistic correction.
    Keep both pre/post reports so a clean mesh cannot stand in for art approval.
    """
    result=points.copy(); movable=np.ones(len(p));movable[fixed]=0.0
    for iteration in range(300):
        bad=np.flatnonzero(area(result)<rest_area*0.05)
        if not len(bad):return result,iteration
        for index in bad:
            face=faces[index];a,b,c=result[face]
            value=cross(b-a,c-a)
            if value>=rest_area[index]*0.05:continue
            gradient=np.array([[b[1]-c[1],c[0]-b[0]],
                               [c[1]-a[1],a[0]-c[0]],
                               [a[1]-b[1],b[0]-a[0]]])
            gradient*=movable[face,None]
            denominator=float(np.sum(gradient*gradient))
            if denominator<1e-15:continue
            result[face]+=gradient*((rest_area[index]*0.075-value)/denominator)
    return result,300

started=time.monotonic();rest_area=area(p);reports={}
for layer,source_frames in [('near',data['frames']),('far',data['far_frames'])]:
    q=p.copy();first=np.asarray(source_frames[0])
    for t in np.linspace(0.05,1.0,20):q=solve(q,p[fixed]*(1.0-t)+first*t,80)
    # Settle the complete cycle before recording; never hide a loop seam by
    # copying the first frame over the last one.
    for settle in range(3):
        for targets in source_frames:q=solve(q,np.asarray(targets),120)
        print('SETTLED_CYCLE',layer,settle+1,flush=True)
    frames=[];ratios=[];raw_ratios=[];repairs=[]
    for frame,targets in enumerate(source_frames):
        q=solve(q,np.asarray(targets),120)
        raw=area(q)/rest_area
        raw_ratios.append({'frame':frame,'inverted':int(np.sum(raw<=0)),'minimum':float(np.min(raw))})
        repaired,iterations=untangle(q,rest_area)
        repairs.append({'iterations':iterations,'max_displacement_source_pixels':float(np.max(np.linalg.norm(repaired-q,axis=1)))})
        # Do not feed a feasibility repair back into ARAP's cycle state.
        rendered=repaired
        ratio=area(rendered)/rest_area
        ratios.append({'frame':frame,'inverted':int(np.sum(ratio<=0)),'minimum':float(np.min(ratio)),'maximum':float(np.max(ratio))})
        frames.append(rendered.round(6).tolist())
        if frame%16==0:print('CORRECTIVE_FRAME',layer,frame,ratios[-1],flush=True)
    report={'schema':3,'method':'triangle ARAP with fixed-target feasibility projection; no raster editing',
            'input_sha256':hashlib.sha256(input_file.read_bytes()).hexdigest(),
            'vertices':len(p),'triangles':len(faces),'constraints':len(fixed),'frames':len(frames),'stride':data['stride'],
            'metrics':ratios,'seconds':round(time.monotonic()-started,2),'artistically_approved':False,
            'loop_seam_source_pixels':float(np.max(np.linalg.norm(np.asarray(frames[0])-np.asarray(frames[-1]),axis=1))),
            'before_feasibility_repair':raw_ratios,'geometric_repairs':repairs,
            'status':'research_only_requires_drawn_pose_corrections'}
    reports[layer]=report
    suffix='' if layer=='near' else '_far'
    (folder/('correctives_walk'+suffix+'.json')).write_text(json.dumps({'points':data['points'],'triangles':data['triangles'],'frames':frames,'stride':data['stride']},separators=(',',':'))+'\n',encoding='utf8')
    print('CORRECTIVES_FINISHED',layer,json.dumps({k:v for k,v in report.items() if k not in ('metrics','before_feasibility_repair','geometric_repairs')}),flush=True)
(folder/'controle_correctifs.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf8')
