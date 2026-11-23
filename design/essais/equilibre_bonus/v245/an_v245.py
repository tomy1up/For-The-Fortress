"""Lecture du recalibrage v0.245 : marges retenues par biome, cas hors cible."""
import json, pathlib, statistics as st
OUT = pathlib.Path(__file__).parent / "v245"
av = json.load(open(OUT / "table_avant.json"))
ap = json.load(open(OUT / "table_apres.json"))
pts = {k: {int(c): v for c, v in p.items()} for k, p in json.load(open(OUT / "points.json")).items()}
BIOMES = [("Gué", 2, 20), ("Ardoises", 21, 40), ("Marais", 41, 60), ("Volcan", 61, 80), ("Désert", 81, 100) ]
BIOMES = [("Gué", 2, 20), ("Ardoises", 21, 40), ("Marais", 41, 60), ("Volcan", 61, 80), ("Citadelle", 81, 100), ("Désert", 101, 120), ("Mines", 121, 140), ("Cieux", 141, 160), ("Côtes", 161, 180), ("Nécropole", 181, 200)]
mar = {}
for fac in (0, 1):
    for m in range(2, 201):
        c = ap[str(fac)][m-1]
        mar[(m, fac)] = pts[f"{m},{fac}"][c]
print("biome        fac  marge_moy  min  max  coef_avant_moy coef_apres_moy  <40 >70")
for n, a, b in BIOMES:
    for fac in (0, 1):
        ms = range(a, b+1)
        v = [mar[(m, fac)]*100 for m in ms]
        print(f"{n:12s} {'AH'[fac]}   {st.mean(v):6.1f} {min(v):6.1f} {max(v):6.1f}   {st.mean(av[str(fac)][m-1] for m in ms):6.1f} {st.mean(ap[str(fac)][m-1] for m in ms):6.1f}   {sum(x < 40 for x in v):3d} {sum(x > 70 for x in v):3d}")
print("\nhors cible (mission faction coef_avant coef_retenu marge | points essayés)")
for (m, fac), v in sorted(mar.items()):
    if v < .40 or v > .70:
        print(m, "AH"[fac], av[str(fac)][m-1], ap[str(fac)][m-1], f"{v*100:.1f}", {c: round(x*100) for c, x in sorted(pts[f'{m},{fac}'].items())})
print("\nsous la courbe (<100) :")
for fac in (0, 1):
    print("AH"[fac], [(m, ap[str(fac)][m-1]) for m in range(1, 201) if ap[str(fac)][m-1] < 100])
print("\nau plancher 100 :", sum(ap[str(f)][m-1] == 100 for f in (0, 1) for m in range(2, 201)))
d = [ap[str(f)][m-1]-av[str(f)][m-1] for f in (0, 1) for m in range(2, 201)]
print("écart moyen", round(st.mean(d), 1), "min", min(d), "max", max(d))
