"""Recalibrage v0.246 : coefficient de PV (plancher 100, courbe validée par le porteur) des 50 missions qui reçoivent un nouvel attaquant.
Par dichotomie sur des parties réelles (30 compositions, tirages 7, 8, 9, première offre) : meilleure marge moyenne visée 55 %, acceptée de 47 à 63 %.
Les points déjà mesurés (coefficients actuels et plancher) servent de bornes. Consoles cachées, cinq parties à la fois."""
import subprocess, os, re, json, pathlib, statistics as st, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v246"
OUT.mkdir(exist_ok=True)
CATALOGUE = pathlib.Path("C:/Projet/For the Fortress!/prototype/scripts/campaign_catalogue.gd")
MISSIONS = [m for first in (31, 71, 111, 131, 171) for m in range(first, first+10)]
SEEDS = (7, 8, 9)
TARGET, LOW, HIGH = 0.55, 0.47, 0.63
CEILING = 200


def read_table():
    s = CATALOGUE.read_bytes().decode("utf-8")
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    return [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]


def write_table(table):
    s = CATALOGUE.read_bytes().decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
    CATALOGUE.write_bytes(s.encode("utf-8"))


def margins(lines_by_seed):
    best = {}
    for seed, lines in lines_by_seed.items():
        for l in lines:
            f = l.split()
            if len(f) < 8 or f[0] != "STUDY":
                continue
            key = (int(f[1]), int(f[2]), seed)
            value = float(f[6])/float(f[7]) if f[5] == "victory" and float(f[7]) > 0 else 0.0
            best[key] = max(best.get(key, 0.0), value)
    return {(m, fac): st.mean(best[(m, fac, s)] for s in SEEDS) for m, fac, s in best}


def from_file(label):
    return margins({s: (OUT / f"{label}_{s}.txt").read_text(encoding="utf-8").splitlines() for s in SEEDS})


def run(job):
    seed, chunk, hpmul = job
    env = dict(os.environ)
    env.update({"SEED": str(seed), "MISSIONS": ",".join(map(str, chunk)), "PYTHONIOENCODING": "utf-8"})
    env.pop("HPMUL", None)
    if hpmul:
        env["HPMUL"] = hpmul
    r = subprocess.run([GODOT, "--headless", "--path", "C:/Projet/For the Fortress!/prototype", "--script", "res://tools/faction_study.gd"],
                       env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3000,
                       creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    return seed, [l for l in r.stdout.splitlines() if l.startswith("STUDY ")]


def measure(missions, hpmul=""):
    jobs = [(s, missions[i:i+4], hpmul) for s in SEEDS for i in range(0, len(missions), 4)]
    out = {}
    with cf.ThreadPoolExecutor(5) as pool:
        for seed, lines in pool.map(run, jobs):
            out.setdefault(seed, []).extend(lines)
    return margins(out)


def choose(points):
    """Coefficient suivant à essayer, ou None si la mission est réglée."""
    ordered = sorted(points)
    if any(LOW <= points[c] <= HIGH for c in ordered):
        return None
    if points[ordered[0]] < TARGET and ordered[0] == 100:
        return None  # Déjà au plancher : la courbe de base reste la limite.
    above = [c for c in ordered if points[c] >= TARGET]
    below = [c for c in ordered if points[c] < TARGET]
    if not below:
        top = ordered[-1]
        return None if top >= CEILING else min(CEILING, top+12)
    a = max([c for c in above if c < min(below)], default=None)
    b = min(below)
    if a is None:
        return None if b <= 100 else max(100, b-12)
    return None if b-a <= 1 else (a+b)//2


def final(points):
    inside = [c for c in points if 0.40 <= points[c] <= 0.70]
    if inside:
        return min(inside, key=lambda c: (abs(points[c]-TARGET), c))
    above = [c for c in points if points[c] > 0.70]
    if above:
        return max(above)  # Trop facile même au plus haut essayé : on garde le plus difficile.
    return min(points)  # Trop dur partout : le plus bas essayé.


start = read_table()
json.dump({"0": start[0], "1": start[1]}, open(OUT / "table_avant.json", "w"))
print("mesure des coefficients actuels", flush=True)
now = measure(MISSIONS)
json.dump({f"{m},{f}": now[(m, f)] for m in MISSIONS for f in (0, 1)}, open(OUT / "depart.json", "w"))
points = {}
for m in MISSIONS:
    for fac in (0, 1):
        p = {start[fac][m-1]: now[(m, fac)]}
        points[(m, fac)] = p
table = [list(start[0]), list(start[1])]
for iteration in range(9):
    pending = {}
    for key, p in points.items():
        c = choose(p)
        if c is not None and c not in p:
            pending[key] = c
    print(f"passe {iteration} : {len(pending)} réglages à mesurer", flush=True)
    if not pending:
        break
    for (m, fac), c in pending.items():
        table[fac][m-1] = c
    write_table(table)
    missions = sorted({m for m, _ in pending})
    measured = measure(missions)
    for (m, fac), c in pending.items():
        points[(m, fac)][c] = measured[(m, fac)]
    json.dump({f"{m},{fac}": p for (m, fac), p in points.items()}, open(OUT / "points.json", "w"))
for (m, fac), p in points.items():
    table[fac][m-1] = final(p)
write_table(table)
json.dump({"0": table[0], "1": table[1]}, open(OUT / "table_apres.json", "w"))
values = {key: p[table[key[1]][key[0]-1]] for key, p in points.items()}
for fac in (0, 1):
    v = [x for (m, f), x in values.items() if f == fac]
    print("AH"[fac], "marge moyenne %.1f" % (st.mean(v)*100), "dans 40-70 :", sum(.4 <= x <= .7 for x in v), "<40 :", sum(x < .4 for x in v), ">70 :", sum(x > .7 for x in v), flush=True)
print("FIN", flush=True)
