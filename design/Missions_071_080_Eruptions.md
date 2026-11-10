# Missions 71 à 80 — Chapitre 8, les éruptions

## Décision du porteur et statut de conception

Le 10 novembre 2026, le porteur valide le principe de la nouveauté du chapitre 8 : **un affixe « Éruptions » qui désactive au hasard l'un des emplacements de défense pendant quelques secondes** (voir `Biomes_cumul_2026-10-31.md`). Le chapitre 8 est le second chapitre du biome volcanique, donc un chapitre de nouveauté (CAMP-017).

Tout le reste est une proposition de prototype de Claude Code, à confirmer : durée et fréquence de la désactivation, noms, tracés, emplacements. L'habillage visuel de la désactivation n'est pas tranché (voir « Habillage » ci-dessous).

## Règle de l'affixe

Réglage de prototype à confirmer : `{"id":"eruptions","interval":14,"warning":3,"duration":5}`.

- Toutes les 14 s de combat (14 s, 28 s, 42 s…), un défenseur en place, tiré au hasard, est désactivé pendant 5 s : il ne tire plus et ne peut pas enchaîner d'attaque pendant ce temps.
- Un avertissement de 3 s précède chaque éruption (de 11 s à 14 s pour la première). Le joueur voit l'emplacement visé avant qu'il soit touché.
- Le chiffre de l'intervalle tient compte de la vitesse du jeu : l'éruption suit le temps de combat, pas le temps réel.
- Un défenseur désactivé garde ses PV, ses améliorations et sa place ; il reprend simplement son rythme de tir à la fin de la désactivation. Les dégâts déjà infligés par ses projectiles en vol ou par ses effets périodiques ne sont pas retirés.
- Le tirage est déterministe : il dépend de la graine de la partie, du numéro de vague et du numéro de l'éruption, jamais du pas de temps. Un rapport avec éruptions se rejoue à l'identique, et un rapport dont l'affixe a été retiré ou altéré est refusé au rejeu.
- Choisir « au hasard » signifie que la répartition est équitable sur le long terme mais pas régulière : le joueur ne peut pas prévoir quel défenseur sera visé avant l'avertissement.
- Bornes acceptées par le modèle : intervalle de 8 à 40 s, avertissement de 1 à 4 s, durée de 2 à 12 s, valeurs entières, `durée + avertissement + 1 ≤ intervalle` (deux éruptions ne se chevauchent jamais).

Effet moyen : un tiers de l'armée de référence est inactif pendant 5 s sur 14 en moyenne, soit environ 12 % de puissance de feu en moins, mais concentrés sur un instant précis qui peut tomber sur une vague critique.

## Cartes

| Mission | Carte | Entrées | Trajets | Ordre d'achat de référence |
| --- | --- | --- | --- | --- |
| 71 | Le Cratère Fumant | 1 | 36 | 4, 2, 3 |
| 72 | Les Cheminées | 1 | 37 | 4, 2, 3 |
| 73 | Le Cône Ardent | 2, pression alternée | 34 / 34 | 4, 2, 3 |
| 74 | La Faille Rougeoyante | 3 | 30 / 26 / 30 | 4, 2, 3 |
| 75 | Les Geysers de Cendres | 1 | 35 | 4, 2, 3 |
| 76 | La Coulée Noire | 2, pression alternée | 33 / 33 | 4, 2, 3 |
| 77 | Les Braises Dormantes | 3 | 29 / 26 / 29 | 4, 2, 3 |
| 78 | Le Dôme d'Obsidienne | 2, pression alternée | 33 / 33 | 4, 2, 3 |
| 79 | La Gorge de Feu | 1 | 34 | 4, 2, 3 |
| 80 | Le Cœur en Éruption | 3 | 38 / 34 / 38 | 4, 2, 3 |

Les cartes sont dans `prototype/scripts/volcanic_maps.gd` avec celles du chapitre 7 (décor « volcanic », sans scénographie : habillage à produire par Codex). L'affixe est porté par le catalogue (`campaign_catalogue.gd`), pas par la carte. Rencontres standard (les dix vagues du Gué), 60 PO et 100 XP à la première victoire, PV ennemis `99 + numéro` % (CAMP-015), de 171 % à 179 %.

## Méthode de réglage

Comme pour les chapitres 6 et 7, les emplacements viennent de la simulation avec les talents réellement accumulés à chaque mission (35 à 40 points), pas d'un choix à l'œil : pour chaque carte, 16 jeux d'emplacements par couverture du trajet et trois ordres d'achat, soit 48 parties par carte et par faction, avec l'affixe actif. On retient le jeu qui maximise les PV restants de la faction la plus faible, armée de référence (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman).

Parties gagnées sur 48 par carte, et PV de forteresse restants avec le jeu retenu (Alliance / Horde) :

| Mission | Gagnées Alliance | Gagnées Horde | PV restants A / H |
| --- | --- | --- | --- |
| 71 | 8 | 4 | 7 / 8 |
| 72 | 8 | 13 | 19 / 22 |
| 73 | 20 | 1 | 14 / 6 |
| 74 | 15 | 4 | 11 / 10 |
| 75 | 18 | 7 | 14 / 17 |
| 76 | 17 | 1 | 15 / 6 |
| 77 | 12 | 8 | 9 / 11 |
| 78 | 18 | 2 | 15 / 9 |
| 79 | 31 | 15 | 19 / 20 |
| 80 | 18 | 10 | 10 / 20 |

(Les PV maximum de la forteresse dépassent 20 avec les talents ; 22 PV pour la Horde en 72 est normal.)

Constats :

- **Deux cartes serrées pour la Horde** : le Cône Ardent (73) et la Coulée Noire (76) ne laissent que 6 PV à la Horde avec l'armée de référence. Les victoires restent déterministes, mais une composition légèrement moins bonne perd.
- **Cartes à plusieurs entrées** : les premiers essais de tracés plus longs ou plus serrés à plusieurs entrées étaient plus difficiles qu'à une entrée, la Horde ne gagnant presque jamais. Les tracés retenus reprennent la forme de la Faille Rougeoyante (trois entrées qui fusionnent tôt) ou du Dôme (deux entrées, boucle longue avant la forteresse).
- **Piège de méthode** : l'éruption désigne le *n*-ième emplacement occupé. Le résultat d'une partie dépend donc de la position physique des défenseurs. Les emplacements ne sont plus permutés pour imposer l'ordre d'achat des tests : l'ordre d'achat de référence (colonne ci-dessus) fait partie de la mesure et est inscrit dans `tests/test_eruption_chapter.gd`.

## Habillage (Codex)

Le code pose un repère neutre dans `valley_view.gd` (`_draw_eruption`) : losange orange pulsant pour l'avertissement, losange sombre et cercles gris pour la désactivation. Le porteur n'a pas tranché entre cendres et lave. Recommandation de Claude Code, à confirmer : **fissures de lave et braises** sur l'emplacement pendant l'avertissement de 3 s (le joueur voit d'où viendra l'éruption), puis **nuage de cendres sur l'unité** pendant la désactivation (l'unité paraît étouffée plutôt que détruite, ce qui reste cohérent avec toutes les unités). Voir `TODO_VISUELS.md`.

## Limites connues

- Valeurs de l'affixe (14 s / 3 s / 5 s) et tracés à confirmer en jeu.
- Aucun son : l'avertissement n'est que visuel.
- La Horde dispose de peu de marge sur 73 et 76 ; la finale (80) est plus aisée qu'une finale du chapitre 7 pour la Horde (20 PV restants).
- Les chapitres 1 à 3 n'ont pas été remesurés avec les talents abaissés de l'Alliance.
