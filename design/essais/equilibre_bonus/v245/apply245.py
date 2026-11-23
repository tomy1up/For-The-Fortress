"""Applique les 20 baisses sous la courbe approuvées par le porteur (23 novembre 2026) et met à jour BELOW_CURVE_MISSIONS."""
import json, pathlib, re
OUT = pathlib.Path(__file__).parent / "v245"
CATALOGUE = pathlib.Path("C:/Projet/For the Fortress!/prototype/scripts/campaign_catalogue.gd")
data = json.load(open(OUT / "sous_courbe.json"))
s = CATALOGUE.read_bytes().decode("utf-8")
nl = "\r\n" if "\r\n" in s else "\n"
a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
table = [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]
assert len(table) == 2 and all(len(t) == 200 for t in table)
assert table == (lambda t: [t["0"], t["1"]])(json.load(open(OUT / "table_iter.json")))
for key, entry in data.items():
    m, f = map(int, key.split(","))
    assert entry["proposal"] is not None and entry["proposal"] < table[f][m-1], key
    table[f][m-1] = entry["proposal"]
assert len(data) == 20
fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
below = {f: [m for m in range(1, 201) if table[f][m-1] < 100] for f in (0, 1)}
new = "const BELOW_CURVE_MISSIONS := {0:%s,1:%s}" % (fmt(below[0]), fmt(below[1]))
s, n = re.subn(r"const BELOW_CURVE_MISSIONS := \{0:\[[0-9,]+\],1:\[[0-9,]+\]\}", new, s)
assert n == 1
CATALOGUE.write_bytes(s.encode("utf-8"))
json.dump({"0": table[0], "1": table[1]}, open(OUT / "table_finale.json", "w"))
final = json.load(open(OUT / "marges_finales.json"))
for key, entry in data.items():
    final[key] = entry["points"][str(entry["proposal"])]
json.dump(final, open(OUT / "marges_retenues.json", "w"))
vals = list(final.values())
print("dans 40-70 :", sum(.4 <= v <= .7 for v in vals), "<40 :", sum(v < .4 for v in vals), ">70 :", sum(v > .7 for v in vals), "total", len(vals))
print(new)
print("sous la courbe :", len(below[0]) + len(below[1]), "minimum", min(table[f][m-1] for f in (0, 1) for m in below[f]))
