"""v0.252 : meilleure marge (30 compositions, tirages 7, 8 et 9) des 18 réglages renforcés, lue dans le catalogue (sans REINFORCE), et nouvelle base de la campagne."""
import json, os, pathlib, subprocess, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
SETTINGS = [(16,0),(23,0),(33,0),(39,0),(72,0),(79,0),(105,0),(173,0),(178,0),(180,0),(11,1),(22,1),(38,1),(41,1),(44,1),(79,1),(131,1),(175,1)]
def job(item):
    (m, f), seed = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed), "POLICY": "", "REFONLY": "", "REINFORCE": ""}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best, wins = 0.0, 0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0:
            wins += 1; best = max(best, float(p[6])/float(p[7]))
    return m, f, seed, best, wins
raw = {}
with cf.ThreadPoolExecutor(6) as pool:
    for m, f, seed, best, wins in pool.map(job, [(s, seed) for s in SETTINGS for seed in (7, 8, 9)]):
        raw.setdefault((m, f), {})[seed] = (best, wins)
base = json.load(open(ROOT / "design/essais/equilibre_bonus/v251/marges_campagne.json"))
new = dict(base)
rows = []
for (m, f), v in sorted(raw.items(), key=lambda x: (x[0][1], x[0][0])):
    b = st.mean(v[s][0] for s in (7, 8, 9)); w = st.mean(v[s][1] for s in (7, 8, 9))
    new[f"{m},{f}"] = b
    rows.append({"mission": m, "faction": f, "avant": base[f"{m},{f}"], "apres": b, "tirages": [v[s][0] for s in (7, 8, 9)], "victoires": w})
    print("%s%-3d %3.0f -> %3.0f %% %s victoires %.1f" % ("AH"[f], m, base[f"{m},{f}"]*100, b*100, [round(v[s][0]*100) for s in (7, 8, 9)], w), flush=True)
out = ROOT / "design/essais/equilibre_bonus/v252"; out.mkdir(parents=True, exist_ok=True)
(out / "renforts_mesures.json").write_text(json.dumps(rows, indent=1), encoding="utf-8")
(out / "marges_campagne.json").write_text(json.dumps(new), encoding="utf-8")
inside = sum(1 for v in new.values() if 0.40 <= v <= 0.70 + 1e-9); above = sum(1 for v in new.values() if v > 0.70 + 1e-9); below = sum(1 for v in new.values() if v < 0.40)
print("campagne", inside, "dans la cible,", below, "en dessous,", above, "au-dessus sur", len(new))
