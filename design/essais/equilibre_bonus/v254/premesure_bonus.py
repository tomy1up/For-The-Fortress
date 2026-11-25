"""v0.254 : pré-mesure de valeurs candidates (réglages d'essai BX_*), bonus imposé au premier choix de la référence, 40 missions, deux factions, tirages 7, 8, 9."""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
CANDIDATES = [
    ("caltrops_hit4", "39", {"FIRSTHIT": "1", "CALTROPS_S": "4"}),
    ("stasis_hit8", "59", {"FIRSTHIT": "1", "STASIS_S": "8"}), ("stasis_hit10", "59", {"FIRSTHIT": "1", "STASIS_S": "10"}),
    ("tenacious_100", "38", {"TENACIOUS": "1.0"}), ("tenacious_150", "38", {"TENACIOUS": "1.5"}),
]
missions = list(range(2, 201, 5))
chunks = [missions[i:i+10] for i in range(0, len(missions), 10)]
def job(item):
    (name, codes, env_extra), chunk, seed = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, chunk)), "SEED": str(seed), "CODES": codes, "FACTIONS": "0,1"}
    for k in list(env):
        if k.startswith("BX_"): env.pop(k)
    for k in ("HPMUL", "REINFORCE", "REFONLY", "POLICY", "V252"): env.pop(k, None)
    env.update({"BX_" + k: v for k, v in env_extra.items()})
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/bonus_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    return name, [l.split() for l in r.stdout.splitlines() if l.startswith("BONUS ")]
res = {}
with cf.ThreadPoolExecutor(6) as pool:
    for name, rows in pool.map(job, [(c, ch, s) for c in CANDIDATES for ch in chunks for s in (7, 8, 9)]):
        for p in rows: res.setdefault((name, int(p[4]), int(p[2])), []).append((float(p[6])/float(p[7]) if p[5] == "victory" else 0.0, p[5] == "victory"))
out = {"%s|%d|%d" % k: [st.mean(x[0] for x in v), st.mean(x[1] for x in v), len(v)] for k, v in res.items()}
pathlib.Path(sys.argv[1]).write_text(json.dumps(out, indent=1), encoding="utf-8")
for k in sorted(out): print(k, "PV %.0f %% victoires %.0f %% (%d)" % (out[k][0]*100, out[k][1]*100, out[k][2]))
