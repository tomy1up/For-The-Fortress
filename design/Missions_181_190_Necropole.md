# Missions 181 à 190 — Chapitre 19, nécropole et terres maudites

## Décision du porteur et statut de conception

Le 13 novembre 2026, le porteur retient **nécropole et terres maudites** (gris-os, violet, vert maladif, brumes) comme dixième et dernier biome, chapitres 19 et 20, parmi trois options proposées par Claude Code (cité en ruines et jungle écartées). L'option comprenait la nouveauté du chapitre 20, le **revenant** (un attaquant qui se relève une fois avec la moitié de ses PV) : principe retenu, à développer au chapitre 20 ; nom et valeurs à confirmer.

## Règles du chapitre 19

- Premier chapitre du biome : rencontres standard du Gué, sans règle propre (CAMP-017).
- PV ennemis (courbe encore ralentie, décision du porteur du 13 novembre 2026 : +0,25 % par mission depuis la mission 181) : 260 % à 262 %. **105 PO** à la première victoire, aucune XP. La borne des PV acceptés passe à 262 %.
- Décor `necro`, palette d'essai (gris-os et violet) posée par le code, sans pièce de décor : habillage à produire par Codex.

## Cartes

`prototype/scripts/necro_maps.gd`. Tracés repris du chapitre 17 (trajets de 39 à 50). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 181 | Le Portail des Ossements | 1 | 46 | 260 % | 16 / 21 |
| 182 | La Route des Tombes | 1 | 47 | 260 % | 16 / 29 |
| 183 | Le Cimetière Oublié | 2 | 44 | 260 % | 17 / 15 |
| 184 | Les Cryptes Basses | 3 | 42 | 260 % | 16 / 29 |
| 185 | Le Marais des Défunts | 1 | 50 | 261 % | 18 / 29 |
| 186 | La Colline des Pendus | 2 | 41 | 261 % | 12 / 12 |
| 187 | Les Mausolées Jumeaux | 3 | 41 | 261 % | 15 / 29 |
| 188 | L'Ossuaire | 2 | 44 | 261 % | 17 / 15 |
| 189 | Le Champ des Stèles | 1 | 44 | 262 % | 13 / 25 |
| 190 | La Nécropole Royale | 3 | 39 | 262 % | 13 / 16 |

Marges correctes (minimum 12 PV, mission 186) : le ralentissement de la courbe à +0,25 % tient au chapitre 19.

## Contrôles

`tests/test_necro_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `necro181…necro190` de `verify_windows_export.py`.
