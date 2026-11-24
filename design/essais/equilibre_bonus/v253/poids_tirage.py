"""v0.253 : armée de référence, premier choix naturel, 40 missions, deux factions, tirages 7 à 16 ; offres d'avant (V252=1) et d'après la v0.253."""
import os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
missions = list(range(2, 201, 5))
def job(item):
    seed, old = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, missions)), "SEED": str(seed), "CODES": "-1", "FACTIONS": "0,1", "V252": "1" if old else ""}
    for k in ("HPMUL", "REINFORCE", "REFONLY", "POLICY"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/bonus_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    return old, [l.split() for l in r.stdout.splitlines() if l.startswith("BONUS ")]
res = {}
with cf.ThreadPoolExecutor(6) as pool:
    for old, rows in pool.map(job, [(s, o) for s in range(7, 17) for o in (True, False)]):
        for p in rows: res.setdefault((old, int(p[2])), []).append((float(p[6]) / float(p[7]) if p[5] == "victory" else 0.0, p[5] == "victory", int(p[1]), int(p[3])))
lines = []
for f in (0, 1):
    for old in (True, False):
        v = res[(old, f)]
        hp = [x[0] for x in v]
        per = {}
        for x in v: per.setdefault(x[2], []).append(x[0])
        spread = st.mean(max(p) - min(p) for p in per.values())
        lines.append("%s %s : victoires %.0f %%, PV moyens %.0f %%, ecart-type %.0f, ecart moyen entre tirages d'une mission %.0f points (%d parties)" % ("Alliance Horde".split()[f], "avant" if old else "apres", 100*st.mean(x[1] for x in v), 100*st.mean(hp), 100*st.pstdev(hp), 100*spread, len(v)))
open(sys.argv[1], "w", encoding="utf-8").write("\n".join(lines)); print("\n".join(lines))
