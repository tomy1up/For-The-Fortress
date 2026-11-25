"""v0.254 : pour les réglages où l'armée de référence des suites perd, plus haut coefficient (sous l'actuel) qui la fait regagner.
Phase 1 : baisse de 3 en 3 jusqu'à la victoire ; phase 2 : remonte d'un ou deux crans si possible. Le catalogue garde le résultat (version candidate)."""
import json, os, pathlib, re, subprocess, sys
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
HERE = pathlib.Path(__file__).parent
sys.path.insert(0, str(HERE))
from guard252 import SUITES, lost_in  # noqa: E402
FLOOR = 92
lost0 = [tuple(x) for x in json.loads((HERE / "guard254a/guard.json").read_text(encoding="utf-8"))["lost"]]


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
    folder = HERE / ("guardsearch254_" + tag); folder.mkdir(exist_ok=True)
    args = [sys.executable, str(ROOT / "prototype/tests/run_regression.py"), "--timeout", "900", "--report", str(folder / "report.json")]
    for suite in SUITES: args += ["--test", suite]
    subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"}, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    lost = set()
    for log in (folder / "report_logs").glob("*.log"): lost |= lost_in(log.read_text(encoding="utf-8", errors="replace"))
    return lost


table = read()
start = {k: table[k[1]][k[0] - 1] for k in lost0}
state = {k: {"fail": start[k], "pass": None} for k in lost0}
print("depart", {"%d,%d" % k: v for k, v in start.items()}, flush=True)
for it in range(6):
    todo = {}
    for k, s in state.items():
        if s["pass"] is None:
            c = max(FLOOR, s["fail"] - 3)
            if c >= s["fail"]: continue
        elif s["fail"] - s["pass"] > 1: c = (s["fail"] + s["pass"] + 1) // 2
        else: continue
        todo[k] = c
    if not todo: break
    for k, c in todo.items(): table[k[1]][k[0] - 1] = c
    for k, s in state.items():
        if k not in todo and s["pass"] is not None: table[k[1]][k[0] - 1] = s["pass"]
    write(table)
    lost = guard(str(it))
    for k, c in todo.items():
        if k in lost: state[k]["fail"] = c
        else: state[k]["pass"] = c
    others = sorted(set(lost) - set(todo) - {k for k, s in state.items() if s["pass"] is None})
    print("tour", it, {"%d,%d" % k: (c, "perd" if k in lost else "gagne") for k, c in todo.items()}, "autres pertes", others, flush=True)
    (HERE / "guardsearch254.json").write_text(json.dumps({"%d,%d" % k: v for k, v in state.items()}, indent=1), encoding="utf-8")
for k, s in state.items(): table[k[1]][k[0] - 1] = s["pass"] if s["pass"] is not None else s["fail"]
write(table)
final = guard("final")
print("fin", {"%d,%d" % k: (start[k], s["pass"]) for k, s in state.items()}, "pertes finales", sorted(final), flush=True)
