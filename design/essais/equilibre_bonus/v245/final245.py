"""Bilan final v0.245 : remesure les réglages abaissés par l'ajustement, puis écrit les marges retenues."""
import subprocess, os, re, json, pathlib, statistics as st, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v245"
SEEDS = (7, 8, 9)
av = json.load(open(OUT / "table_avant.json"))
cal = json.load(open(OUT / "table_apres.json"))
fin = json.load(open(OUT / "table_iter.json"))
pts = {k: {int(c): v for c, v in p.items()} for k, p in json.load(open(OUT / "points.json")).items()}
changed = sorted({m for f in "01" for m in range(2, 201) if cal[f][m-1] != fin[f][m-1]})


def run(job):
    seed, chunk = job
    env = {**os.environ, "SEED": str(seed), "MISSIONS": ",".join(map(str, chunk)), "PYTHONIOENCODING": "utf-8"}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", "C:/Projet/For the Fortress!/prototype", "--script", "res://tools/faction_study.gd"],
                       env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3000,
                       creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    return seed, [l for l in r.stdout.splitlines() if l.startswith("STUDY ")]


jobs = [(s, changed[i:i+4]) for s in SEEDS for i in range(0, len(changed), 4)]
best = {}
with cf.ThreadPoolExecutor(5) as pool:
    for seed, lines in pool.map(run, jobs):
        for l in lines:
            f = l.split()
            key = (int(f[1]), int(f[2]), seed)
            value = float(f[6])/float(f[7]) if f[5] == "victory" and float(f[7]) > 0 else 0.0
            best[key] = max(best.get(key, 0.0), value)
for m in changed:
    for fac in (0, 1):
        pts[f"{m},{fac}"][fin[str(fac)][m-1]] = st.mean(best[(m, fac, s)] for s in SEEDS)
final = {f"{m},{fac}": pts[f"{m},{fac}"][fin[str(fac)][m-1]] for m in range(2, 201) for fac in (0, 1)}
json.dump(final, open(OUT / "marges_finales.json", "w"))
BIOMES = [("Gué", 2, 20), ("Ardoises", 21, 40), ("Marais", 41, 60), ("Volcan", 61, 80), ("Citadelle", 81, 100), ("Désert", 101, 120), ("Mines", 121, 140), ("Cieux", 141, 160), ("Côtes", 161, 180), ("Nécropole", 181, 200)]
for n, a, b in BIOMES:
    for fac in (0, 1):
        v = [final[f"{m},{fac}"]*100 for m in range(a, b+1)]
        print(f"{n:10s} {'AH'[fac]} moyenne {st.mean(v):5.1f} min {min(v):5.1f} max {max(v):5.1f} coef {st.mean(fin[str(fac)][m-1] for m in range(a, b+1)):6.1f}  <40:{sum(x < 40 for x in v)} >70:{sum(x > 70 for x in v)}")
for fac in (0, 1):
    v = [final[f"{m},{fac}"] for m in range(2, 201)]
    print("AH"[fac], "moyenne %.1f" % (st.mean(v)*100), "dans 40-70 :", sum(.4 <= x <= .7 for x in v), "<40 :", sum(x < .4 for x in v), ">70 :", sum(x > .7 for x in v))
print("\nhors cible :")
for fac in (0, 1):
    print("AH"[fac], [(m, fin[str(fac)][m-1], round(final[f"{m},{fac}"]*100)) for m in range(2, 201) if not .4 <= final[f"{m},{fac}"] <= .7])
print("\nréglages abaissés après coup :")
for fac in (0, 1):
    print("AH"[fac], [(m, cal[str(fac)][m-1], fin[str(fac)][m-1], round(final[f"{m},{fac}"]*100)) for m in range(2, 201) if cal[str(fac)][m-1] != fin[str(fac)][m-1]])
print("sous la courbe :", [("AH"[f], m, fin[str(f)][m-1]) for f in (0, 1) for m in range(2, 201) if fin[str(f)][m-1] < 100])
print("FIN")
