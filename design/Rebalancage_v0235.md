# Nouvelle référence de la Horde et recalibrage de ses PV d'ennemis — v0.235

**Statut.** Suite du recalibrage de la v0.234 (`design/Rebalancage_v0234.md`). Le 21 novembre 2026, le porteur a choisi de **changer la composition de référence de la Horde** (O-028, réponse « Changer la référence »). Avant ce choix, deux haches et un chaman devaient gagner chaque mission, ce qui bridait 89 missions de la Horde au-dessus de la cible. La cible reste celle du porteur (MAJ-69) : la meilleure composition d'une mission finit avec 40 à 70 % de ses PV de forteresse. Les coefficients sont des **réglages de prototype à confirmer** en partie réelle.

## La référence, c'est quoi

C'est l'armée fixe que jouent les suites de campagne sur chaque mission, et qui doit gagner. Elle sert de garde-fou : une armée simple, sans optimisation, peut gagner partout.

Stratégie d'achat fixe :
- deux unités à l'ouverture sur les emplacements 3 et 4, la troisième à la vague 2 ;
- la première unité est améliorée à la vague 2, puis tout ce qui est payable à partir de la vague 5 ;
- premier bonus proposé (hors six bonus particuliers), sans relance ni boutique ;
- points de talents dans un seul arbre.

La définition est désormais centralisée dans `prototype/tests/reference_army.gd` :

| Faction | Missions | Armée | Arbre de talents |
| --- | --- | --- | --- |
| Alliance | 1 à 200 | archer elfe, deux arbalétriers nains | Maîtrise du tir |
| Horde | 1 à 70 | deux lanceurs de haches, un chaman orc (inchangé) | Fureur de guerre |
| Horde | **71 à 200** | **deux sapeurs gobelins, un chaman orc** | **Démolition** |

## Pourquoi cette référence et cette bascule

- Dans l'étude de la v0.234, deux sapeurs et un chaman (arbre Démolition) est la composition de la Horde qui gagne le plus de missions sur les trois tirages (101 sur 200, contre 96 pour deux haches et un chaman). Sur les 90 missions au-dessus de la cible, elle gardait en moyenne 66 % de marge, contre 52 % pour l'ancienne référence.
- Elle est en revanche plus faible que les haches au début de la campagne, quand l'arbre Démolition a encore peu de points : utilisée partout, elle aurait fait baisser les PV des chapitres 1 à 3 (27 missions bridées de plus de 5 points).
- J'ai mesuré la référence sur toutes les missions de 100 à 230 % des PV de base, puis comparé plusieurs missions de bascule. **La mission 71 (chapitre 8)** est la plus proche de la cible : écart moyen de 0,5 point de coefficient, 4 missions bridées de plus de 5 points.

## Deuxième correction : les règles des suites des chapitres 4, 7 et 13

Les suites des Vents contraires (chapitre 4), du volcan (chapitre 7) et de la mine (chapitre 13) jouaient encore avec les **anciennes règles de bonus** : douze bonus, trois choix par partie. Leur référence gagnait donc beaucoup moins facilement que dans le jeu actuel, et l'ajustement de la v0.234 avait abaissé leurs coefficients. C'est pour cela que les chapitres 7 et 13 de la Horde étaient les plus faciles (90 et 95 % de marge). Ces trois suites jouent maintenant avec les règles actuelles (60 bonus, rareté, relance).

## Méthode

