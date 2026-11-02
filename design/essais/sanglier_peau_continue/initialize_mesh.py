"""Create a feasible starting skin with the existing constrained-ARAP kernel.

Only the geometry definitions are loaded from the wolf authoring script; its
command-line driver is never executed. No game or approved motion is changed.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='2'
import ast
import hashlib
import json
from pathlib import Path
import numpy as np

folder=Path(__file__).resolve().parent
source_path=folder/'captures/correctives_input.json'
source=json.loads(source_path.read_text(encoding='utf8'))
fixed=np.asarray(source['fixed_indices'],dtype=np.int32)
kernel_path=folder.parent/'loup_peau_continue/bake_followed_motion.py'
tree=ast.parse(kernel_path.read_text(encoding='utf8'))
names={'cross','area','minimum_area','FollowedMesh'}
definitions=[item for item in tree.body if isinstance(item,(ast.FunctionDef,ast.ClassDef)) and item.name in names]
assert len(definitions)==len(names)
namespace={'np':np,'fixed':fixed}
exec(compile(ast.Module(body=definitions,type_ignores=[]),str(kernel_path),'exec'),namespace)
Mesh=namespace['FollowedMesh'];area=namespace['area']
p=np.asarray(source['points'],dtype=float);faces=np.asarray(source['triangles'],dtype=np.int32)
assert np.all(area(p,faces)>0)
original_area=float(area(p,faces).sum());flips=0
def cross(a,b):return a[0]*b[1]-a[1]*b[0]
def orient(a,b,c):return [a,b,c] if cross(p[b]-p[a],p[c]-p[a])>0 else [b,a,c]
for sweep in range(100):
    edges={}
    for index,face in enumerate(faces):
        for side in range(3):edges.setdefault(tuple(sorted((int(face[side]),int(face[(side+1)%3])))),[]).append(index)
    used=set();changed=0
    for (a,b),pair in edges.items():
        if len(pair)!=2 or any(index in used for index in pair):continue
        first,second=pair
        c=next(int(v) for v in faces[first] if v not in (a,b));d=next(int(v) for v in faces[second] if v not in (a,b))
        if cross(p[c]-p[d],p[a]-p[d])*cross(p[c]-p[d],p[b]-p[d])>=0:continue
        ac,bc=p[a]-p[c],p[b]-p[c];ad,bd=p[a]-p[d],p[b]-p[d]
        cot=np.dot(ac,bc)/abs(cross(ac,bc))+np.dot(ad,bd)/abs(cross(ad,bd))
        if cot>=-1e-7:continue
        faces[first]=orient(c,d,a);faces[second]=orient(d,c,b)
        changed+=1;used.update(pair)
    flips+=changed
    if not changed:break
assert abs(float(area(p,faces).sum())-original_area)<1e-5
print('BOAR_DELAUNAY edge_flips=',flips,flush=True)
reports={}
for layer,suffix,field in [('near','','frames'),('far','_far','far_frames')]:
    mesh=Mesh(p,faces)
    q=p.copy();start=p[fixed];target=np.asarray(source[field][0],dtype=float)
    progress=0.0;steps=0;shortened=0;relaxations=0;repair_report=None
    while progress<1.0-1e-12:
        step=min(0.05,1.0-progress)
        candidate=None
        while step>1/65536:
            candidate=mesh.advance(q,start+(target-start)*(progress+step))
            if candidate is not None:break
            shortened+=1;step*=0.5
        if candidate is None:
            if relaxations<1:
                for iteration in range(24):
                    relaxed=mesh.advance(q,start+(target-start)*progress)
                    assert relaxed is not None
                    q=relaxed
                relaxations+=1
                continue
            # Initialization is not part of the playback cycle. An exact-target
            # relaxation may find another feasible starting configuration when
            # the homotopy from the drawing is trapped at a near-flat triangle.
            blocked_progress=progress
            q[fixed]=target
            for iteration in range(200):q[mesh.free]=mesh.global_target(q,target)
            before=q.copy();raw_min=float((area(q,faces)/mesh.rest_area).min())
            movable=np.ones(len(p));movable[fixed]=0
            for repair in range(600):
                bad=np.flatnonzero(area(q,faces)<mesh.rest_area*0.03)
                if not len(bad):break
                for index in bad:
                    face=faces[index];a,b,c=q[face];value=cross(b-a,c-a)
                    if value>=mesh.rest_area[index]*0.03:continue
                    gradient=np.array([[b[1]-c[1],c[0]-b[0]],[c[1]-a[1],a[0]-c[0]],[a[1]-b[1],b[0]-a[0]]])*movable[face,None]
                    denominator=float(np.sum(gradient*gradient))
                    assert denominator>1e-15
                    q[face]+=gradient*((mesh.rest_area[index]*0.04-value)/denominator)
            assert float((area(q,faces)/mesh.rest_area).min())>0.025
            repair_report={'blocked_initialization_progress':blocked_progress,'raw_minimum_area_ratio':raw_min,
                           'projection_iterations':repair,'max_free_displacement_source_pixels':float(np.max(np.linalg.norm(q-before,axis=1)))}
            progress=1.0
            break
        progress+=step;q=candidate;steps+=1
        assert steps<2000
    ratio=area(q,faces)/mesh.rest_area
    error=float(np.max(np.linalg.norm(q[fixed]-target,axis=1)))
    assert float(ratio.min())>0 and error<1e-8
    result={'schema':2,'points':source['points'],'triangles':faces.tolist(),
            'frames':[q.round(9).tolist()],'stride':source['stride'],'artistically_approved':False}
    path=folder/('correctives_walk'+suffix+'.json')
    path.write_text(json.dumps(result,separators=(',',':'))+'\n',encoding='utf8')
    reports[layer]={'steps':steps,'shortened_steps':shortened,'relaxation_batches':relaxations,'minimum_area_ratio':float(ratio.min()),
                    'anchor_error_source_pixels':error,'output_sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
    reports[layer]['starting_pose_feasibility_repair']=repair_report
    print('BOAR_INITIAL',layer,json.dumps(reports[layer]),flush=True)
reports['kernel_sha256']=hashlib.sha256(kernel_path.read_bytes()).hexdigest()
reports['topology_edge_flips']=flips
reports['source_input_sha256']=hashlib.sha256(source_path.read_bytes()).hexdigest()
(folder/'controle_initialisation.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf8')
