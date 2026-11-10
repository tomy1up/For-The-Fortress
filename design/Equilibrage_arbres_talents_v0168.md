# Équilibrage des arbres de talents — v0.168 et v0.169

## Résumé

- **v0.168** : les trois arbres de chaque faction sont réglés pour se valoir (voir ci-dessous).
- **v0.169** : sur décision du porteur, les talents de l'Alliance sont abaissés pour rejoindre ceux de la Horde (section « Écart entre factions », en fin de fiche). Les arbres de l'Alliance restent équilibrés entre eux.

## Demande du porteur

Le 10 novembre 2026, le porteur demande que les arbres de talents se valent pendant toute l'aventure : si une spécialisation est meilleure que les autres, les autres n'ont aucun intérêt. Cette fiche décrit la mesure, le réglage retenu et ses limites. Les valeurs sont des réglages de prototype à confirmer en jeu.

## Constat de la v0.167

Les essais de campagne de la v0.167 donnaient des écarts énormes entre arbres (Alliance : 357 victoires sur 360 avec Entraînement, 90 avec Étude des arcanes ; Horde : 176 avec Entraînement, 50 avec Rituels). Ces essais combinent trois orientations de talents avec des compositions fixes très orientées archer et hache, et achètent la troisième unité tard : ils surestiment l'écart. Pour juger les arbres eux-mêmes, un banc de mesure dédié a été construit (voir plus bas). Il montre un déséquilibre réel, mais seulement du côté de l'Alliance.

Puissance mesurée de chaque arbre avec tous ses points, armée naturelle (v0.167, avant réglage). Le gain est exprimé en points de « PV ennemis battus » au-dessus de l'armée sans talent :

| Faction | Arbre | 10 points | 20 points | 35 points | 51 points |
| --- | --- | --- | --- | --- | --- |
| Alliance | Bastion | +10 | +21 | +45 | +83 |
| Alliance | Maîtrise du tir | +20 | +46 | +70 | +120 |
| Alliance | Arts arcaniques | +13 | +25 | +36 | +51 |
| Horde | Fureur de guerre (hache) | +10 | +20 | +31 | +47 |
| Horde | Voie des maléfices (chaman) | +11 | +20 | +34 | +53 |
| Horde | Démolition (sapeur) | +12 | +22 | +30 | +45 |

Les trois arbres de la Horde se valaient déjà (à moins de 12 %). Du côté de l'Alliance, Arts arcaniques n'offrait que 43 % de la puissance de Maîtrise du tir à 51 points, et Bastion 69 %, avec une montée tardive.

## Méthode de mesure

Pour chaque arbre, tous les points sont investis dans cet arbre (priorité aux talents majeurs, ou ordre simple : on garde le meilleur des deux). L'armée jouée est celle qu'un joueur de cet arbre constituerait : l'unité que l'arbre améliore est achetée à l'ouverture, les deux autres types complètent. Une recherche par dichotomie trouve les PV ennemis les plus élevés (en % de la référence, de 80 % à 700 %) qui permettent encore de gagner les dix vagues. La puissance de l'arbre est ce seuil moyen sur trois cartes (le Gué, les Trois Passages des Ardoises, les Bassins Engloutis) et deux ordres d'achat, avec 10, 20, 35 et 51 points.

Deux armées sont mesurées : l'armée naturelle (un exemplaire de l'unité de l'arbre) et l'armée doublée (deux exemplaires, quota maximal). La parité est jugée sur la moyenne des deux, car le nombre d'unités achetées dépend du joueur et de son budget.

Précisions qui ont changé le résultat :

- Un arbre dont l'unité n'est achetée qu'à la vague 2 ou plus (mage, chaman, unités à 100 or) vaut environ la moitié si l'unité arrive tard : dans l'armée « naturelle », elle est donc achetée à l'ouverture, comme le ferait un joueur de cet arbre.
- Une première mesure avait inversé les armées de deux arbres de la Horde et laissait croire à un déséquilibre massif du chaman ; elle a été corrigée avant tout réglage.

