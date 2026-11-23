"""Ajustement v0.246 : adapte les suites des chapitres pairs aux nouvelles rencontres, puis abaisse de 3 points (plancher 100) les missions perdues par les politiques de référence.
Les missions au plancher encore perdues sont listées : elles relèvent d'une décision du porteur."""
import re, json, subprocess, os, pathlib
os.chdir("C:/Projet/For the Fortress!")
S = pathlib.Path(__file__).parent / "v246" / "iter"
S.mkdir(parents=True, exist_ok=True)
CATALOGUE = pathlib.Path("prototype/scripts/campaign_catalogue.gd")
T = pathlib.Path("prototype/tests")
SUITES = ["test_campaign_guidance.gd", "test_campaign_sample.gd", "test_slate_campaign.gd", "test_headwinds.gd", "test_marsh_campaign.gd", "test_drowned_chapter.gd",
          "test_volcanic_chapter.gd", "test_eruption_chapter.gd", "test_citadel_chapter.gd", "test_garrison_chapter.gd", "test_desert_chapter.gd", "test_sandstorm_chapter.gd",
          "test_mine_chapter.gd", "test_rockfall_chapter.gd", "test_sky_chapter.gd", "test_eagle_chapter.gd", "test_coast_chapter.gd", "test_seamist_chapter.gd",
          "test_necro_chapter.gd", "test_revenant_chapter.gd", "test_biome_attackers.gd", "test_horde_curve.gd", "test_drowned.gd", "test_enemy_art.gd"]
STEP = 3

for name, wave_set in (("test_eruption_chapter.gd", "ash_golems"), ("test_sandstorm_chapter.gd", "dune_scorpions"), ("test_rockfall_chapter.gd", "mine_moles"), ("test_seamist_chapter.gd", "coast_crabs")):
    p = T / name
    s = p.read_bytes().decode("utf-8")
    if wave_set not in s:
        for old, new in (('not definition.has("wave_set_id")', f'definition.get("wave_set_id","") == "{wave_set}"'),
                         ('Catalogue.runtime(definition.id).get("wave_set_id","ford") == "ford"', f'Catalogue.runtime(definition.id).get("wave_set_id","ford") == "{wave_set}"'),
                         ('model.wave_set_id == "ford"', f'model.wave_set_id == "{wave_set}"'),
                         ('not report.has("wave_set_id")', f'report.get("wave_set_id","") == "{wave_set}"')):
            assert s.count(old) == 1, (name, old, s.count(old))
            s = s.replace(old, new)
        s = s.replace("rencontres standard du Gué avec", "rencontres du biome avec")
        p.write_bytes(s.encode("utf-8"))
p = T / "test_drowned.gd"
s = p.read_bytes().decode("utf-8")
s = s.replace('Model.Enemies.for_profile(13,0).is_empty()', 'Model.Enemies.for_profile(19,0).is_empty()')
p.write_bytes(s.encode("utf-8"))
p = T / "test_enemy_art.gd"
s = p.read_bytes().decode("utf-8")
if "Art.TEXTURES.size() == 25" not in s:
    assert s.count("Art.TEXTURES.size() == 19") == 1
    s = s.replace("Art.TEXTURES.size() == 19", "Art.TEXTURES.size() == 25")
    old = 'or "enemy.neutral.revenant" in [a,b]: continue'
    assert s.count(old) == 1
    s = s.replace(old, 'or "enemy.neutral.revenant" in [a,b] or Art.PLACEHOLDER_TINTS.has(a) or Art.PLACEHOLDER_TINTS.has(b): continue')
    p.write_bytes(s.encode("utf-8"))


def read_table():
    s = CATALOGUE.read_bytes().decode("utf-8")
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    return [list(map(int, r.split(","))) for r in re.findall(r"\[([0-9,]+)\]", s[a:b])]


def write_table(table):
    s = CATALOGUE.read_bytes().decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const REBALANCE_PERCENT := ["); b = s.index("static func rebalance_percent")
    fmt = lambda v: "[" + ",".join(map(str, v)) + "]"
    s = s[:a] + "const REBALANCE_PERCENT := [" + nl + "\t" + fmt(table[0]) + "," + nl + "\t" + fmt(table[1]) + nl + "]" + nl + nl + s[b:]
    below = [[m for m in range(1, 201) if t[m-1] < 100] for t in table]
    s, n = re.subn(r"const BELOW_CURVE_MISSIONS := \{0:\[[0-9,]*\],1:\[[0-9,]*\]\}", "const BELOW_CURVE_MISSIONS := {0:%s,1:%s}" % (fmt(below[0]), fmt(below[1])), s)
    assert n == 1
    CATALOGUE.write_bytes(s.encode("utf-8"))


def lost_in(log):
    lost = {(int(m), int(f)) for f, m in re.findall(r"[A-Z_]+_RESULT=(\d),(\d+),defeat", log)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR:.*\(mission (\d+), faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR: Mission (\d+) : une composition accessible gagne \(faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for f, m in re.findall(r"^ERROR:.*\(faction (\d), mission (\d+) : defeat", log, re.M)}
    return lost


table = read_table()
write_table(table)
start = [list(table[0]), list(table[1])]
blocked = set()
for iteration in range(20):
    args = []
    for suite in SUITES:
        args += ["--test", suite]
    report = S / f"r{iteration}.json"
    run = subprocess.run(["python", "prototype/tests/run_regression.py"] + args + ["--timeout", "590", "--report", str(report)],
                         capture_output=True, text=True, encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"},
                         creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    failed = [l.split()[1] for l in run.stdout.splitlines() if l.startswith("ÉCHEC")]
    lost, unexplained = set(), []
    for suite in failed:
        log = (S / f"r{iteration}_logs" / (suite + ".log")).read_text(encoding="utf-8", errors="replace")
        found = lost_in(log)
        lost |= found
        if not found:
            unexplained.append(suite)
    print(f"passe {iteration} : suites en échec {failed}, missions perdues {sorted(lost)}, échecs sans mission perdue {unexplained}", flush=True)
    if not failed:
        print("TOUT PASSE", flush=True)
        break
    movable = [(m, f) for m, f in lost if table[f][m-1] > 100]
    blocked |= {(m, f) for m, f in lost if table[f][m-1] <= 100}
    if not movable:
        print("PLUS RIEN A ABAISSER", flush=True)
        break
    for m, f in movable:
        table[f][m-1] = max(100, table[f][m-1]-STEP)
    write_table(table)
json.dump({"0": table[0], "1": table[1]}, open(S.parent / "table_iter.json", "w"))
print("MODIFIÉES :", [("AH"[f], m+1, start[f][m], table[f][m]) for f in (0, 1) for m in range(200) if start[f][m] != table[f][m]], flush=True)
print("AU PLANCHER ET PERDUES :", sorted(blocked), flush=True)
print("FIN", flush=True)
