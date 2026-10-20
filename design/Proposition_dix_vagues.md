# For the Fortress! — Séquence de référence des dix vagues

Proposition initiale du 19 octobre 2026 — approuvée et intégrée au GDD v0.6 le 20 octobre 2026.

**Statut : séquence approuvée pour le prototype — V.** Quantités, intervalles et réglages temporels restent des hypothèses H. Cette fiche détaille la séquence intégrée au GDD v0.6 ; elle utilise les sept archétypes ordinaires, le boss et les récompenses établis, sans en changer les valeurs. Aucun essai jouable ne confirme encore l’équilibrage.

## Règles de lecture et d’apparition approuvées

- Le temps de chaque vague repart à zéro ; son premier ennemi apparaît à t = 0.
- Les groupes apparaissent dans l’ordre des flèches. Chaque intervalle concerne les apparitions successives d’un même groupe, à vitesse de jeu normale.
- Le groupe suivant commence 4 secondes après la dernière apparition du précédent. Cette séparation ne dépend pas de la mort des ennemis : les groupes peuvent coexister sur le chemin.
- Pour un groupe de n ennemis espacés de Δ secondes, l’émission dure (n − 1) × Δ. Un ennemi unique ne consomme aucun intervalle interne.
- Une vague se termine après la dernière apparition et lorsque tous ses ennemis ont été éliminés ou ont atteint la forteresse, sous réserve que celle-ci survive. La vague suivante est lancée par le joueur depuis la préparation.
- Les constructions, améliorations et ventes restent limitées aux préparations. L’or des éliminations est immédiatement crédité, mais ne devient dépensable qu’à la préparation suivante.
- Les choix roguelite restent après les vagues 3, 6 et 9, avant le lancement de la suivante. Aucune prime de fin de vague n’est ajoutée.

La fin de vague intervient après toutes ses apparitions et la résolution de tous ses ennemis. Après la vague 10 entièrement résolue et si la forteresse survit, la partie est gagnée — V. Avec les valeurs actuelles, laisser passer le boss inflige 20 dégâts, donc détruit la forteresse initiale à 20 PV.

## Composition et revenus maximaux

Les montants supposent que chaque ennemi est éliminé. Le cumul exclut les 150 or initiaux et ne déduit aucun achat. Les intervalles sont donnés dans le même ordre que les groupes.

| Vague | Groupes dans l’ordre d’apparition | Intervalles internes | Or maximal | Cumul maximal |
| --- | --- | --- | --- | --- |
| 1 | 10 Pillards | 2,5 s | 30 | 30 |
| 2 | 10 Pillards → 8 Grouillants | 2 s / 0,65 s | 38 | 68 |
| 3 | 8 Pillards → 8 Sprinters | 1,8 s / 1,4 s | 48 | 116 |
| 4 | 4 Brutes → 16 Grouillants | 3 s / 0,5 s | 44 | 160 |
| 5 | 6 Maraudeurs → 4 Brutes → 8 Sprinters | 2 s / 3 s / 1,2 s | 88 | 248 |
| 6 | 2 Colosses → 6 Brutes → 12 Grouillants | 4 s / 2,2 s / 0,5 s | 82 | 330 |
| 7 | 1 Élite → 2 Colosses → 8 Maraudeurs | unique / 4 s / 1,6 s | 96 | 426 |
| 8 | 24 Grouillants → 12 Sprinters → 8 Maraudeurs | 0,35 s / 1 s / 1,2 s | 108 | 534 |
| 9 | 2 Élites → 2 Colosses → 4 Brutes → 6 Maraudeurs | 5 s / 4 s / 2,2 s / 1,4 s | 132 | 666 |
| 10 | 1 Seigneur de siège → 2 Élites → 8 Sprinters | unique / 5 s / 1 s | 104 | 770 |

## Charge et durée d’émission

