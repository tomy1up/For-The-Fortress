# Équilibrage des arbres de talents — v0.168

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

Les mêmes 2 160 parties du chapitre 7 durci, jouées avec l'armée de chaque arbre (voir `Missions_061_070_Volcan.md`), donnent des victoires sur 360 très proches : Alliance 343 (Bastion), 349 (Maîtrise du tir), 351 (Arts arcaniques) ; Horde 195 (Fureur de guerre), 162 (Voie des maléfices), 201 (Démolition). Avec les compositions fixes des essais habituels (archer et hache dans tous les cas, troisième unité achetée à la vague 4), le même chapitre donne encore Alliance 332 (Bastion), 329 (Maîtrise du tir) et 125 (Arts arcaniques), Horde 147 (Fureur de guerre), 39 (Voie des maléfices) et 128 (Démolition). Ces compositions pénalisent toujours les arbres du mage et du chaman, dont l'unité est achetée tard ou absente : ce résultat mesure la composition, pas l'arbre. Pour comparaison, avant ce réglage et sur les cartes de la v0.167, les mêmes compositions donnaient Alliance 262 / 357 / 90 et Horde 176 / 50 / 133 (mêmes ordres d'arbres) ; les cartes ont changé entre-temps (durcissement du chapitre), donc seuls les écarts entre arbres d'une même série sont comparables. Les armées de chaque arbre restent la mesure à retenir.

## Vérifications

La régression complète réussit : 103 suites, 62 490 contrôles Godot et 17 tests Python, dont la nouvelle suite `test_talent_balance.gd` (421 contrôles : échelle de chaque arbre, règle des anciens rapports et parité mesurée à 51 points). Les anciens rapports de version antérieure à la 0.168 se rejouent avec les valeurs historiques : les rapports de référence du grenadier (v0.100), qui contiennent des talents de la Horde, se vérifient toujours à l'identique. Les 52 essais Windows ciblés, dont les écrans de talents des deux factions, réussissent et les 87 empreintes de sources correspondent au projet.

## Limites et questions ouvertes

- **Parité jugée par un joueur automatique.** Les mesures utilisent une stratégie d'achat fixe sur trois cartes. Elles montrent l'ordre de grandeur, pas un jugement de joueur. La parité est vérifiée à 51 points par le test ; à des budgets intermédiaires, l'écart peut atteindre 12 %.
- **Unités chères.** Un arbre dont l'unité coûte 100 or (Arts arcaniques, Voie des maléfices) vaut moins tant que l'unité n'est pas achetée. Le réglage suppose son achat à l'ouverture. Si les joueurs achètent d'abord les unités peu chères, ces arbres seront moins rentables ; leur facteur pourrait être augmenté.
- **Armées mixtes.** Un joueur qui répartit ses points entre plusieurs arbres n'est pas mesuré directement ; la parité de chaque arbre rend ce cas neutre en moyenne.
- **Écart entre factions.** À armée comparable, les talents de l'Alliance sont beaucoup plus puissants que ceux de la Horde (moyenne à 51 points : +136 contre +67,5 pour les arbres de référence). C'est sans doute une cause du retard constaté de la Horde dans tous les essais de campagne. Le réglage de cette version se limite aux arbres d'une même faction ; aligner la Horde sur l'Alliance changerait fortement sa difficulté et demande une décision du porteur.
