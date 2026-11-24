"""v0.251 : marges des quatre mines à une entrée après l'écart de 0,6 s (30 compositions, tirages 7, 8 et 9), comparées à la v0.250."""
import json, os, pathlib, statistics as st, subprocess, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
def study(item):
    m, seed = item
    env = {**os.environ, "MISSIONS": str(m), "SEED": str(seed)}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=1800, creationflags=FLAGS)
    out = {}
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY":
            key = int(p[2])
            best, wins = out.get(key, (0.0, 0))
            if p[5] == "victory" and float(p[7]) > 0:
                out[key] = (max(best, float(p[6])/float(p[7])), wins+1)
            else:
                out.setdefault(key, (best, wins))
    return m, seed, out
raw = {}
with cf.ThreadPoolExecutor(4) as pool:
    for m, seed, out in pool.map(study, [(m, s) for m in (121, 122, 125, 128) for s in (7, 8, 9)]):
        for f, v in out.items(): raw.setdefault((m, f), []).append(v)
before = json.load(open(ROOT / "design/essais/equilibre_bonus/v248/marges_campagne.json"))
result = {}
for (m, f), v in sorted(raw.items()):
    best = st.mean(x[0] for x in v); wins = st.mean(x[1] for x in v)
    result[f"{m},{f}"] = {"avant": before[f"{m},{f}"], "apres": best, "victoires": wins}
    print("AH"[f], m, "marge %.0f -> %.0f" % (before[f"{m},{f}"]*100, best*100), "victoires %.1f/30" % wins, [round(x[0]*100) for x in v], flush=True)
json.dump(result, open(pathlib.Path(__file__).parent / "marges251.json", "w"))