| Vague | Ennemis | PV cumulés | Dernière apparition | Budget brut après la vague |
| --- | --- | --- | --- | --- |
| 1 | 10 | 400 | 22,5 s | 180 or |
| 2 | 18 | 496 | 26,55 s | 218 or |
| 3 | 16 | 512 | 26,4 s | 266 or |
| 4 | 20 | 672 | 20,5 s | 310 or |
| 5 | 18 | 1152 | 35,4 s | 398 or |
| 6 | 20 | 1344 | 28,5 s | 480 or |
| 7 | 11 | 1480 | 23,2 s | 576 or |
| 8 | 44 | 1216 | 35,45 s | 684 or |
| 9 | 14 | 2160 | 34,6 s | 816 or |
| 10 | 11 | 1512 | 20 s | 920 or |

Le budget brut est égal à 150 + récompenses cumulées, avant achats et ventes ; il ne représente pas le solde réellement disponible. Les PV cumulés mesurent une charge brute et ne suffisent pas à comparer la difficulté de vagues aux vitesses et densités différentes.

## Horaires exacts des groupes

Pour chaque ligne, les apparitions forment la séquence premier, premier + intervalle, …, dernier. Les heures ci-dessous sont relatives au lancement de la vague, en secondes.

| Vague | Groupe | Nombre | Intervalle | Première apparition | Dernière apparition |
| --- | --- | --- | --- | --- | --- |
| 1 | Pillard | 10 | 2,5 s | 0 s | 22,5 s |
| 2 | Pillard | 10 | 2 s | 0 s | 18 s |
| 2 | Grouillant | 8 | 0,65 s | 22 s | 26,55 s |
| 3 | Pillard | 8 | 1,8 s | 0 s | 12,6 s |
| 3 | Sprinter | 8 | 1,4 s | 16,6 s | 26,4 s |
| 4 | Brute | 4 | 3 s | 0 s | 9 s |
| 4 | Grouillant | 16 | 0,5 s | 13 s | 20,5 s |
| 5 | Maraudeur | 6 | 2 s | 0 s | 10 s |
| 5 | Brute | 4 | 3 s | 14 s | 23 s |
| 5 | Sprinter | 8 | 1,2 s | 27 s | 35,4 s |
| 6 | Colosse | 2 | 4 s | 0 s | 4 s |
| 6 | Brute | 6 | 2,2 s | 8 s | 19 s |
| 6 | Grouillant | 12 | 0,5 s | 23 s | 28,5 s |
| 7 | Élite | 1 | 0 s | 0 s | 0 s |
| 7 | Colosse | 2 | 4 s | 4 s | 8 s |
| 7 | Maraudeur | 8 | 1,6 s | 12 s | 23,2 s |
| 8 | Grouillant | 24 | 0,35 s | 0 s | 8,05 s |
| 8 | Sprinter | 12 | 1 s | 12,05 s | 23,05 s |
| 8 | Maraudeur | 8 | 1,2 s | 27,05 s | 35,45 s |
| 9 | Élite | 2 | 5 s | 0 s | 5 s |
| 9 | Colosse | 2 | 4 s | 9 s | 13 s |
| 9 | Brute | 4 | 2,2 s | 17 s | 23,6 s |
| 9 | Maraudeur | 6 | 1,4 s | 27,6 s | 34,6 s |
| 10 | Seigneur de siège | 1 | 0 s | 0 s | 0 s |
| 10 | Élite | 2 | 5 s | 4 s | 9 s |
| 10 | Sprinter | 8 | 1 s | 13 s | 20 s |

## Intention de chaque vague

1. Lire le chemin et éprouver la défense initiale.
2. Introduire les ennemis nombreux et les dégâts secondaires.
3. Introduire la vitesse avant le premier choix roguelite.
4. Opposer endurance et petit groupe de poursuivants.
5. Introduire le maraudeur et varier les vitesses dans une même vague.
6. Introduire le colosse avant le deuxième choix roguelite.
7. Introduire l’élite et laisser des unités rapides rattraper les plus lentes.
8. Tester une forte densité et des arrivées rapides.
9. Tester une charge élevée de PV avant le dernier choix roguelite.
10. Confronter le boss à la défense finale, avec deux élites et huit sprinters.

