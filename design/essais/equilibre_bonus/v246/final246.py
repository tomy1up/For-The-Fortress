"""Bilan v0.246 : remesure les réglages abaissés, puis cherche le coefficient sous la courbe qui ramènerait à 40 % les réglages encore trop durs. Le catalogue est restauré à la fin."""
import subprocess, os, re, json, pathlib, statistics as st, concurrent.futures as cf
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v246"
CATALOGUE = pathlib.Path("C:/Projet/For the Fortress!/prototype/scripts/campaign_catalogue.gd")
SEEDS = (7, 8, 9)
LEVELS = (98, 96, 94, 92, 90, 88)
MISSIONS = [m for first in (31, 71, 111, 131, 171) for m in range(first, first+10)]
original = CATALOGUE.read_bytes()
cal = json.load(open(OUT / "table_apres.json"))
fin = json.load(open(OUT / "table_iter.json"))
pts = {k: {int(c): v for c, v in p.items()} for k, p in json.load(open(OUT / "points.json")).items()}


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


try:
    changed = sorted({m for f in "01" for m in MISSIONS if cal[f][m-1] != fin[f][m-1]})
    write_table([fin["0"], fin["1"]])
    got = measure(changed)
    for m in changed:
        for f in (0, 1):
            pts[f"{m},{f}"][fin[str(f)][m-1]] = got[(m, f)]
    final = {f"{m},{f}": pts[f"{m},{f}"][fin[str(f)][m-1]] for m in MISSIONS for f in (0, 1)}
    json.dump(final, open(OUT / "marges_finales.json", "w"))
    cases = [(m, f) for f in (0, 1) for m in MISSIONS if final[f"{m},{f}"] < .40 or (m, f) == (180, 0)]
    print("cas sous 40 % ou perdus par la référence :", cases, flush=True)
    results = {c: {fin[str(c[1])][c[0]-1]: final[f"{c[0]},{c[1]}"]} for c in cases}
    pending = list(cases)
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
print("catalogue restauré", CATALOGUE.read_bytes() == original, flush=True)
json.dump({f"{m},{f}": {str(k): v for k, v in p.items()} for (m, f), p in results.items()}, open(OUT / "sous_courbe.json", "w"))
for c, p in results.items():
    ok = [l for l, v in p.items() if v >= .40]
    print("AH"[c[1]], c[0], "actuel", fin[str(c[1])][c[0]-1], "proposé", max(ok) if ok else None, {l: round(v*100) for l, v in sorted(p.items(), reverse=True)}, flush=True)
vals = list(final.values())
print("bilan avant décision : dans 40-70", sum(.4 <= v <= .7 for v in vals), "<40", sum(v < .4 for v in vals), ">70", sum(v > .7 for v in vals), "sur", len(vals), flush=True)
print("au-dessus de 70 :", [("AH"[int(k.split(',')[1])], int(k.split(',')[0]), round(v*100)) for k, v in final.items() if v > .7], flush=True)
print("FIN", flush=True)
