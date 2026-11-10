"""Contrôle des sources déclarées par un paquet Windows, sans exécuter son contenu."""
from pathlib import Path
import hashlib
import re

SOURCE_PATHS = ('project.godot', 'export_presets.cfg', 'scenes/main.tscn',
                'scripts/main.gd', 'scripts/valley_model.gd', 'scripts/valley_view.gd',
                'scripts/campaign_data.gd', 'scripts/progression_data.gd',
                'scripts/run_report.gd', 'scripts/combat_metrics.gd', 'scripts/horde_art.gd',
                'assets/units/horde/troll_v001.png', 'assets/units/horde/gobelin_v001.png',
                'assets/units/horde/chaman_v001.png',
                'assets/units/horde/troll_v001.png.import', 'assets/units/horde/gobelin_v001.png.import',
                'assets/units/horde/chaman_v001.png.import',
                'scripts/alliance_art.gd',
                'assets/units/alliance/archer_v001.png',
                'assets/units/alliance/arbaletrier_rearmement_v001.png',
                'assets/units/alliance/arbaletrier_rearmement_v001.png.import',
                'assets/units/alliance/archer_lacher_v001.png',
                'assets/units/alliance/archer_rearmement_v001.png',
                'assets/units/alliance/archer_encochage_v001.png',
                'assets/units/alliance/archer_lacher_v001.png.import',
                'assets/units/alliance/archer_rearmement_v001.png.import',
                'assets/units/alliance/archer_encochage_v001.png.import',
                'assets/units/alliance/arbaletrier_v001.png',
                'assets/units/alliance/mage_v001.png',
                'assets/units/alliance/archer_v001.png.import',
                'assets/units/alliance/arbaletrier_v001.png.import',
                'assets/units/alliance/mage_v001.png.import',
                'scripts/enemy_art.gd',
                'assets/enemies/rosters/neutres_v001.png',
                'assets/enemies/rosters/alliance_v002.png',
                'assets/enemies/rosters/horde_v003.png',
                'assets/enemies/rosters/neutres_v001.png.import',
                'assets/enemies/rosters/alliance_v002.png.import',
                'assets/enemies/rosters/horde_v003.png.import', 'scripts/enemy_catalogue.gd','scripts/meta_talents.gd','scripts/meta_profile.gd','scripts/meta_screen.gd','scripts/meta_talents_v067.gd','scripts/profile_codec.gd','scripts/map_definition.gd','scripts/mission_progress.gd','scripts/meta_talents_expanded.gd','scripts/meta_talents_v068.gd','scripts/talent_experience.gd','scripts/meta_talents_linked.gd','scripts/campaign_catalogue.gd','scripts/campaign_screen.gd','scripts/shop_catalogue.gd','scripts/shop_screen.gd','scripts/shop_art.gd','assets/units/shop/rodeur_v001.png','assets/units/shop/rodeur_v001.png.import','assets/units/shop/mousquetaire_v002.png','assets/units/shop/mousquetaire_v002.png.import','assets/units/shop/traqueur_v001.png','assets/units/shop/traqueur_v001.png.import','assets/units/shop/grenadier_v001.png','assets/units/shop/grenadier_v001.png.import')
SOURCE_PATHS += ('scripts/bank_encounters.gd', 'assets/enemies/rosters/tortue_gardienne_v001.png', 'assets/enemies/rosters/tortue_gardienne_v001.png.import')
SOURCE_PATHS += ('scripts/fortress_art.gd', 'assets/fortresses/forteresse_alliance_v001.png', 'assets/fortresses/forteresse_alliance_v001.png.import', 'assets/fortresses/forteresse_horde_v001.png', 'assets/fortresses/forteresse_horde_v001.png.import', 'assets/fortresses/roi_alliance_v001.png', 'assets/fortresses/roi_alliance_v001.png.import', 'assets/fortresses/roi_horde_v001.png', 'assets/fortresses/roi_horde_v001.png.import')
SOURCE_PATHS += ('scripts/enemy_walk_art.gd', 'assets/enemies/animations/loup_corps_v002.png', 'assets/enemies/animations/loup_corps_v002.png.import')
SOURCE_PATHS += ('assets/enemies/animations/loup_marche_v002.bin', 'scripts/route_geometry.gd', 'scripts/mission_scout.gd', 'distribution/Lancer_atelier_routes.cmd')
SOURCE_PATHS += ('scripts/marsh_art.gd','scripts/drowned_encounters.gd','scripts/drowned_maps.gd','scripts/volcanic_maps.gd')


def verify_sources(manifest, source_project=None):
    sources = manifest.get('source_sha256')
    if not isinstance(sources, dict) or set(sources) != set(SOURCE_PATHS):
        raise ValueError('Liste des sources du paquet inattendue.')
    for relative, digest in sources.items():
        if not isinstance(digest, str) or re.fullmatch('[0-9a-f]{64}', digest) is None:
            raise ValueError('Empreinte source incorrecte : ' + relative)
        if source_project is not None:
            root = Path(source_project).resolve()
            source = (root / relative).resolve()
            if not source.is_relative_to(root) or not source.is_file():
                raise ValueError('Source absente ou hors projet : ' + relative)
            if hashlib.sha256(source.read_bytes()).hexdigest() != digest:
                raise ValueError('Source différente du paquet : ' + relative)
    return len(sources)
