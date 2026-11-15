"""Régression visuelle du combat : capture chaque défenseur (types 0 à 47) au moment de son attaque et de son tir, puis compare avec les images de référence.

Les images de référence sont des vignettes 320 x 200 dans design/essais/captures_reference/. Elles se créent avec --update et doivent être regardées avant d'être
acceptées : le test ne dit pas qu'une image est belle, seulement qu'elle n'a pas changé sans qu'on le sache.

Usage (écran de droite, sans fenêtre minimisée) :
    python prototype/tests/visual_regression.py                     # tout comparer
    python prototype/tests/visual_regression.py --only unit46_pose  # une capture
    python prototype/tests/visual_regression.py --update            # créer ou remplacer les références
    python prototype/tests/visual_regression.py --types 40-47       # une plage de types
    python prototype/tests/visual_regression.py --group menus       # un groupe : units, menus, missions, effects
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
# Tolérances particulières : les traits de vent des Vents contraires (mission 31) suivent l'horloge réelle et varient d'une capture à l'autre.
TILE_LIMIT_BY_NAME = {"mountain31": 2.0, "ash71": 12.0}
# Éruptions (mission 71) : la position des ennemis aux instants de l'affixe varie légèrement avec la cadence d'images de la machine ; on ne surveille que les écarts nets.
MEAN_LIMIT_BY_NAME = {"ash71": 0.4}


GROUPS = ("units", "menus", "missions", "effects", "affixes", "armies")
# Armées complètes (six défenseurs de niveaux 1 à 3) face aux vagues 5 et 10 de trois missions, pour voir une vraie bataille.
ARMY_VARIANTS = ["mountain31play", "garrison94play", "necro195play"]
# Affixes de mission (variante main.gd, instants de combat en secondes simulées).
AFFIX_VARIANTS = {"ash71play": "3,11,13.5,15,17", "dune115play": "6,12,20", "mine135play": "6,14,24", "coast175play": "6,12,20"}
# Une mission par chapitre (variante `<nom>play` de main.gd : deux défenseurs posés), vagues 1, 5 et 10.
MISSION_VARIANTS = ["mountain31play", "marsh51play", "volcano61play", "ash71play", "citadel87play", "garrison94play", "dune105play", "mine125play", "sky145play", "coast165play", "necro195play"]
MISSION_TIMELINE = "1:3,5:6,10:4"


def scenarios(types, groups):
    """Rend (nom, arguments, plusieurs_images) : `plusieurs_images` vaut vrai quand une série d'images <nom>_*.png est attendue."""
    if "units" in groups:
        for type_id in types:
            yield f"unit{type_id:02d}_pose", ["--capture-state=effects", f"--capture-type={type_id}", "--capture-slot=1", "--capture-attack-pose"], False
            yield f"unit{type_id:02d}_shot", ["--capture-state=effects", f"--capture-type={type_id}", "--capture-slot=1", "--capture-projectile"], False
    for faction in ("alliance", "horde"):
        if "menus" in groups:
            for variant in ("fresh", "completed", "talents", "future", "blocked"):
                yield f"menu_{faction}_{variant}", ["--capture-state=campaign_menu", f"--capture-faction={faction}", f"--capture-campaign={variant}"], False
            yield f"menu_{faction}_shop", ["--capture-state=shop_menu", f"--capture-faction={faction}"], False
        if "missions" in groups:
            for variant in MISSION_VARIANTS:
                yield f"mission_{faction}_{variant}", ["--capture-state=campaign_menu", f"--capture-faction={faction}", f"--capture-campaign={variant}", "--capture-mountain-defence", f"--capture-timeline={MISSION_TIMELINE}"], True
        if "armies" in groups:
            for variant in ARMY_VARIANTS:
                yield f"army_{faction}_{variant}", ["--capture-state=campaign_menu", f"--capture-faction={faction}", f"--capture-campaign={variant}", "--capture-mountain-defence", "--capture-full-army", "--capture-timeline=5:6,10:6"], True
        if "affixes" in groups:
            for variant, instants in AFFIX_VARIANTS.items():
                yield f"affix_{faction}_{variant}", ["--capture-state=campaign_menu", f"--capture-faction={faction}", f"--capture-campaign={variant}", "--capture-mountain-defence", f"--capture-timeline={instants}"], True
        if "effects" in groups:
            yield f"effect_{faction}_elimination", ["--capture-state=elimination", "--capture-type=%d" % (0 if faction == "alliance" else 3), "--capture-slot=1"], False
    if "effects" in groups:
        # Ces deux états imposent le type 5 (chaman) quel que soit le camp : une seule capture suffit.
        yield "effect_damage_tick", ["--capture-state=damage_tick", "--capture-slot=1"], False
        yield "effect_curse", ["--capture-state=curse", "--capture-type=5", "--capture-slot=1"], False


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


