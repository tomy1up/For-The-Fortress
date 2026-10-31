# Comparaison des alternatives de boutique

**Relevé vérifié sur le jeu v0.99.1 : 3 744 comparaisons appariées, soit 7 488 simulations de politiques fixes.** Les 475 155 contrôles du relevé ne détectent aucune anomalie de budget, de recrutement ou de résultat terminal. Aucun réglage de combat n’est modifié par cette étude.

Ces simulations ne mesurent pas le taux de victoire humain et ne représentent pas un joueur optimal. Elles comparent des décisions identiques avec une unité de base ou son alternative, en laissant les différences de prix, de portée, de cadence, de dégâts et de synergies produire leurs effets réels.

## Résultats des politiques fixes

| Alternative | Politique | Cas | Victoires témoin | Victoires alternative | Défaite → victoire | Victoire → défaite |
|---|---|---:|---:|---:|---:|---:|
| Rôdeur elfe | Substitution | 504 | 446 | 436 | 12 | 22 |
| Rôdeur elfe | Renfort | 504 | 492 | 486 | 2 | 8 |
| Mousquetaire nain | Substitution | 432 | 360 | 280 | 6 | 86 |
| Mousquetaire nain | Renfort | 432 | 426 | 420 | 6 | 12 |
| Traqueur troll | Substitution | 504 | 149 | 334 | 195 | 10 |
| Traqueur troll | Renfort | 504 | 226 | 228 | 23 | 21 |
| Grenadier gobelin | Substitution | 432 | 345 | 150 | 0 | 195 |
| Grenadier gobelin | Renfort | 432 | 194 | 181 | 11 | 24 |

Les colonnes de changement comparent exactement les mêmes paramètres de politique, de mission, de placement, de branche, de talents et de tirage. Elles comptent des cas de simulation, pas des joueurs.

Le **traqueur** change fortement les ouvertures testées : 195 défaites deviennent des victoires en substitution, contre 10 changements inverses. Comme renfort, son avantage en nombre de victoires devient beaucoup plus faible et 21 victoires deviennent des défaites. Il n’est donc pas supérieur dans toutes les situations couvertes. Son gain d’ouverture mérite une comparaison séparée de portée et de cadence avant de conclure à une hausse de puissance acceptable.

Le **grenadier** est beaucoup moins efficace que le sapeur dans ces substitutions d’ouverture : aucune défaite n’y devient victoire, contre 195 changements inverses. Il apporte toutefois 11 victoires supplémentaires dans certains cas de renfort. Son intérêt ne peut pas être écarté sur les seules ouvertures ; son prix, sa portée et l’accès à sa spécialisation demandent des essais distincts. Ces résultats n’autorisent pas à le présenter comme déjà équilibré.

Le **mousquetaire** est plus pénalisé en substitution qu’en renfort dans les politiques couvertes. Le **rôdeur** produit des changements plus limités dans les deux sens. Ces observations ne séparent pas l’effet du coût, des seuils de dégâts, du placement ou des améliorations achetées ensuite.

### Couverture effective du quatrième type

Dans la politique de renfort, le grenadier n’est jamais recruté dans **140 cas sur 432**, le traqueur dans **84 sur 504**, le mousquetaire dans **4 sur 432**. Le rôdeur est toujours recruté. La partie peut se terminer avant son achat, ou les achats précédents peuvent laisser trop peu d’or.

**Aucune alternative n’atteint le niveau 4 dans cette politique de renfort.** L’ordre d’amélioration favorise les trois défenseurs habituels. Les deux branches configurées ne constituent donc pas une évaluation des deux spécialisations de l’alternative en quatrième position. La prochaine comparaison devra lui donner la priorité d’investissement, avec un témoin suivant le même ordre. Les spécialisations sont en revanche atteintes dans une partie des substitutions.

### Deux exemples vérifiables dans le relevé

- Traqueur, mission 6, placement 5, substitution, branche A, talents de famille, graine 77 : le témoin gagne avec 3 PV, l’alternative perd. Cet exemple contredit une supériorité universelle du traqueur.
- Grenadier, mission 5, placement 1, renfort, branche A, aucun talent, graine 1 : le témoin perd, l’alternative gagne avec 1 PV. Cet exemple montre une utilité possible sans établir une cause unique ni un équilibre global.

Les données de tous les cas sont conservées ; ces exemples ne remplacent pas la grille complète.

## Progression et financement

| Alternative | Famille de référence | Déblocage de prototype | Première mission étudiée | PO avant achat | XP à l’entrée | Points accessibles |
|---|---|---:|---:|---:|---:|---:|
| Rôdeur elfe | Archer elfe | 180 PO | 4 | 180 | 300 | 1 |
| Mousquetaire nain | Arbalétrier nain | 240 PO | 5 | 240 | 400 | 2 |
| Traqueur troll | Lanceur de haches troll | 180 PO | 4 | 180 | 300 | 1 |
| Grenadier gobelin | Sapeur gobelin | 240 PO | 5 | 240 | 400 | 2 |

L’hypothèse est un parcours ayant obtenu toutes les premières victoires précédentes dans la faction, sans autre achat en boutique. Il n’y a ni farm, ni PO accordées par une mission future. Chaque alternative est étudiée séparément jusqu’à la mission 10. La comparaison n’implique pas que tous les joueurs achètent cette unité dès qu’ils en ont les moyens.

