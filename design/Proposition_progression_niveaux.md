# For the Fortress! — Proposition de progression des niveaux

Proposition du 20 octobre 2026, fondée sur le GDD v0.6.

**Statut P — proposition à valider.** Les multiplicateurs et valeurs dérivées sont des hypothèses H. Le niveau maximum 4, les coûts provisoires de 50, 100 puis 150 or et le déblocage de deux spécialisations au niveau 4 proviennent du GDD. Aucune branche ni effet de spécialisation n’est défini ici.

## Principe proposé

Augmenter les dégâts aux niveaux 2 à 4. La cadence, la portée, les rayons, le nombre maximal de victimes secondaires, les coefficients de rebond et d’explosion, la durée et les horaires de malédiction conservent leurs valeurs de niveau 1. Le comportement et le rôle de chaque défenseur restent ainsi comparables entre niveaux.

Appliquer le même multiplicateur aux dégâts directs, secondaires et périodiques. Les nombres fractionnaires sont conservés sans arrondi intermédiaire pour ces statistiques de référence. L’ordre de calcul avec les futurs bonus, résistances et spécialisations demeure à définir.

| Niveau | Multiplicateur des dégâts N1 | Coût du passage | Améliorations cumulées hors achat |
| --- | --- | --- | --- |
| 1 | × 1 | Achat du défenseur | 0 or |
| 2 | × 1,5 | 50 or | 50 or |
| 3 | × 2,25 | 100 or | 150 or |
| 4 | × 3,25 | 150 or | 300 or |

Les multiplicateurs sont relatifs au niveau 1. Le niveau 3 applique donc × 2,25 au dégât initial, et non × 2,25 au dégât du niveau 2. Le niveau 4 décrit le socle avant les effets d’une branche ; un éventuel coût distinct de spécialisation reste ouvert.

## DPS théorique sur une cible

Valeurs hors bonus, résistance et spécialisation. Le chaman inclut ses deux dégâts de malédiction ; sa cible doit survivre suffisamment longtemps et recevoir les attaques en continu.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 8 | 12 | 18 | 26 |
| Arbalétrier nain | 9,6 | 14,4 | 21,6 | 31,2 |
| Mage humain | 10,8 | 16,2 | 24,3 | 35,1 |
| Lanceur de haches troll | 8 | 12 | 18 | 26 |
| Sapeur gobelin | 9,6 | 14,4 | 21,6 | 31,2 |
| Chaman orc | 10,8 | 16,2 | 24,3 | 35,1 |

## Dégâts directs par attaque

Les intervalles restent de 1 seconde pour l’archer, 2,5 secondes pour l’arbalétrier, le mage et le sapeur, et 2 secondes pour le troll et le chaman.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 8 | 12 | 18 | 26 |
| Arbalétrier nain | 24 | 36 | 54 | 78 |
| Mage humain | 27 | 40,5 | 60,75 | 87,75 |
| Lanceur de haches troll | 16 | 24 | 36 | 52 |
| Sapeur gobelin | 24 | 36 | 54 | 78 |
| Chaman orc | 12 | 18 | 27 | 39 |

## Dégâts secondaires et périodiques

| Défenseur | Mesure | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- | --- |
| Mage humain | Par victime secondaire | 10,8 | 16,2 | 24,3 | 35,1 |
| Lanceur de haches troll | Par victime secondaire | 8 | 12 | 18 | 26 |
| Sapeur gobelin | Par victime secondaire | 9,6 | 14,4 | 21,6 | 31,2 |
| Chaman orc | Par application à +1 s puis +2 s | 4,8 | 7,2 | 10,8 | 15,6 |

Le mage conserve deux victimes secondaires au maximum, le troll un rebond et le sapeur trois victimes secondaires. Le rayon reste d’une unité de carte. Le chaman conserve deux applications de malédiction, à une et deux secondes après l’attaque, selon les règles de renouvellement du GDD.

## DPS total théorique contre les groupes

