"""v0.258 : meilleure marge (30 compositions, première offre, tirages 7, 8, 9) en Héroïque, PV seuls (HEROIC=hp) puis PV et champions (HEROIC=1), 40 missions."""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
missions = list(range(2, 201, 5))
chunks = [missions[i:i+4] for i in range(0, len(missions), 4)]
def job(item):
    mode, chunk, seed = item
    env = {**os.environ, "MISSIONS": ",".join(map(str, chunk)), "SEED": str(seed), "POLICY": "", "REFONLY": "", "REINFORCE": "", "V252": "", "HEROIC": mode}
    env.pop("HPMUL", None); env.pop("FACTIONS", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT/"prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=7200, creationflags=FLAGS)
    best = {}
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY":
            key = (int(p[1]), int(p[2])); b = best.get(key, 0.0)
            if p[5] == "victory" and float(p[7]) > 0: b = max(b, float(p[6])/float(p[7]))
            best[key] = b
    return mode, seed, best
raw = {}
with cf.ThreadPoolExecutor(6) as pool:
    for mode, seed, best in pool.map(job, [(mode, c, s) for mode in ("hp", "1") for c in chunks for s in (7, 8, 9)]):
        for key, v in best.items(): raw.setdefault((mode, key), []).append(v)
normal = json.load(open(ROOT / "design/essais/equilibre_bonus/v256/marges_campagne.json"))
out = {}
for f in (0, 1):
    for mode in ("hp", "1"):
        vals = {m: st.mean(raw[(mode, (m, f))]) for m in missions if (mode, (m, f)) in raw}
        out["%d,%s" % (f, mode)] = vals
    base = [normal["%d,%d" % (m, f)] for m in missions]
    hp = list(out["%d,hp" % f].values()); ch = list(out["%d,1" % f].values())
    print("%s normal %.0f %% | heroique PV %.0f %% | PV+champions %.0f %% | sous 40 %% : %d puis %d | defaites totales : %d puis %d" % ("AH"[f], 100*st.mean(base), 100*st.mean(hp), 100*st.mean(ch), sum(v < 0.40 for v in hp), sum(v < 0.40 for v in ch), sum(v == 0 for v in hp), sum(v == 0 for v in ch)))
pathlib.Path(sys.argv[1]).write_text(json.dumps({k: {str(m): v for m, v in d.items()} for k, d in out.items()}), encoding="utf-8")
