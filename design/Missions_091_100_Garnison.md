# Missions 91 à 100 — Chapitre 10, la Garnison

## Décision du porteur et statut de conception

Le 11 novembre 2026, le porteur valide la nouveauté du chapitre 10 (second chapitre du biome de la citadelle ennemie, CAMP-017) : la **Garnison**, un nouvel ennemi propre à la citadelle, l'unité d'élite de la faction adverse, plus résistante. Récompenses inchangées : 60 PO et 100 XP à la première victoire (les missions 101 et suivantes ne donneront plus d'XP dans le design retenu).

Les valeurs et les noms ci-dessous sont des réglages de prototype de Claude Code, à confirmer.

## La Garnison

- Type d'ennemi 10, « Capitaine de garnison » : 520 PV de base (élite ordinaire : 360, boss : 600), vitesse 0,6 (élite : 0,75, boss : 0,45), −4 PV de forteresse, 26 d'or de récompense. Les PV suivent la courbe de difficulté (99 + numéro) %.
- Identités : « Capitaine de garnison orc » quand on joue l'Alliance, « Capitaine de garnison humain » quand on joue la Horde. Le porteur évoquait « chef de guerre ou maréchal » : ces deux noms désignent déjà les boss de fin de mission, le prototype donne donc un nom propre à la Garnison. À trancher.
- Rencontres propres à la citadelle (`scripts/garrison_encounters.gd`, ensemble `citadel_garrison`) : les rencontres du Gué, avec une ou deux Garnisons aux vagues 5, 7, 9 et 10 (à la place des brutes et de l'élite).
- Silhouette provisoire : celle du maréchal ou du chef de guerre. Visuel à produire par Codex.
- Aucun comportement spécial en combat : seule la résistance change.

## Cartes

Cartes dans `prototype/scripts/citadel_maps.gd` (décor `citadel`, habillage par faction à produire).

| Mission | Carte | Entrées | Trajets |
| --- | --- | --- | --- |
| 91 | La Brèche | 1 | 34 |
| 92 | Le Siège | 1 | 35 |
| 93 | Les Mâchicoulis | 2, pression alternée | 38 / 38 |
| 94 | La Grande Salle | 3 | 38 / 34 / 38 |
| 95 | Les Casernes | 1 | 31 |
| 96 | La Tour de Guet | 2, pression alternée | 35 / 35 |
| 97 | L'Armurerie | 3 | 38 / 34 / 38 |
| 98 | Les Escaliers | 2, pression alternée | 38 / 38 |
| 99 | La Salle du Trône | 1 | 32 |
| 100 | Le Cœur de la Citadelle | 3 | 38 / 34 / 38 |

## Méthode de réglage

Même méthode que le chapitre 9 : simulation avec les talents réels (50 points à la mission 100), 48 parties par carte et par faction avec la Garnison, armée de référence (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman), choix du jeu d'emplacements qui maximise les PV restants de la faction la plus faible.

PV de forteresse restants (Alliance / Horde) : 91 : 16 / 18 ; 92 : 11 / 10 ; 93 : 11 / 17 ; 94 : 14 / 19 ; 95 : 15 / 10 ; 96 : 14 / 14 ; 97 : 14 / 21 ; 98 : 13 / 19 ; 99 : 16 / 23 ; 100 : 19 / 23.

Constats :

- **La Garnison durcit nettement le chapitre** : avec les tracés du chapitre 9, la plupart des cartes n'avaient aucun jeu gagnant pour les deux factions. Les tracés retenus reprennent la forme du Cœur des éruptions (entrées à bosse sur une queue partagée), qui offre la meilleure couverture.
- **La finale est la plus facile des marges** (19 / 23 PV) : à durcir si le porteur le souhaite, par exemple en raccourcissant le trajet de la mission 100.
- Les cartes les plus serrées sont 92 et 95 (10 PV pour la Horde).

- **Tracés qui se croisent** : sur les cartes à trois entrées (94, 97, 100), les entrées à bosse et le trajet central se croisent près de la jonction (capture de la mission 94). Les cartes restent valides pour le jeu, mais la lecture est chargée ; à reprendre si le porteur le demande (la forme à bosse est celle qui donne la meilleure couverture aux défenseurs).

## Habillage et animations (Codex)

Visuel de la Garnison (une version par faction), à produire ; voir `TODO_VISUELS.md`.

## Limites connues

- Noms, statistiques, composition des vagues et tracés à confirmer en jeu.
- Aucun son.