## Vérification des possibilités d’achat

Scénario arithmétique commun aux deux factions, sans vente, sans copie d’un même défenseur, avec toutes les éliminations et sans effet de bonus économique. Les trois paliers de prix sont 50, 75 et 100 or. Le scénario n’atteste ni la survie ni une stratégie optimale.

| Moment | Action après crédit des récompenses | Dépense | Solde |
| --- | --- | --- | --- |
| Départ | Acheter les défenseurs à 50 et 75 or | 125 | 25 |
| Après vague 1 | Conserver les 30 or gagnés | 0 | 55 |
| Après vague 2 | Conserver les 38 or gagnés | 0 | 93 |
| Après vague 3 | Acheter le défenseur à 100 or | 100 | 41 |
| Après vague 4 | Améliorer le défenseur à 50 or au niveau 2 | 50 | 35 |
| Après vague 5 | Améliorer ce défenseur au niveau 3 | 100 | 23 |
| Après vague 6 | Conserver les 82 or gagnés | 0 | 105 |
| Après vague 7 | Améliorer ce défenseur au niveau 4 | 150 | 51 |
| Après vague 8 | Améliorer les deux autres défenseurs au niveau 2 | 100 | 59 |
| Après vague 9 | Améliorer le défenseur à 75 or au niveau 3 | 100 | 91 |
| Après vague 10 | Récompenses finales, sans préparation supplémentaire prévue | 0 | 195 |

Le niveau 4 devient ici finançable avant la vague 8. Son éventuel coût de spécialisation distinct reste ouvert dans le GDD et est exclu de ces calculs. Les gains de statistiques par niveau et les branches ne sont pas encore définis : cette séquence prouve la capacité de financement, pas la puissance nécessaire pour gagner.

## Revenus réellement obtenus

Pour une vague, revenu réel = somme des récompenses des seuls ennemis éliminés. Tout ennemi atteignant la forteresse réduit les gains par rapport au maximum. Exemple : deux Pillards non éliminés en vague 1 ramènent son revenu à 24 or au lieu de 30. Sans dépenses, le solde passe à 174 au lieu de 180.

Le revenu maximal des vagues 1 à 9 est de 666 or. Le budget brut avant le boss est donc de 816 or avec le capital initial. La vague 10 rapporte au maximum 104 or, dont 40 pour le boss ; ces gains ne peuvent pas financer la défense de cette vague puisque les achats en combat restent interdits. Le total maximal de la partie est de 770 or de récompenses, soit 920 or avec le capital initial, avant dépenses.

## Durée et essais nécessaires

La somme des fenêtres d’émission des dix vagues vaut 273,1 secondes, soit 4 min 33,1 s à vitesse normale. Cette valeur exclut la résolution des ennemis après la dernière apparition, les préparations et les sélections roguelite. Ces durées doivent être mesurées ; la cible de 8 à 12 minutes ne peut pas encore être confirmée sans la carte et ses distances. L’accélération autorisée par le GDD modifie la durée réelle, pas ces horaires de référence.

Surveiller d’abord les ouvertures des deux factions, les Grouillants de la vague 4, la densité de la vague 8, le saut de PV en vague 9 et le temps d’attaque réellement disponible contre le boss. Les vagues 8 et 9 sollicitent des défenses différentes : moins de PV ne signifie pas automatiquement moins de difficulté.

Avant implémentation définitive, préciser la géométrie de la carte, les premiers tirs et projectiles, les gains par niveau, les spécialisations et le catalogue des bonus. Un essai limité au niveau 1 reste utile pour comparer les défenseurs, mais ne valide pas à lui seul cette partie complète.
