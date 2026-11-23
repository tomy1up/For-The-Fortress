"""Étude v0.244 : les 50 missions qui reçoivent l'affixe de leur biome (chapitres 3, 7, 11, 13, 17), 30 compositions, trois tirages, première offre.
Usage : python run_v244.py <étiquette> [HPMUL]  (sans HPMUL : coefficients actuels du catalogue). Consoles cachées, cinq parties à la fois."""
import subprocess, os, sys, pathlib, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
OUT = pathlib.Path(__file__).parent / "v244"
OUT.mkdir(exist_ok=True)
label = sys.argv[1]
hpmul = sys.argv[2] if len(sys.argv) > 2 else ""
missions = [m for first in (21, 61, 101, 121, 161) for m in range(first, first+10)]
jobs = [(s, missions[i:i+4]) for s in (7, 8, 9) for i in range(0, len(missions), 4)]


def run(job):
    seed, chunk = job
    env = dict(os.environ)
    env.update({"SEED": str(seed), "MISSIONS": ",".join(map(str, chunk)), "PYTHONIOENCODING": "utf-8"})
    env.pop("HPMUL", None)
    if hpmul:
        env["HPMUL"] = hpmul
    r = subprocess.run([GODOT, "--headless", "--path", "C:/Projet/For the Fortress!/prototype", "--script", "res://tools/faction_study.gd"],
                       env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3000,
                       creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    return seed, [l for l in r.stdout.splitlines() if l.startswith("STUDY ")]


results = {}
with cf.ThreadPoolExecutor(5) as pool:
    for seed, lines in pool.map(run, jobs):
        results.setdefault(seed, []).extend(lines)
for seed, lines in results.items():
    (OUT / f"{label}_{seed}.txt").write_text("\n".join(lines)+"\n", encoding="utf-8")
    print(seed, len(lines), flush=True)
