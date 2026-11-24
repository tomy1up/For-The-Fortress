"""v0.252 : écrit un tableau de renforts dans `campaign_catalogue.gd` (WAVE_REINFORCEMENTS) et lance les suites de campagne.
Usage : guard252.py <choix.json> <dossier> [--keep]  — choix.json : {"m,f": "NOM_ECHELLE", ...}. Sans --keep, le catalogue est remis à l'identique."""
import json, os, pathlib, re, subprocess, sys
ROOT = pathlib.Path("C:/Projet/For the Fortress!")
CATALOGUE = ROOT / "prototype/scripts/campaign_catalogue.gd"
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from ladder252 import LADDER  # noqa: E402  (échelle commune)
SUITES = ["test_campaign_guidance.gd", "test_campaign_sample.gd", "test_slate_campaign.gd", "test_headwinds.gd", "test_marsh_campaign.gd", "test_drowned_chapter.gd",
          "test_volcanic_chapter.gd", "test_eruption_chapter.gd", "test_citadel_chapter.gd", "test_garrison_chapter.gd", "test_desert_chapter.gd", "test_sandstorm_chapter.gd",
          "test_mine_chapter.gd", "test_rockfall_chapter.gd", "test_sky_chapter.gd", "test_eagle_chapter.gd", "test_coast_chapter.gd", "test_seamist_chapter.gd",
          "test_necro_chapter.gd", "test_revenant_chapter.gd", "test_biome_attackers.gd", "test_horde_curve.gd", "test_drowned.gd", "test_enemy_art.gd",
          "test_wave_reinforcements.gd", "test_campaign.gd", "test_bank_guardian.gd", "test_mission_scout.gd"]


def table_text(choice, nl):
    rows = [{}, {}]
    for key, name in choice.items():
        m, f = map(int, key.split(","))
        rows[f][m] = [[int(a), int(b), int(c), float(d)] for a, b, c, d in (s.split(":") for s in LADDER[name])]
    def fmt(d):
        if not d: return "{}"
        parts = []
        for m in sorted(d):
            parts.append("%d:[%s]" % (m, ",".join("[%d,%d,%d,%s]" % (a, b, c, ("%g" % d_) if "." in ("%g" % d_) else "%g.0" % d_) for a, b, c, d_ in d[m])))
        return "{" + ",".join(parts) + "}"
    return "const WAVE_REINFORCEMENTS := [" + nl + "\t" + fmt(rows[0]) + "," + nl + "\t" + fmt(rows[1]) + nl + "]"


def write(choice, original):
    s = original.decode("utf-8")
    nl = "\r\n" if "\r\n" in s else "\n"
    a = s.index("const WAVE_REINFORCEMENTS := ["); b = s.index("static func wave_reinforcements")
    s = s[:a] + table_text(choice, nl) + nl + nl + s[b:]
    CATALOGUE.write_bytes(s.encode("utf-8"))


def lost_in(log):
    lost = {(int(m), int(f)) for f, m in re.findall(r"[A-Z_]+_RESULT=(\d),(\d+),defeat", log)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR:.*\(mission (\d+), faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for m, f in re.findall(r"^ERROR: Mission (\d+) : une composition accessible gagne \(faction (\d)\)", log, re.M)}
    lost |= {(int(m), int(f)) for f, m in re.findall(r"^ERROR:.*\(faction (\d), mission (\d+) : defeat", log, re.M)}
    lost |= {(int(m), int(f)) for f, m in re.findall(r"faction (\d), mission (\d+)", "\n".join(l for l in log.splitlines() if l.startswith("ERROR")))}
    return lost


if __name__ == "__main__":
    choice = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    folder = pathlib.Path(sys.argv[2]); folder.mkdir(parents=True, exist_ok=True)
    original = CATALOGUE.read_bytes()
    try:
        write(choice, original)
        args = [sys.executable, str(ROOT / "prototype/tests/run_regression.py"), "--timeout", "900", "--report", str(folder / "report.json")]
        for suite in SUITES: args += ["--test", suite]
        r = subprocess.run(args, capture_output=True, text=True, encoding="utf-8", errors="replace", env={**os.environ, "PYTHONIOENCODING": "utf-8"},
                           creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        summary = [l for l in r.stdout.splitlines() if l.startswith(("OK ", "ÉCHEC", "REGRESSION"))]
        lost = set()
        errors = []
        for log in (folder / "report_logs").glob("*.log"):
            text = log.read_text(encoding="utf-8", errors="replace")
            lost |= lost_in(text)
            errors += [log.name + " : " + l for l in text.splitlines() if l.startswith("ERROR")][:6]
        (folder / "guard.json").write_text(json.dumps({"choice": choice, "lost": sorted(lost), "summary": summary, "errors": errors[:80]}, ensure_ascii=False, indent=1), encoding="utf-8")
        print("\n".join(l for l in summary if not l.startswith("OK ")))
        print("LOST", sorted(lost))
        print("\n".join(errors[:30]))
    finally:
        if "--keep" not in sys.argv:
            CATALOGUE.write_bytes(original)
