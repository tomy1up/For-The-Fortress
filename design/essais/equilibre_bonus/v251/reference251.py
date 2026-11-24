"""v0.251, remesure des finales (24 novembre 2026) : PV restants de l'armée de référence (REFONLY, POLICY=ref) sur les 200 missions, deux factions, tirages 7, 8 et 9."""
import json, os, pathlib, subprocess, sys, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
OUT = pathlib.Path(sys.argv[1])
SEEDS = [int(s) for s in (sys.argv[2] if len(sys.argv) > 2 else "7,8,9").split(",")]


def run(item):
    first, last, seed = item
    env = {**os.environ, "REFONLY": "1", "POLICY": "ref", "FIRST": str(first), "LAST": str(last), "SEED": str(seed)}
    for k in ("HPMUL", "MISSIONS", "FACTIONS", "OLDREF"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env,
                       capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    rows = []
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) == 6 and p[0] == "REF":
            rows.append({"mission": int(p[1]), "faction": int(p[2]), "seed": seed, "result": p[3], "hp": int(p[4]), "max": int(p[5])})
    return rows


items = [(a, min(a + 19, 200), s) for s in SEEDS for a in range(1, 201, 20)]
rows = []
with cf.ThreadPoolExecutor(5) as pool:
    for part in pool.map(run, items):
        rows.extend(part)
        print(len(rows), flush=True)
OUT.write_text(json.dumps(sorted(rows, key=lambda r: (r["faction"], r["mission"], r["seed"]))), encoding="utf-8")
print("done", len(rows))
