"""Essai v0.245, sans décision : quel coefficient sous la courbe ramènerait à 40 % de marge les 20 réglages trop durs au plancher ?
Le tableau du catalogue est toujours restauré à la fin ; le résultat sert seulement à préparer la question au porteur."""
import subprocess, os, re, json, pathlib, statistics as st, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v245"
CATALOGUE = pathlib.Path("C:/Projet/For the Fortress!/prototype/scripts/campaign_catalogue.gd")
SEEDS = (7, 8, 9)
LEVELS = (98, 96, 94, 92, 90, 88, 86, 84)
original = CATALOGUE.read_bytes()
fin = json.load(open(OUT / "table_iter.json"))
final = json.load(open(OUT / "marges_finales.json"))
cases = [(m, f) for f in (0, 1) for m in range(2, 201) if final[f"{m},{f}"] < .40]


def write_table(table):
    s = original.decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
    CATALOGUE.write_bytes(s.encode("utf-8"))


def run(job):
    seed, chunk = job
    env = {**os.environ, "SEED": str(seed), "MISSIONS": ",".join(map(str, chunk)), "PYTHONIOENCODING": "utf-8"}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", "C:/Projet/For the Fortress!/prototype", "--script", "res://tools/faction_study.gd"],
                       env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=3000,
                       creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    return seed, [l for l in r.stdout.splitlines() if l.startswith("STUDY ")]


def measure(missions):
    best = {}
    jobs = [(s, missions[i:i+4]) for s in SEEDS for i in range(0, len(missions), 4)]
    with cf.ThreadPoolExecutor(5) as pool:
        for seed, lines in pool.map(run, jobs):
            for l in lines:
                f = l.split()
                key = (int(f[1]), int(f[2]), seed)
                value = float(f[6])/float(f[7]) if f[5] == "victory" and float(f[7]) > 0 else 0.0
                best[key] = max(best.get(key, 0.0), value)
    return {(m, fac): st.mean(best[(m, fac, s)] for s in SEEDS) for m, fac, s in best}


results = {c: {fin[str(c[1])][c[0]-1]: final[f"{c[0]},{c[1]}"]} for c in cases}
pending = list(cases)
try:
    for level in LEVELS:
        todo = [c for c in pending if fin[str(c[1])][c[0]-1] > level]
        if not todo:
            continue
        table = [list(fin["0"]), list(fin["1"])]
        for m, f in todo:
            table[f][m-1] = level
        write_table(table)
        got = measure(sorted({m for m, _ in todo}))
        for c in todo:
            results[c][level] = got[c]
        pending = [c for c in pending if max(results[c].values()) < .40]
        print(f"niveau {level} : {len(todo)} mesurés, encore sous 40 % : {len(pending)}", flush=True)
        if not pending:
            break
finally:
    CATALOGUE.write_bytes(original)
print("tableau restauré", CATALOGUE.read_bytes() == original, flush=True)
proposal = {}
for c, p in results.items():
    ok = [l for l, v in p.items() if v >= .40]
    proposal[c] = max(ok) if ok else None
    print("AH"[c[1]], c[0], "plancher", fin[str(c[1])][c[0]-1], "proposé", proposal[c], {l: round(v*100) for l, v in sorted(p.items(), reverse=True)}, flush=True)
json.dump({f"{m},{f}": {"proposal": proposal[(m, f)], "points": results[(m, f)]} for m, f in cases}, open(OUT / "sous_courbe.json", "w"))
print("FIN", flush=True)