Les deux membres d’une paire ont la même mission, les mêmes PV ennemis, la même géométrie, le même placement, le même tirage initial et la même configuration de talents. Les PO persistantes servent seulement à vérifier la possibilité de l’achat : elles ne sont jamais converties en or de combat. Les parties commencent avec le budget normal de 150 or et la forteresse normale, ajustée uniquement par les talents du scénario.

Deux configurations de talents sont utilisées : aucun point investi, ou des talents d’entrée favorisant la famille étudiée dans la limite des points réellement accessibles. Ce second choix est déterministe et ne prétend pas être optimal. De 1 à 4 points sont accessibles avant les missions couvertes ; le cinquième vient après la mission 10. Aucun talent majeur n’est ainsi attribué artificiellement aux premières missions.

## Politiques comparées

| Politique | Témoin | Avec alternative |
|---|---|---|
| Substitution | Un défenseur de la famille étudiée, puis les deux autres types de base | L’alternative à la place du premier défenseur ; les deux autres types restent identiques |
| Renfort | Les trois types de base, puis un second exemplaire de la famille étudiée | Les trois types de base, puis l’alternative comme quatrième type |

La substitution utilise trois emplacements. Les deux premières recrues sont tentées avant la vague 1, la troisième à partir de la vague 4. Le renfort utilise quatre emplacements : les deux premières recrues avant la vague 1, la troisième à partir de la vague 3 et la quatrième à partir de la vague 4. Une tentative refusée faute d’or est réessayée lors des préparations suivantes ; aucun achat n’est forcé.

Une amélioration du premier défenseur est tentée avant la vague 2. À partir de la vague 5, une amélioration par défenseur est tentée dans l’ordre du recrutement à chaque préparation. Deux choix de branche, A et B, sont testés séparément ; ils n’ont d’effet que si l’unité atteint réellement le niveau de spécialisation. Les coûts restent ceux du jeu. La politique ne vend pas et ne réorganise pas ses unités.

Le premier bonus proposé est choisi après les vagues 3, 6 et 9, si la partie atteint ces choix. Trois graines sont utilisées : 1, 42 et 77. Ce choix imposé ne représente pas toutes les combinaisons possibles.

| Placement | Emplacements dans l’ordre des recrutements |
|---|---|
| 1 | E1, E2, E3, E5 |
| 2 | E2, E3, E5, E6 |
| 3 | E2, E4, E5, E1 |
| 4 | E1, E3, E5, E6 |
| 5 | E3, E5, E6, E2 |
| 6 | E3, E4, E6, E1 |

Les positions physiques de ces emplacements dépendent de la carte. La substitution ignore le quatrième emplacement du tableau. Les limites de deux exemplaires par type et l’isolation des factions s’appliquent aux deux politiques.

## Vérifications et limites

Le relevé doit contenir exactement toutes les combinaisons prévues, sans doublon ni omission. Chaque simulation doit atteindre une victoire ou une défaite et conserver l’équation `or restant = 150 + revenus de combat − or investi`. Les unités recrutées doivent être autorisées et les talents valides.

Un contrôle distinct rejoue les rapports complets de 16 scénarios et les compare à petits et grands pas de simulation. Les 7 488 simulations du grand relevé ne sont pas toutes rejouées individuellement.

Il faudra distinguer une alternative effectivement recrutée d’une option restée trop chère ou arrivée trop tard dans une politique donnée. Une branche annoncée par le scénario n’est pas forcément atteinte. Les compteurs de recrutement et de spécialisation doivent accompagner les résultats.

Un échec de ces politiques ne prouve pas qu’une mission est impossible. Un gain de victoires ne prouve pas qu’une unité domine avec tous les placements, talents ou bonus. Une comparaison à politique constante inclut les effets économiques du prix de recrutement et les achats ultérieurs : elle n’isole pas une seule statistique de l’unité.

## Reproduction

Sources : [génération des essais](../prototype/tests/survey_shop.gd), [contrôle de la méthode](../prototype/tests/test_shop_survey.gd), [analyse du relevé](../prototype/tests/analyse_shop.py).

```powershell
godot --headless --path prototype --script res://tests/survey_shop.gd -- --output=C:/chemin/releves.json
python prototype/tests/run_regression.py --test test_shop_survey.gd --timeout 90 --report C:/chemin/controle.json
python prototype/tests/analyse_shop.py C:/chemin/releves.json --destination design/essais --regression C:/chemin/controle.json
```

Le générateur accepte aussi `--card=alliance.scout` et `--parity=0` ou `1` pour répartir le travail en lots indépendants. Les lots doivent être réunis et la grille complète contrôlée avant toute interprétation globale. Ces commandes n’ouvrent ni ne modifient de sauvegarde joueur.

## Preuves et suites

[Relevés complets compressés](essais/boutique_v0991_releves.json.gz), [résumé et empreintes](essais/boutique_v0991_resume.json), [contrôle de méthode](essais/boutique_v0991_controle_methode.json). Le contrôle de méthode passe 90 vérifications Godot et 16 tests Python. Il ne remplace pas une nouvelle exécution de toutes les suites du jeu.

Les 56 sources du paquet v0.99.1 conservent leur empreinte. Cette livraison ajoute des outils et des résultats d’essai ; elle ne recompile pas un jeu identique et ne modifie aucun profil. Les noms, prix et statistiques des alternatives restent des hypothèses de prototype.

Prochain lot d’équilibrage : comparer un renfort prioritaire, vérifier ses deux spécialisations réellement atteintes, puis isoler des variations de prix et de portée si l’écart persiste. Éviter d’ajuster plusieurs paramètres à la fois ou d’optimiser uniquement pour ces politiques fixes. Confronter ensuite les résultats aux essais humains.
