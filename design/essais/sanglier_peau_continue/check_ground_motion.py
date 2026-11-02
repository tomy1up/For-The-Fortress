"""Audit rendered-curve hoof positions against stationary world contacts."""
from pathlib import Path
import hashlib,json,math,re
import numpy as np
folder=Path(__file__).resolve().parent
source=json.loads((folder/'captures/correctives_input.json').read_text(encoding='utf8'))
labels=dict(zip(source['fixed_labels'],source['fixed_indices']))
stride=source['stride'];duty=source['contact_duty'];reports={}
for layer,suffix,offset in [('near','',np.array([0.,0.])),('far','_far',np.array([22.,-24.]))]:
    data=json.loads((folder/('smooth_walk'+suffix+'.json')).read_text(encoding='utf8'))
    q=np.asarray(data['frames']);phases=np.asarray(data['phases']);p=np.asarray(data['points'])
    for label,start,center,rest in [('FrontNear2',0 if layer=='near' else .5,np.array([930.,936.]),np.array([1010.,936.])),('HindNear3',.5 if layer=='near' else 0,np.array([445.,936.]),np.array([320.,936.]))]:
        indices=[i for name,i in zip(source['fixed_labels'],source['fixed_indices']) if name==label and p[i,1]>=930]
        assert indices
        worst=0.;count=0
        for phase in np.linspace(0,2,2049):
            contact_phase=(phase-start)%1.0;cycle=math.floor(phase-start)
            if contact_phase>duty:continue
            expected=p[indices]-rest+center+offset+np.array([(cycle+start+duty*.5)*stride,0])
            normalized=phase%1.0
            first=min(int(np.searchsorted(phases,normalized,side='right')-1),len(q)-2)
            t=(normalized-phases[first])/(phases[first+1]-phases[first])
            # Hoof vertices are hard anchors, therefore linearly interpolated.
            actual=q[first,indices]*(1-t)+q[first+1,indices]*t+np.array([phase*stride,0])
            worst=max(worst,float(np.max(np.linalg.norm(actual-expected,axis=1))));count+=len(indices)
        reports[layer+'_'+label]={'hoof_vertices':len(indices),'world_positions_compared':count,'maximum_world_contact_error_source_pixels':worst}
        assert worst<0.05,reports[layer+'_'+label]
trace=json.loads((folder/'captures/motion_trace.json').read_text(encoding='utf8'))
assert trace['movie'] and len(trace['frames'])==144
speeds=[]
for previous,current in zip(trace['frames'],trace['frames'][1:]):
    assert current['distance_source']>previous['distance_source']
    speed=(current['distance_source']-previous['distance_source'])*trace['profile_scale']/(current['time']-previous['time'])
    speeds.append(speed)
assert max(abs(value-trace['screen_speed']) for value in speeds)<1e-8
model=(folder.parents[2]/'prototype/scripts/valley_model.gd').read_text(encoding='utf8')
speed=float(re.search(r'"name": "Sprinter"[^\n]+"speed": ([0-9.]+)',model)[1])
# Godot Vector2.length() returns a 32-bit vector magnitude in this build.
expected_speed=speed*float(np.float32(math.hypot(27,13.5)))
assert abs(trace['screen_speed']-expected_speed)<1e-8
out={'scope':'2 cycles, actual linear hoof anchor paths and monotonic native preview ground trace; not artistic approval','passed':True,'contacts':reports,'screen_speed_pixels_per_second':trace['screen_speed'],'cycle_seconds':stride*trace['profile_scale']/trace['screen_speed'],'native_preview_frames':144,'renderer_sha256':hashlib.sha256((folder/'render_study.gd').read_bytes()).hexdigest()}
(folder/'controle_appuis_rendu.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf8')
print('BOAR_GROUND_AUDIT',json.dumps(out))
