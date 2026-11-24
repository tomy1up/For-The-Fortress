"""Essai v0.248 : hausse maximale de PV des 27 réglages au-dessus de 70 %, point par point, tant que l'armée de référence gagne dans les vraies suites
et que la meilleure marge réelle reste d'au moins 40 %. Remet ensuite `campaign_catalogue.gd` exactement dans son état d'origine."""
import re, json, subprocess, os, pathlib, statistics as st, concurrent.futures as cf
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
os.chdir(ROOT)
HERE = pathlib.Path(__file__).parent
OUT = HERE / "v247" / "search"
OUT.mkdir(parents=True, exist_ok=True)
GODOT = "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe"
FLAGS = getattr(subprocess, "CREATE_NO_WINDOW", 0) | getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
ORIGINAL = CATALOGUE.read_bytes()
SUITES = ["test_campaign_guidance.gd", "test_campaign_sample.gd", "test_slate_campaign.gd", "test_headwinds.gd", "test_marsh_campaign.gd", "test_drowned_chapter.gd",
          "test_volcanic_chapter.gd", "test_eruption_chapter.gd", "test_citadel_chapter.gd", "test_garrison_chapter.gd", "test_desert_chapter.gd", "test_sandstorm_chapter.gd",
          "test_mine_chapter.gd", "test_rockfall_chapter.gd", "test_sky_chapter.gd", "test_eagle_chapter.gd", "test_coast_chapter.gd", "test_seamist_chapter.gd",
          "test_necro_chapter.gd", "test_revenant_chapter.gd", "test_biome_attackers.gd", "test_horde_curve.gd", "test_drowned.gd", "test_enemy_art.gd"]
SEEDS = (7, 8, 9)
MARGINS = json.load(open(ROOT / "design/essais/equilibre_bonus/v246/marges_campagne.json"))
SETTINGS = sorted((int(k.split(",")[0]), int(k.split(",")[1])) for k, v in MARGINS.items() if v > 0.70)
assert len(SETTINGS) == 27


def read_table():
    s = ORIGINAL.decode("utf-8")
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    return [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]


def write_table(table):
    s = ORIGINAL.decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
    CATALOGUE.write_bytes(s.encode("utf-8"))


def lost_in(log):
    lost = {(int(m), int(f)) for f, m in re.findall(r"[A-Z_]+_RESULT=(\d),(\d+),defeat", log)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR:.*\(mission (\d+), faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR: Mission (\d+) : une composition accessible gagne \(faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for f, m in re.findall(r"^ERROR:.*\(faction (\d), mission (\d+) : defeat", log, re.M)}
    return lost


def study(item):
    m, f, seed = item
    env = {**os.environ, "MISSIONS": str(m), "FACTIONS": str(f), "SEED": str(seed)}
    env.pop("HPMUL", None)
    r = subprocess.run([GODOT, "--headless", "--path", "prototype", "--script", "res://tools/faction_study.gd"], env=env, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=1800, creationflags=FLAGS)
    best, wins = 0.0, 0
    for line in r.stdout.splitlines():
        p = line.split()
        if len(p) >= 8 and p[0] == "STUDY" and p[5] == "victory" and float(p[7]) > 0:
            wins += 1
            best = max(best, float(p[6])/float(p[7]))
    return m, f, best, wins


def margins(keys):
    raw = {}
    with cf.ThreadPoolExecutor(5) as pool:
        for m, f, best, wins in pool.map(study, [(m, f, seed) for m, f in keys for seed in SEEDS]):
            raw.setdefault((m, f), []).append((best, wins))
    return {key: (st.mean(x[0] for x in v), st.mean(x[1] for x in v)) for key, v in raw.items()}


try:
    base = read_table()
    write_table(base)
    start = margins(SETTINGS)
    final = {key: base[key[1]][key[0]-1] for key in SETTINGS}
    state = {key: {"from": final[key], "start_best": start[key][0], "start_wins": start[key][1], "best": start[key][0], "wins": start[key][1], "stop": "", "tried": {}} for key in SETTINGS}
    active = set(SETTINGS)
    for iteration in range(8):
        if not active:
            break
        table = [list(base[0]), list(base[1])]
        for key, c in final.items():
            table[key[1]][key[0]-1] = c
        trial = {key: final[key]+1 for key in active}
        for key, c in trial.items():
            table[key[1]][key[0]-1] = c
        write_table(table)
        args = [x for suite in SUITES for x in ("--test", suite)]
        run = subprocess.run(["python", "prototype/tests/run_regression.py"] + args + ["--timeout", "590", "--report", str(OUT / f"r{iteration}.json")], capture_output=True, text=True,
                             encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"}, creationflags=FLAGS)
        failed = [l.split()[1] for l in run.stdout.splitlines() if l.startswith("ÉCHEC")]
        lost = set()
        for suite in failed:
            lost |= lost_in((OUT / f"r{iteration}_logs" / (suite + ".log")).read_text(encoding="utf-8", errors="replace"))
        stray = lost-set(trial)
        measured = margins(sorted(trial))
        for key, c in trial.items():
            best, wins = measured[key]
            state[key]["tried"][c] = {"best": best, "wins": wins, "guard": key not in lost}
            if key in lost:
                state[key]["stop"] = "reference"
                active.discard(key)
            elif best < 0.40:
                state[key]["stop"] = "falaise"
                active.discard(key)
            else:
                final[key] = c
                state[key]["best"], state[key]["wins"] = best, wins
                if best <= 0.70:
                    state[key]["stop"] = "cible"
                    active.discard(key)
        print(f"passe {iteration} : essayés {len(trial)}, encore actifs {len(active)}, suites en échec {len(failed)}, pertes hors essai {sorted(stray)}", flush=True)
        json.dump({f"{m},{f}": {**v, "to": final[(m, f)]} for (m, f), v in state.items()}, open(HERE / "v247" / "recherche.json", "w"))
finally:
    CATALOGUE.write_bytes(ORIGINAL)
for (m, f), v in sorted(state.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    print("AH"[f], m, v["from"], "->", final[(m, f)], "marge %.0f -> %.0f" % (v["start_best"]*100, v["best"]*100), "victoires %.0f -> %.0f" % (v["start_wins"], v["wins"]), v["stop"] or "plafond d'essais", flush=True)
print("CATALOGUE RESTAURÉ", flush=True)
