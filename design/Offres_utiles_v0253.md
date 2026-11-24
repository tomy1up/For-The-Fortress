# Offres utiles et recalage de l'Alliance (v0.253)

**Statut.** Décisions du porteur du 24 novembre 2026 :
- pour rendre les bonus moins décisifs, retenir seulement les « offres utiles » (sans changer la valeur d'aucun bonus) ;
- puis, au vu des mesures, « garder et recaler l'Alliance ».

Le critère d'utilité et les coefficients relevés sont des réglages de prototype à confirmer en partie réelle.

## Point de départ : ce qui rend le tirage décisif

Chaque bonus a été imposé au premier choix (vague 2) de l'armée de référence, puis le choix de référence a joué les choix suivants. La mesure porte sur 40 missions (une sur cinq), les deux factions et les tirages 7, 8 et 9, soit 14 640 parties (`valeur_bonus.py`, `valeur_bonus.txt`). PV de forteresse restants en moyenne (0 en cas de défaite) :

| | Alliance | Horde |
| --- | --- | --- |
| Bonus sans aucun effet sur l'armée | environ 27 % | environ 10 à 15 % |
| Plus faibles | Élite sacrifiée 13 %, Forteresse blindée 14 %, Pluie de feu 17 %, Temps suspendu et Chausse-trappes 18 % | Élite sacrifiée 2 %, Forteresse blindée 3 %, Chausse-trappes 6 %, Malédiction tenace 7 %, Temps suspendu 9 % |
| Plus forts | Lames runiques 92 %, Ascension 92 %, Armée d'élite 94 % | Lames runiques 86 %, Armée d'élite et Ascension 93 % |

Environ un quart du catalogue n'a aucun effet sur une armée donnée. Pour l'archer et les arbalétriers de l'Alliance : Tir de barrage, Sortilèges durables, Mêlée acharnée, Soutien efficace, Écho des ricochets et Pluie de feu. Deux limites de cette mesure : imposer le bonus au tout premier choix désavantage les bonus de fin de partie, et la stratégie de référence n'utilise jamais la relance.

## La règle

- Une carte tirée qui ne sert à **aucun défenseur déployé** est remplacée par le premier bonus utile qui la suit dans la même rareté, dans l'ordre des codes et en boucle. Il n'y a **pas de nouveau tirage aléatoire** : une offre dont toutes les cartes étaient utiles reste exactement celle d'avant la v0.253, et toute la suite de la partie aussi. La relance suit la même règle.
- Les bonus soumis au critère et leur condition, identique à leur effet en combat :

| Bonus | Proposé si un défenseur déployé… |
| --- | --- |
| Exercice de tir | n'est pas le chaman orc de base ou l'une de ses spécialisations |
| Éclats meurtriers | est un mage, un lanceur de haches ou un sapeur (ou une de leurs alternatives) avec des dégâts secondaires |
| Propagation | est de ces familles et touche des cibles secondaires |
| Tir de barrage, Écho des ricochets, Pluie de feu | touche des cibles secondaires |
| Sortilèges durables, Malédiction tenace | inflige des dégâts sur la durée |
| Salves rapprochées / Coups de maître | attaque toutes les 1,3 s ou moins / toutes les 2,4 s ou plus |
| Vue dégagée, Tir de couverture / Mêlée acharnée | a une portée de base de 4,5 ou plus / de 3,6 ou moins |
| Soutien efficace | marque, ralentit, pille, pose une charge volatile ou porte une aura |
| Formation serrée / Francs-tireurs | a un voisin à 3 ou moins / n'a aucun voisin à 4,2 ou moins |
| Promotion / Ascension | est au niveau 1 / au niveau 1 ou 2 |

- Les autres bonus restent toujours proposés : dégâts de tous, portée, forteresse, or et prix, ennemis visés, ralentissement à l'apparition. C'est aussi le cas des bonus qui suivent le niveau au fil de la partie (Recrues aguerries, Vétérans, Élite sacrifiée).
- Code : `ValleyModel.bonus_useful`, `_useful_substitute`, `rules_v253`. Les rapports d'avant la v0.253 se rejouent sans le filtre (`Replay.rules_v253_for`). Test : `prototype/tests/test_useful_offers.gd`. Il vérifie notamment, pour les 40 unités à tous les niveaux, que le critère suit l'effet réel du bonus en combat.

## Effets mesurés

**Poids du tirage pour l'armée de référence** (premier choix naturel, 40 missions, tirages 7 à 16 ; `poids_tirage.txt`) :

| | Victoires | PV moyens | Écart moyen entre tirages d'une mission |
| --- | --- | --- | --- |
| Alliance, avant → après | 89 → 92 % | 53 → 62 % | 76 → 81 points |
| Horde, avant → après | 75 → 79 % | 41 → 44 % | 76 → 79 points |

Le filtre ne réduit pas l'écart entre tirages. Ce qui fait gagner ou perdre l'armée de référence, ce sont des bonus utiles mais faibles, ou très forts, et non les cartes mortes.

**Difficulté de la campagne** (meilleure des 30 compositions, première offre, tirages 7, 8 et 9) :
- **Horde** : les 199 réglages sont inchangés, car ses armées profitent de presque tous les bonus.
- **Alliance** : la marge moyenne passe de 55 à 66,5 % et 61 réglages dépassent 70 %, dont les missions 2 et 3 qui l'étaient déjà (`marges_avant_recalage.json`). La stratégie de mesure prend toujours la première carte : elle subissait toutes les cartes mortes. Un vrai joueur les évitait déjà en choisissant parmi trois, donc son gain réel est plus petit.

## Recalage de l'Alliance

Recherche par dichotomie du plus petit coefficient de PV qui ramène la meilleure marge à 70 % ou moins (`recherche253.py`, `recherche.json`), puis garde dans 28 suites de campagne (`garde253.py`) :
- **57 coefficients relevés**, de 1 à 7 points. L'Alliance 64 repasse au-dessus de la courbe de base (101) et sort de la liste des missions sous la courbe.
- **Restent au-dessus de 70 %** :
  - missions 12 (72 %), 13 (82 %), 137 (73 %) et 178 (73 %) : un point de plus fait tomber la marge sous 40 % ;
  - missions 33 (79 %) et 164 (73 %) : la hausse suivante fait perdre l'armée de référence.

## Sur toute la campagne

**386 réglages sur 398 dans la cible**, aucun en dessous, 12 au-dessus (392, 0 et 6 en v0.252) :
- Alliance : 2, 3, 12, 13, 33, 137, 164, 178 ;
- Horde : 2, 3, 23, 39.

Marge moyenne de la meilleure composition : Alliance 63 % (55 % en v0.252), Horde 57 % (inchangée). La nouvelle base est `marges_campagne.json`.

## Limites et suites possibles

- L'Alliance finit plus près du haut de la cible que la Horde. Revenir à sa marge d'avant demanderait un second recalage, mais il rendrait l'Alliance plus dure qu'avant pour un vrai joueur, qui évitait déjà les cartes mortes.
- Pour réduire réellement le poids du tirage, il faudrait agir sur les bonus faibles (Chausse-trappes, Temps suspendu, Élite sacrifiée, Forteresse blindée, Marché noir) ou trop forts (Lames runiques, Exercice de tir, Cadence effrénée, Pari risqué). Le porteur ne l'a pas retenu pour l'instant.

Données et scripts : `design/essais/equilibre_bonus/v253/`.
