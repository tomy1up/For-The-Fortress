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
| 121 | L'Entrée de la Mine | 1 | 34 | 20 / 29 |
| 122 | Le Puits Principal | 1 | 35 | 18 / 25 |
| 123 | La Galerie des Échos | 2, pression alternée | 35 / 35 | 16 / 28 |
| 124 | La Grotte aux Cristaux | 3 | 36 / 36 / 36 | 15 / 29 |
| 125 | Les Rails Abandonnés | 1 | 31 | 20 / 29 |
| 126 | La Forge Souterraine | 2, pression alternée | 32 / 32 | 13 / 22 |
| 127 | Le Lac Noir | 3 | 29 / 29 / 29 | 6 / 18 |
| 128 | La Chambre Forte | 2, pression alternée | 32 / 32 | 16 / 24 |
| 129 | L'Éboulis | 1 | 32 | 20 / 29 |
| 130 | Le Cœur de la Montagne | 3 | 33 / 33 / 33 | 17 / 25 |

La carte 127 reste la plus serrée côté Alliance (6 PV).

## Contrôles

`tests/test_mine_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `mine121…mine130` de `verify_windows_export.py`.
