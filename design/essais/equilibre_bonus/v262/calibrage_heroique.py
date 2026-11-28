"""v0.262 (lot 5) : calibrage des PV de l'Héroïque, mission par mission et faction par faction.
Cible (porteur, 27 novembre 2026) : la meilleure des 30 compositions, jouée par un joueur avisé (POLICY=refwise), finit entre 40 et 70 % de ses PV de forteresse.
Héroïque complet (HEROIC=1 : champions, rappels, bonus héroïques, 51 points de talent) ; coefficient essayé par HEROIC_COEF (en % des PV du Normal de la faction).
Phase 1 : encadrement sur le tirage 7. Phase 2 : confirmation sur les tirages 7, 8 et 9 (moyenne), encadrement repris si besoin.
L'état est enregistré après chaque tour et repris au lancement suivant. Usage : python calib262.py <etat.json> [workers]"""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
STATE = pathlib.Path(sys.argv[1])
WORKERS = int(sys.argv[2]) if len(sys.argv) > 2 else 14
LOW, HIGH, AIM = 0.40, 0.70, 0.55
MIN_COEF, MAX_COEF = 30, 320
V261 = json.loads((ROOT / "design/essais/equilibre_bonus/v261/marges_heroique_bonus.json").read_text(encoding="utf-8"))


def guess(m, f):
    vals = [v for k, v in V261["%d,wise" % f].items() if (int(k)-1)//10 == (m-1)//10]
    margin = st.mean(vals) if vals else 0.0
    if margin <= 0.02: return 85
    return int(max(MIN_COEF, min(MAX_COEF, round(130 + (margin - AIM) * 160))))


def study(item):
    m, f, seed, coef = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed), "POLICY": "refwise", "REFONLY": "", "REINFORCE": "", "V252": "", "HEROIC": "1", "HEROIC_COEF": str(coef)}
    for k in ("HPMUL", "HEROIC_HP"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best = 0.0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0: best = max(best, float(p[6]) / float(p[7]))
    return m, f, seed, coef, best


def candidate(data, m, f):
    """Prochain coefficient à essayer d'après {coef: marge} ; None si l'encadrement est fermé ; 'edge' si une borne est atteinte."""
    if not data: return guess(m, f)
    easy = [c for c, v in data.items() if v > HIGH]
    hard = [c for c, v in data.items() if v < LOW]
    lo = max(easy) if easy else None
    hi = min(hard) if hard else None
    if lo is not None and hi is not None:
        return None if hi - lo <= 1 else (lo + hi) // 2
    if lo is not None:
        if lo >= MAX_COEF: return "edge"
        return min(MAX_COEF, lo + max(4, round((data[lo] - AIM) * 70)))
    if hi <= MIN_COEF: return "edge"
    return max(MIN_COEF, hi - (18 if data[hi] <= 0.0 else max(4, round((AIM - data[hi]) * 70))))


def closest(data):
    return min(data, key=lambda c: (abs(data[c] - AIM), c))


state = json.loads(STATE.read_text(encoding="utf-8")) if STATE.exists() else {"%d,%d" % (m, f): {"one": {}, "three": {}, "coarse": None, "done": None} for m in range(1, 201) for f in (0, 1)}
save = lambda: STATE.write_text(json.dumps(state), encoding="utf-8")
keys = sorted(state, key=lambda k: tuple(map(int, k.split(","))))

# Phase 1 : tirage 7.
for round_index in range(12):
    todo = []
    for key in keys:
        s = state[key]
        if s["coarse"] is not None: continue
        m, f = map(int, key.split(","))
        data = {int(c): v for c, v in s["one"].items()}
        inside = [c for c, v in data.items() if LOW <= v <= HIGH]
        if inside: s["coarse"] = min(inside, key=lambda c: abs(data[c] - AIM)); continue
        c = candidate(data, m, f)
        if c is None or c == "edge": s["coarse"] = closest(data); s["edge1"] = True; continue
        todo.append((m, f, 7, c))
    if not todo: break
    with cf.ThreadPoolExecutor(WORKERS) as pool:
        for m, f, seed, coef, best in pool.map(study, todo):
            state["%d,%d" % (m, f)]["one"][str(coef)] = best
    save()
    print("phase 1, tour %d : %d études" % (round_index + 1, len(todo)), flush=True)

# Phase 2 : tirages 7, 8 et 9 (le tirage 7 déjà mesuré est réutilisé).
for round_index in range(10):
    todo = []
    for key in keys:
        s = state[key]
        if s["done"] is not None: continue
        m, f = map(int, key.split(","))
        data = {int(c): st.mean(v) for c, v in s["three"].items()}
        if not data: c = s["coarse"]
        else:
            inside = [c for c, v in data.items() if LOW <= v <= HIGH]
            if inside: s["done"] = min(inside, key=lambda c: abs(data[c] - AIM)); continue
            c = candidate(data, m, f)
            if c is None or c == "edge": s["done"] = closest(data); s["edge"] = True; continue
        for seed in (7, 8, 9):
            if seed == 7 and str(c) in s["one"]: continue
            todo.append((m, f, seed, c))
        s["pending"] = c
    if not todo: break
    results = {}
    with cf.ThreadPoolExecutor(WORKERS) as pool:
        for m, f, seed, coef, best in pool.map(study, todo):
            results[(m, f, coef, seed)] = best
    for key in keys:
        s = state[key]
        c = s.pop("pending", None)
        if c is None: continue
        m, f = map(int, key.split(","))
        s["three"][str(c)] = [s["one"][str(c)] if (m, f, c, 7) not in results else results[(m, f, c, 7)], results[(m, f, c, 8)], results[(m, f, c, 9)]]
        if (m, f, c, 7) in results: s["one"][str(c)] = results[(m, f, c, 7)]
    save()
    print("phase 2, tour %d : %d études, reste %d" % (round_index + 1, len(todo), sum(1 for k in keys if state[k]["done"] is None)), flush=True)
print("fini", sum(1 for k in keys if state[k]["done"] is not None), "bornes", sum(1 for k in keys if state[k].get("edge")), flush=True)