## Réglage retenu

Un facteur multiplie les dégâts, rebonds, malédictions et portée des talents d'un arbre. Il existe un facteur « début » (talents des lignes 0 à 2) et un facteur « fin » (les autres). Les PV de forteresse, les unités visées et la structure des arbres (prérequis, paliers, rangs, exclusivités) ne changent pas, donc les sauvegardes restent valides : seuls les bonus affichés changent.

| Faction | Arbre | Début | Fin |
| --- | --- | --- | --- |
| Alliance | Bastion | 3,8 | 1,2 |
| Alliance | Maîtrise du tir | 1,0 | 1,0 |
| Alliance | Arts arcaniques | 2,0 | 2,15 |
| Horde | Fureur de guerre | 1,0 | 1,0 |
| Horde | Voie des maléfices | 1,15 | 1,0 |
| Horde | Démolition | 1,0 | 1,4 |

Exemples de valeurs affichées : Étude des arcanes passe de +3 % à +6 % de dégâts et d'explosions par rang ; Puissance directe du mage de +8 % à +16 % ; Bastion, Veille passe de +0,05 à +0,19 de portée par rang et Vigilance de +0,15 à +0,57 ; Démolition, Shrapnels passe de +4 % à +5,6 % d'explosions par rang. Maîtrise du tir et Fureur de guerre, arbres de référence, ne changent pas : le reste de la campagne, réglé avec eux, garde sa difficulté.

La règle est portée par `TREE_SCALE` dans `prototype/scripts/meta_talents_expanded.gd`. Pour que les anciens rapports de partie se rejouent à l'identique, les rapports de version antérieure à la 0.168 sont rejoués avec les valeurs historiques (`talent_rules_legacy`). Toute future modification des effets de talents doit faire de même avec un nouveau seuil de version.

## Résultats après réglage

Gain de puissance à 10 / 20 / 35 / 51 points, moyenne de l'armée naturelle et de l'armée doublée, avec l'écart à l'arbre de référence de la faction :

| Faction | Arbre | Armée naturelle | Armée doublée | Moyenne | Écart à la référence |
| --- | --- | --- | --- | --- | --- |
| Alliance | Bastion | 21 / 49 / 89 / 132 | 21 / 49 / 89 / 132 | 21 / 49 / 89 / 132 | −11 % / −8 % / +5 % / −3 % |
| Alliance | Maîtrise du tir | 20 / 46 / 70 / 120 | 27 / 60 / 100 / 152 | 23,5 / 53 / 85 / 136 | référence |
| Alliance | Arts arcaniques | 22 / 44 / 63 / 119 | 30 / 63 / 87 / 170 | 26 / 53,5 / 75 / 144,5 | +11 % / +1 % / −12 % / +6 % |
| Horde | Fureur de guerre | 10 / 20 / 31 / 47 | 19 / 39 / 57 / 88 | 14,5 / 29,5 / 44 / 67,5 | référence |
| Horde | Voie des maléfices | 12 / 23 / 34 / 57 | 15 / 31 / 49 / 81 | 13,5 / 27 / 41,5 / 69 | −7 % / −8 % / −6 % / +2 % |
| Horde | Démolition | 12 / 24 / 35 / 51 | 19 / 35 / 50 / 82 | 15,5 / 29,5 / 42,5 / 66,5 | +7 % / 0 % / −3 % / −1 % |

Tous les arbres sont à moins de 12 % de la référence à chaque palier, et la plupart à moins de 8 %. Bastion fait exception dans le sens où son armée ne change pas entre les deux séries : il améliore toutes les unités, donc son gain ne dépend pas du nombre d'exemplaires d'une unité.

