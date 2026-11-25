"""v0.253 : meilleure marge (30 compositions, première offre, tirages 7, 8 et 9) des 398 réglages avec l armée de référence avisée ; comparaison à la base v0.254."""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
out = pathlib.Path(sys.argv[1])
missions = [int(x) for x in sys.argv[2].split(",")] if len(sys.argv) > 2 else list(range(2, 201))
chunks = [missions[i:i+5] for i in range(0, len(missions), 5)]
def job(item):
    chunk, seed = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, chunk)), "SEED": str(seed), "POLICY": "", "REFONLY": "", "REINFORCE": "", "V252": ""}
    env.pop("HPMUL", None); env.pop("FACTIONS", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    best = {}
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY":
            key = (int(p[1]), int(p[2])); b, w = best.get(key, (0.0, 0))
            if p[5] == "victory" and float(p[7]) > 0: best[key] = (max(b, float(p[6])/float(p[7])), w+1)
            else: best.setdefault(key, (b, w))
    return seed, best
raw = {}
with cf.ThreadPoolExecutor(6) as pool:
    for i, (seed, best) in enumerate(pool.map(job, [(c, s) for c in chunks for s in (7, 8, 9)])):
        for key, v in best.items(): raw.setdefault(key, {})[seed] = v
        if i % 10 == 0: print(i, flush=True)
new = {"%d,%d" % k: st.mean(v[s][0] for s in (7, 8, 9)) for k, v in raw.items() if len(v) == 3}
out.write_text(json.dumps(new), encoding="utf-8")
base = json.load(open(ROOT / "design/essais/equilibre_bonus/v254/marges_campagne.json"))
inside = sum(1 for v in new.values() if 0.40 <= v <= 0.70 + 1e-9)
print("reglages", len(new), "dans la cible", inside, "en dessous", sum(1 for v in new.values() if v < 0.40), "au-dessus", sum(1 for v in new.values() if v > 0.70 + 1e-9))
print("variation moyenne %.1f points" % (100 * st.mean(new[k] - base[k] for k in new if k in base)))
moved = sorted(((k, base.get(k), v) for k, v in new.items() if not (0.40 <= v <= 0.70 + 1e-9)), key=lambda x: x[2])
print("hors cible :", [(k, round(b*100) if b is not None else None, round(v*100)) for k, b, v in moved])
