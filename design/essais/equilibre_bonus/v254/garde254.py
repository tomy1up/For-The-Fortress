"""v0.254 : écrit les coefficients trouvés par search254.py (deux factions) et met à jour les missions sous la courbe, puis lance les suites de campagne.
Usage : apply254.py <search254.json> <dossier> [surcharges m,f=coef;...]"""
import json, os, pathlib, re, subprocess, sys
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from guard252 import SUITES, lost_in  # noqa: E402

choice = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["choice"]
folder = pathlib.Path(sys.argv[2]); folder.mkdir(parents=True, exist_ok=True)
overrides = {}
if len(sys.argv) > 3 and sys.argv[3]:
    for item in sys.argv[3].split(";"):
        key, value = item.split("=")
        overrides[key] = int(value)
raw = CATALOGUE.read_bytes().decode("utf-8")
nl = "\r\n" if "\r\n" in raw else "\n"
a = raw.index("const REBALANCE_PERCENT := [")
end = raw.index("]" + nl + "]", a) + 1
table = [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", raw[a:end])][:2]
original = [list(table[0]), list(table[1])]
for key, c in choice.items():
    m, f = map(int, key.split(","))
    table[f][m - 1] = int(c["to"])
for key, value in overrides.items():
    m, f = map(int, key.split(","))
    table[f][m - 1] = value
fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
end2 = raw.index("]" + nl + "]", a) + len("]" + nl + "]")
raw = raw[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + raw[end2:]
b = raw.index("const BELOW_CURVE_MISSIONS := {")
e = raw.index("}", b)
lists = {int(f): [int(x) for x in body.split(",") if x] for f, body in re.findall(r"(\d):\[([0-9,]*)\]", raw[b:e])}
below = {f: sorted(m for m in range(1, 201) if table[f][m - 1] < 100) for f in (0, 1)}
raw = raw[:b] + "const BELOW_CURVE_MISSIONS := {0:[" + ",".join(map(str, below[0])) + "],1:[" + ",".join(map(str, below[1])) + "]" + raw[e:]
CATALOGUE.write_bytes(raw.encode("utf-8"))
changed = {"%d,%d" % (i + 1, f): (original[f][i], table[f][i]) for f in (0, 1) for i in range(200) if original[f][i] != table[f][i]}
print("modifies", len(changed), "sous la courbe avant", lists, "apres", below, flush=True)
args = [sys.executable, str(ROOT / "prototype/tests/run_regression.py"), "--timeout", "900", "--report", str(folder / "report.json")]
for suite in SUITES: args += ["--test", suite]
r = subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"},
                   creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
lost, errors = set(), []
for log in (folder / "report_logs").glob("*.log"):
    text = log.read_text(encoding="utf-8", errors="replace")
    lost |= lost_in(text)
    errors += [log.name + " : " + l for l in text.splitlines() if l.startswith("ERROR")][:6]
summary = [l for l in r.stdout.splitlines() if l.startswith(("ÉCHEC", "REGRESSION"))]
(folder / "guard.json").write_text(json.dumps({"changed": changed, "lost": sorted(lost), "summary": summary, "errors": errors[:80]}, ensure_ascii=False, indent=1), encoding="utf-8")
print("\n".join(summary)); print("LOST", sorted(lost)); print("\n".join(errors[:30]))
