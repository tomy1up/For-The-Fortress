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
| 191 | La Porte des Tombeaux | 1 | 46 | 262 % | 13 / 22 |
| 192 | La Veillée Funèbre | 1 | 47 | 262 % | 16 / 26 |
| 193 | Les Catacombes | 2 | 44 | 263 % | 15 / 14 |
| 194 | Le Champ d'Ossements | 3 | 42 | 263 % | 15 / 14 |
| 195 | Le Bourbier des Âmes | 1 | 50 | 263 % | 18 / 29 |
| 196 | Le Gibet Oublié | 2 | 41 | 263 % | 13 / 13 |
| 197 | Les Tombes Jumelles | 3 | 41 | 264 % | 13 / 12 |
| 198 | Le Charnier | 2 | 44 | 264 % | 15 / 14 |
| 199 | Les Obélisques Noirs | 1 | 44 | 264 % | 11 / 22 |
| 200 | Le Trône du Roi Mort | 3 | 39 | 264 % | 13 / 24 |

Marges correctes (minimum 11 PV, mission 199).

## Contrôles

`tests/test_revenant.gd` (définition, relève unique et avant la mort, indépendance du pas, rejeu) et `tests/test_revenant_chapter.gd` (cartes, récompenses, rapports rejouables, enchaînement), cas `necro191…necro200` de `verify_windows_export.py`.

Il n'existe plus de chapitre « à venir » : les tests qui s'appuyaient sur un contenu futur (aperçu de terrain, repérage des rencontres) portent désormais sur une mission verrouillée du chapitre 20.
