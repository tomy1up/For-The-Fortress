# Missions 161 à 170 — Chapitre 17, côtes et récifs

## Décision du porteur et statut de conception

Le 12 novembre 2026, le porteur retient **côtes et récifs** (port abandonné, falaises, mer : turquoise, blanc d'écume, bois gris) comme neuvième biome, chapitres 17 et 18, parmi quatre options proposées par Claude Code (jungle, nécropole et cité en ruines écartées). L'option retenue comprenait l'affixe du chapitre 18, **Brume marine** : toutes les 22 s, pendant 6 s, l'or gagné par élimination est réduit de 30 %, annoncé 3 s avant ; ces valeurs restent des réglages de prototype à confirmer.

## Règles du chapitre 17

- Premier chapitre du biome : rencontres standard du Gué, sans règle propre (CAMP-017).
- PV ennemis (courbe ralentie) : 250 % à 254 %. **95 PO** à la première victoire, aucune XP. La borne des PV acceptés passe à 254 %.
- Décor `coast`, palette d'essai (turquoise) posée par le code, sans pièce de décor : habillage à produire par Codex.

## Cartes

`prototype/scripts/coast_maps.gd`. Formes prolongées du chapitre 16 (trajets de 39 à 50 ; le Quai des Brumes a un tracé propre, la forme de la Corniche ne laissant aucun jeu gagnant à ce niveau de PV). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 161 | La Jetée Abandonnée | 1 | 46 | 250 % | 18 / 25 |
| 162 | Le Phare Éteint | 1 | 47 | 250 % | 16 / 29 |
| 163 | Les Récifs Blancs | 2 | 44 | 251 % | 17 / 20 |
| 164 | La Baie des Épaves | 3 | 42 | 251 % | 18 / 29 |
| 165 | Le Quai des Brumes | 1 | 50 | 252 % | 18 / 29 |
| 166 | La Falaise du Guet | 2 | 41 | 252 % | 12 / 17 |
| 167 | Les Criques Jumelles | 3 | 41 | 253 % | 15 / 29 |
| 168 | Le Port Englouti | 2 | 44 | 253 % | 17 / 17 |
| 169 | L'Écueil Noir | 1 | 44 | 254 % | 13 / 27 |
| 170 | La Forteresse du Cap | 3 | 39 | 254 % | 14 / 25 |

## Contrôles

`tests/test_coast_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `coast161…coast170` de `verify_windows_export.py`.
