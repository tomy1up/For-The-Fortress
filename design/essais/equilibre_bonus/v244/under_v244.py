import subprocess, os, statistics as st, concurrent.futures as cf, json
GODOT="C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
MISSIONS=[23,63,64,65,66,68,69]
MULS=[98,96,94,92,90,88,86,84,82,80]
def run(job):
    mul,seed=job
    env=dict(os.environ); env.update({"SEED":str(seed),"MISSIONS":",".join(map(str,MISSIONS)),"HPMUL":str(mul),"PYTHONIOENCODING":"utf-8"})
    r=subprocess.run([GODOT,"--headless","--path","C:/Projet/For the Fortress!/prototype","--script","res://tools/faction_study.gd"],env=env,capture_output=True,text=True,encoding="utf-8",errors="replace",timeout=1500,creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
    return mul,seed,[l for l in r.stdout.splitlines() if l.startswith("STUDY ")]
best={}; ref={}
with cf.ThreadPoolExecutor(5) as pool:
    for mul,seed,lines in pool.map(run,[(m,s) for m in MULS for s in (7,8,9)]):
        for l in lines:
            f=l.split(); m,fac,tree,comp=int(f[1]),int(f[2]),int(f[3]),f[4]
            v=float(f[6])/float(f[7]) if f[5]=="victory" else 0.0
            k=(mul,m,fac,seed); best[k]=max(best.get(k,0.0),v)
            if (fac==0 and tree==1 and comp=="011") or (fac==1 and tree==0 and comp=="002"): ref[k]=v
for fac in (0,1):
    for m in MISSIONS:
        print("AH"[fac],m," ".join(f"{mul}:{st.mean(best[(mul,m,fac,s)] for s in (7,8,9))*100:.0f}/{ref.get((mul,m,fac,7),-1)*100:.0f}" for mul in MULS),flush=True)
json.dump({f"{k}":v for k,v in best.items()},open("v244/under.json","w"))
