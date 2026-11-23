"""Lecture du recalibrage v0.246 : marges retenues par chapitre, cas hors cible."""
import json, pathlib, statistics as st
OUT = pathlib.Path(__file__).parent / "v246"
av = json.load(open(OUT / "table_avant.json"))
ap = json.load(open(OUT / "table_apres.json"))
dep = json.load(open(OUT / "depart.json"))
pts = {k: {int(c): v for c, v in p.items()} for k, p in json.load(open(OUT / "points.json")).items()}
CH = [("Ardoises 4", 31), ("Volcan 8", 71), ("Désert 12", 111), ("Mines 14", 131), ("Côtes 18", 171)]
mar = {}
for name, first in CH:
    for fac in (0, 1):
        ms = range(first, first+10)
        for m in ms:
            mar[(m, fac)] = pts[f"{m},{fac}"][ap[str(fac)][m-1]]
        v = [mar[(m, fac)]*100 for m in ms]
        d = [dep[f"{m},{fac}"]*100 for m in ms]
        print(f"{name:11s} {'AH'[fac]} marge avant recalibrage {st.mean(d):5.1f} | après {st.mean(v):5.1f} (min {min(v):5.1f}, max {max(v):5.1f}) | coef {st.mean(av[str(fac)][m-1] for m in ms):6.1f} -> {st.mean(ap[str(fac)][m-1] for m in ms):6.1f} | <40:{sum(x < 40 for x in v)} >70:{sum(x > 70 for x in v)}")
vals = list(mar.values())
print("dans 40-70 :", sum(.4 <= x <= .7 for x in vals), "<40 :", sum(x < .4 for x in vals), ">70 :", sum(x > .7 for x in vals), "sur", len(vals))
print("\nhors cible (mission faction avant retenu marge | points)")
for (m, fac), v in sorted(mar.items()):
    if not .4 <= v <= .7:
        print(m, "AH"[fac], av[str(fac)][m-1], ap[str(fac)][m-1], f"{v*100:.1f}", {c: round(x*100) for c, x in sorted(pts[f'{m},{fac}'].items())})
