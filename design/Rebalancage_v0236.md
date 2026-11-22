# Fin du recalibrage et choix de bonus guidé — v0.236

**Statut.** Suite de la v0.235 (`design/Rebalancage_v0235.md`), demandée par le porteur le 21 novembre 2026 (« Finir l'équilibrage ») : remonter les missions encore au-dessus de la cible, puis mesurer la dépendance au tirage avec un choix de bonus réaliste. La cible reste celle du porteur (MAJ-69) : la meilleure composition finit avec 40 à 70 % de ses PV de forteresse. Les coefficients sont des **réglages de prototype à confirmer** en partie réelle.

## Recalibrage

- Table de départ : pour les deux factions et toutes les missions sauf la première, coefficient ramenant la meilleure marge moyenne à 55 %, plafonné par la référence de la mission (`tests/reference_army.gd`). Mêmes données qu'en v0.234 et v0.235 (`calibrage_v233.json`, `reference_v233.json`, `reference_v235.json`).
- Seules 29 missions pouvaient remonter (13 pour l'Alliance, 16 pour la Horde). Les autres missions au-dessus de la cible sont déjà à leur coefficient cible, ou bridées par la référence de leur faction.
- Ajustement par dix suites de campagne, par pas de 3 points cette fois, en six passes : seules les missions perdues par une suite sont abaissées.
- **Alliance** : 12 missions relevées, surtout aux chapitres 7 et 13 (+6 points). Ces missions étaient bridées par les suites du volcan et de la mine, qui jouaient avec les anciennes règles de bonus jusqu'à la v0.234. Coefficient moyen 112,7 % (112,3 %).
- **Horde** : 9 missions relevées de 1 à 3 points ; les stratégies propres à chaque mission des Ardoises (chapitre 3) ramènent les missions 24 à 29 à leur valeur précédente. Coefficient moyen 126,8 % (126,7 %).

### Pourquoi certaines missions restent au-dessus de 70 %

La marge chute brutalement avec les PV ennemis. Par exemple, la mission 121 de l'Alliance passe de 85 % de marge moyenne à 125 % de PV à 42 % à 130 %. Une mission réglée quelques points sous cette falaise reste au-dessus de 70 %. Les 32 missions encore au-dessus de la cible (8 pour l'Alliance, 24 pour la Horde) se répartissent ainsi :
- bridées par une suite de campagne : armée de référence ou stratégie propre à la mission ;
- bridées par la référence de la faction ;
- déjà à leur coefficient cible, sans pouvoir aller plus haut ;
- la mission 1, gardée à 100 % pour le format historique de son rapport.

## Vérification (21 novembre 2026)

Étude complète : 200 missions × 2 factions × 30 compositions × 3 tirages (7, 8, 9) = 36 000 parties, première offre de bonus.

| Mesure | Alliance v0.235 | Alliance v0.236 | Horde v0.235 | Horde v0.236 |
| --- | --- | --- | --- | --- |
| Meilleure marge moyenne | 56,3 % | **54,7 %** | 58,7 % | **58,5 %** |
| Missions dans la cible 40-70 % | 174 | **185** | 174 | 174 |
| Au-dessus de 70 % | 19 | 8 | 24 | 24 |
| Sous 40 % | 7 | 7 | 2 | 2 |
| Chapitre 7 / chapitre 13 | 63 / 70 % | 54 / 50 % | 57 / 52 % | 57 / 52 % |

## Choix de bonus guidé (nouvelle mesure)

`tools/faction_study.gd`, `POLICY=look` : à chaque choix, chaque offre est essayée sur une copie exacte de la partie, jouée jusqu'au bout. Si la relance est disponible, les trois offres relancées sont essayées aussi, et l'offre qui finit avec le plus de PV de forteresse est retenue. La copie a été contrôlée : dix parties serrées copiées en cours de route finissent à l'identique. Le joueur simulé voit donc l'issue de chaque offre : c'est une **borne haute** d'un joueur qui choisit bien ses bonus. Mesure sur une mission sur deux (100 missions × 2 factions × 30 compositions × 3 tirages = 18 000 parties).

| Mesure (missions paires) | Alliance, première offre | Alliance, choix guidé | Horde, première offre | Horde, choix guidé |
| --- | --- | --- | --- | --- |
| Meilleure marge moyenne | 55,2 % | **89,2 %** | 57,3 % | **90,9 %** |
| Moyenne par tirage (7, 8, 9) | 76, 33, 57 % | 88, 93, 86 % | 70, 25, 77 % | 83, 95, 94 % |
| Écart moyen entre tirages | 44 points | 18 points | 57 points | 17 points |
| Missions perdues par les 30 compositions (tirage 8) | 6 | 0 | 24 | 0 |
| Victoires, toutes compositions | — | 44,1 % | — | 25,3 % |

Constats :
- **La dépendance de la Horde au tirage vient de la stratégie « première offre ».** Quand le bonus est bien choisi, les deux factions se valent (89 et 91 %) et aucune mission n'est perdue, même sur le tirage le moins favorable.
- **Bien choisir ses bonus rend la campagne beaucoup plus facile** : la meilleure composition finit vers 90 % de marge, bien au-dessus de la cible. Cette mesure est une borne haute : un vrai joueur ne voit pas l'issue de chaque offre. La cible de 40 à 70 % reste mesurée avec la première offre ; la mesurer avec un choix guidé demanderait de durcir fortement toutes les missions. C'est une décision du porteur (O-028), tranchée le 22 novembre 2026 : la cible reste mesurée avec la première offre (MAJ-79, `design/Joueur_avise_v0239.md`).

Données : `design/essais/equilibre_bonus/parties_v236_{7,8,9}.txt` (première offre), `parties_v236_look_{7,8,9}.txt` (choix guidé), `table_v235_final.json`, `rebalance_table.json`.
