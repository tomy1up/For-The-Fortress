# Missions 121 à 130 — Chapitre 13, souterrains et mines

## Statut de conception

**Biome « souterrains et mines » validé par le porteur le 12 novembre 2026** (voir `Cadrage_missions_101_200.md`). Titres, palette et valeurs restent des réglages de prototype à confirmer.

## Règles

- Rencontres standard du Gué, pas d'affixe (la nouveauté du biome est prévue au chapitre 14, à décider avec le porteur).
- PV ennemis `99 + numéro` %, de **220 % à 229 %** : la borne des PV acceptés passe à 229 %.
- **75 PO** à la première victoire (60 + 5 par chapitre au-delà du dixième, valeur d'essai), aucune XP.
- Décor `mine`, palette d'essai posée par le code (sol `#423B47`, faces `#362F3C` et `#29242F`), sans pièce de décor : habillage à produire par Codex.

## Cartes

`prototype/scripts/mine_maps.gd`. Formes reprises des tracés longs du chapitre 12 (les formes courtes du chapitre 11 ne laissaient aucun jeu gagnant à 220 % pour les deux factions). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajets | PV restants A / H |
| --- | --- | --- | --- | --- |
| 121 | L'Entrée de la Mine | 1 | 41 | 20 / 29 |
| 122 | Le Puits Principal | 1 | 54 | 16 / 25 |
| 123 | La Galerie des Échos | 2, pression alternée | 34 / 33 | 15 / 22 |
| 124 | La Grotte aux Cristaux | 3 | 34 / 31 / 35 | 15 / 23 |
| 125 | Les Rails Abandonnés | 1 | 41 | 20 / 29 |
| 126 | La Forge Souterraine | 2, pression alternée | 32 / 34 | 13 / 24 |
| 127 | Le Lac Noir | 2, pression alternée | 30 / 32 | 7 / 22 |
| 128 | La Chambre Forte | 1 | 50 | 14 / 13 |
| 129 | L'Éboulis | 2, pression alternée | 34 / 34 | 18 / 27 |
| 130 | Le Cœur de la Montagne | 2, pression alternée | 35 / 24 | 17 / 26 |

*Refonte des cartes (v0.225) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

La carte 127 reste la plus serrée côté Alliance (6 PV).

## Contrôles

`tests/test_mine_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `mine121…mine130` de `verify_windows_export.py`.
