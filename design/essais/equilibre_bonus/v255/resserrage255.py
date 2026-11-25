"""v0.255 : avec l'armée de référence en joueur avisé, remonte les 23 coefficients que la garde de la v0.254 avait baissés vers leur valeur d'avant la garde
(dans la cible pour la meilleure composition). Pour chaque réglage où la référence perd encore, plus haut coefficient (entre celui de la v0.254 et la cible) qui la fait gagner.
Le catalogue garde le résultat (version candidate). Usage : python resserrage255.py"""
import json, os, pathlib, re, subprocess, sys
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
HERE = pathlib.Path(__file__).parent
sys.path.insert(0, str(HERE))
from garde_suites import SUITES, lost_in  # noqa: E402
OUT = HERE / "resserrage"
OUT.mkdir(exist_ok=True)
# Coefficients d'avant la garde de la v0.254 (recherche par la marge), réglages baissés ensuite pour la référence à première offre.
TARGET = {"21,1": 111, "22,1": 100, "23,1": 100, "25,1": 100, "28,1": 115, "33,1": 112, "34,1": 125, "39,1": 115, "46,1": 111, "47,1": 111, "49,1": 121, "50,1": 106,
          "81,1": 106, "84,1": 100, "88,1": 109, "91,1": 102, "120,1": 128, "132,0": 113, "141,1": 141, "145,1": 142, "149,1": 104, "162,1": 148, "177,1": 144}


def read():
    raw = CATALOGUE.read_bytes().decode("utf-8"); nl = "\r\n" if "\r\n" in raw else "\n"
    a = raw.index("const REBALANCE_PERCENT := ["); end = raw.index("]" + nl + "]", a) + 1
    return [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", raw[a:end])][:2]


def write(table):
    raw = CATALOGUE.read_bytes().decode("utf-8"); nl = "\r\n" if "\r\n" in raw else "\n"
    a = raw.index("const REBALANCE_PERCENT := ["); end = raw.index("]" + nl + "]", a) + len("]" + nl + "]")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    raw = raw[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + raw[end:]
    b = raw.index("const BELOW_CURVE_MISSIONS := {"); e = raw.index("}", b)
    below = {f: [m for m in range(1, 201) if table[f][m - 1] < 100] for f in (0, 1)}
    raw = raw[:b] + "const BELOW_CURVE_MISSIONS := {0:[" + ",".join(map(str, below[0])) + "],1:[" + ",".join(map(str, below[1])) + "]" + raw[e:]
    CATALOGUE.write_bytes(raw.encode("utf-8"))


def guard(tag):
    folder = OUT / tag; folder.mkdir(exist_ok=True)
    args = [sys.executable, str(ROOT / "prototype/tests/run_regression.py"), "--timeout", "900", "--report", str(folder / "report.json")]
    for suite in SUITES: args += ["--test", suite]
    subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"}, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    lost = set()
    for log in (folder / "report_logs").glob("*.log"): lost |= lost_in(log.read_text(encoding="utf-8", errors="replace"))
    return lost


table = read()
state = {}
for key, target in TARGET.items():
    m, f = map(int, key.split(","))
    state[(m, f)] = {"pass": table[f][m - 1], "fail": None, "target": target}
print("depart", {"%d,%d" % k: (s["pass"], s["target"]) for k, s in state.items()}, flush=True)
for it in range(6):
    todo = {}
    for k, s in state.items():
        if s["fail"] is None and s["pass"] < s["target"]: todo[k] = s["target"] if it == 0 else None
        elif s["fail"] is not None and s["fail"] - s["pass"] > 1: todo[k] = (s["pass"] + s["fail"]) // 2
    todo = {k: c for k, c in todo.items() if c is not None}
    if not todo: break
    for k, s in state.items(): table[k[1]][k[0] - 1] = todo.get(k, s["pass"])
    write(table)
    lost = guard("tour%d" % it)
    for k, c in todo.items():
        if k in lost: state[k]["fail"] = c
        else: state[k]["pass"] = c
    print("tour", it, {"%d,%d" % k: (c, "perd" if k in lost else "gagne") for k, c in todo.items()}, "autres pertes", sorted(set(lost) - set(todo)), flush=True)
    (OUT / "etat.json").write_text(json.dumps({"%d,%d" % k: v for k, v in state.items()}, indent=1), encoding="utf-8")
for k, s in state.items(): table[k[1]][k[0] - 1] = s["pass"]
write(table)
final = guard("final")
print("fin", {"%d,%d" % k: (s["pass"], s["target"]) for k, s in state.items()}, "pertes finales", sorted(final), flush=True)
