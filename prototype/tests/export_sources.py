"""Contrôle des sources déclarées par un paquet Windows, sans exécuter son contenu."""
from pathlib import Path
import hashlib
import re

SOURCE_PATHS = ('project.godot', 'export_presets.cfg', 'scenes/main.tscn',
                'scripts/main.gd', 'scripts/valley_model.gd', 'scripts/valley_view.gd','scripts/sound_bank.gd','scripts/sound_director.gd','scripts/sound_player.gd',
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
                'assets/enemies/rosters/horde_v003.png.import', 'scripts/enemy_catalogue.gd','scripts/meta_talents.gd','scripts/meta_profile.gd','scripts/meta_screen.gd','scripts/meta_talents_v067.gd','scripts/profile_codec.gd','scripts/map_definition.gd','scripts/mission_progress.gd','scripts/meta_talents_expanded.gd','scripts/meta_talents_v068.gd','scripts/talent_experience.gd','scripts/meta_talents_linked.gd','scripts/campaign_catalogue.gd','scripts/campaign_screen.gd','scripts/shop_catalogue.gd','scripts/shop_screen.gd','scripts/shop_art.gd','assets/units/shop/rodeur_v001.png','assets/units/shop/rodeur_v001.png.import','assets/units/shop/mousquetaire_v002.png','assets/units/shop/mousquetaire_v002.png.import','assets/units/shop/traqueur_v001.png','assets/units/shop/traqueur_v001.png.import','assets/units/shop/grenadier_v001.png','assets/units/shop/grenadier_v001.png.import','assets/units/shop/fantassin_squelette_v001.png','assets/units/shop/fantassin_squelette_v001.png.import','assets/units/shop/tirailleur_gnome_v001.png','assets/units/shop/javeline_v001.png','assets/units/shop/eclat_v001.png','assets/units/shop/tirailleur_gnome_v001.png.import','assets/units/shop/javeline_v001.png.import','assets/units/shop/eclat_v001.png.import','assets/units/shop/pierre_v001.png','assets/units/shop/pierre_v001.png.import','assets/enemies/rosters/capitaine_orc_v001.png','assets/enemies/rosters/capitaine_orc_v001.png.import','assets/effects/shop/slow.png','assets/effects/shop/slow.png.import','assets/effects/shop/mark.png','assets/effects/shop/mark.png.import','assets/effects/shop/loot.png','assets/effects/shop/loot.png.import','assets/effects/shop/volatile.png','assets/effects/shop/volatile.png.import','assets/effects/shop/aura.png','assets/effects/shop/aura.png.import','assets/effects/shop/volatile_burst.png','assets/effects/shop/volatile_burst.png.import','assets/units/shop/gobelin_kamikaze_v001.png','assets/units/shop/gobelin_kamikaze_v001.png.import','assets/units/shop/chef_guerre_veteran_v001.png','assets/units/shop/chef_guerre_veteran_v001.png.import','assets/units/shop/veteran_royal_v001.png','assets/units/shop/veteran_royal_v001.png.import','assets/units/shop/pillard_gobelin_v001.png','assets/units/shop/pillard_gobelin_v001.png.import','assets/units/shop/poseur_mines_v001.png','assets/units/shop/poseur_mines_v001.png.import','assets/units/shop/baliste_guerre_v001.png','assets/units/shop/baliste_guerre_v001.png.import','assets/units/shop/piegeur_nain_v001.png','assets/units/shop/piegeur_nain_v001.png.import','assets/units/shop/balliste_royale_v001.png','assets/units/shop/balliste_royale_v001.png.import','assets/units/shop/alchimiste_gnome_v001.png','assets/units/shop/alchimiste_gnome_v001.png.import','assets/units/shop/eclaireur_observateur_v001.png','assets/units/shop/eclaireur_observateur_v001.png.import','assets/units/shop/pretre_guerrier_v001.png','assets/units/shop/pretre_guerrier_v001.png.import','assets/units/shop/chaman_marais_v001.png','assets/units/shop/chaman_marais_v001.png.import','assets/units/shop/totem_guerre_v001.png','assets/units/shop/totem_guerre_v001.png.import','assets/units/shop/ancien_tribus_v001.png','assets/units/shop/ancien_tribus_v001.png.import','assets/units/shop/marchand_mercenaire_v001.png','assets/units/shop/marchand_mercenaire_v001.png.import','assets/units/shop/hache_en_chaine_v001.png','assets/units/shop/hache_en_chaine_v001.png.import','assets/units/shop/lanceur_double_troll_v001.png','assets/units/shop/lanceur_double_troll_v001.png.import','assets/units/shop/lanceur_masse_orc_v001.png','assets/units/shop/lanceur_masse_orc_v001.png.import','assets/units/shop/sarbacane_gobeline_v001.png','assets/units/shop/sarbacane_gobeline_v001.png.import','assets/units/shop/mage_givre_v001.png','assets/units/shop/mage_givre_v001.png.import','assets/units/shop/fronde_elfe_v001.png','assets/units/shop/fronde_elfe_v001.png.import','assets/units/shop/arbalete_lourde_v001.png','assets/units/shop/arbalete_lourde_v001.png.import','assets/units/shop/pyromancien_humain_v001.png','assets/units/shop/pyromancien_humain_v001.png.import','assets/units/shop/lance_eclats_gobelin_v001.png','assets/units/shop/lance_eclats_gobelin_v001.png.import','assets/units/shop/catapulte_gobeline_v001.png','assets/units/shop/catapulte_gobeline_v001.png.import','assets/units/shop/lance_epieu_orc_v001.png','assets/units/shop/lance_epieu_orc_v001.png.import','assets/units/shop/bruleur_cendres_v001.png','assets/units/shop/bruleur_cendres_v001.png.import','assets/units/shop/mage_foudre_humain_v001.png','assets/units/shop/mage_foudre_humain_v001.png.import','assets/units/shop/archer_double_v001.png','assets/units/shop/archer_double_v001.png.import','assets/units/shop/bombarde_naine_v001.png','assets/units/shop/bombarde_naine_v001.png.import','assets/units/shop/piquier_humain_v001.png','assets/units/shop/piquier_humain_v001.png.import','assets/units/shop/arquebusier_nain_v001.png','assets/units/shop/arquebusier_nain_v001.png.import','assets/units/shop/veilleur_cendres_v001.png','assets/units/shop/veilleur_cendres_v001.png.import','assets/units/shop/veilleur_cendres_guet_v001.png','assets/units/shop/veilleur_cendres_guet_v001.png.import','assets/units/shop/tireur_elite_elfe_v001.png','assets/units/shop/tireur_elite_elfe_v001.png.import','assets/units/shop/sentinelle_elfe_v001.png','assets/units/shop/sentinelle_elfe_v001.png.import','assets/units/shop/sentinelle_elfe_guet_v001.png','assets/units/shop/sentinelle_elfe_guet_v001.png.import','assets/units/shop/javelinier_troll_v001.png','assets/units/shop/javelinier_troll_v001.png.import')
