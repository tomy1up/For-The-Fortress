"""Ajustement v0.244 : abaisse de 3 points (plancher 100) le coefficient des missions que l'armée de référence perd, jusqu'à ce que les suites passent.
Les missions déjà au plancher et encore perdues sont listées : elles relèvent d'une décision du porteur."""
import re, json, subprocess, os, pathlib
os.chdir("C:/Projet/For the Fortress!")
S = pathlib.Path(__file__).parent / "v244" / "iter"
S.mkdir(parents=True, exist_ok=True)
CATALOGUE = pathlib.Path("prototype/scripts/campaign_catalogue.gd")
SUITES = ["test_slate_campaign.gd", "test_volcanic_chapter.gd", "test_desert_chapter.gd", "test_mine_chapter.gd", "test_coast_chapter.gd"]
STEP = 3


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


table = read_table()
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
    lost = set()
    for suite in failed:
        log = (S / f"r{iteration}_logs" / (suite + ".log")).read_text(encoding="utf-8", errors="replace")
        for fac, mission in re.findall(r"[A-Z_]+_RESULT=(\d),(\d+),defeat", log):
            lost.add((int(mission), int(fac)))
    print(f"passe {iteration} : suites en échec {failed}, missions perdues {sorted(lost)}", flush=True)
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
print("AU PLANCHER ET PERDUES :", sorted(blocked), flush=True)
print("FIN", flush=True)
