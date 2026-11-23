"""Applique les 3 baisses sous la courbe approuvées par le porteur (23 novembre 2026, v0.246) et dresse le bilan final."""
import json, pathlib, re, statistics as st
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v246"
CATALOGUE = pathlib.Path("C:/Projet/For the Fortress!/prototype/scripts/campaign_catalogue.gd")
CHOSEN = {(113, 0): 96, (118, 0): 92, (180, 0): 94}
s = CATALOGUE.read_bytes().decode("utf-8")
nl = "\r\n" if "\r\n" in s else "\n"
a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
table = [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]
assert table == (lambda t: [t["0"], t["1"]])(json.load(open(OUT / "table_iter.json")))
for (m, f), value in CHOSEN.items():
    assert value < table[f][m-1]
    table[f][m-1] = value
fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
below = [[m for m in range(1, 201) if t[m-1] < 100] for t in table]
s, n = re.subn(r"const BELOW_CURVE_MISSIONS := \{0:\[[0-9,]*\],1:\[[0-9,]*\]\}", "const BELOW_CURVE_MISSIONS := {0:%s,1:%s}" % (fmt(below[0]), fmt(below[1])), s)
assert n == 1
CATALOGUE.write_bytes(s.encode("utf-8"))
json.dump({"0": table[0], "1": table[1]}, open(OUT / "table_finale.json", "w"))
prop = json.load(open(OUT / "sous_courbe.json"))
new = json.load(open(OUT / "marges_finales.json"))
for (m, f), value in CHOSEN.items():
    new[f"{m},{f}"] = prop[f"{m},{f}"][str(value)]
json.dump(new, open(OUT / "marges_retenues.json", "w"))
old = json.load(open(HERE / "v245" / "marges_retenues.json"))
all_margins = {**old, **new}
json.dump(all_margins, open(OUT / "marges_campagne.json", "w"))
before = json.load(open(OUT / "depart.json"))
for name, first in (("Ardoises 4", 31), ("Volcan 8", 71), ("Désert 12", 111), ("Mines 14", 131), ("Côtes 18", 171)):
    row = [name]
    for f in (0, 1):
        row.append("%.1f" % (st.mean(new[f"{m},{f}"] for m in range(first, first+10))*100))
    row.append(sum(.4 <= new[f"{m},{f}"] <= .7 for f in (0, 1) for m in range(first, first+10)))
    print(row)
for f in (0, 1):
    v = [all_margins[f"{m},{f}"] for m in range(2, 201)]
    print("AH"[f], "campagne moyenne %.1f" % (st.mean(v)*100), "dans", sum(.4 <= x <= .7 for x in v), "<40", sum(x < .4 for x in v), ">70", sum(x > .7 for x in v))
    w = [new[f"{m},{f}"] for first in (31, 71, 111, 131, 171) for m in range(first, first+10)]
    print("   50 missions moyenne %.1f" % (st.mean(w)*100))
print("au-dessus de 70 (50 missions) :", [("AH"[int(k.split(',')[1])], int(k.split(',')[0]), round(v*100)) for k, v in new.items() if v > .7])
print("sous la courbe :", len(below[0])+len(below[1]))
for f in (0, 1):
    groups = {}
    for m in below[f]:
        groups.setdefault(table[f][m-1], []).append(m)
    print("AH"[f], {k: groups[k] for k in sorted(groups, reverse=True)})
