# Équilibre entre factions : étude multi-compositions (missions 1 à 200)

**Statut : étude de mesure réalisée le 17 novembre 2026 par Claude Code, à la suite de la précision du porteur** (« il ne doit pas y avoir d'écart énorme entre les deux factions, mais une seule composition ne permet pas de conclure »). Aucune valeur du jeu n'a été modifiée. Les chiffres sont des mesures de simulation : le porteur juge l'équilibre en jouant, et toute modification de valeur lui revient.

## Méthode

`prototype/tools/faction_study.gd` joue, pour chaque mission (1 à 200) et chaque faction : chacun des **trois arbres de talents** (tous les points réels de la mission dépensés dans cet arbre, selon la même priorité pour les deux factions) et chacune des **dix compositions de trois unités de base** (combinaisons avec répétition des trois unités de la faction ; les deux moins chères à l'ouverture, la plus chère à la vague 2 ; emplacements 3, 4 puis 2 ; améliorations scriptées comme dans les tests de chapitre). Deux compositions de deux mages ou de deux sapeurs plus un autre type ne sont pas achetables à l'ouverture (or insuffisant) : elles sont écartées, il reste **8 compositions valides** par arbre. Cela fait 24 parties par faction et par mission, 9 600 parties valides en tout (12 000 lancées).

Pour chaque partie on relève la victoire et la **marge** : PV de forteresse restants rapportés aux PV maximaux de la partie (0 % en cas de défaite, 100 % si aucun ennemi n'a touché la forteresse). Trois lectures complémentaires : la **marge moyenne** de toutes les parties (puissance « moyenne » des choix), la **meilleure marge** (puissance atteignable par un joueur qui choisit bien l'arbre et la composition) et la **meilleure marge par arbre**.

```
FIRST=1 LAST=200 [SAME_HP=1] godot --headless --path prototype --script res://tools/faction_study.gd
```

**Limites** : seulement les trois unités de base de chaque faction (pas les 20 unités de boutique, pas le choix d'une unité de boutique par mission), un seul scénario d'achats et d'améliorations scripté, bonus de partie pris dans l'ordre proposé, une seule graine aléatoire. Les chiffres montrent donc *où les factions divergent avec les unités de base*, pas ce qu'un joueur expérimenté obtient avec tout l'arsenal.

## Résultat par chapitre

| Chapitre | Victoires A | Victoires H | Marge moyenne A | Marge moyenne H | Meilleure marge A | Meilleure marge H | Écart (H − A) | Missions où H meilleure / A meilleure / égales (± 5) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 79 % | 65 % | 64 % | 38 % | 99 % | 94 % | -4 | 0 / 2 / 8 |
| 2 | 59 % | 29 % | 38 % | 16 % | 84 % | 92 % | +7 | 3 / 2 / 5 |
| 3 | 65 % | 45 % | 38 % | 27 % | 86 % | 92 % | +6 | 3 / 1 / 6 |
| 4 | 17 % | 10 % | 6 % | 5 % | 44 % | 45 % | +1 | 4 / 4 / 2 |
| 5 | 40 % | 25 % | 21 % | 15 % | 76 % | 91 % | +15 | 8 / 1 / 1 |
| 6 | 26 % | 10 % | 11 % | 4 % | 70 % | 53 % | -17 | 4 / 6 / 0 |
| 7 | 35 % | 32 % | 22 % | 20 % | 85 % | 86 % | +1 | 4 / 3 / 3 |
| 8 | 17 % | 10 % | 6 % | 5 % | 54 % | 67 % | +13 | 5 / 2 / 3 |
| 9 | 26 % | 29 % | 13 % | 18 % | 84 % | 87 % | +3 | 5 / 3 / 2 |
| 10 | 36 % | 29 % | 19 % | 18 % | 75 % | 78 % | +2 | 4 / 3 / 3 |
| 11 | 34 % | 31 % | 21 % | 23 % | 82 % | 97 % | +14 | 6 / 0 / 4 |
| 12 | 27 % | 28 % | 16 % | 21 % | 74 % | 91 % | +17 | 6 / 0 / 4 |
| 13 | 26 % | 30 % | 13 % | 22 % | 78 % | 98 % | +19 | 8 / 0 / 2 |
| 14 | 14 % | 24 % | 7 % | 17 % | 76 % | 94 % | +18 | 9 / 0 / 1 |
| 15 | 22 % | 26 % | 12 % | 17 % | 70 % | 90 % | +20 | 7 / 0 / 3 |
| 16 | 24 % | 38 % | 12 % | 30 % | 90 % | 100 % | +10 | 3 / 0 / 7 |
| 17 | 17 % | 36 % | 10 % | 29 % | 76 % | 100 % | +24 | 9 / 0 / 1 |
| 18 | 12 % | 32 % | 6 % | 24 % | 72 % | 96 % | +23 | 10 / 0 / 0 |
| 19 | 15 % | 35 % | 7 % | 27 % | 74 % | 100 % | +26 | 10 / 0 / 0 |
| 20 | 12 % | 33 % | 6 % | 24 % | 64 % | 98 % | +33 | 9 / 0 / 1 |

## Constats

1. **Missions 1 à 100 : puissances similaires.** Écart moyen de la meilleure marge (Horde − Alliance) : +3 points sur les missions 1 à 90, avec des avantages qui alternent d'un chapitre à l'autre (chapitre 5 en faveur de la Horde, chapitre 6 en faveur de l'Alliance). C'est le comportement voulu : pas d'écart énorme, des variations d'un chapitre à l'autre.

2. **Missions 101 à 200 : un avantage net et régulier de la Horde.** Écart moyen de la meilleure marge : +18 points sur les chapitres 11 à 15 et +23 points sur les chapitres 16 à 20. Sur les 100 missions des chapitres 11 à 20, la Horde a une meilleure marge nettement supérieure (plus de 5 points) sur 77 missions, l'Alliance sur 0. Le constat tient avec les trois lectures (marge moyenne, meilleure marge, composition de référence du rapport de courbe de difficulté) : il ne dépend pas d'une composition particulière.

3. **Largeur des arbres.** Meilleure marge moyenne par arbre de talents sur les missions 91 à 200 : Alliance 21 / 75 / 26 %, Horde 90 / 33 / 90 % (arbres d'indice 0, 1, 2). Avec les seules unités de base, **la Horde a deux arbres très performants, l'Alliance un seul** ; le meilleur arbre de l'Alliance (75 %) reste en dessous des deux meilleurs de la Horde (90 %). Une partie de l'écart tient donc à ce que les deux autres arbres de l'Alliance ne sont pas exploités par ses unités de base : l'ajout des unités de boutique pourrait réduire l'écart, ce que cette étude ne mesure pas.

4. **Réduction de PV d'ennemis propre à la Horde (décision v0.212, 10 % de PV en moins à partir de la mission 150, 15 % à la mission 200).** Mesure sans cette réduction (mêmes PV d'ennemis que l'Alliance, option `SAME_HP=1`) sur les missions 150 à 200 : meilleure marge moyenne de la Horde 99 % avec la réduction, 94 % sans, contre 75 % pour l'Alliance. **La réduction n'explique qu'environ 5 points sur les 24 points d'écart** : la retirer ne suffirait pas à rapprocher les factions.

5. **Mises en garde.** (a) Les arbres sont dépensés dans un seul arbre par partie, alors qu'un joueur peut répartir ses points. (b) Les chapitres 4 et 8 ont des marges très basses pour les deux factions (ces chapitres ont été réglés avec des compositions et des évolutions propres à chaque mission). (c) Les nombres sont des moyennes de simulations sans variation aléatoire : un joueur humain fera moins bien ou mieux selon son jeu.

## Pistes (à décider par le porteur ; rien n'est modifié)

Ces pistes sont des options de réglage, pas des recommandations validées. Toute valeur ou habillage modifié serait « réglage de prototype à confirmer ».

- **Compléter l'étude avant toute décision** : ajouter les 20 unités de boutique par faction (une unité de boutique choisie par mission, comme dans le jeu) et la répartition libre des points de talents. C'est la mesure qui manque pour dire si l'écart des chapitres 11 à 20 est réel pour un joueur qui joue tout l'arsenal.

- **Retirer ou réduire la réduction de PV de la Horde** (v0.212) : effet limité (voir constat 4) ; à n'envisager qu'avec d'autres leviers.

- **Régler la puissance des arbres de l'Alliance ou les PV de forteresse des factions** (la Horde commence les chapitres 10 à 20 avec davantage de PV maximaux que l'Alliance dans la plupart des arbres) : décision de règles, à étudier avec l'équilibrage des talents (`design/Equilibrage_arbres_talents_v0168.md`).

## Données

Parties brutes : `design/essais/equilibre_factions/parties.txt` (12 000 lignes « STUDY mission faction arbre composition résultat PV_restants PV_maximaux », composition = indices des trois unités, « refus » = composition non achetable à l'ouverture) et `parties_sans_reduction_horde.txt` (Horde sans la réduction de PV d'ennemis, missions 150 à 200) ; les agrégats ci-dessus se recalculent à partir d'elles.

