import sys, random, json, pickle, subprocess, os, re
S = "C:/Users/Tomy/AppData/Local/Temp/claude/984c24dbc05689ef/f976c2cb-5bea-4c15-b0a6-9d087df8d7c5/scratchpad"
sys.path.insert(0, S)
import forge as F

GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
PROJECT = "C:/Projet/For the Fortress!/prototype"
# mission -> (gabarit, nombre de routes, PV restants de référence [Alliance, Horde] des anciennes cartes)
PLAN = {111: ("serpent_h", (20, 29)), 112: ("serpent_v", (16, 26)), 113: ("Y_tardif", (17, 22)), 114: ("croisement_fusion", (14, 14)), 115: ("aller_retour", (16, 26)),
        116: ("fusion2", (15, 22)), 117: ("fusion3", (10, 16)), 118: ("peigne", (15, 17)), 119: ("serpent_v", (16, 29)), 120: ("fusion3", (8, 23))}
COUNT = int(sys.argv[1]) if len(sys.argv) > 1 else 28
only = [int(x) for x in sys.argv[2:]] if len(sys.argv) > 2 else list(PLAN)

def simulate(mission, cands):
    path = S + "/cand_batch.json"
    json.dump([{"id": "c%d" % i, "routes": [[list(p) for p in r] for r in c["routes"]], "slots": [list(s) for s in F.order_slots(c["routes"], c["slots"])],
                "alternating": len(c["routes"]) == 2} for i, c in enumerate(cands)], open(path, "w"))
    env = dict(os.environ, CANDIDATES=path, MISSION=str(mission))
    out = subprocess.run([GODOT, "--headless", "--path", PROJECT, "--script", "res://tools/sim_map_candidates.gd"], capture_output=True, text=True, env=env, timeout=3000).stdout
    res = {}
    for m in re.finditer(r"SIM (\d+) (\d) (\w+) (-?\d+) (\d+)", out):
        res.setdefault(int(m.group(1)), {})[int(m.group(2))] = (m.group(3), int(m.group(4)), int(m.group(5)))
    return res

results = {}
if os.path.exists(S + "/search12.pkl"): results = pickle.load(open(S + "/search12.pkl", "rb"))
used = set(str(v["routes"]) for v in results.values())
for n in only:
    name, ref = PLAN[n]
    cands = []
    seed = 1000*n
    while len(cands) < COUNT and seed < 1000*n + 4000:
        seed += 1
        rng = random.Random(seed)
        for nm, routes in F.templates(rng):
            if nm != name or not F.valid_routes(routes) or str(routes) in used: continue
            if nm not in ("croisement","croisement_fusion") and F.crossings(routes) > 0: continue
            if F.crossings(routes) > 2: continue
            target = rng.uniform(32, 52)
            slots = F.place_slots_target(routes, random.Random(seed), target, iterations=220, restarts=2)
            if not slots: continue
            m = F.metrics(routes, slots)
            if m["cover"] < 0.9 or m["first_half"] < 0.8: continue
            cands.append({"routes": routes, "slots": slots, "m": m, "seed": seed, "name": nm})
            if len(cands) >= COUNT: break
    sim = simulate(n, cands)
    best = None
    for i, c in enumerate(cands):
        r = sim.get(i)
        if not r or 0 not in r or 1 not in r: continue
        if r[0][0] != "victory" or r[1][0] != "victory": continue
        err = abs(r[0][1]-ref[0]) + abs(r[1][1]-ref[1])*0.5 + 0.1*abs(sum(F.turns(x) for x in c["routes"])/len(c["routes"])-(4+(n-111)*0.9))
        if best is None or err < best[0]: best = (err, i, r)
    if best:
        c = cands[best[1]]
        c.update({"hp": (best[2][0][1], best[2][1][1]), "ref": ref, "mission": n})
        results[n] = c
        used.add(str(c["routes"]))
        print(n, name, "candidats", len(cands), "retenu seed", c["seed"], "hp", c["hp"], "ref", ref, "couverture %.2f" % c["m"]["cover"], flush=True)
    else:
        wins = sum(1 for i in sim if sim[i].get(0, ("",))[0] == "victory" and sim[i].get(1, ("",))[0] == "victory")
        print(n, name, "aucun candidat valide (%d simulés, %d victoires doubles)" % (len(sim), wins), flush=True)
    pickle.dump(results, open(S + "/search12.pkl", "wb"))
