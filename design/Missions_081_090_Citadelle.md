# Missions 81 à 90 — Chapitre 9, la citadelle ennemie

## Décision du porteur et statut de conception

Le 11 novembre 2026, le porteur retient pour les chapitres 9 et 10 (missions 81–100, cinquième biome) une thématique unique : **la citadelle de la faction adverse**. En jouant l'Alliance, on assiège une citadelle de la Horde ; en jouant la Horde, une citadelle de l'Alliance. Le chapitre 9 ouvre le biome sans règle propre ; la nouveauté arrive au chapitre 10 (CAMP-017) : **la Garnison**, un nouvel ennemi propre à la citadelle, l'unité d'élite de la faction adverse (chef de guerre orc face à l'Alliance, maréchal de l'Alliance face à la Horde), plus résistante. Gains inchangés : 60 PO et 100 XP à la première victoire (le porteur précise que les missions 101 et suivantes ne donneront plus d'XP dans le design retenu).

Tout le reste (noms, tracés, emplacements) est une proposition de prototype de Claude Code, à confirmer.

## Règles

Aucune règle propre : rencontres standard (les dix vagues de base). Les attaquants sont déjà ceux de la faction adverse (fantassins et gardes humains face à la Horde ; guerriers orcs et gardes morts-vivants face à l'Alliance), ce qui colle au thème sans code supplémentaire. PV ennemis `99 + numéro` % (CAMP-015), de 180 % à 189 %.

## Cartes

Les cartes sont dans `prototype/scripts/citadel_maps.gd`, décor `citadel`. Elles sont identiques pour les deux factions ; seul l'habillage devra dépendre de la faction jouée (travail de Codex, voir `TODO_VISUELS.md`). Le code pose un repère de couleur de pierre neutre.

| Mission | Carte | Entrées | Trajets |
| --- | --- | --- | --- |
| 81 | Les Glacis | 1 | 28 |
| 82 | Le Pont-levis | 1 | 29 |
| 83 | La Barbacane | 2, pression alternée | 31 / 31 |
| 84 | Les Remparts | 3 | 27 / 28 / 27 |
| 85 | La Cour d'Armes | 1 | 29 |
| 86 | Les Deux Tours | 2, pression alternée | 31 / 31 |
| 87 | Les Portes Jumelles | 3 | 30 / 26 / 30 |
| 88 | Le Chemin de Ronde | 2, pression alternée | 32 / 32 |
| 89 | Les Oubliettes | 1 | 28 |
| 90 | Le Donjon | 3 | 30 / 26 / 30 |

## Méthode de réglage

Même méthode que pour les chapitres 6 à 8 : emplacements choisis par simulation avec les talents réellement accumulés (40 à 44 points), 16 jeux d'emplacements et trois ordres d'achat par carte (48 parties par faction), armée de référence (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman), en retenant le jeu qui maximise les PV restants de la faction la plus faible.

PV de forteresse restants avec l'armée de référence, jeu retenu (Alliance / Horde) : 81 : 13 / 22 ; 82 : 18 / 25 ; 83 : 16 / 25 ; 84 : 16 / 11 ; 85 : 20 / 26 ; 86 : 18 / 19 ; 87 : 15 / 25 ; 88 : 16 / 24 ; 89 : 20 / 23 ; 90 : 13 / 9.

Constats :

- **Plus aisé que le chapitre 8** : sans affixe, les deux factions gagnent chaque carte avec 9 à 26 PV d'avance ; la finale (90) est la plus serrée, surtout pour la Horde (9 PV). Le chapitre 10 devra durcir avec la Garnison.
- **Sensibilité du tracé** : à nombre d'entrées égal, de petits changements de forme font passer la Horde de zéro à vingt victoires sur 48. Les tracés retenus sont le résultat de plusieurs itérations ; les réajuster demande de refaire la simulation après avoir régénéré le fichier de cartes (la simulation lit les tracés du dépôt).

## Habillage (Codex)

Deux habillages de citadelle sont à produire, un par faction adverse : citadelle de la Horde (vue quand on joue l'Alliance) et citadelle de l'Alliance (vue quand on joue la Horde). Voir `TODO_VISUELS.md`.

## Limites connues

- Tracés et emplacements à confirmer en jeu.
- Les noms des cartes sont identiques pour les deux factions.
- Aucun son.
