"""Ajustement v0.245 : corrige les constantes de rythme des suites, puis abaisse de 3 points (plancher 100) les missions perdues par les politiques de référence.
Les missions déjà au plancher et encore perdues sont listées : elles relèvent d'une décision du porteur."""
import re, json, subprocess, os, pathlib
os.chdir("C:/Projet/For the Fortress!")
S = pathlib.Path(__file__).parent / "v245" / "iter"
S.mkdir(parents=True, exist_ok=True)
CATALOGUE = pathlib.Path("prototype/scripts/campaign_catalogue.gd")
T = pathlib.Path("prototype/tests")
SUITES = ["test_campaign_guidance.gd", "test_campaign_sample.gd", "test_slate_campaign.gd", "test_headwinds.gd", "test_marsh_campaign.gd", "test_drowned_chapter.gd",
          "test_volcanic_chapter.gd", "test_eruption_chapter.gd", "test_citadel_chapter.gd", "test_garrison_chapter.gd", "test_desert_chapter.gd", "test_sandstorm_chapter.gd",
          "test_mine_chapter.gd", "test_rockfall_chapter.gd", "test_sky_chapter.gd", "test_eagle_chapter.gd", "test_coast_chapter.gd", "test_seamist_chapter.gd",
          "test_necro_chapter.gd", "test_revenant_chapter.gd"]
STEP = 3


def patch(name, old, new):
    p = T / name
    s = p.read_bytes().decode("utf-8")
    if new in s and old not in s:
        return
    assert s.count(old) == 1, (name, old, s.count(old))
    p.write_bytes(s.replace(old, new).encode("utf-8"))


patch("test_eruption_chapter.gd", 'mission_detail.tooltip_text.contains("14 s")', 'mission_detail.tooltip_text.contains("12 s")')
patch("test_rockfall_chapter.gd", 'int(definition.combat_affix.interval) == 18', 'int(definition.combat_affix.interval) == 12')
patch("test_seamist_chapter.gd", 'int(definition.combat_affix.interval) == 22', 'int(definition.combat_affix.interval) == 12')


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
    CATALOGUE.write_bytes(s.encode("utf-8"))


def lost_in(log):
    lost = {(int(m), int(f)) for f, m in re.findall(r"[A-Z_]+_RESULT=(\d),(\d+),defeat", log)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR:.*\(mission (\d+), faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR: Mission (\d+) : une composition accessible gagne \(faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for f, m in re.findall(r"^ERROR:.*\(faction (\d), mission (\d+) : defeat", log, re.M)}
    return lost


table = read_table()
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
