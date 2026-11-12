# Missions 131 à 140 — Chapitre 14, souterrains et mines : l'éboulement

## Décision du porteur et statut de conception

Le 12 novembre 2026, le porteur valide le biome « souterrains et mines », puis retient **l'éboulement qui bloque un trajet** comme nouveauté du chapitre 14 (CAMP-017). Le principe est validé. Le porteur a aussi validé le 12 novembre 2026 les valeurs d'essai proposées par Claude Code (18 s, 7 s, 3 s, report sur l'entrée suivante) ; elles restent à réévaluer à l'équilibrage.

## Règle

- Toutes les **18 s de combat**, un éboulement bloque une entrée pendant **7 s** ; il est annoncé **3 s** avant.
- Les ennemis qui devaient apparaître sur l'entrée bloquée pendant ces 7 s **apparaissent par l'entrée suivante** (modulo le nombre d'entrées). Ceux qui sont déjà en chemin ne sont pas touchés.
- L'éboulement numéro n tombe sur l'entrée de rang (n + numéro de vague) modulo le nombre d'entrées : aucun hasard, la prévision de vague tient compte du report et le rejeu est identique à tout pas de simulation.
- Il exige au moins deux entrées : les dix cartes du chapitre ont deux ou trois entrées. L'affixe est refusé sur une carte à une seule entrée.
- PV ennemis `99 + numéro` % (230 % à 239 %, borne portée à 239 %), **80 PO** à la première victoire, aucune XP, rencontres standard du Gué.
- Habillage provisoire dans le code (anneau qui pulse puis éboulis gris à l'entrée touchée) ; l'habillage définitif revient à Codex.

## Cartes

`prototype/scripts/mine_maps.gd` (décor `mine`). Les tracés reprennent les formes à plusieurs entrées des chapitres 11 à 13 (il n'en existe que douze ; certaines servent donc deux fois avec un autre jeu d'emplacements). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points, éboulement actif :

| Mission | Carte | Entrées | Trajet principal | PV restants A / H |
| --- | --- | --- | --- | --- |
| 131 | Les Piliers Fissurés | 2 | 38 | 18 / 27 |
| 132 | La Veine Oubliée | 3 | 35 | 16 / 26 |
| 133 | Le Tunnel Éventré | 2 | 38 | 18 / 22 |
| 134 | La Voûte Instable | 3 | 36 | 17 / 29 |
| 135 | Les Galeries Jumelles | 2 | 38 | 16 / 24 |
| 136 | Le Gouffre Noir | 3 | 33 | 16 / 25 |
| 137 | L'Écluse Souterraine | 2 | 38 | 16 / 24 |
| 138 | Le Carrefour des Éboulis | 2 | 35 | 16 / 23 |
| 139 | La Crypte des Mineurs | 3 | 35 | 16 / 24 |
| 140 | Le Cœur Effondré | 3 | 33 | 14 / 25 |

## Contrôles

`tests/test_rockfall.gd` (validation, fenêtres de blocage, report des apparitions, prévision, indépendance du pas, rejeu, dessin) et `tests/test_rockfall_chapter.gd` (cartes, récompenses, rapports rejouables, enchaînement), cas `mine131…mine140` de `verify_windows_export.py`.
