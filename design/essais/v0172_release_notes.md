# Prototype v0.172 — Chapitre 9 : la citadelle ennemie

Sur décision du porteur (11 novembre 2026), les chapitres 9 et 10 (missions 81 à 100) forment un biome à thématique unique : la citadelle de la faction adverse. Le chapitre 9 ouvre ce biome sans règle propre ; la Garnison (ennemi d'élite de la citadelle) arrivera au chapitre 10.

- **Dix cartes de citadelle** (missions 81 à 90) à une, deux ou trois entrées, rencontres standard, 60 PO et 100 XP à la première victoire, PV ennemis de 180 % à 189 %. Emplacements choisis par simulation avec les talents réellement accumulés ; les deux factions gagnent chaque carte avec leur armée de référence (9 à 26 PV d'avance, la finale étant la plus serrée pour la Horde).
- Le décor de citadelle est provisoire (couleurs de pierre) : l'habillage par faction est confié à Codex (`TODO_VISUELS.md`).
- Nouveau fichier d'exécution `scripts/citadel_maps.gd`, déclaré dans les trois listes d'export.

La régression complète réussit : 106 suites, 70 650 contrôles Godot et 17 tests Python. 8 essais Windows ciblés et 88 empreintes de sources du paquet réussissent.

Documentation : `design/Missions_081_090_Citadelle.md`, `design/Biomes_cumul_2026-10-31.md`.
