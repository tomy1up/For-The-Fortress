"""Exploration v0.247+ : pour les 27 réglages au-dessus de 70 % de marge, jusqu'où monter les PV, et à partir de quand l'armée de référence perd.
Aucune écriture dans le dépôt (multiplicateur HPMUL de faction_study). Consoles cachées, priorité basse, cinq parties à la fois."""
import subprocess, os, re, json, pathlib, statistics as st, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
PROJECT = "C:/Projet/For the Fortress!/prototype"
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
OUT = pathlib.Path(__file__).parent / "v247"
OUT.mkdir(exist_ok=True)
SEEDS = (7, 8, 9)
TARGET, LOW, HIGH = 0.55, 0.47, 0.63
CEILING = 260
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)

s = (ROOT / "prototype/scripts/campaign_catalogue.gd").read_bytes().decode("utf-8")
a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
TABLE = [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]
MARGINS = json.load(open(ROOT / "design/essais/equilibre_bonus/v246/marges_campagne.json"))
SETTINGS = sorted((int(k.split(",")[0]), int(k.split(",")[1])) for k, v in MARGINS.items() if v > 0.70)
assert len(SETTINGS) == 27


def godot(env_extra):
    env = dict(os.environ)
    env.pop("HPMUL", None)
    env.update({k: str(v) for k, v in env_extra.items()})
    r = subprocess.run([GODOT, "--headless", "--path", PROJECT, "--script", "res://tools/faction_study.gd"], env=env, capture_output=True,
                       text=True, encoding="utf-8", errors="replace", timeout=1800, creationflags=FLAGS)
    return r.stdout.splitlines()


def job(item):
    m, f, c, seed = item
    base = {"MISSIONS": m, "FACTIONS": f, "SEED": seed, "HPMUL": c}
    best, wins = 0.0, 0
    for line in godot(base):
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0:
            wins += 1
            best = max(best, float(p[6])/float(p[7]))
    ref = [l.split() for l in godot({**base, "REFONLY": 1, "POLICY": "ref"}) if l.startswith("REF ")]
    return m, f, c, seed, best, wins, ref[0][3] == "victory" if ref else None


def measure(wanted):
    items = [(m, f, c, seed) for (m, f), c in wanted.items() for seed in SEEDS]
    raw = {}
    with cf.ThreadPoolExecutor(5) as pool:
        for m, f, c, seed, best, wins, ref in pool.map(job, items):
            raw.setdefault((m, f, c), []).append((best, wins, ref))
    return {key: {"best": st.mean(x[0] for x in v), "wins": st.mean(x[1] for x in v), "ref": sum(bool(x[2]) for x in v)} for key, v in raw.items()}


def choose(points):
    ordered = sorted(points)
    if any(LOW <= points[c]["best"] <= HIGH for c in ordered):
        return None
    above = [c for c in ordered if points[c]["best"] > TARGET]
    below = [c for c in ordered if points[c]["best"] < TARGET]
    if not below:
        top = ordered[-1]
        return None if top >= CEILING else min(CEILING, top+12)
    low, high = max(c for c in above if c < min(below)), min(below)
    return None if high-low <= 1 else (low+high)//2


points = {key: {} for key in SETTINGS}
first = measure({key: TABLE[key[1]][key[0]-1] for key in SETTINGS})
for (m, f, c), v in first.items():
    points[(m, f)][c] = v
for iteration in range(9):
    pending = {}
    for key, p in points.items():
        c = choose(p)
        if c is not None and c not in p:
            pending[key] = c
    print(f"passe {iteration} : {len(pending)} réglages", flush=True)
    if not pending:
        break
    for (m, f, c), v in measure(pending).items():
        points[(m, f)][c] = v
    json.dump({f"{m},{f}": p for (m, f), p in points.items()}, open(OUT / "scan.json", "w"))
json.dump({f"{m},{f}": p for (m, f), p in points.items()}, open(OUT / "scan.json", "w"))
print("FIN", flush=True)
