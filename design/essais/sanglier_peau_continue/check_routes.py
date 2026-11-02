"""Check the native route preview trace and its planted-hoof positions."""
from pathlib import Path
import hashlib,json,math
import numpy as np

folder=Path(__file__).resolve().parent
trace=json.loads((folder/'captures/routes_trace.json').read_text(encoding='utf8'))
assert (trace['frames'],trace['fps'],trace['profile_loaded'])==(240,60,False)
rows=trace['trace'];assert len(rows)==80
scale=34/880*.85;stride=700
speed=1.65*float(np.float32(math.hypot(27,13.5)))
max_geometry_error=0.;max_contact_error=0.;contacts=0
source=json.loads((folder/'captures/correctives_input.json').read_text(encoding='utf8'))
layers={}
for suffix in ['', '_far']:
    data=json.loads((folder/('smooth_walk'+suffix+'.json')).read_text(encoding='utf8'))
    layers[suffix]=(np.asarray(data['points']),np.asarray(data['frames']),np.asarray(data['phases']))

for row in rows:
    time=row['time'];factor=row['factor'];direction=np.array(row['direction'])
    elapsed=min(time,1.5)+2*min(max(time-1.5,0),.6)+max(0,time-2.5)
    assert abs(row['distance']-elapsed*speed)<1e-8
    assert abs(row['phase']-(row['distance']/(stride*scale))%1)<1e-8
    basis=np.array(row['basis']).T
    expected_scale=scale*factor
    error=np.max(np.abs(basis.T@basis-np.eye(2)*expected_scale**2))
    max_geometry_error=max(max_geometry_error,float(error))
    assert error<1e-8
    if row['reaction']>0:continue # An impact intentionally offsets planted hooves.
    assert np.linalg.norm(basis[:,0]/expected_scale-direction)<1e-6
    root_distance=row['distance']/scale
    full_phase=root_distance/stride
    start=np.array(row['anchor'])-direction*row['distance']*factor
    for suffix,offset in [('',np.array([0.,0.])),('_far',np.array([22.,-24.]))]:
        points,frames,phases=layers[suffix]
        first=min(int(np.searchsorted(phases,row['phase'],side='right')-1),len(frames)-2)
        t=(row['phase']-phases[first])/(phases[first+1]-phases[first])
        for label,leg_start,center,rest in [
            ('FrontNear2',0 if suffix=='' else .5,np.array([930.,936.]),np.array([1010.,936.])),
            ('HindNear3',.5 if suffix=='' else 0,np.array([445.,936.]),np.array([320.,936.]))]:
            if (full_phase-leg_start)%1>source['contact_duty']:continue
            ids=[i for name,i in zip(source['fixed_labels'],source['fixed_indices']) if name==label and points[i,1]>=930]
            actual_source=frames[first,ids]*(1-t)+frames[first+1,ids]*t
            actual=np.array(row['anchor'])+(actual_source-np.array([750.,936.]))@basis.T
            cycle=math.floor(full_phase-leg_start)
            expected_source=points[ids]-rest+center+offset+np.array([(cycle+leg_start+source['contact_duty']*.5)*stride,0])
            expected=start+(expected_source-np.array([750.,936.]))@basis.T
            error=float(np.max(np.linalg.norm(actual-expected,axis=1)))
            max_contact_error=max(max_contact_error,error);contacts+=len(ids)
            assert error<.001,error

for direction in {(tuple(r['direction'])) for r in rows}:
    for factor in [1,2]:
        samples={r['frame']:r for r in rows if tuple(r['direction'])==direction and r['factor']==factor}
        assert samples[126]['phase']==samples[149]['phase']
        assert samples[126]['anchor']==samples[149]['anchor']
        assert samples[174]['reaction']>0 and samples[188]['reaction']==0

report={'passed':True,'scope':'Controlled straight projected lanes; not a mission or artistic approval',
        'directions':4,'sizes':2,'native_trace_samples':len(rows),'contact_vertices_compared':contacts,
        'maximum_orthogonality_error':max_geometry_error,'maximum_contact_error_pixels':max_contact_error,
        'pause_checked':True,'double_speed_checked':True,'hit_pulse_and_recovery_checked':True,
        'profile_loaded':False,'artistically_approved':False,
        'source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [folder/'render_routes.gd',folder/'check_routes.py',folder/'smooth_walk.json',folder/'smooth_walk_far.json']}}
(folder/'controle_routes.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_ROUTES_AUDIT',json.dumps(report))
