"""Replace the wolf-specific visibility diagnostics with the boar draw mask."""
from pathlib import Path
import json
import numpy as np
folder=Path(__file__).resolve().parent
report=json.loads((folder/'controle_lissage.json').read_text(encoding='utf8'))
for layer,suffix in [('near',''),('far','_far')]:
    periodic=json.loads((folder/('periodic_walk'+suffix+'.json')).read_text(encoding='utf8'))
    smooth=json.loads((folder/('smooth_walk'+suffix+'.json')).read_text(encoding='utf8'))
    p=np.asarray(smooth['points']);f=np.asarray(smooth['triangles']);q=np.asarray(smooth['frames'])[:-1]
    free=np.setdiff1d(np.arange(len(p)),smooth['fixed_indices']);visible=free
    if layer=='far':
        centers=p[f].mean(axis=1)
        mask=((centers[:,1]>690)&(centers[:,0]>780)&(centers[:,0]<1120))|((centers[:,1]>625)&(centers[:,0]>180)&(centers[:,0]<600))
        visible=np.intersect1d(np.unique(f[mask]),free)
    frames=np.asarray(periodic['frames']);phases=np.asarray(periodic['phases']);baseline=np.empty_like(q)
    for vertex in range(len(p)):
        for axis in range(2):baseline[:,vertex,axis]=np.interp(np.arange(len(q))/len(q),phases,frames[:,vertex,axis])
    before=np.roll(baseline,1,axis=0)-2*baseline+np.roll(baseline,-1,axis=0)
    after=np.roll(q,1,axis=0)-2*q+np.roll(q,-1,axis=0)
    report[layer]['visible_free_vertices']=len(visible)
    report[layer]['visible_free_second_difference_rms_before']=float(np.sqrt(np.mean(before[:,visible]**2)))
    report[layer]['visible_free_second_difference_rms_after']=float(np.sqrt(np.mean(after[:,visible]**2)))
report['visibility_scope']='Boar rendering mask; supersedes the shared wolf-specific visibility diagnostic. The all-face geometry certificate is independent.'
(folder/'controle_lissage.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print('BOAR_VISIBILITY_METRICS',report['far']['visible_free_vertices'])
