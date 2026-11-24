"""v0.253 : écrit les coefficients de l'Alliance trouvés par search253.py (et la liste des missions sous la courbe), puis lance les suites de campagne.
Usage : apply253.py <search253.json> <dossier> [surcharges m=coef,...] — le catalogue reste modifié (c'est la version candidate)."""
import json, os, pathlib, re, subprocess, sys
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from guard252 import SUITES, lost_in  # noqa: E402

choice = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["choice"]
folder = pathlib.Path(sys.argv[2]); folder.mkdir(parents=True, exist_ok=True)
overrides = dict((int(a), int(b)) for a, b in (x.split("=") for x in sys.argv[3].split(","))) if len(sys.argv) > 3 and sys.argv[3] else {}
raw = CATALOGUE.read_bytes().decode("utf-8")
nl = "\r\n" if "\r\n" in raw else "\n"
a = raw.index("const REBALANCE_PERCENT := [")
end = raw.index("]" + nl + "]", a) + 1
table = [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", raw[a:end])][:2]
original = list(table[0])
for m, c in choice.items():
    table[0][int(m) - 1] = int(c["to"])
for m, c in overrides.items():
    table[0][m - 1] = c
fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
end2 = raw.index("]" + nl + "]", a) + len("]" + nl + "]")
raw = raw[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + raw[end2:]
# Missions de l'Alliance sous la courbe de base (92 à 99 %) : celles dont le coefficient atteint 100 en sortent.
b = raw.index("const BELOW_CURVE_MISSIONS := {0:[")
e = raw.index("]", b)
below = [int(x) for x in raw[b + len("const BELOW_CURVE_MISSIONS := {0:["):e].split(",")]
kept = [m for m in below if table[0][m - 1] < 100]
raw = raw[:b] + "const BELOW_CURVE_MISSIONS := {0:[" + ",".join(map(str, kept)) + raw[e:]
CATALOGUE.write_bytes(raw.encode("utf-8"))
changed = {i + 1: (original[i], table[0][i]) for i in range(200) if original[i] != table[0][i]}
print("modifies", len(changed), "sortis de sous la courbe", sorted(set(below) - set(kept)), flush=True)
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
