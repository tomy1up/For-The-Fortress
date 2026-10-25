"""Contrôle des sources déclarées par un paquet Windows, sans exécuter son contenu."""
from pathlib import Path
import hashlib
import re

SOURCE_PATHS = ('project.godot', 'export_presets.cfg', 'scenes/main.tscn',
                'scripts/main.gd', 'scripts/valley_model.gd', 'scripts/valley_view.gd',
                'scripts/campaign_data.gd', 'scripts/progression_data.gd',
                'scripts/run_report.gd', 'scripts/combat_metrics.gd')


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
