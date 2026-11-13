# Missions 171 à 180 — Chapitre 18, côtes et récifs : la brume marine

## Décision du porteur et statut de conception

Le 12 novembre 2026, le porteur retient l'option « côtes et récifs » avec son affixe, la **brume marine**, comme nouveauté du chapitre 18 (CAMP-017), puis demande de l'attaquer. Le principe est validé ; la mécanique précise et ses valeurs sont des **réglages de prototype à confirmer** proposés par Claude Code.

## Règle

- Toutes les **22 s de combat**, une brume dure **6 s** et réduit de **30 %** l'or gagné par élimination ; elle est annoncée **3 s** avant.
- L'or d'une élimination est calculé à l'instant de la mort : `base × 0,7` arrondi à l'entier le plus proche, **au moins 1 or** (grouillant 1, sprinter 3 → 2, brute 7 → 5, colosse 14 → 10, élite 20 → 14, boss 40 → 28). Les revenus de fin de vague et l'or de départ ne sont pas touchés.
- Fonction du seul temps de combat : aucun hasard, rejouable à l'identique à tout pas de simulation. Aucune frontière de brume ne déclenche d'événement : l'état se lit à l'instant de chaque mort.
- PV ennemis (courbe ralentie) : 255 % à 259 %. **100 PO** à la première victoire, aucune XP. La borne des PV acceptés passe à 259 %.
- Habillage provisoire dans le code (liséré clair pendant l'avertissement, voile blanc-bleu et traînées pendant la brume) ; l'habillage définitif revient à Codex.

## Cartes

`prototype/scripts/coast_maps.gd`. Les tracés reprennent ceux du chapitre 17 (les variantes en miroir testées en premier ne laissaient presque aucun jeu gagnant avec la brume) ; la citadelle de la mission 180 reprend la forme de la Baie des Épaves. PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points, brume active :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 171 | Le Phare des Brumes | 1 | 46 | 255 % | 13 / 12 |
| 172 | La Digue Noyée | 1 | 47 | 255 % | 9 / 29 |
| 173 | Les Falaises Blanches | 2 | 44 | 256 % | 11 / 8 |
| 174 | Le Cimetière des Navires | 3 | 42 | 256 % | 13 / 29 |
| 175 | Le Banc de Sable | 1 | 50 | 257 % | 15 / 25 |
| 176 | La Baie Fantôme | 2 | 41 | 257 % | 6 / 6 |
| 177 | Les Écueils Jumeaux | 3 | 41 | 258 % | 11 / 15 |
| 178 | L'Arsenal Englouti | 2 | 44 | 258 % | 11 / 3 |
| 179 | Le Cap des Tempêtes | 1 | 44 | 259 % | 9 / 19 |
| 180 | La Citadelle des Embruns | 3 | 42 | 259 % | 13 / 29 |

**Marges minces** : missions 176 (6 / 6), 178 (Horde : 3 PV) et 173 (Horde : 8 PV). À 255-259 % de PV avec la brume, la référence est près de sa limite : c'est la question O-016 du GDD (courbe de PV), à trancher avec le porteur si les chapitres 19 et 20 ne tiennent plus.

## Contrôles

`tests/test_seamist.gd` (validation, calcul de l'or, états, indépendance du pas, rejeu, dessin) et `tests/test_seamist_chapter.gd` (cartes, récompenses, rapports rejouables, enchaînement), cas `coast171…coast180` de `verify_windows_export.py`.
