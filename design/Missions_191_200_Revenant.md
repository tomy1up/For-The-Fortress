# Missions 191 à 200 — Chapitre 20, nécropole et terres maudites : le revenant

## Décision du porteur et statut de conception

Le 13 novembre 2026, le porteur retient le **revenant**, attaquant qui se relève une fois avec la moitié de ses PV, comme nouveauté du chapitre 20 (CAMP-017), avec le biome de la nécropole. Le principe est validé ; nom et valeurs sont des **réglages de prototype à confirmer** proposés par Claude Code. Avec ce chapitre, **la campagne de 200 missions est entièrement jouable**.

## Règle

- **Revenant** (type 12, attaquant neutre commun aux deux factions, `scripts/revenant_encounters.gd`) : 30 PV de base, vitesse 0,9, −1 PV de forteresse, 5 d'or à sa mort définitive. Quand ses PV tombent à 0 pour la première fois, il se relève une seule fois avec **50 % de ses PV maximum** : aucune élimination ni or à cet instant, les malédictions déjà posées restent sur lui. Il apparaît par petits groupes à partir de la vague 4 (jeu de rencontres `necro_revenants`, dérivé de celui du Gué).
- La relève se produit à l'instant exact de la mort : fonction du seul combat, rejouable à l'identique à tout pas de simulation (événement `relève` dans le journal).
- Réglage : avec 60 PV et des groupes de 3 à 6, aucune carte n'avait de jeu gagnant pour les deux factions ; à 30 PV et des groupes de 2 à 4, toutes sont gagnables.
- PV ennemis (courbe à +0,25 % par mission) : 262 % à 264 %. **110 PO** à la première victoire, aucune XP. La borne des PV acceptés passe à 264 %.
- Visuel provisoire : la silhouette de l'ours (cadre partagé) ; l'illustration et l'animation du revenant sont à produire par Codex.

## Cartes

`prototype/scripts/necro_maps.gd`. Tracés repris du chapitre 19 (trajets de 39 à 50). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 191 | La Porte des Tombeaux | 1 | 50 | 262 % | 13 / 29 |
| 192 | La Veillée Funèbre | 1 | 41 | 262 % | 16 / 29 |
| 193 | Les Catacombes | 2 | 44 | 263 % | 14 / 26 |
| 194 | Le Champ d'Ossements | 3 | 36 | 263 % | 6 / 26 |
| 195 | Le Bourbier des Âmes | 1 | 50 | 263 % | 19 / 29 |
| 196 | Le Gibet Oublié | 2 | 42 | 263 % | 13 / 29 |
| 197 | Les Tombes Jumelles | 3 | 37 | 264 % | 9 / 29 |
| 198 | Le Charnier | 2 | 42 | 264 % | 15 / 20 |
| 199 | Les Obélisques Noirs | 1 | 39 | 264 % | 12 / 29 |
| 200 | Le Trône du Roi Mort | 3 | 38 | 264 % | 12 / 29 |

*Refonte des cartes (v0.227) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

Marges correctes (minimum 11 PV, mission 199).

## Contrôles

`tests/test_revenant.gd` (définition, relève unique et avant la mort, indépendance du pas, rejeu) et `tests/test_revenant_chapter.gd` (cartes, récompenses, rapports rejouables, enchaînement), cas `necro191…necro200` de `verify_windows_export.py`.

Il n'existe plus de chapitre « à venir » : les tests qui s'appuyaient sur un contenu futur (aperçu de terrain, repérage des rencontres) portent désormais sur une mission verrouillée du chapitre 20.
