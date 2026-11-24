"""v0.253 : recalage des réglages de l'Alliance passés au-dessus de 70 % avec les offres utiles. Pour chaque réglage, plus petit coefficient de PV
(`REBALANCE_PERCENT`) dont la meilleure marge (30 compositions, première offre, tirages 7, 8 et 9) revient à 70 % ou moins, par dichotomie en parallèle.
Écrit le tableau à chaque tour puis le remet à l'identique ; résultat dans <sortie>.json. Usage : search253.py <marges.json> <sortie.json>"""
import json, os, pathlib, re, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
ORIGINAL = CATALOGUE.read_bytes()
HIGH = 0.70 + 1e-9
LOW = 0.40
margins = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
out = pathlib.Path(sys.argv[2])
SKIP = {2, 3}  # missions de prise en main (v0.252)
SETTINGS = sorted(int(k.split(",")[0]) for k, v in margins.items() if k.endswith(",0") and v > HIGH and int(k.split(",")[0]) not in SKIP)


def read_table():
    s = ORIGINAL.decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := [")
    end = s.index("]" + nl + "]", a) + 1
    return [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:end])][:2]


def write_table(table):
    s = ORIGINAL.decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := [")
    end = s.index("]" + nl + "]", a) + len("]" + nl + "]")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + s[end:]
    CATALOGUE.write_bytes(s.encode("utf-8"))


def study(item):
    m, seed = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": "0", "SEED": str(seed), "POLICY": "", "REFONLY": "", "REINFORCE": "", "V252": ""}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best = 0.0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0: best = max(best, float(p[6]) / float(p[7]))
    return m, seed, best


def measure(missions):
    raw = {}
    with cf.ThreadPoolExecutor(6) as pool:
        for m, seed, best in pool.map(study, [(m, s) for m in missions for s in (7, 8, 9)]):
            raw.setdefault(m, []).append(best)
    return {m: st.mean(v) for m, v in raw.items()}


base = read_table()
state = {m: {"from": base[0][m - 1], "lo": base[0][m - 1], "hi": None, "tried": {str(base[0][m - 1]): margins[f"{m},0"]}} for m in SETTINGS}
print("reglages", len(SETTINGS), SETTINGS, flush=True)
try:
    for round_index in range(12):
        table = [list(base[0]), list(base[1])]
        todo = {}
        for m, s in state.items():
            if s["hi"] is not None and s["hi"] - s["lo"] <= 1: continue
            if s["hi"] is None:
                last = s["tried"][str(s["lo"])]
                candidate = s["lo"] + max(3, round((last - 0.58) * 45))
            else:
                candidate = (s["lo"] + s["hi"]) // 2
            candidate = min(candidate, 200)
            if candidate <= s["lo"]: continue
            todo[m] = candidate
            table[0][m - 1] = candidate
        if not todo: break
        write_table(table)
        result = measure(list(todo))
        for m, value in result.items():
            c = todo[m]; s = state[m]
            s["tried"][str(c)] = value
            if value > HIGH: s["lo"] = c
            else: s["hi"] = c
            if s["hi"] is None and c >= 200: s["hi"] = 200
        print("tour", round_index, {m: (todo[m], round(result[m] * 100)) for m in todo}, flush=True)
        out.write_text(json.dumps(state, indent=1), encoding="utf-8")
finally:
    CATALOGUE.write_bytes(ORIGINAL)
choice = {}
for m, s in state.items():
    hi = s["hi"]
    value = s["tried"].get(str(hi)) if hi is not None else None
    choice[m] = {"from": s["from"], "to": hi if hi is not None and value is not None and value >= LOW else s["lo"], "margin_hi": value, "margin_lo": s["tried"][str(s["lo"])], "cliff": value is not None and value < LOW}
out.write_text(json.dumps({"state": state, "choice": choice}, indent=1), encoding="utf-8")
print("fin", {m: (c["from"], c["to"], round((c["margin_hi"] or 0) * 100), c["cliff"]) for m, c in choice.items()}, flush=True)