Un test automatique (`prototype/tests/test_talent_balance.gd`) vérifie les facteurs, la règle des anciens rapports et la parité à 51 points : à 51 points, la puissance moyenne sur trois cartes des trois arbres d'une faction doit rester à moins de 15 % d'écart (mesure : Alliance 246, 231 et 246 ; Horde 155, 166 et 168).

## Résultats en campagne

Après le réglage de la v0.168 (avant l'alignement des factions), les mêmes 2 160 parties du chapitre 7 durci, jouées avec l'armée de chaque arbre (voir `Missions_061_070_Volcan.md`), donnent des victoires sur 360 très proches : Alliance 343 (Bastion), 349 (Maîtrise du tir), 351 (Arts arcaniques) ; Horde 195 (Fureur de guerre), 162 (Voie des maléfices), 201 (Démolition). Avec les compositions fixes des essais habituels (archer et hache dans tous les cas, troisième unité achetée à la vague 4), le même chapitre donne encore Alliance 332 (Bastion), 329 (Maîtrise du tir) et 125 (Arts arcaniques), Horde 147 (Fureur de guerre), 39 (Voie des maléfices) et 128 (Démolition). Ces compositions pénalisent toujours les arbres du mage et du chaman, dont l'unité est achetée tard ou absente : ce résultat mesure la composition, pas l'arbre. Pour comparaison, avant ce réglage et sur les cartes de la v0.167, les mêmes compositions donnaient Alliance 262 / 357 / 90 et Horde 176 / 50 / 133 (mêmes ordres d'arbres) ; les cartes ont changé entre-temps (durcissement du chapitre), donc seuls les écarts entre arbres d'une même série sont comparables. Les armées de chaque arbre restent la mesure à retenir.

## Vérifications

La régression complète réussit : 103 suites, 62 495 contrôles Godot et 17 tests Python, dont `test_talent_balance.gd` (426 contrôles : échelle de chaque arbre, trois jeux de règles par version, parité à 51 points). Les 52 essais Windows ciblés réussissent (menus et lancements des missions 61 à 70 dans les deux factions, chapitre 7 terminé avec rejeu sans nouveau gain, mission 60 comme témoin, écrans de talents, spécialisations à trois entrées) et les 87 empreintes de sources du paquet correspondent au projet. Les rapports de référence du grenadier (v0.100) et le relevé historique de la boutique se rejouent à l'identique avec les valeurs de talents d'origine.

## Limites et questions ouvertes

- **Parité jugée par un joueur automatique.** Les mesures utilisent une stratégie d'achat fixe sur trois cartes. Elles montrent l'ordre de grandeur, pas un jugement de joueur. La parité est vérifiée à 51 points par le test ; à des budgets intermédiaires, l'écart peut atteindre 12 %.
- **Unités chères.** Un arbre dont l'unité coûte 100 or (Arts arcaniques, Voie des maléfices) vaut moins tant que l'unité n'est pas achetée. Le réglage suppose son achat à l'ouverture. Si les joueurs achètent d'abord les unités peu chères, ces arbres seront moins rentables ; leur facteur pourrait être augmenté.
- **Armées mixtes.** Un joueur qui répartit ses points entre plusieurs arbres n'est pas mesuré directement ; la parité de chaque arbre rend ce cas neutre en moyenne.
- **Écart entre factions** : traité dans la section suivante.

## Écart entre factions (v0.169)

**Constat.** Sans talent, les deux factions se valent : le seuil moyen de PV ennemis battus est de 116 (Alliance, armée « Maîtrise du tir ») contre 111 à 118 (Horde). Tout l'écart venait des talents. Avec la v0.168, à 10, 20, 35 et 51 points, un arbre de l'Alliance apportait en moyenne +23,5, +53, +85 et +136, contre +14,5, +28,7, +42,7 et +67,7 pour un arbre de la Horde (rapport d'environ 1,6 à 2). Les cartes des chapitres 4 à 7 sont réglées pour que la stratégie de référence de la Horde gagne : l'Alliance les écrasait (97 % de victoires avec l'armée de son arbre, contre 52 % pour la Horde au chapitre 7).

**Décision du porteur.** Baisser les talents de l'Alliance pour les aligner sur ceux de la Horde. Les cartes, déjà réglées pour ce niveau, n'ont pas à être refaites.

**Réglage.** Les facteurs de l'Alliance sont multipliés par un coefficient qui dépend de la ligne (début, avec un coefficient proche de 0,6 ; fin, proche de 0,5, ajustés arbre par arbre pour garder la parité). Facteurs `TREE_SCALE` de la v0.169 :

| Faction | Arbre | Début | Fin | Valeur v0.168 (début / fin) |
| --- | --- | --- | --- | --- |
| Alliance | Bastion | 2,4 | 0,38 | 3,8 / 1,2 |
| Alliance | Maîtrise du tir | 0,58 | 0,52 | 1,0 / 1,0 |
| Alliance | Arts arcaniques | 1,1 | 1,05 | 2,0 / 2,15 |
| Horde | Fureur de guerre | 1,0 | 1,0 | inchangé |
| Horde | Voie des maléfices | 1,15 | 1,0 | inchangé |
| Horde | Démolition | 1,0 | 1,4 | inchangé |

Les valeurs de la Horde ne changent pas. Exemple : l'Entraînement de Maîtrise du tir (Alliance) passe de +3 % à +1,7 % de dégâts par rang. Les anciens rapports de partie se rejouent avec les valeurs de leur version : historiques avant la 0.168, équilibrées de la v0.168 pour la 0.168, en vigueur à partir de la 0.169 (`Replay.talent_rules_for`).

**Résultat.** Gain de puissance moyen sur les deux séries d'armées (naturelle et doublée), à 10 / 20 / 35 / 51 points, avec l'écart à la moyenne des trois arbres de la Horde (14,5 / 28,7 / 42,7 / 67,7) :

| Faction | Arbre | Gain moyen | Écart |
| --- | --- | --- | --- |
| Alliance | Bastion | 13 / 27 / 51 / 62 | −10 % / −6 % / +20 % / −8 % |
| Alliance | Maîtrise du tir | 14 / 28,5 / 47 / 63,5 | −3 % / −1 % / +10 % / −6 % |
| Alliance | Arts arcaniques | 16,5 / 31,5 / 45 / 62,5 | +14 % / +10 % / +5 % / −8 % |
| Horde | Fureur de guerre | 14,5 / 29,5 / 44 / 67,5 | 0 % / +3 % / +3 % / 0 % |
| Horde | Voie des maléfices | 13,5 / 27 / 41,5 / 69 | −7 % / −6 % / −3 % / +2 % |
| Horde | Démolition | 15,5 / 29,5 / 42,5 / 66,5 | +7 % / +3 % / 0 % / −2 % |

Les deux factions sont maintenant au même niveau à moins de 10 % près, sauf Bastion à 35 points (+20 %, un creux d'équilibrage de cet arbre qui se retrouve quel que soit son facteur de fin) et Arts arcaniques au début (+14 %). Le test de parité (`test_talent_balance.gd`) vérifie la parité des arbres d'une faction à 51 points.

**Conséquences sur les cartes.** À talents égaux, la composition de référence « archer, arbalétrier, mage » ne gagnait plus plusieurs cartes des chapitres 4 à 7, alors que la composition de référence de la Horde (deux haches et un chaman) les gagnait. Les tests utilisent donc, pour l'Alliance, la composition équivalente « archer, arbalétrier, arbalétrier » (et, au chapitre 4, des compositions et renforts propres à quelques missions, comme la Horde en avait déjà). Le finale du chapitre 7 (Cœur du Volcan) a été rallongé de deux unités (27, 24, 27) pour que les deux factions le gagnent avec marge.