# Pied de page gauche (« Prototype v0.xxx · Nom de travail ») : le numéro de version change à chaque publication et n'est pas un défaut visuel.
FOOTER_MASK = (0, 190, 110, 200)  # coordonnées de la vignette 320 x 200


def masked(image):
    image = image.copy()
    image.paste((0, 0, 0), FOOTER_MASK)
    return image


def compare(current, reference):
    current, reference = masked(current), masked(reference)
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


def check_image(path, update, results):
    """Compare (ou enregistre) une capture ; retourne le nombre d'écarts."""
    name = path.stem
    current = thumbnail(path)
    reference_path = REFERENCE_DIR / f"{name}.png"
    if update:
        current.save(reference_path, optimize=True)
        results.append({"name": name, "status": "référence écrite"})
        print(f"RÉFÉRENCE {name}")
        return 0
    if not reference_path.exists():
        results.append({"name": name, "status": "référence absente"})
        print(f"ABSENTE {name} : lancer avec --update après avoir regardé l'image")
        return 1
    mean, worst, diff = compare(current, Image.open(reference_path).convert("RGB"))
    tile_limit = max([TILE_LIMIT] + [limit for key, limit in TILE_LIMIT_BY_NAME.items() if key in name])
    mean_limit = max([MEAN_LIMIT] + [limit for key, limit in MEAN_LIMIT_BY_NAME.items() if key in name])
    changed = mean > mean_limit or worst > tile_limit
    results.append({"name": name, "status": "changée" if changed else "ok", "mean": round(mean, 3), "worst_tile": round(worst, 3)})
    if changed:
        sheet = Image.new("RGB", (THUMB[0] * 3, THUMB[1]))
        sheet.paste(current, (0, 0))
        sheet.paste(Image.open(reference_path).convert("RGB"), (THUMB[0], 0))
        sheet.paste(diff.point(lambda value: min(255, value * 4)), (THUMB[0] * 2, 0))
        sheet.save(OUTPUT_DIR / f"{name}_ecart.png")
        print(f"CHANGÉE {name} : moyenne {mean:.2f}, pire tuile {worst:.2f}")
        return 1
    print(f"ok {name} : moyenne {mean:.2f}, pire tuile {worst:.2f}")
    return 0


def run_scenario(name, extra, series, update, results):
    """Capture un scénario et compare ses images ; retourne le nombre d'écarts."""
    for old in OUTPUT_DIR.glob(f"{name}*.png"):
        old.unlink()
    destination = OUTPUT_DIR / f"{name}.png"
    ok, reason = capture(name, extra, destination)
    if not ok:
        results.append({"name": name, "status": "erreur", "detail": reason})
        print(f"ERREUR {name} : {reason}")
        return 1
    images = sorted(path for path in OUTPUT_DIR.glob(f"{name}_*.png") if not path.stem.endswith("_ecart")) if series else [destination]  # l'image finale <nom>.png répète la dernière de la série
    return sum(check_image(path, update, results) for path in images)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--update", action="store_true", help="créer ou remplacer les images de référence")
    parser.add_argument("--only", action="append", help="limiter à une capture nommée (répétable, préfixe accepté pour les séries)")
    parser.add_argument("--types", default="0-47", help="types de défenseurs, ex. 0-47 ou 3,21,46")
    parser.add_argument("--group", action="append", choices=GROUPS, help="groupe de scénarios (répétable) ; tous par défaut")
    arguments = parser.parse_args()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    REFERENCE_DIR.mkdir(parents=True, exist_ok=True)
    results = []
    failures = 0
    for name, extra, series in scenarios(parse_types(arguments.types), arguments.group or GROUPS):
        if arguments.only and not any(name == only or name.startswith(only) for only in arguments.only):
            continue
        # Un écart est confirmé par une seconde capture : certaines captures (éruptions) dépendent du découpage des images à l'écran et varient parfois avec la charge de la machine.
        for attempt in (1, 2):
            scenario_results = []
            scenario_failures = run_scenario(name, extra, series, arguments.update, scenario_results)
            if scenario_failures == 0 or arguments.update:
                break
            if attempt == 1:
                print(f"  -> nouvel essai de {name}")
        failures += scenario_failures
        results.extend(scenario_results)
    (OUTPUT_DIR / "report.json").write_text(json.dumps({"results": results, "failures": failures}, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"VISUAL ok={failures == 0} captures={len(results)} écarts={failures}")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
