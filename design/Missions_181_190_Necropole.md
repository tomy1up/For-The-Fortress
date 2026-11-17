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
| 181 | Le Portail des Ossements | 1 | 45 | 260 % | 16 / 29 |
| 182 | La Route des Tombes | 1 | 50 | 260 % | 16 / 29 |
| 183 | Le Cimetière Oublié | 2 | 40 | 260 % | 17 / 29 |
| 184 | Les Cryptes Basses | 3 | 38 | 260 % | 11 / 29 |
| 185 | Le Marais des Défunts | 1 | 41 | 261 % | 18 / 29 |
| 186 | La Colline des Pendus | 2 | 39 | 261 % | 12 / 29 |
| 187 | Les Mausolées Jumeaux | 3 | 39 | 261 % | 13 / 29 |
| 188 | L'Ossuaire | 2 | 41 | 261 % | 17 / 29 |
| 189 | Le Champ des Stèles | 1 | 50 | 262 % | 13 / 29 |
| 190 | La Nécropole Royale | 3 | 38 | 262 % | 13 / 29 |

*Refonte des cartes (v0.227) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

Marges correctes (minimum 12 PV, mission 186) : le ralentissement de la courbe à +0,25 % tient au chapitre 19.

## Contrôles

`tests/test_necro_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `necro181…necro190` de `verify_windows_export.py`.
