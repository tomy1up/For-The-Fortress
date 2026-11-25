"""v0.256 : grille de renforts (REINFORCE) sur les 5 derniers réglages corrigeables ; référence en joueur avisé (POLICY=refwise) : meilleure marge (30 compositions) et référence (REFONLY), tirages 7, 8, 9."""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
SETTINGS = [(2,0),(3,0),(16,0),(23,0),(33,0),(39,0),(72,0),(79,0),(105,0),(173,0),(178,0),(180,0),(2,1),(3,1),(11,1),(22,1),(23,1),(38,1),(39,1),(41,1),(44,1),(79,1),(131,1),(175,1)]
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from ladder252 import LADDER
out = pathlib.Path(sys.argv[1])
names = sys.argv[2].split(",") if len(sys.argv) > 2 else list(LADDER)
settings = [tuple(map(int, x.split("/"))) for x in sys.argv[3].split(",")] if len(sys.argv) > 3 else SETTINGS
def godot(env):
    full = {**os.environ, **env}
    for k in ("HPMUL", "OLDREF", "FIRST", "LAST"): full.pop(k, None)
    return subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=full, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS).stdout
def job(item):
    (m, f), name, seed = item
    base = {"MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed), "REINFORCE": ";".join(LADDER[name])}
    best, wins = 0.0, 0
    for line in godot({**base, "POLICY": "", "REFONLY": ""}).splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0:
            wins += 1; best = max(best, float(p[6])/float(p[7]))
    ref = None
    for line in godot({**base, "POLICY": "refwise", "REFONLY": "1"}).splitlines():
        p = line.split()
        if len(p) == 6 and p[0] == "REF": ref = [p[3], int(p[4]), int(p[5])]
    return m, f, name, seed, best, wins, ref
data = json.loads(out.read_text(encoding="utf-8")) if out.exists() else {}
items = [(s, n, seed) for s in settings for n in names for seed in (7, 8, 9) if f"{s[0]},{s[1]},{n},{seed}" not in data]
with cf.ThreadPoolExecutor(6) as pool:
    for i, (m, f, name, seed, best, wins, ref) in enumerate(pool.map(job, items)):
        data[f"{m},{f},{name},{seed}"] = {"best": best, "wins": wins, "ref": ref}
        if i % 20 == 0:
            out.write_text(json.dumps(data), encoding="utf-8"); print(i, len(items), flush=True)
out.write_text(json.dumps(data), encoding="utf-8"); print("done", len(data))