Ces plafonds supposent en permanence le nombre maximal de cibles admissibles, suffisamment de PV et des attaques sans interruption. Ils ne prédisent pas le DPS effectif ni le nombre d’éliminations.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Mage humain | 19,44 | 29,16 | 43,74 | 63,18 |
| Lanceur de haches troll | 12 | 18 | 27 | 39 |
| Sapeur gobelin | 21,12 | 31,68 | 47,52 | 68,64 |

## Coût total investi par défenseur

Pièces d’or, achat compris, hors éventuel coût distinct de spécialisation. Les coûts du GDD restent provisoires.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 50 | 100 | 200 | 350 |
| Arbalétrier nain | 75 | 125 | 225 | 375 |
| Mage humain | 100 | 150 | 250 | 400 |
| Lanceur de haches troll | 50 | 100 | 200 | 350 |
| Sapeur gobelin | 75 | 125 | 225 | 375 |
| Chaman orc | 100 | 150 | 250 | 400 |

## Seuils utiles pour les essais

À statistiques ennemies inchangées, sans résistance ni bonus :

- Archer N2 : 12 dégâts directs, soit un Grouillant éliminé en un impact.
- Archer N4 : 26 dégâts directs, soit un Sprinter à 24 PV éliminé en un impact.
- Troll N2 : 24 dégâts principaux et 12 dégâts de rebond ; il peut éliminer un Sprinter par le premier impact et un Grouillant par le rebond.
- Arbalétrier N3 : 54 dégâts directs, soit un Pillard à 40 PV éliminé en un impact.
- Mage N2 : 16,2 dégâts par victime secondaire, suffisants contre un Grouillant à 12 PV.
- Sapeur N2 : 14,4 dégâts par victime secondaire, suffisants contre un Grouillant à 12 PV.
- Chaman N3 : 27 dégâts immédiats, suffisants contre un Sprinter à 24 PV sans attendre la malédiction.

Ces seuils rendent les améliorations sensibles ; ils peuvent aussi provoquer des sauts de difficulté. Les vérifier en priorité sur les vagues denses, notamment la vague 8.

## Cohérence avec le scénario de dépenses du GDD

Le scénario approuvé atteint avant la vague 10 : défenseur à 50 or au N4, défenseur à 75 or au N3 et défenseur à 100 or au N2. Avec cette proposition, son DPS théorique sur une cible est de 26 + 21,6 + 16,2 = 63,8, pour l’Alliance comme pour la Horde. Les attaques secondaires et les dégâts différés conservent leurs différences.

L’investissement total est de 350 + 225 + 150 = 725 or. Avec les 816 or de budget brut maximal avant la vague 10, le solde est de 91 or, conformément au GDD. La faisabilité économique ne garantit pas la victoire : portée effective, géométrie de la carte, tirs perdus et bonus restent déterminants.

## Intérêt des achats et améliorations

L’amélioration concentre la puissance sur un emplacement déjà choisi. L’achat permet de couvrir un autre segment du chemin. Exemple sur l’archer : le passage N1 vers N2 coûte 50 or pour +4 DPS ; le passage N2 vers N3 coûte 100 or pour +6 DPS ; le passage N3 vers N4 coûte 150 or pour +8 DPS et débloque le choix de spécialisation existant.

Le rendement marginal en DPS par pièce d’or diminue dans cet exemple. Les six emplacements et les spécialisations doivent rendre la concentration de puissance intéressante. La possibilité de recruter des copies reste ouverte : elle influencera fortement la comparaison entre nouveaux achats et améliorations, et n’est pas approuvée par cette fiche.

## Points à valider et essais suivants

Confirmer le principe de dégâts seuls et la courbe × 1,5 / × 2,25 / × 3,25. Définir ensuite les branches du niveau 4 et leur éventuel coût distinct, puis la géométrie de la carte. Comparer les deux factions avec les mêmes vagues et budgets. Aucun essai jouable n’a encore vérifié cette progression ou les dix vagues complètes.