SOURCE_PATHS += ('scripts/bank_encounters.gd', 'assets/enemies/rosters/tortue_gardienne_v001.png', 'assets/enemies/rosters/tortue_gardienne_v001.png.import')
SOURCE_PATHS += ('scripts/fortress_art.gd', 'assets/fortresses/forteresse_alliance_v001.png', 'assets/fortresses/forteresse_alliance_v001.png.import', 'assets/fortresses/forteresse_horde_v001.png', 'assets/fortresses/forteresse_horde_v001.png.import', 'assets/fortresses/roi_alliance_v001.png', 'assets/fortresses/roi_alliance_v001.png.import', 'assets/fortresses/roi_horde_v001.png', 'assets/fortresses/roi_horde_v001.png.import')
SOURCE_PATHS += ('scripts/enemy_walk_art.gd', 'assets/enemies/animations/loup_corps_v002.png', 'assets/enemies/animations/loup_corps_v002.png.import')
SOURCE_PATHS += ('assets/enemies/animations/loup_marche_v002.bin', 'scripts/route_geometry.gd', 'scripts/mission_scout.gd', 'distribution/Lancer_atelier_routes.cmd','distribution/Lancer_essai_boutique.cmd')
SOURCE_PATHS += ('scripts/marsh_art.gd','scripts/drowned_encounters.gd','scripts/drowned_maps.gd','scripts/volcanic_maps.gd','scripts/citadel_maps.gd','scripts/garrison_encounters.gd','scripts/animation_library.gd','scripts/decor_art.gd','scripts/desert_maps.gd','scripts/mine_maps.gd','scripts/sky_maps.gd','scripts/eagle_encounters.gd','scripts/coast_maps.gd','scripts/necro_maps.gd','scripts/revenant_encounters.gd')
SOURCE_PATHS += ('assets/enemies/rosters/capitaine_humain_v001.png','assets/enemies/rosters/capitaine_humain_v001.png.import','assets/enemies/rosters/gueule_de_vase_v001.png','assets/enemies/rosters/gueule_de_vase_v001.png.import','assets/enemies/rosters/aigle_des_cimes_v001.png','assets/enemies/rosters/aigle_des_cimes_v001.png.import','assets/enemies/rosters/revenant_v001.png','assets/enemies/rosters/revenant_v001.png.import')


def animation_assets(project_root=None):
    """Planches et descriptions de assets/animations, images et decor.json de assets/decor, découverts sur disque."""
    root = Path(project_root) if project_root is not None else Path(__file__).resolve().parent.parent
    found = []
    for name in ('animations', 'decor', 'audio'):
        folder = root / 'assets' / name
        if folder.is_dir():
            found += [path.relative_to(root).as_posix() for path in folder.rglob('*') if path.is_file() and path.suffix in ('.png', '.json', '.ogg', '.wav')]
    return tuple(sorted(found))


SOURCE_PATHS += animation_assets()


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
