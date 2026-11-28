"""Après la v0.262 : effet d'un plancher des PV héroïques au-dessus du Normal (demande du porteur du 28 novembre 2026 : l'Héroïque doit avoir
plus de PV que le Normal, le Mythique plus que l'Héroïque). Pour chaque plancher essayé (en % des PV du Normal), les réglages calibrés sous ce
plancher sont rejoués au plancher (HEROIC_COEF), Héroïque complet, joueur avisé, meilleure des 30 compositions, tirages 4, 5 et 6 ; les autres
gardent la mesure de contrôle (`controle_tirages_456.json`). Usage : python planchers_heroique.py <sortie.json> [planchers, ex. 105,110,120] [workers]"""
import json, os, pathlib, subprocess, sys, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
V = ROOT / "design/essais/equilibre_bonus/v262"
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
FLOORS = [int(x) for x in (sys.argv[2] if len(sys.argv) > 2 else "105,110,120").split(",")]
WORKERS = int(sys.argv[3]) if len(sys.argv) > 3 else 14
SEEDS = (4, 5, 6)
state = json.loads((V / "etat_calibrage.json").read_text(encoding="utf-8"))
control = json.loads((V / "controle_tirages_456.json").read_text(encoding="utf-8"))
coef = {(m, f): int(state["%d,%d" % (m, f)]["done"]) for m in range(1, 201) for f in (0, 1)}


def study(item):
    m, f, seed, c = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed), "POLICY": "refwise", "REFONLY": "", "REINFORCE": "", "V252": "", "HEROIC": "1", "HEROIC_COEF": str(c)}
    for k in ("HPMUL", "HEROIC_HP"): env.pop(k, None)
    r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "prototype"), "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=3600, creationflags=FLAGS)
    best = 0.0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0: best = max(best, float(p[6]) / float(p[7]))
    return m, f, seed, c, best


jobs = sorted({(m, f, s, fl) for fl in FLOORS for (m, f), c in coef.items() if c < fl for s in SEEDS})
measured = {}
with cf.ThreadPoolExecutor(WORKERS) as pool:
    for m, f, seed, c, best in pool.map(study, jobs):
        measured.setdefault("%d,%d,%d" % (m, f, c), {})[str(seed)] = best
out = {"floors": FLOORS, "measured": measured}
pathlib.Path(sys.argv[1]).write_text(json.dumps(out), encoding="utf-8")
for fl in FLOORS:
    for f in (0, 1):
        v = []
        lost = one = 0
        for m in range(1, 201):
            seeds = measured["%d,%d,%d" % (m, f, fl)] if coef[(m, f)] < fl else control["%d,%d" % (m, f)]
            v.append(st.mean(seeds.values())); lost += all(x == 0 for x in seeds.values()); one += any(x == 0 for x in seeds.values())
        late = v[100:]
        print("plancher %d faction %d : marge %.1f %%, cible %d, sous 40 %d, au-dessus de 70 %d, perdues sur 3 tirages %d, sur au moins un %d ; chapitres 11-20 : marge %.1f %%, cible %d" % (
            fl, f, 100 * st.mean(v), sum(0.40 <= x <= 0.70 for x in v), sum(x < 0.40 for x in v), sum(x > 0.70 for x in v), lost, one, 100 * st.mean(late), sum(0.40 <= x <= 0.70 for x in late)), flush=True)
