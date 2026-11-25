"""v0.254 : recalage des réglages sortis de la cible (au-dessus de 70 % ou sous 40 %) après le rééquilibrage des bonus, deux factions. Pour chaque réglage, plus petit coefficient de PV
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
SETTINGS = sorted((int(k.split(",")[0]), int(k.split(",")[1])) for k, v in margins.items() if (v > HIGH or v < LOW) and int(k.split(",")[0]) not in SKIP)


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
    (m, f), seed = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed), "POLICY": "", "REFONLY": "", "REINFORCE": "", "V252": ""}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best = 0.0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0: best = max(best, float(p[6]) / float(p[7]))
    return (m, f), seed, best


def measure(missions):
    raw = {}
    with cf.ThreadPoolExecutor(6) as pool:
        for m, seed, best in pool.map(study, [(m, s) for m in missions for s in (7, 8, 9)]):
            raw.setdefault(m, []).append(best)
    return {m: st.mean(v) for m, v in raw.items()}


base = read_table()
FLOOR = 92  # sous la courbe de base : 92 % au plus bas (décision du porteur, 23 novembre 2026)
state = {}
for m, f in SETTINGS:
    c = base[f][m - 1]; v = margins[f"{m},{f}"]
    up = v > HIGH
    # en hausse : « lo » = coefficient trop facile connu, « hi » = premier coefficient dans la cible ; en baisse : « hi » = trop dur connu, « lo » = premier dans la cible.
    state[(m, f)] = {"from": c, "up": up, "lo": c if up else None, "hi": None if up else c, "tried": {str(c): v}}
print("reglages", len(SETTINGS), SETTINGS, flush=True)
try:
    for round_index in range(12):
        table = [list(base[0]), list(base[1])]
        todo = {}
        for key, s_ in state.items():
            m, f = key
            if s_["lo"] is not None and s_["hi"] is not None and s_["hi"] - s_["lo"] <= 1: continue
            if s_["up"] and s_["hi"] is None:
                candidate = min(200, s_["lo"] + max(3, round((s_["tried"][str(s_["lo"])] - 0.58) * 45)))
                if candidate <= s_["lo"]: continue
            elif not s_["up"] and s_["lo"] is None:
                candidate = max(FLOOR, s_["hi"] - max(3, round((0.52 - s_["tried"][str(s_["hi"])]) * 45)))
                if candidate >= s_["hi"]: continue
            else:
                candidate = (s_["lo"] + s_["hi"]) // 2
            todo[key] = candidate
            table[f][m - 1] = candidate
        if not todo: break
        write_table(table)
        result = measure(list(todo))
        for key, value in result.items():
            c = todo[key]; s_ = state[key]
            s_["tried"][str(c)] = value
            if s_["up"]:
                if value > HIGH: s_["lo"] = c
                else: s_["hi"] = c
            else:
                if value < LOW: s_["hi"] = c
                else: s_["lo"] = c
            if not s_["up"] and s_["lo"] is None and c <= FLOOR: s_["lo"] = FLOOR - 1  # plancher atteint sans revenir dans la cible
        print("tour", round_index, {"%d,%d" % k: (todo[k], round(result[k] * 100)) for k in todo}, flush=True)
        out.write_text(json.dumps({"%d,%d" % k: v for k, v in state.items()}, indent=1), encoding="utf-8")
finally:
    CATALOGUE.write_bytes(ORIGINAL)
choice = {}
for key, s_ in state.items():
    if s_["up"]:
        value = s_["tried"].get(str(s_["hi"])) if s_["hi"] is not None else None
        to = s_["hi"] if value is not None and value >= LOW else s_["lo"]
    else:
        value = s_["tried"].get(str(s_["lo"])) if s_["lo"] is not None and s_["lo"] >= FLOOR else None
        to = s_["lo"] if value is not None and value <= HIGH else s_["hi"]
    choice["%d,%d" % key] = {"from": s_["from"], "to": to, "margin_to": s_["tried"].get(str(to)), "up": s_["up"]}
out.write_text(json.dumps({"state": {"%d,%d" % k: v for k, v in state.items()}, "choice": choice}, indent=1), encoding="utf-8")
print("fin", {k: (c["from"], c["to"], round((c["margin_to"] or 0) * 100)) for k, c in choice.items()}, flush=True)
