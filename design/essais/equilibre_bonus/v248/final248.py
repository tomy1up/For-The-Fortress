"""Bilan v0.248 : marges réelles des trois réglages relevés, sur la table du dépôt, puis bilan de la campagne."""
import json, os, pathlib, shutil, statistics as st, subprocess, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
HERE = pathlib.Path(__file__).parent
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
def study(item):
    m, seed = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": "1", "SEED": str(seed)}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=900, creationflags=FLAGS)
    best, wins = 0.0, 0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0:
            wins += 1; best = max(best, float(p[6])/float(p[7]))
    return m, best, wins
raw = {}
with cf.ThreadPoolExecutor(3) as pool:
    for m, best, wins in pool.map(study, [(m, s) for m in (34, 37, 64) for s in (7, 8, 9)]):
        raw.setdefault(m, []).append((best, wins))
OUT = ROOT / "design/essais/equilibre_bonus/v248"
OUT.mkdir(parents=True, exist_ok=True)
camp = json.load(open(ROOT / "design/essais/equilibre_bonus/v246/marges_campagne.json"))
for m, v in raw.items():
    camp[f"{m},1"] = st.mean(x[0] for x in v)
    print("H", m, "marge %.1f" % (camp[f"{m},1"]*100), "victoires %.1f/30" % st.mean(x[1] for x in v), [round(x[0]*100) for x in v])
json.dump(camp, open(OUT / "marges_campagne.json", "w"))
for name in ("scan.json", "recherche.json"):
    shutil.copy(HERE / "v247" / name, OUT / name)
for name in ("scan247.py", "search247.py", "final248.py"):
    shutil.copy(HERE / name, OUT / name)
for f in (0, 1):
    v = [camp[f"{m},{f}"] for m in range(2, 201)]
    print("AH"[f], "moyenne %.1f" % (st.mean(v)*100), "dans", sum(.4 <= x <= .7 for x in v), "<40", sum(x < .4 for x in v), ">70", sum(x > .7 for x in v))
print("total dans", sum(.4 <= x <= .7 for x in camp.values()), "sur", len(camp), "<40", sum(x < .4 for x in camp.values()), ">70", sum(x > .7 for x in camp.values()))
