"""v0.260 : meilleure marge (30 compositions, tirages 7, 8, 9, 51 points de talent) en Héroïque complet (PV, champions, rappels et bonus héroïques, HEROIC=1),
avec la première offre de bonus puis en joueur avisé (POLICY=refwise), 40 missions. Comparaison avec la mesure v0.258 (PV et champions, sans rappel)."""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
missions = list(range(2, 201, 5))
chunks = [missions[i:i+4] for i in range(0, len(missions), 4)]
POLICIES = {"wise": "refwise"}


def job(item):
    policy, chunk, seed = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, chunk)), "SEED": str(seed), "POLICY": POLICIES[policy], "REFONLY": "", "REINFORCE": "", "V252": "", "HEROIC": "1"}
    env.pop("HPMUL", None); env.pop("FACTIONS", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    best = {}
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY":
            key = (int(p[1]), int(p[2])); b = best.get(key, 0.0)
            if p[5] == "victory" and float(p[7]) > 0: b = max(b, float(p[6])/float(p[7]))
            best[key] = b
    return policy, seed, best


raw = {}
with cf.ThreadPoolExecutor(6) as pool:
    for policy, seed, best in pool.map(job, [(policy, c, s) for policy in POLICIES for c in chunks for s in (7, 8, 9)]):
        for key, v in best.items(): raw.setdefault((policy, key), []).append(v)
out = {}
for f in (0, 1):
    for policy in POLICIES:
        out["%d,%s" % (f, policy)] = {str(m): st.mean(raw[(policy, (m, f))]) for m in missions if (policy, (m, f)) in raw}
pathlib.Path(sys.argv[1]).write_text(json.dumps(out), encoding="utf-8")
print("ok", {k: len(v) for k, v in out.items()})
