"""Audit controlled boar traversal, timing, rigid orientation and planted hooves."""
from pathlib import Path
import hashlib,json,math
import numpy as np
folder=Path(__file__).resolve().parent
scale=34/880*.85;stride=700.;pivot=np.array([750.,936.])
source=json.loads((folder/'captures/correctives_input.json').read_text(encoding='utf8'))
layers={}
for suffix in ['', '_far']:
    data=json.loads((folder/('smooth_walk'+suffix+'.json')).read_text(encoding='utf8'))
    points=np.array(data['points']);fixed=list(zip(source['fixed_labels'],source['fixed_indices']))
    ids={name:[i for label,i in fixed if label==name and points[i,1]>=930] for name in ['FrontNear2','HindNear3']}
    assert all(ids.values())
    layers[suffix]=(np.array(data['frames']),np.array(data['phases']),ids)
reports=[];native_rows=[]
for camp,name in enumerate(['alliance','horde']):
    data=json.loads((folder/f'captures/context_{name}.json').read_text(encoding='utf8'))
    assert (data['frames'],data['fps'],data['faction'],data['profile_loaded'])==(720,60,camp,False)
    assert data['controlled_spawn_schedule'] and data['imposed_impact']
    rows=data['records'];assert len(rows)==720
    path=np.array(data['path']);delta=np.diff(path,axis=0);lengths=np.linalg.norm(delta,axis=1)
    previous={};contacts=0;corner_changes=0;max_contact=0.;max_anchor=0.;max_geometry=0.;max_phase=0.;impact_samples=0
    directions=set()
    for frame,row in enumerate(rows):
        assert row['frame']==frame and abs(row['wall_time']-frame/60)<1e-9
        expected_time=min(frame/60,4)+2*max(0,frame/60-4.4)
        if row['enemies']: assert abs(row['elapsed']-expected_time)<1e-8
        current={}
        for e in row['enemies']:
            assert abs(e['distance']-(e['time']-e['spawn'])*1.65)<1e-8
            assert e['id'] in [0,1,2] and e['speed']==1.65
            remaining=e['distance'];logical=path[0];travel=0.;direction=None
            for a,b,length in zip(path[:-1],path[1:],lengths):
                d=b-a;projected=np.array([(d[0]-d[1])*27,(d[0]+d[1])*13.5]);screen_length=np.linalg.norm(projected)
                direction=projected/screen_length
                if remaining<length-1e-9:
                    logical=a+d*remaining/length;travel+=screen_length*remaining/length;break
                travel+=screen_length;remaining-=length;logical=b
            anchor=np.array([658+(logical[0]-logical[1])*27,174+(logical[0]+logical[1])*13.5])
            max_anchor=max(max_anchor,float(np.linalg.norm(anchor-e['anchor'])))
            assert max_anchor<.001
            phase=(e['travel']/(scale*stride)+e['id']*.137)%1
            max_phase=max(max_phase,abs(phase-e['phase']));assert max_phase<1e-8
            assert abs(travel-e['travel'])<.001 and np.linalg.norm(direction-e['direction'])<1e-6
            basis=np.array(e['basis']).T
            error=float(np.max(np.abs(basis.T@basis-np.eye(2)*scale**2)));max_geometry=max(max_geometry,error);assert error<1e-8
            directions.add(tuple(np.round(e['direction'],5)))
            old=previous.get(e['id']);feet={}
            if old and np.linalg.norm(np.array(old['direction'])-direction)>.001: corner_changes+=1
            if e['reaction']>0: impact_samples+=1
            for suffix,(frames,phases,ids) in layers.items():
                first=min(int(np.searchsorted(phases,e['phase'],side='right')-1),len(frames)-2)
                t=(e['phase']-phases[first])/(phases[first+1]-phases[first])
                for label,indices in ids.items():
                    start=(0 if label=='FrontNear2' else .5) if not suffix else (.5 if label=='FrontNear2' else 0)
                    stance=(e['phase']-start)%1<source['contact_duty']
                    points=frames[first,indices]*(1-t)+frames[first+1,indices]*t
                    world=np.array(e['anchor'])+(points-pivot)@basis.T
                    key=suffix+label;feet[key]={'stance':stance,'world':world}
                    if old and stance and old['feet'][key]['stance'] and e['reaction']==0 and old['reaction']==0 and np.linalg.norm(np.array(old['direction'])-direction)<1e-6:
                        error=float(np.max(np.linalg.norm(world-old['feet'][key]['world'],axis=1)))
                        max_contact=max(max_contact,error);contacts+=len(indices)
                        assert error<.003,(name,frame,key,error)
            current[e['id']]={**e,'feet':feet}
        previous=current
    assert directions=={(.89443,.44721),(-.89443,.44721),(.89443,-.44721)}
    assert corner_changes==18 and impact_samples>0
    paused=[rows[i]['enemies'] for i in range(240,265)];assert all(p==paused[0] for p in paused)
    assert rows[-1]['escaped']==3 and rows[-1]['hp']==17 and not rows[-1]['enemies']
    reports.append({'faction':name,'frames':720,'enemies':3,'route_corners':corner_changes,'projected_directions':len(directions),'contact_vertices_compared':contacts,'maximum_contact_drift_pixels':max_contact,'maximum_anchor_error_pixels':max_anchor,'maximum_rigid_basis_error':max_geometry,'maximum_phase_error':max_phase,'pause_frames':25,'impact_samples':impact_samples,'final_fortress_hp':17,'arrivals':3})
    native_rows.append(rows)
assert native_rows[0]==native_rows[1], 'Same neutral actors must follow the same simulation in both factions'
report={'passed':True,'scope':'Controlled three-boar traversal on the actual valley path; not a played mission or artistic approval','profile_loaded':False,'artistically_approved':False,'factions':reports,'neutral_simulations_identical':True,'corners':'Instant profile changes at segment boundaries; contact tests exclude turns and impact reaction. No frontal drawing or turn animation supplied.','source_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [folder/'render_context.gd',folder/'check_context.py',folder/'smooth_walk.json',folder/'smooth_walk_far.json']}}
(folder/'controle_contexte.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_CONTEXT_AUDIT',json.dumps(report))
