"""Régression visuelle du combat : capture chaque défenseur (types 0 à 47) au moment de son attaque et de son tir, puis compare avec les images de référence.

Les images de référence sont des vignettes 320 x 200 dans design/essais/captures_reference/. Elles se créent avec --update et doivent être regardées avant d'être
acceptées : le test ne dit pas qu'une image est belle, seulement qu'elle n'a pas changé sans qu'on le sache.

Usage (écran de droite, sans fenêtre minimisée) :
    python prototype/tests/visual_regression.py                     # tout comparer
    python prototype/tests/visual_regression.py --only unit46_pose  # une capture
    python prototype/tests/visual_regression.py --update            # créer ou remplacer les références
    python prototype/tests/visual_regression.py --types 40-47       # une plage de types
Rapport : dist/visual/report.json et, pour chaque écart, une image « courant | référence | écart » dans dist/visual/.
"""
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageStat

ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / "prototype"
REFERENCE_DIR = ROOT / "design" / "essais" / "captures_reference"
OUTPUT_DIR = ROOT / "dist" / "visual"
GODOT = os.environ.get("GODOT", "C:/Projet/.tools/Godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe")
THUMB = (320, 200)
MEAN_LIMIT = 0.15     # écart moyen par canal (0 à 255) sur toute la vignette (deux captures identiques donnent 0,00)
TILE_LIMIT = 0.8      # écart moyen par canal sur une tuile de 20 x 20 px de la vignette : détecte un projectile ou un effet déplacé
TILE = 20
CAPTURE_TIMEOUT = 90


def scenarios(types):
    for type_id in types:
        yield f"unit{type_id:02d}_pose", ["--capture-state=effects", f"--capture-type={type_id}", "--capture-slot=1", "--capture-attack-pose"]
        yield f"unit{type_id:02d}_shot", ["--capture-state=effects", f"--capture-type={type_id}", "--capture-slot=1", "--capture-projectile"]


def capture(name, extra, destination):
    command = [GODOT, "--path", str(PROJECTILE_PATH), "--screen", "1", "--", f"--capture={destination}", *extra]
    try:
        run = subprocess.run(command, capture_output=True, timeout=CAPTURE_TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, "délai dépassé"
    if not destination.exists():
        return False, "image absente (code %d)" % run.returncode
    return True, ""


def thumbnail(path):
    return Image.open(path).convert("RGB").resize(THUMB, Image.LANCZOS)


def compare(current, reference):
    diff = ImageChops.difference(current, reference)
    mean = sum(ImageStat.Stat(diff).mean) / 3
    width, height = diff.size
    worst = 0.0
    for top in range(0, height, TILE):
        for left in range(0, width, TILE):
            tile = diff.crop((left, top, left + TILE, top + TILE))
            worst = max(worst, sum(ImageStat.Stat(tile).mean) / 3)
    return mean, worst, diff


def parse_types(text):
    if "-" in text:
        low, high = text.split("-")
        return list(range(int(low), int(high) + 1))
    return [int(part) for part in text.split(",")]


PROJECTILE_PATH = PROJECT


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--update", action="store_true", help="créer ou remplacer les images de référence")
    parser.add_argument("--only", action="append", help="limiter à une capture nommée (répétable)")
    parser.add_argument("--types", default="0-47", help="types de défenseurs, ex. 0-47 ou 3,21,46")
    arguments = parser.parse_args()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    REFERENCE_DIR.mkdir(parents=True, exist_ok=True)
    results = []
    failures = 0
    for name, extra in scenarios(parse_types(arguments.types)):
        if arguments.only and name not in arguments.only:
            continue
        destination = OUTPUT_DIR / f"{name}.png"
        if destination.exists():
            destination.unlink()
        ok, reason = capture(name, extra, destination)
        if not ok:
            failures += 1
            results.append({"name": name, "status": "erreur", "detail": reason})
            print(f"ERREUR {name} : {reason}")
            continue
        current = thumbnail(destination)
        reference_path = REFERENCE_DIR / f"{name}.png"
        if arguments.update:
            current.save(reference_path, optimize=True)
            results.append({"name": name, "status": "référence écrite"})
            print(f"RÉFÉRENCE {name}")
            continue
        if not reference_path.exists():
            failures += 1
            results.append({"name": name, "status": "référence absente"})
            print(f"ABSENTE {name} : lancer avec --update après avoir regardé l'image")
            continue
        mean, worst, diff = compare(current, Image.open(reference_path).convert("RGB"))
        changed = mean > MEAN_LIMIT or worst > TILE_LIMIT
        results.append({"name": name, "status": "changée" if changed else "ok", "mean": round(mean, 3), "worst_tile": round(worst, 3)})
        if changed:
            failures += 1
            sheet = Image.new("RGB", (THUMB[0] * 3, THUMB[1]))
            sheet.paste(current, (0, 0))
            sheet.paste(Image.open(reference_path).convert("RGB"), (THUMB[0], 0))
            sheet.paste(diff.point(lambda value: min(255, value * 4)), (THUMB[0] * 2, 0))
            sheet.save(OUTPUT_DIR / f"{name}_ecart.png")
            print(f"CHANGÉE {name} : moyenne {mean:.2f}, pire tuile {worst:.2f}")
        else:
            print(f"ok {name} : moyenne {mean:.2f}, pire tuile {worst:.2f}")
    (OUTPUT_DIR / "report.json").write_text(json.dumps({"results": results, "failures": failures}, ensure_ascii=False, indent=1), encoding="utf-8")
    total = len(results)
    print(f"VISUAL ok={failures == 0} captures={total} écarts={failures}")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
