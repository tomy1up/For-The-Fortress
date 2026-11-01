"""Follow constrained motion continuously instead of repairing isolated poses.

Experimental geometry only. A feasible mesh is not an approved wolf walk.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='2'
from pathlib import Path
import json,time,hashlib
import numpy as np

folder=Path(__file__).resolve().parent
source=json.loads((folder/'captures/correctives_input.json').read_text(encoding='utf8'))
fixed=np.asarray(source['fixed_indices'],dtype=np.int32)
reports={}

def cross(a,b):return a[...,0]*b[...,1]-a[...,1]*b[...,0]

def area(q,f):return cross(q[f[:,1]]-q[f[:,0]],q[f[:,2]]-q[f[:,0]])

def minimum_area(a,b,f):
    ab=a[f[:,1]]-a[f[:,0]];ac=a[f[:,2]]-a[f[:,0]]
    dab=b[f[:,1]]-b[f[:,0]]-ab;dac=b[f[:,2]]-b[f[:,0]]-ac
    c=cross(ab,ac);linear=cross(dab,ac)+cross(ab,dac);quadratic=cross(dab,dac)
    t=np.zeros(len(f));np.divide(-linear,2*quadratic,out=t,where=quadratic>0)
    t=np.clip(t,0,1)
    return np.minimum(np.minimum(c,area(b,f)),c+linear*t+quadratic*t*t)

class FollowedMesh:
    def __init__(self,points,faces):
        self.p=points;self.f=faces;self.free=np.setdiff1d(np.arange(len(points)),fixed)
        rest_edges=np.stack((points[faces[:,1]]-points[faces[:,0]],points[faces[:,2]]-points[faces[:,0]]),axis=-1)
        self.rest_inverse=np.linalg.inv(rest_edges)
        self.rest_area=area(points,faces);self.areas=self.rest_area*0.5
        self.grad=np.stack((-self.rest_inverse[:,0,:]-self.rest_inverse[:,1,:],self.rest_inverse[:,0,:],self.rest_inverse[:,1,:]),axis=1)
        stiffness=self.areas[:,None,None]*np.einsum('tik,tjk->tij',self.grad,self.grad)
        lap=np.zeros((len(points),len(points)))
        for a in range(3):
            for b in range(3):np.add.at(lap,(faces[:,a],faces[:,b]),stiffness[:,a,b])
        self.inverse=np.linalg.inv(lap[np.ix_(self.free,self.free)])
        self.boundary=lap[np.ix_(self.free,fixed)]
        self.free_lookup=np.full(len(points),-1,dtype=int);self.free_lookup[self.free]=np.arange(len(self.free))

    def global_target(self,q,target):
        f=self.f
        edges=np.stack((q[f[:,1]]-q[f[:,0]],q[f[:,2]]-q[f[:,0]]),axis=-1)
        deformation=edges@self.rest_inverse
        angle=np.arctan2(deformation[:,1,0]-deformation[:,0,1],deformation[:,0,0]+deformation[:,1,1])
        co,si=np.cos(angle),np.sin(angle)
        rotated=np.stack((co[:,None]*self.grad[:,:,0]-si[:,None]*self.grad[:,:,1],si[:,None]*self.grad[:,:,0]+co[:,None]*self.grad[:,:,1]),axis=-1)*self.areas[:,None,None]
        rhs=np.zeros_like(q);np.add.at(rhs,f.reshape(-1),rotated.reshape(-1,2))
        destination=self.inverse@(rhs[self.free]-self.boundary@target)
        current_area=area(q,f)
        active=np.flatnonzero(current_area<self.rest_area*0.3)
        if not len(active):return destination
        # Positive quadratic area resistance, linearized at this pose. Solve
        # its low-rank update without weakening the exact inversion barrier.
        u=np.zeros((len(self.free),2,len(active)));v=[]
        for column,index in enumerate(active):
            face=f[index];a,b,c=q[face]
            gradient=np.array([[b[1]-c[1],c[0]-b[0]],
                               [c[1]-a[1],a[0]-c[0]],
                               [a[1]-b[1],b[0]-a[0]]])
            activation=float(np.clip((0.3-current_area[index]/self.rest_area[index])/0.15,0,1))
            activation=activation*activation*(3.0-2.0*activation)
            weight=np.sqrt(100.0/self.rest_area[index])*activation
            for vertex,grad in zip(face,gradient):
                free_index=self.free_lookup[vertex]
                if free_index>=0:u[free_index,:,column]=grad*weight
            v.append((self.rest_area[index]*0.3-current_area[index])*weight)
        li=np.empty_like(u)
        for axis in range(2):li[:,axis,:]=self.inverse@u[:,axis,:]
        flat=u.reshape(-1,len(active));preconditioned=li.reshape(-1,len(active))
        delta=destination-q[self.free]
        adjustment=np.linalg.solve(np.eye(len(active))+flat.T@preconditioned,np.asarray(v)-flat.T@delta.reshape(-1))
        return destination+(preconditioned@adjustment).reshape(-1,2)

    def advance(self,previous,target):
        q=previous.copy();q[fixed]=target
        # Extend the target motion harmonically to free vertices before the
        # shape solve. Freezing them while roots move creates an artificial
        # collision barrier even for an ordinary translation.
        q[self.free]-=self.inverse@(self.boundary@(target-previous[fixed]))
        if np.any(minimum_area(previous,q,self.f)<=self.rest_area*0.001):return None
        for iteration in range(8):
            destination=self.global_target(q,target)
            alpha=1.0;accepted=False
            for line in range(18):
                trial=q.copy();trial[self.free]=q[self.free]+alpha*(destination-q[self.free])
                if np.all(minimum_area(previous,trial,self.f)>self.rest_area*0.001):
                    accepted=True;break
                alpha*=0.5
            if not accepted:break
            movement=np.max(np.abs(trial-q));q=trial
            if movement<0.001:break
        return q

started=time.monotonic()
for layer,suffix in [('near',''),('far','_far')]:
    data=json.loads((folder/('correctives_walk'+suffix+'.json')).read_text(encoding='utf8'))
    points=np.asarray(data['points'],dtype=float);faces=np.asarray(data['triangles'],dtype=np.int32)
    targets=np.asarray(source['frames' if layer=='near' else 'far_frames'],dtype=float)
    target_drift=targets[-1]-targets[0]
    mesh=FollowedMesh(points,faces)
    q=np.asarray(data['frames'][0],dtype=float)
    history=[];complete=True;last_keys=[]
    def target_at(phase):
        at=phase*64;first=min(int(at),63);t=at-first
        return targets[first]*(1-t)+targets[first+1]*t+(0.5-phase)*target_drift
    # The target regularization is subpixel and explicitly audited below.
    q[fixed]=target_at(0.0)
    for cycle in range(6):
        beginning=q.copy();keys=[(0.0,q.copy())];phase=0.0;rejected=0
        while phase<1.0-1e-12:
            next_grid=min((int(np.floor((phase+1e-12)*128))+1)/128.0,1.0)
            step=next_grid-phase
            candidate=None
            while step>=1.0/32768.0:
                candidate=mesh.advance(q,target_at(phase+step))
                if candidate is not None:break
                rejected+=1;step*=0.5
            if candidate is None:
                complete=False;break
            phase+=step;q=candidate;keys.append((phase,q.copy()))
            if len(keys)>4096:complete=False;break
        seam=float(np.max(np.linalg.norm(q-beginning,axis=1)))
        item={'cycle':cycle,'completed_phase':phase,'keys':len(keys),'shortened_steps':rejected,'seam_source_pixels':seam}
        history.append(item);last_keys=keys
        print('FOLLOWED_CYCLE',layer,item,flush=True)
        if not complete or seam<0.01:break
    report={'complete_cycle':complete,'cycles':history,'artistically_approved':False,'seconds':round(time.monotonic()-started,2),
            'maximum_target_regularization_source_pixels':float(np.max(np.linalg.norm(target_drift,axis=1)))*0.5,
            'method':'forward constrained ARAP with exact interval feasibility; adaptive time steps'}
    reports[layer]=report
    if complete:
        out={'schema':2,'points':data['points'],'triangles':data['triangles'],'stride':data['stride'],
             'frames':[v.round(6).tolist() for _,v in last_keys],'phases':[t for t,_ in last_keys],
             'artistically_approved':False}
        out['source_input_sha256']=hashlib.sha256((folder/'captures/correctives_input.json').read_bytes()).hexdigest()
        out['source_builder_sha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
        output_path=folder/'captures'/('followed_walk'+suffix+'.json')
        output_path.write_text(json.dumps(out,separators=(',',':'))+'\n',encoding='utf8')
        report['output_sha256']=hashlib.sha256(output_path.read_bytes()).hexdigest()
(folder/'controle_suivi.json').write_text(json.dumps(reports,indent=2)+'\n',encoding='utf8')
