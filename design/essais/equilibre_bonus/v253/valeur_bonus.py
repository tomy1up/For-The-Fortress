"""v0.253 : valeur de chaque bonus imposé au premier choix de l'armée de référence (tools/bonus_study.gd), 40 missions, deux factions, tirages 7, 8 et 9."""
import os, pathlib, subprocess, sys, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
out = pathlib.Path(sys.argv[1])
missions = [int(x) for x in sys.argv[2].split(",")] if len(sys.argv) > 2 else list(range(2, 201, 5))
codes = sys.argv[3] if len(sys.argv) > 3 else ",".join(str(c) for c in range(-1, 60))
chunks = [missions[i:i+4] for i in range(0, len(missions), 4)]
def job(item):
    chunk, seed = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, chunk)), "SEED": str(seed), "CODES": codes, "FACTIONS": "0,1"}
    for k in ("HPMUL", "REINFORCE", "REFONLY", "POLICY"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/bonus_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    return [l for l in r.stdout.splitlines() if l.startswith("BONUS ")]
lines = []
with cf.ThreadPoolExecutor(6) as pool:
    for part in pool.map(job, [(c, s) for c in chunks for s in (7, 8, 9)]):
        lines += part; print(len(lines), flush=True)
out.write_text("\n".join(lines), encoding="utf-8"); print("done", len(lines))