1. Coefficients de la Horde **inchangés pour les missions 1-30 et 41-60** : la référence et les suites n'y changent pas.
2. **Missions 31-40 et 61-200** : même méthode qu'en v0.234 :
   - meilleure marge des 30 compositions moyennée sur les tirages 7, 8 et 9, interpolée jusqu'à 55 % (données de `calibrage_v233.json`, toujours valables) ;
   - plafond : la référence de la mission garde au moins 25 % de marge (`reference_v233.json` jusqu'à la mission 70, `reference_v235.json` ensuite).
3. **Ajustement par les suites** de ces chapitres : les 15 suites ont été relancées, et chaque mission perdue par la référence a été abaissée de 4 points. Une seule passe a suffi, pour 5 missions (33, 34, 39, 111, 189). En v0.234, ce même ajustement avait abaissé 52 coefficients de la Horde.
4. Les **coefficients de l'Alliance ne changent pas**.

Données : `design/essais/equilibre_bonus/reference_v235.json` (nouvelle référence), `table_v234_final.json` (table de la v0.234), `rebalance_table.json` (table finale), `parties_v235_horde_{7,8,9}.txt` (vérification). Outil : `prototype/tools/faction_study.gd` (`REFONLY=1`, `OLDREF=1` pour l'ancienne référence).

## Table de la Horde

| | v0.234 | v0.235 |
| --- | --- | --- |
| Coefficient moyen | 122,2 % | **126,7 %** |
| Médiane, minimum, maximum | 120, 100, 183 % | 123, 100, 183 % |
| Missions à 100 % | 11 | 4 |
| Missions modifiées | — | 109 (100 relevées, 9 abaissées) |

Coefficient moyen par chapitre (Horde) :

| Chapitre | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| v0.234 | 119 | 118 | 113 | 100 | 116 | 109 | 110 | 109 | 122 | 128 | 132 | 127 | 110 | 123 | 123 | 143 | 140 | 134 | 138 | 130 |
| v0.235 | 119 | 118 | 113 | 106 | 116 | 109 | 120 | 113 | 121 | 131 | 136 | 131 | 133 | 130 | 126 | 150 | 142 | 139 | 143 | 138 |

## Vérification (21 novembre 2026)

Étude de la Horde avec la nouvelle table : 200 missions × 30 compositions × 3 tirages (7, 8, 9), soit 18 000 parties, règles de la v0.233. L'Alliance reprend l'étude de la v0.234 : sa table et ses règles n'ont pas changé.

| Mesure | Alliance (v0.234 = v0.235) | Horde v0.234 | Horde v0.235 |
| --- | --- | --- | --- |
| Meilleure marge moyenne | 56,3 % | 69,4 % | **58,7 %** |
| Meilleure marge médiane | 55,0 % | 67,8 % | 56,3 % |
| Missions dans la cible 40-70 % | 174 | 108 | **174** |
| Missions au-dessus de 70 % | 19 | 90 | **24** |
| Missions sous 40 % | 7 | 2 | 2 |
| Missions à 100 % sur les trois tirages | 0 | 5 | 2 |
| Victoires, toutes compositions confondues | 16,6 % | 16,5 % | 12,9 % |

Meilleure marge moyenne de la Horde par chapitre :

| Chapitre | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| v0.234 | 70 | 56 | 78 | 72 | 64 | 59 | 90 | 67 | 60 | 58 | 66 | 71 | 95 | 73 | 64 | 73 | 63 | 71 | 71 | 66 |
| v0.235 | 70 | 56 | 78 | 62 | 64 | 59 | **57** | 53 | 60 | 55 | 55 | 58 | **52** | 54 | 59 | 55 | 57 | 53 | 60 | 57 |

## Limites et points à surveiller

- **24 missions de la Horde restent au-dessus de 70 %**, surtout aux chapitres 3 (7 missions), 4 (5), 1 (4) et 5 (3). Ces chapitres gardent des stratégies de test propres à chaque mission (Ardoises, Vents contraires) ou leur coefficient de la v0.234.
- **La Horde dépend davantage du tirage des bonus.** Moyenne de la meilleure marge par tirage : 73 %, 25 % et 79 %. L'écart moyen entre tirages pour une même mission monte à 58 points (46 en v0.234). Avec le tirage 8 et sans choisir ses bonus, 49 missions de la Horde sont perdues par les 30 compositions (23 en v0.234, 9 pour l'Alliance). Aucune n'est perdue sur les trois tirages.
- La mesure repose sur une stratégie d'achat fixe et prend toujours la première offre. Un joueur qui choisit ses bonus, utilise la relance et achète en boutique fera mieux, surtout sur un mauvais tirage. Une mesure avec un choix de bonus plus réaliste dirait si cette dépendance au tirage se ressent en partie réelle.
- Deux haches et un chaman ne sont plus garantis de gagner à partir de la mission 71 : c'est l'effet voulu du changement de référence.
