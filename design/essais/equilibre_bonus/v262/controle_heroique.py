"""v0.262 (lot 5) : contrôle du calibrage de l'Héroïque sur d'autres tirages que ceux du calibrage (7, 8, 9).
Héroïque complet avec les coefficients du catalogue (HEROIC=1, sans HEROIC_COEF), 200 missions, deux factions, joueur avisé (POLICY=refwise),
meilleure des 30 compositions, 51 points de talent. Usage : python controle_heroique.py <sortie.json> [tirages, ex. 4,5,6] [workers]"""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
SEEDS = [int(x) for x in (sys.argv[2] if len(sys.argv) > 2 else "4,5,6").split(",")]
WORKERS = int(sys.argv[3]) if len(sys.argv) > 3 else 14


def job(item):
    mission, seed = item
    env = {**os.environ, "MISSIONS": str(mission), "SEED": str(seed), "POLICY": "refwise", "REFONLY": "", "REINFORCE": "", "V252": "", "HEROIC": "1"}
    for k in ("HPMUL", "FACTIONS", "HEROIC_HP", "HEROIC_COEF"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best = {}
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY":
            key = int(p[2]); b = best.get(key, 0.0)
            if p[5] == "victory" and float(p[7]) > 0: b = max(b, float(p[6]) / float(p[7]))
            best[key] = b
    return mission, seed, best


raw = {}
with cf.ThreadPoolExecutor(WORKERS) as pool:
    for mission, seed, best in pool.map(job, [(m, s) for m in range(1, 201) for s in SEEDS]):
        for faction, v in best.items(): raw.setdefault("%d,%d" % (mission, faction), {})[str(seed)] = v
pathlib.Path(sys.argv[1]).write_text(json.dumps(raw), encoding="utf-8")
for faction in (0, 1):
    means = [st.mean(raw["%d,%d" % (m, faction)].values()) for m in range(1, 201) if "%d,%d" % (m, faction) in raw]
    print("faction", faction, "missions", len(means), "marge", round(st.mean(means), 3), "cible", sum(0.40 <= v <= 0.70 for v in means),
          "sous 40", sum(v < 0.40 for v in means), "au-dessus de 70", sum(v > 0.70 for v in means), flush=True)
