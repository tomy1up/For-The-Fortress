# For the Fortress!

Game Design Document — Version 0.13 — 20 octobre 2026

Document de référence pour concevoir, prototyper et faire évoluer le jeu. Cette version consolide le GDD v0.1 fourni, ses cinq captures et les règles de combat des deux factions, les ennemis, les récompenses, les dix vagues, la progression par niveau, les spécialisations, la géométrie du Gué, la résolution du combat, les bonus roguelite, les synergies, le recrutement et la vente approuvés ensuite. Elle conserve les choix établis, les valeurs provisoires et les questions ouvertes, tout en ajoutant des outils de suivi explicitement proposés.

Nom de travail — disponibilité juridique à confirmer.

## Sommaire

1. [1 Vision et cadre de conception](#s1)
2. [2 Boucle de jeu et carte du prototype](#s2)
3. [3 Factions races et classes](#s3)
4. [4 Statistiques niveaux et spécialisations](#s4)
5. [5 Combat des défenseurs de l Alliance](#s5)
6. [6 Combat des défenseurs de la Horde](#s6)
7. [7 Économie et calculs de référence](#s7)
8. [8 Bonus roguelite et synergies](#s8)
9. [9 Ennemis et boss du prototype](#s9)
10. [10 Composition des dix vagues](#s10)
11. [11 Calendrier et budget des vagues](#s11)
12. [12 Progression et dégâts par niveau](#s12)
13. [13 Coûts et lecture de la progression](#s13)
14. [14 Choix des spécialisations](#s14)
15. [15 Spécialisations de l Alliance](#s15)
16. [16 Rebonds et explosifs spécialisés](#s16)
17. [17 Spécialisations du chaman](#s17)
18. [18 Géométrie de La Vallée du Gué](#s18)
19. [19 Emplacements et couvertures](#s19)
20. [20 Plan et temps de traversée](#s20)
21. [21 Premier tir et ciblage](#s21)
22. [22 Impacts et malédictions](#s22)
23. [23 Ordre de résolution du combat](#s23)
24. [24 Cas de référence du combat](#s24)
25. [25 Bonus de combat et couverture](#s25)
26. [26 Bonus de niveau survie et économie](#s26)
27. [27 Tirage et cumul des bonus](#s27)
28. [28 Paramètres et prix avec bonus](#s28)
29. [29 Calculs et essais des bonus](#s29)
30. [30 Cadre et diversité raciale des synergies](#s30)
31. [31 Synergies de proximité](#s31)
32. [32 Synergies de spécialisations et budget](#s32)
33. [33 Cumul et recalcul des synergies](#s33)
34. [34 Calculs et essais des synergies](#s34)
35. [35 Recrutement des exemplaires](#s35)
36. [36 Copies synergies et nouvelle construction](#s36)
37. [37 Vente et remboursements](#s37)
38. [38 Compositions et budgets des copies](#s38)
39. [39 Vérifications du recrutement et des ventes](#s39)
40. [40 Présentation interface et validation du prototype](#s40)
41. [41 Périmètre commercial et feuille de route](#s41)
42. [42 Registre des décisions](#s42)
43. [43 Questions ouvertes et suivi](#s43)
44. [44 Sources et historique du GDD](#s44)
45. [45 Maintenance du GDD](#s45)

<a id="s1"></a>

## 1 Vision et cadre de conception

For the Fortress! est un Tower Defense roguelite solo dans un univers médiéval-fantasy coloré. Le joueur choisit une faction, compose sa défense sur des emplacements fixes et protège sa forteresse contre des vagues d’ennemis. La promesse est de proposer des règles simples à comprendre et de nombreuses combinaisons stratégiques.

### Fiche du projet
| Élément | Référence | Statut |
| --- | --- | --- |
| Nom de travail | For the Fortress! | V — nom de travail ; disponibilité juridique à confirmer |
| Genre et mode | Tower Defense roguelite fantasy, solo | V |
| Plateforme prioritaire | PC, Steam | C — orientation prioritaire |
| Moteur envisagé | Godot | C — choix à confirmer |
| Modèle économique | Premium | C — intention commerciale |
| Prix envisagé | 7,99 € | H — prix de travail |
| Durée d’une partie prototype | 8 à 12 minutes | C — cible à mesurer |

### Les quatre piliers validés
- Deux factions réellement différentes par leur style de jeu, leurs défenseurs et leurs synergies, au-delà de leur apparence.
- Un Tower Defense lisible : chemins fixes, emplacements prédéfinis et attaques automatiques.
- Des décisions de composition, d’achat, d’amélioration, de spécialisation et de sélection de bonus.
- Une rejouabilité fondée sur les compositions et les améliorations aléatoires.

### Statuts utilisés dans tout le GDD
| Code | Signification | Conséquence |
| --- | --- | --- |
| V | Décision validée dans le socle fourni | À conserver jusqu’à une décision explicite de modification |
| H | Hypothèse de valeur ou d’équilibrage | À tester ; ne constitue pas un réglage final |
| C | Cible ou intention de périmètre | Guide de travail ; ne constitue pas un engagement de production |
| O | Question ouverte | Règle ou valeur à décider avant son implémentation définitive |
| P | Proposition ajoutée pour organiser le travail | À examiner ; aucune nouvelle fonctionnalité approuvée |

Les calculs dérivés sont signalés comme tels. Ils illustrent les valeurs de référence et n’ajoutent pas de règle de jeu. Les nombres de la version commerciale restent des objectifs envisagés.

<a id="s2"></a>

## 2 Boucle de jeu et carte du prototype

### Déroulement validé
1. Choisir sa faction et sa carte.
2. Construire et améliorer les défenseurs entre les vagues.
3. Lancer une vague et résister aux ennemis.
4. Récupérer de l’or et adapter sa stratégie.
5. Après certaines vagues, choisir une amélioration roguelite.
6. Recommencer jusqu’à la victoire ou à la destruction de la forteresse.

### Actions selon la phase
| Action | Entre les vagues | Pendant les combats |
| --- | --- | --- |
| Construire ou acheter un défenseur | Autorisé — V | Non autorisé — V |
| Améliorer un défenseur | Autorisé — V | Non autorisé — V |
| Vendre un défenseur | Autorisé — V | Non autorisé — V |
| Observer et inspecter les unités | Ergonomie à préciser — O | Autorisé — V |
| Accélérer le déroulement | Sans objet | Autorisé — V ; multiplicateurs ouverts |
| Choisir un bonus roguelite | Après les vagues prévues — V | Pas de choix en combat dans le socle |

### La Vallée du Gué
La carte initiale est une scène médiévale-fantasy en vue isométrique. Elle comporte une route sinueuse, un pont, six emplacements de construction et une forteresse. Les ennemis suivent des chemins fixes et les défenseurs attaquent automatiquement depuis leurs emplacements.

| Paramètre du prototype | Valeur de référence | Statut |
| --- | --- | --- |
| Cartes | 1 | C |
| Emplacements de construction | 6 | C |
| Vagues | 10 | C |
| Or initial | 150 pièces d’or | H — valeur de départ à tester |
| Points de vie de la forteresse | 20 PV | H — valeur de départ à tester |
| Choix roguelite | Après les vagues 3, 6 et 9 | V — calendrier du prototype |

### Conditions de fin à préciser
La destruction de la forteresse met fin à la partie — V. Les dégâts d’arrivée sont définis par ennemi en section 9, avec des valeurs H ; les arrivées simultanées sont résolues selon la section 23. La victoire survient lorsque la vague 10 est entièrement résolue et que la forteresse survit — V. Les règles de résolution figurent en section 10.

Le tracé de 28 unités et les six positions sont approuvés pour les essais, avec dimensions H. Les conventions et mesures figurent en sections 18 à 20 ; les portées initiales restent en sections 5 et 6. Aucun placement libre n’est ajouté.

<a id="s3"></a>

## 3 Factions races et classes

### Identité des factions
| Faction provisoire | Races validées | Orientation validée |
| --- | --- | --- |
| Alliance des Royaumes | Humains, Elfes, Nains | Défense, précision, magie et ingénierie |
| Horde des Cendres | Orcs, Trolls, Morts-vivants, Gobelins | Offensive, poisons, malédictions et explosifs |

Les deux factions sont jouables — V. Leurs noms sont provisoires. Les comportements retenus pour le prototype sont détaillés en sections 5 et 6. Les autres axes, dont le poison, restent à spécifier.

### Roster du prototype
| Identifiant | Faction | Race | Classe ou rôle nommé |
| --- | --- | --- | --- |
| ALL_ELF_ARCHER | Alliance | Elfe | Archer |
| ALL_DWA_CROSSBOW | Alliance | Nain | Arbalétrier |
| ALL_HUM_MAGE | Alliance | Humain | Mage |
| HOR_TRO_AXE | Horde | Troll | Lanceur de haches |
| HOR_GOB_SAPPER | Horde | Gobelin | Sapeur |
| HOR_ORC_SHAMAN | Horde | Orc | Chaman |

Les six défenseurs sont issus du socle validé. Les identifiants ci-dessus sont une convention documentaire proposée — P — pour suivre les fiches dans Git et les futures données de jeu. Ils ne constituent pas une décision d’architecture.

### Limites du contenu défini
Les Morts-vivants appartiennent à la Horde, mais aucun défenseur mort-vivant n’est nommé dans le prototype. Aucun rôle supplémentaire ne doit être créé pour compléter artificiellement la liste. Le druide est cité uniquement dans un exemple de synergie ; sa présence dans le jeu et son appartenance de faction ne sont pas validées.

La version commerciale envisage huit défenseurs par faction, chacun doté de deux spécialisations — C. Les dix défenseurs supplémentaires, leurs races, leurs classes et leurs branches restent à définir. Le recrutement est limité au roster de la faction choisie pour le prototype — V.

### Fiche évolutive de défenseur
Chaque fiche pourra réunir : identifiant, nom, faction, race, classe, coût d’achat, statistiques par niveau, ciblage, spécialisation A, spécialisation B, interactions de synergie, statut des valeurs et source de validation. Tout champ non documenté conserve la valeur « À définir » ; cette absence ne signifie jamais zéro.

<a id="s4"></a>

## 4 Statistiques niveaux et spécialisations

### Statistiques initiales des défenseurs
Toutes les valeurs de ce tableau sont des hypothèses initiales non équilibrées — H. Le coût est exprimé en pièces d’or. Le DPS représente des dégâts par seconde ; il ne suffit pas à définir les dégâts d’une attaque ou sa cadence.

| Défenseur | Achat en or | DPS de base | Statut |
| --- | --- | --- | --- |
| Archer elfe | 50 | 8 | H |
| Arbalétrier nain | 75 | 9,6 | H |
| Mage humain | 100 | 10,8 | H |
| Lanceur de haches troll | 50 | 8 | H |
| Sapeur gobelin | 75 | 9,6 | H |
| Chaman orc | 100 | 10,8 | H |

Les factions partagent les mêmes trois couples coût/DPS pour le prototype. Cette symétrie numérique n’annule pas l’objectif validé de différenciation. Les comportements initiaux sont précisés en sections 5 et 6 ; leur équilibre reste à tester.

### Progression avec l’or
Chaque défenseur peut être amélioré jusqu’au niveau 4 — V. Le niveau 4 débloque un choix entre deux branches de spécialisation — V. Les coûts d’amélioration restent provisoires — H.

| Passage | Coût supplémentaire en or | Investissement cumulé hors achat |
| --- | --- | --- |
| Niveau 1 vers niveau 2 | 50 | 50 |
| Niveau 2 vers niveau 3 | 100 | 150 |
| Niveau 3 vers niveau 4 | 150 | 300 |

La lecture séquentielle des trois coûts correspond aux trois améliorations jusqu’au niveau 4. La progression approuvée augmente uniquement les dégâts : × 1,5 au N2, × 2,25 au N3 et × 3,25 au N4, relativement au N1 — valeurs H. Cadence, portée, rayons, plafonds de victimes et horaires des effets restent inchangés — V. Les tableaux complets figurent en sections 12 et 13. Les valeurs finales spécialisées sont détaillées en sections 15 à 17 ; elles restent H.

### Paramètres manquants
| Domaine | Données à définir — O |
| --- | --- |
| Attaque | Comportements en sections 5 et 6 ; valeurs N1 à N4 en section 12 |
| Résolution des dégâts | Types et résistances futures ; cumul des bonus et synergies défini |
| Spécialisations | Noms définitifs, interface et équilibre des branches |
| Niveaux | Bonus et synergies définis en sections 27 et 33 |

Le choix de spécialisation est inclus dans le coût du passage au N4. Les effets approuvés sont détaillés en sections 14 à 17. Les dégâts secondaires du mage constituent une décision explicite documentée en section 5 ; critiques, soins, invocations et contrôle restent non définis.

<a id="s5"></a>

## 5 Combat des défenseurs de l Alliance

### Portée de la validation
Les rôles, les comportements et les règles communes ci-dessous ont été approuvés pour le prototype dans l’échange suivant le GDD v0.2 — V. Les nombres sont retenus comme réglages initiaux à tester — H. Cette approbation ne les transforme pas en équilibre final et ne définit pas les spécialisations.

### Statistiques au niveau 1
Valeurs sans bonus ni synergie. Les coûts et DPS prolongent les hypothèses du socle. Les dégâts, intervalles et portées sont les nouveaux réglages initiaux approuvés pour les essais.

| Paramètre | Archer elfe | Arbalétrier nain | Mage humain |
| --- | --- | --- | --- |
| Coût en or — H | 50 | 75 | 100 |
| Dégâts principaux par attaque — H | 8 | 24 | 27 |
| Intervalle entre attaques — H | 1 seconde | 2,5 secondes | 2,5 secondes |
| DPS sur une cible — H | 8 | 9,6 | 10,8 |
| Portée en unités de carte — H | 4 | 5 | 3,5 |

Les distances n’imposent pas de grille de placement. L’échelle commune utilise le plan logique de La Vallée du Gué, en sections 18 à 20 ; ses dimensions restent H. DPS = dégâts par attaque ÷ intervalle entre attaques ; il s’agit d’un débit théorique en régime continu, sans déplacement de cible ni temps perdu.

### Rôles et comportements validés
L’archer elfe est une défense économique à cadence régulière. Il tire sur une seule cible, sans effet secondaire au niveau 1. Sa faiblesse est l’absence de dégâts de zone et des dégâts modestes par tir.

L’arbalétrier nain est un tireur lent à longue portée. Il touche une seule cible ; les dégâts dépassant les PV restants sont perdus. Le premier essai ne lui attribue ni perforation ni bonus contre les armures. Sa faible cadence rend un tir gaspillé plus pénalisant.

Le mage humain est spécialisé contre les groupes, avec une portée plus courte. Sa cible principale reçoit 27 dégâts. Jusqu’à deux autres ennemis situés à moins d’une unité du point d’impact reçoivent chacun 40 % des dégâts principaux, soit 10,8 dégâts. Chaque ennemi reçoit au maximum une application par attaque. Le rayon, le plafond et le coefficient sont des réglages H ; le principe de cette attaque est V.

Le DPS total théorique du mage atteint (27 + 10,8 + 10,8) ÷ 2,5 = 19,44 lorsque trois ennemis sont constamment regroupés. Cette valeur dérivée ne remplace pas son DPS de 10,8 sur une cible.

### Règles communes validées pour le premier essai
- Cibler automatiquement l’ennemi à portée le plus avancé sur le chemin vers la forteresse.
- Commencer une attaque uniquement avec une cible valide à portée ; recalculer sa priorité avant chaque tir selon la section 21.
- Tester sans réduction de dégâts liée aux résistances, sans bonus raciaux et sans spécialisations, afin de comparer les niveaux 1.

Les victimes secondaires les plus proches du point d’impact sont prioritaires — V. Le premier tir, les égalités et les impacts instantanés sont précisés en sections 21 à 23. Le premier test comparera des ennemis isolés puis regroupés sur le même tronçon de route ; aucun test jouable n’est encore réalisé.

<a id="s6"></a>

## 6 Combat des défenseurs de la Horde

### Portée de la validation
Les comportements sont approuvés pour le prototype — V. Les nombres restent des réglages initiaux — H. Les fiches décrivent le niveau 1 sans bonus ni spécialisation, avec les coûts et DPS du socle.

### Statistiques initiales
| Paramètre | Lanceur de haches troll | Sapeur gobelin | Chaman orc |
| --- | --- | --- | --- |
| Coût en or — H | 50 | 75 | 100 |
| Dégâts principaux par attaque — H | 16 | 24 | 12 immédiats et malédiction |
| Intervalle entre attaques — H | 2 secondes | 2,5 secondes | 2 secondes |
| DPS théorique sur une cible — H | 8 | 9,6 | 10,8, malédiction comprise |
| Portée en unités de carte — H | 3,5 | 3 | 4,5 |

L’unité de distance est commune aux factions et suit le plan logique de la carte, avec dimensions H. Les DPS supposent des attaques continues et des cibles survivant assez longtemps.

### Lanceur de haches troll
Une attaque inflige 16 dégâts à la cible principale, puis la hache peut rebondir sur un autre ennemi situé à moins d’une unité de celle-ci. Le rebond inflige 8 dégâts, soit 50 % du premier impact. Une attaque touche au maximum deux ennemis distincts ; elle ne revient pas blesser la cible principale. Sans seconde cible admissible, aucun rebond n’a lieu.

Le DPS théorique sur deux ennemis atteint (16 + 8) ÷ 2 = 12. Le troll traite les petits groupes ; face à l’archer, il perd en portée et en régularité. Le comportement de rebond est V ; ses valeurs restent H.

### Sapeur gobelin
Un explosif inflige 24 dégâts à la cible principale et 9,6 dégâts à chacune de ses victimes secondaires, soit 40 %. Jusqu’à trois ennemis secondaires situés à moins d’une unité du point d’impact peuvent être touchés. Chaque ennemi reçoit au maximum une application par explosion.

Avec quatre ennemis constamment regroupés, le DPS total théorique atteint (24 + 3 × 9,6) ÷ 2,5 = 21,12. La courte portée limite ses emplacements efficaces et son temps d’attaque. Sa supériorité possible sur le mage contre les groupes denses est un risque d’équilibrage à tester, pas un résultat acquis.

### Chaman orc
Toutes les deux secondes, une attaque inflige 12 dégâts immédiats et applique une malédiction. Celle-ci inflige 4,8 dégâts après une seconde puis 4,8 après deux secondes. Le total d’une attaque complète est de 21,6 dégâts, soit 10,8 DPS théoriques en régime continu. Une partie des dégâts peut arriver trop tard contre une cible fragile ou proche de la forteresse.

Les malédictions d’un même chaman ne se cumulent pas sur une cible ; une nouvelle application renouvelle l’effet. Au même instant, le dernier dégât périodique précède le renouvellement. Les effets de chamans différents fonctionnent indépendamment. La malédiction ne ralentit pas et ne réduit pas les résistances.

### Ciblage et comparaison des factions
La cible principale reste l’ennemi à portée le plus avancé. Pour les rebonds et explosions, priorité aux victimes secondaires les plus proches du point d’impact — V ; égalités départagées selon la section 21. Comparer les deux factions sur la même carte avant de conclure à leur équilibre.

<a id="s7"></a>

## 7 Économie et calculs de référence

### Règles et paramètres
L’or finance les achats et les améliorations — V. Pour le premier essai, chaque élimination rapporte immédiatement une récompense unique, selon le tableau de la section 9. Les montants sont H. Le capital initial de référence est de 150 or — H. Aucun revenu passif ni monnaie supplémentaire n’est validé.

### Récompenses validées pour le premier essai
- Créditer l’or immédiatement à la mort d’un ennemi, une seule fois, y compris après des dégâts de malédiction.
- Appliquer les mêmes récompenses aux deux factions.
- Lorsqu’un ennemi atteint la forteresse, appliquer ses dégâts puis le retirer de la partie, sans récompense.
- Ne pas attribuer de prime de fin de vague pendant ce premier essai.

Une unité peut être vendue uniquement entre les vagues contre 70 % de l’or total investi — V. Les synergies sont alors recalculées — V. Le remboursement est arrondi à l’entier inférieur, une seule fois par exemplaire vendu — V. R-10 et R-11 réduisent les dépenses futures selon la section 28 ; le remboursement utilise les montants réellement payés.

### Achat et améliorations cumulés
Le total au niveau 4 ci-dessous additionne l’achat et les trois coûts provisoires de 50, 100 et 150 or. Le choix de spécialisation est inclus dans l’amélioration vers le N4. Les remboursements appliquent 70 % puis l’arrondi inférieur par exemplaire.

| Défenseurs concernés | Investi N1 | Investi N4 | Vente N1 / N4 |
| --- | --- | --- | --- |
| Archer elfe ; Lanceur de haches troll | 50 | 350 | 35 / 245 |
| Arbalétrier nain ; Sapeur gobelin | 75 | 375 | 52 / 262 |
| Mage humain ; Chaman orc | 100 | 400 | 70 / 280 |

Formules dérivées : investissement = achat + améliorations payées ; remboursement = partie entière inférieure de (investissement × 0,70). La perte représente au moins 30 % de cet investissement. Ces calculs dépendent des hypothèses de coût et n’attestent pas leur équilibre.

### Exemples de budget initial
| Composition dans une seule faction | Dépense en or | Solde sur 150 or |
| --- | --- | --- |
| Deux défenseurs à 50 | 100 | 50 |
| Deux défenseurs à 75 | 150 | 0 |
| Un défenseur à 100 et un à 50 | 150 | 0 |
| Un défenseur à 75 et un à 50 | 125 | 25 |

Ces compositions respectent la limite de deux exemplaires par type (valeur H). Trois défenseurs à 50 or du même type sont interdits. Aucune composition n’est présentée comme stratégie optimale.

### Décisions d’équilibrage à prendre
Tester les gains par ennemi retenus en section 9 et la limite H de deux exemplaires par type. Les plafonds de revenus et un scénario de dépenses figurent en sections 10 et 11. Vérifier en jeu les choix entre élargir une défense et atteindre une spécialisation ; les gains réels dépendent des éliminations.

<a id="s8"></a>

## 8 Bonus roguelite et synergies

### Améliorations pendant une partie
Après certaines vagues, le joueur choisit une amélioration parmi trois propositions aléatoires — V. Les bonus obtenus restent actifs jusqu’à la fin de la partie — V. Pour le prototype, les sélections ont lieu après les vagues 3, 6 et 9 — V, soit trois moments de choix.

Le prototype utilise douze bonus approuvés, détaillés en sections 25 à 29. Les valeurs restent H. La cible commerciale d’environ 60 bonus reste C. Les trois offres sont distinctes et les bonus déjà sélectionnés sont exclus ; pas de relance ni de rareté pour le prototype.

| Règle de génération | État |
| --- | --- |
| Trois propositions par choix | V |
| Tirage aléatoire | V |
| Poids égaux ; douze bonus éligibles aux deux factions ; aucune rareté | V |
| Trois offres distinctes ; bonus choisi exclu des tirages suivants | V |
| Pourcentages de dégâts additionnés selon les composantes ; voir section 27 | V |
| Catalogue de 12, 11 puis 10 entrées avant les trois tirages | Calcul dérivé |

### Les trois mécanismes de synergie
| Mécanisme validé | Intention | Règle du prototype |
| --- | --- | --- |
| Diversité de défenseurs d’une même race | Récompenser une composition raciale diversifiée | Deux types distincts par race ; +8 % H ; non activable avec le roster actuel |
| Spécialisations | Créer des interactions entre choix de branches | Six associations N4 ; cumul par composante |
| Proximité entre certaines unités | Valoriser la disposition des défenseurs | Six associations ; centres à 5 unités H au maximum |

La diversité compte les types de défenseurs de base, pas les copies, niveaux ou branches. Chaque race n’ayant qu’un type dans le prototype, le volet racial est conservé sans activation. Les sections 30 à 34 précisent les synergies ; le recrutement est limité à deux exemplaires par type (H).

### Exemple non contractuel
Le socle illustre une interaction possible par un archer elfe placé près d’un druide qui pourrait recevoir des flèches empoisonnées. Cet exemple n’approuve ni le druide comme défenseur, ni une valeur de poison, ni une portée de voisinage. Il sert uniquement à expliquer le principe.

### Recalcul et progression persistante
Recalculer conditions et valeurs après construction, amélioration, choix de branche, vente et sélection d’un bonus, depuis les références sans cumul répété — V. La progression entre les parties demeure ouverte : aucune monnaie persistante, arbre de talents ou amélioration permanente n’est approuvé.

<a id="s9"></a>

## 9 Ennemis et boss du prototype

### Périmètre et statut des valeurs
Sept archétypes ordinaires et un boss distinct sont retenus pour le prototype — V. Leurs noms restent provisoires. Les PV, vitesses, dégâts à la forteresse et récompenses sont des réglages initiaux — H. Les premiers essais distinguent les ennemis par leur endurance, leur vitesse et leur nombre, sans résistances ni capacités spéciales supplémentaires.

### Statistiques initiales
Les vitesses utilisent l’unité de carte commune aux portées des défenseurs, selon le plan logique approuvé, avec dimensions H. La récompense est exprimée en pièces d’or et créditée uniquement à l’élimination. Tous les nombres de ce tableau sont H.

| Ennemi provisoire | PV | Vitesse par seconde | Dégâts forteresse | Or |
| --- | --- | --- | --- | --- |
| Grouillant | 12 | 1,15 | 1 | 1 |
| Pillard | 40 | 1 | 1 | 3 |
| Sprinter | 24 | 1,65 | 1 | 3 |
| Brute | 120 | 0,70 | 2 | 7 |
| Maraudeur | 80 | 1,20 | 2 | 6 |
| Colosse | 240 | 0,50 | 3 | 14 |
| Élite | 360 | 0,75 | 4 | 20 |
| Boss Seigneur de siège | 600 | 0,45 | 20 | 40 |

### Rôle des sept archétypes ordinaires
Le grouillant teste les groupes denses. Ses 12 PV de référence lui permettent de survivre à une seule application secondaire du mage à 10,8 dégâts ou au rebond du troll à 8 dégâts. Le nombre et l’espacement initiaux des grouillants figurent en section 10 — H.

Le pillard est l’ennemi de référence pour comparer les défenseurs. Sans bonus, 40 PV nécessitent cinq impacts d’archer à 8 dégâts ou deux impacts d’arbalétrier à 24 dégâts. Ces calculs comptent les impacts et ne prédisent pas un temps d’élimination.

Le sprinter teste la couverture du chemin. Fragile et rapide, il peut être éliminé par un impact d’arbalétrier ; des arrivées rapprochées exposent la lenteur de cette arme. La brute est lente et endurante ; elle permet d’observer les dégâts soutenus et les malédictions.

Le maraudeur combine endurance et vitesse pour éprouver les défenses concentrées sur un seul emplacement. Le colosse occupe longtemps les défenseurs ; sa position sur le chemin peut détourner des tirs d’autres ennemis. L’élite, robuste et plus mobile que le colosse, prépare les dernières vagues sans capacité particulière.

### Seigneur de siège
Le boss est prévu à la vague 10 — V. Les essais initiaux lui attribuent 600 PV, une vitesse de 0,45 et 20 dégâts à la forteresse — H. Avec la forteresse initiale à 20 PV, son arrivée est fatale. Il rapporte 40 or s’il est éliminé ; cette récompense ne présume pas d’une utilisation après la dernière vague.

Le premier essai ne comporte ni phases ni invocations. Rebonds, explosions et malédictions s’appliquent normalement au boss. Ses éventuelles capacités ultérieures restent ouvertes ; la victoire est définie en section 10. Aucun résultat d’équilibrage ni test jouable n’est encore établi.

<a id="s10"></a>

## 10 Composition des dix vagues

### Statut et lecture de la séquence
La séquence et les règles d’apparition sont approuvées pour le prototype — V. Quantités, intervalles et pause de groupe sont des réglages initiaux — H. Les récompenses utilisent les valeurs H de la section 9 ; leurs cumuls sont des calculs dérivés, pas des gains garantis.

### Règles d’apparition et de résolution
- Le temps repart à zéro au lancement de chaque vague ; son premier ennemi apparaît à t = 0.
- Les groupes apparaissent dans l’ordre des flèches. Chaque intervalle s’applique entre deux apparitions successives d’un même groupe, à vitesse de jeu normale.
- Le groupe suivant commence 4 secondes après la dernière apparition du précédent — H. Les ennemis précédents peuvent encore être présents sur le chemin.
- Un groupe de n ennemis espacés de Δ secondes émet pendant (n − 1) × Δ secondes. Un ennemi unique n’a aucun intervalle interne.
- La vague est terminée après sa dernière apparition, lorsque tous ses ennemis ont été éliminés ou ont atteint la forteresse. Si celle-ci survit, le joueur peut préparer puis lancer la suivante.
- Les choix roguelite restent après les vagues 3, 6 et 9. Après résolution complète de la vague 10, la forteresse survivante remporte la victoire ; sa destruction entraîne la défaite.

### Quantités intervalles et revenus
Les intervalles sont indiqués dans le même ordre que les groupes. Le cumul exclut les 150 or initiaux et ne déduit aucun achat ; tous les ennemis doivent être éliminés pour atteindre ce maximum. Aucun bonus économique non défini n’est inclus.

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

### Progression recherchée
Les vagues 1 à 3 présentent le chemin, les groupes puis la vitesse. Les vagues 4 à 7 introduisent Brutes, Maraudeurs, Colosses et Élites. La vague 8 sollicite les dégâts de groupe ; la vague 9 augmente fortement la charge de PV. La vague 10 confronte la défense au boss, à deux Élites et à huit Sprinters. Les chevauchements réels sur le chemin et la difficulté restent à mesurer.

<a id="s11"></a>

## 11 Calendrier et budget des vagues

### Charge et horaires calculés
Les horaires indiquent la dernière apparition depuis le lancement de chaque vague, avec les intervalles et séparations de la section 10. Les PV cumulés ne mesurent pas seuls la difficulté.

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

Le budget brut vaut 150 + récompenses cumulées, avant toute dépense. Le revenu réel additionne seulement les récompenses des ennemis éliminés. Deux Pillards atteignant la forteresse en vague 1 ramènent son revenu de 30 à 24 or.

### Scénario de dépenses calculé
Exemple pour les trois défenseurs distincts de chaque faction, sans bonus, vente ni doublon et avec toutes les éliminations. Les soldes incluent les vagues intermédiaires sans achat. Les prix restent H ; le scénario démontre seulement la capacité de financement.

| Moment | Achat ou amélioration | Dépense en or | Solde en or |
| --- | --- | --- | --- |
| Départ | Acheter les défenseurs à 50 et 75 or | 125 | 25 |
| Après vague 3 | Acheter le défenseur à 100 or | 100 | 41 |
| Après vague 4 | Défenseur à 50 or au niveau 2 | 50 | 35 |
| Après vague 5 | Ce même défenseur au niveau 3 | 100 | 23 |
| Après vague 7 | Ce même défenseur au niveau 4 | 150 | 51 |
| Après vague 8 | Les deux autres défenseurs au niveau 2 | 100 | 59 |
| Après vague 9 | Défenseur à 75 or au niveau 3 | 100 | 91 |
| Après vague 10 | Aucun achat supplémentaire prévu | 0 | 195 |

Le N4 est finançable avant la vague 8. Avant le boss, la composition N4 / N3 / N2 atteint 63,8 DPS théoriques hors spécialisation (section 13). Ce calcul ne garantit pas la victoire.

### Totaux et durée à éprouver
Total : 182 ennemis et 770 or de récompenses maximales. Avant le boss : 816 or bruts, capital inclus. Les 104 or de la dernière vague ne peuvent financer sa défense : les achats en combat sont interdits.

Les apparitions durent au total 4 min 33,1 s (273,1 s), hors fins de combat et préparations. La cible de 8 à 12 minutes reste à vérifier. Horaires détaillés : design/Proposition_dix_vagues.md.

<a id="s12"></a>

## 12 Progression et dégâts par niveau

### Principe et multiplicateurs
Ces règles décrivent la progression de base, avant les dérogations des branches spécialisées.

Le principe de progression est validé — V ; les nombres sont des hypothèses H. Les dégâts N1 sont multipliés par 1 / 1,5 / 2,25 / 3,25 aux niveaux 1 / 2 / 3 / 4. Un multiplicateur s’applique au N1, jamais au niveau précédent. Il affecte les dégâts directs, secondaires et périodiques.

Cadence, portée, rayons, nombre de victimes secondaires, coefficients et horaires des effets restent inchangés. Les fractions sont conservées sans arrondi intermédiaire pour les statistiques de référence. Bonus, résistances et branches sont exclus de ces tableaux. Le N4 représente le socle avant spécialisation.

### DPS théorique sur une cible
Le chaman inclut les deux applications de malédiction, sur une cible survivante et attaquée en continu.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 8 | 12 | 18 | 26 |
| Arbalétrier nain | 9,6 | 14,4 | 21,6 | 31,2 |
| Mage humain | 10,8 | 16,2 | 24,3 | 35,1 |
| Lanceur de haches troll | 8 | 12 | 18 | 26 |
| Sapeur gobelin | 9,6 | 14,4 | 21,6 | 31,2 |
| Chaman orc | 10,8 | 16,2 | 24,3 | 35,1 |

### Dégâts directs par attaque
Intervalles : archer 1 s ; arbalétrier, mage et sapeur 2,5 s ; troll et chaman 2 s.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 8 | 12 | 18 | 26 |
| Arbalétrier nain | 24 | 36 | 54 | 78 |
| Mage humain | 27 | 40,5 | 60,75 | 87,75 |
| Lanceur de haches troll | 16 | 24 | 36 | 52 |
| Sapeur gobelin | 24 | 36 | 54 | 78 |
| Chaman orc | 12 | 18 | 27 | 39 |

### Dégâts secondaires et périodiques
Par victime secondaire pour mage, troll et sapeur ; par application à +1 s et +2 s pour le chaman.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Mage humain | 10,8 | 16,2 | 24,3 | 35,1 |
| Lanceur de haches troll | 8 | 12 | 18 | 26 |
| Sapeur gobelin | 9,6 | 14,4 | 21,6 | 31,2 |
| Chaman orc | 4,8 | 7,2 | 10,8 | 15,6 |

Le mage conserve au maximum deux victimes secondaires à 40 %, le troll un rebond à 50 % et le sapeur trois victimes secondaires à 40 %. Leur rayon ou distance reste d’une unité de carte. Les règles de renouvellement de malédiction restent celles de la section 6.

<a id="s13"></a>

## 13 Coûts et lecture de la progression

### Plafonds théoriques de dégâts de groupe — H
Ces plafonds supposent des attaques continues, des cibles admissibles au maximum et assez de PV. Mage : trois victimes au total ; troll : deux ; sapeur : quatre. Ils ne prédisent pas les éliminations réelles.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Mage humain | 19,44 | 29,16 | 43,74 | 63,18 |
| Lanceur de haches troll | 12 | 18 | 27 | 39 |
| Sapeur gobelin | 21,12 | 31,68 | 47,52 | 68,64 |

### Investissement total par défenseur — H
Pièces d’or, achat et améliorations compris ; spécialisation incluse. Les trois passages coûtent 50, 100 et 150 or.

| Défenseur | N1 | N2 | N3 | N4 |
| --- | --- | --- | --- | --- |
| Archer elfe | 50 | 100 | 200 | 350 |
| Arbalétrier nain | 75 | 125 | 225 | 375 |
| Mage humain | 100 | 150 | 250 | 400 |
| Lanceur de haches troll | 50 | 100 | 200 | 350 |
| Sapeur gobelin | 75 | 125 | 225 | 375 |
| Chaman orc | 100 | 150 | 250 | 400 |

### Seuils de dégâts à vérifier
Sans résistance ni bonus et aux PV ennemis actuels :
- Archer N2 : 12 dégâts, soit un Grouillant en un impact ; N4 : 26 dégâts, soit un Sprinter.
- Troll N2 : 24 dégâts directs contre un Sprinter et 12 par rebond contre un Grouillant.
- Arbalétrier N3 : 54 dégâts directs, suffisants contre un Pillard à 40 PV.
- Mage N2 : 16,2 dégâts secondaires et sapeur N2 : 14,4 ; chacun suffit contre un Grouillant.
- Chaman N3 : 27 dégâts immédiats, suffisants contre un Sprinter sans attendre sa malédiction.

Ces seuils peuvent produire des sauts de difficulté, notamment sur la vague 8. Aucun essai jouable ne les a encore vérifiés.

### Achats et concentration de puissance
Pour l’archer, les améliorations coûtent 50 or pour +4 DPS, 100 or pour +6 et 150 or pour +8 et le choix de spécialisation. Le rendement marginal diminue ; les six emplacements et les branches doivent rendre la concentration de puissance intéressante. Deux exemplaires par type peuvent être déployés ; le seuil reste H.

Le scénario de la section 11 investit 350 + 225 + 150 = 725 or avant le boss, avec un solde maximal de 91 or. La fiche design/Proposition_progression_niveaux.md rassemble les calculs. Les branches sont détaillées en sections 14 à 17.

<a id="s14"></a>

## 14 Choix des spécialisations

### Choix validé au niveau 4
Choisir une des deux branches pendant le passage N3 vers N4, entre les vagues — V. Le choix est inclus dans les 150 or provisoires de l’amélioration : aucun surcoût pour le prototype. Une seule branche par unité, fixée jusqu’à la vente. Une nouvelle unité repart au N1 ; le recrutement est limité à deux exemplaires par type (H).

Les deux branches sont accessibles dès les essais, sans déblocage persistant ni prérequis racial ajouté. Terminer le choix avant de lancer la vague suivante. Aucun effet n’est rétroactif sur une attaque ou malédiction déjà appliquée. La présentation de cette interaction reste à concevoir.

Les noms sont provisoires. Les rôles et comportements des douze branches sont approuvés — V ; toutes les statistiques sont des hypothèses H. La fiche design/Proposition_specialisations.md conserve les détails et le plan d’essais.

### Lecture des valeurs spécialisées
Les sections 15 à 17 donnent les valeurs finales au N4 spécialisé, hors bonus et résistances. Ne pas appliquer à nouveau le multiplicateur × 3,25. Les branches dérogent uniquement aux paramètres explicitement remplacés ; les autres règles du GDD continuent de s’appliquer.

Le ciblage principal reste l’ennemi à portée le plus avancé et les victimes secondaires les plus proches restent prioritaires. Le DPS suppose des attaques continues et assez de PV ; les plafonds de groupe supposent toutes les victimes admissibles. Les douze bonus suivent les formules de la section 27 ; les résistances futures restent ouvertes ; les synergies suivent la section 33.

### Budget conservé et comparaisons
Le total investi au N4 reste 350, 375 ou 400 or. La vente à 70 %, arrondie vers le bas par exemplaire, rend 245, 262 ou 280 or.

Le scénario de la section 11 conserve 725 or investis et 91 or de solde maximal avant le boss. Seul le défenseur à 50 or y atteint le N4 ; les deux autres sont N3 et N2.

| Composition avant le boss | DPS sur une cible |
| --- | --- |
| Alliance : Veilleur N4 + Arbalétrier N3 + Mage N2 | 63,8 |
| Alliance : Tireur de volée N4 + Arbalétrier N3 + Mage N2 | 70,3 |
| Horde : Fendeur N4 + Sapeur N3 + Chaman N2 | 70,3 |
| Horde : Ricochets N4 + Sapeur N3 + Chaman N2 | 60,8 |

Dégâts secondaires exclus. Ces calculs ne garantissent pas la victoire. Tester les branches à 75 et 100 or avec d’autres allocations du même budget, sans leur attribuer gratuitement des niveaux supplémentaires.

<a id="s15"></a>

## 15 Spécialisations de l Alliance

### Archer elfe portée ou cadence

N4 de base : 26 dégâts toutes les 1 s, portée 4, soit 26 DPS sur une cible.

| Branche | Dégâts par tir | Intervalle | Portée | DPS sur une cible |
| --- | --- | --- | --- | --- |
| A — Veilleur des remparts | 39 | 1,5 s | 5 | 26 |
| B — Tireur de volée | 19,5 | 0,6 s | 3,5 | 32,5 |

Veilleur : couvrir un segment plus long et frapper plus fort par impact. La cadence plus lente augmente les dégâts perdus sur les petites cibles. Le gain de portée peut accroître le temps de tir réel sans modifier le DPS continu.

Tireur de volée : attaques fréquentes et meilleur DPS continu, contre une portée réduite et un dégât par impact plus faible. Les tirs restent dirigés sur une seule cible ; « volée » ne signifie pas attaque de zone.

### Arbalétrier nain puissance ou couverture

N4 de base : 78 dégâts toutes les 2,5 s, portée 5, soit 31,2 DPS sur une cible.

| Branche | Dégâts par tir | Intervalle | Portée | DPS sur une cible |
| --- | --- | --- | --- | --- |
| A — Brise-siège | 117 | 3 s | 5 | 39 |
| B — Sentinelle des tours | 78 | 2,5 s | 6,5 | 31,2 |

Brise-siège : tirs puissants pour les ennemis endurants ; cadence plus lente, dégâts excédentaires perdus. À 117 dégâts, il n’élimine pas une Brute à 120 PV en un impact sans autre effet.

Sentinelle : étendre la couverture depuis un emplacement fixe, sans gain de dégâts ou de cadence. Son intérêt dépend fortement du tracé de la carte. Aucun changement de priorité vers les boss ou ennemis à forts PV n’est ajouté.

### Mage humain concentration ou dispersion

N4 de base : 87,75 dégâts principaux, deux victimes secondaires à 35,1 chacune, intervalle 2,5 s, portée 3,5, rayon 1. DPS : 35,1 sur une cible ; 63,18 au plafond de trois victimes.

| Branche | Dégâts principaux | Par victime secondaire | Maximum secondaire | Rayon |
| --- | --- | --- | --- | --- |
| A — Arcaniste de concentration | 110 | 22 (20 %) | 2 | 1 |
| B — Maître des déflagrations | 70 | 28 (40 %) | 4 | 1,3 |

Intervalle 2,5 s et portée 3,5 pour les deux branches.

Concentration : 44 DPS sur une cible et 61,6 au plafond de trois victimes. Renforce la cible principale ; réduit l’efficacité de zone.

Déflagrations : 28 DPS sur une cible et 72,8 au plafond de cinq victimes. Agrandit la zone et le nombre de victimes, au prix du dégât principal. Une même victime n’est touchée qu’une fois par explosion.

<a id="s16"></a>

## 16 Rebonds et explosifs spécialisés

### Lanceur de haches troll impact ou chaîne

N4 de base : 52 dégâts principaux, un rebond à 26, intervalle 2 s, portée 3,5, distance de rebond 1. DPS : 26 sur une cible ; 39 sur deux.

| Branche | Dégâts principaux | Par rebond | Nombre maximal de rebonds | Distance par rebond |
| --- | --- | --- | --- | --- |
| A — Fendeur de crânes | 65 | 16,25 (25 %) | 1 | 1 |
| B — Maître des ricochets | 46 | 23 (50 %) | 3 | 1 |

Intervalle 2 s et portée 3,5 pour les deux branches.

Fendeur : 32,5 DPS sur une cible et 40,625 sur deux. Meilleur impact principal, mais rebond plus faible que celui du N4 de base.

Ricochets : 23 DPS sur une cible et 57,5 au plafond de quatre victimes. Les rebonds sont successifs : à chaque étape, chercher l’ennemi admissible le plus proche de la dernière victime, à une distance strictement inférieure à 1. Chaque rebond inflige 50 % du dégât principal initial, sans réduction supplémentaire d’étape en étape. Une attaque ne touche jamais deux fois le même ennemi ; elle s’arrête faute de cible. Les égalités de distance sont départagées par progression puis ordre d’apparition, selon la section 21.

### Sapeur gobelin charge concentrée ou large explosion

N4 de base : 78 dégâts principaux et trois victimes secondaires à 31,2, intervalle 2,5 s, portée 3, rayon 1. DPS : 31,2 sur une cible ; 68,64 sur quatre.

| Branche | Dégâts principaux | Par victime secondaire | Maximum secondaire | Rayon |
| --- | --- | --- | --- | --- |
| A — Expert en démolition | 104 | 26 (25 %) | 3 | 1 |
| B — Artificier des foules | 65 | 26 (40 %) | 5 | 1,4 |

Intervalle 2,5 s et portée 3 pour les deux branches.

Démolition : 41,6 DPS sur une cible et 72,8 au plafond de quatre victimes. Renforce le point d’impact en sacrifiant les dégâts par victime secondaire.

Foules : 26 DPS sur une cible et 78 au plafond de six victimes. Plus de couverture et de victimes possibles, mais moins de dégâts sur la cible principale et sur chaque victime que le N4 de base. Aucune mine, zone persistante ou explosion en chaîne n’est ajoutée. Chaque victime n’est touchée qu’une fois par attaque.

<a id="s17"></a>

## 17 Spécialisations du chaman

### Chaman orc dégâts immédiats ou malédiction

N4 de base : 39 dégâts immédiats et deux applications à 15,6, à +1 s et +2 s. Intervalle 2 s, portée 4,5. DPS complet sur une cible survivante : 35,1.

| Branche | Dégâts immédiats | Dégâts à +1 s | Dégâts à +2 s | DPS complet |
| --- | --- | --- | --- | --- |
| A — Chaman de guerre | 58,5 | 9,75 | 9,75 | 39 |
| B — Tisseur de malédictions | 26 | 29,25 | 29,25 | 42,25 |

Intervalle 2 s et portée 4,5 inchangés. Guerre inflige 78 dégâts sur un cycle complet ; Malédictions en inflige 84,5.

Guerre : davantage de dégâts dès l’impact, moins de dégâts différés. Utile lorsque la cible risque d’atteindre rapidement la forteresse.

Malédictions : chaque application périodique devient plus forte, contre un impact initial plus faible. Les effets déjà appliqués suivent les règles de renouvellement du GDD ; au même instant, le dernier dégât périodique précède le renouvellement. Aucun cumul supplémentaire, ralentissement, transfert de malédiction ou réduction de résistance n’est proposé.

Guerre élimine un Pillard à 40 PV dès l’impact ; Malédictions élimine un Sprinter à 24 PV dès l’impact, mais doit attendre la suite de l’effet pour dépasser le total de Guerre. Les malédictions continuent après sortie de portée tant que la cible reste présente, selon la section 22. Le gain total de Malédictions donne une contrepartie mesurable à son impact initial réduit. Les synergies du catalogue suivent les sections 30 à 34 ; autres effets ouverts.



### Essais et questions ouvertes
Comparer chaque branche au N4 de base puis à sa concurrente, sur les mêmes vagues, carte et budget. Observer le temps de tir, les victimes secondaires réelles, les dégâts perdus et les PV de forteresse perdus. Vérifier les vagues 4 et 8 pour les groupes, les vagues 6, 7, 9 et 10 pour les cibles endurantes, et la vague 3 pour la vitesse.

L’interface reste ouverte ; la vente est arrondie à l’entier inférieur par exemplaire ; le combat conserve les fractions et applique les synergies définies. Aucun test jouable n’établit encore l’équilibre des branches.

<a id="s18"></a>

## 18 Géométrie de La Vallée du Gué

### Géométrie approuvée pour le prototype
La Vallée du Gué utilise un seul trajet A → B → C → D → E → F → G → H, identique pour tous les ennemis et les deux factions — V. Une entrée et une arrivée à la forteresse, sans bifurcation. Dimensions et coordonnées ci-dessous : réglages initiaux H.

Le terrain logique mesure 18 × 10 unités. Origine en bas à gauche ; x vers la droite et y vers le haut. Cette convention ne prescrit pas les axes du moteur. La projection isométrique conserve les distances du plan logique.

| Point | Coordonnées (x ; y) | Distance depuis l’entrée |
| --- | --- | --- |
| A | 0 ; 3 | 0 u |
| B | 4 ; 3 | 4 u |
| C | 4 ; 7 | 8 u |
| D | 9 ; 7 | 13 u |
| E | 9 ; 3 | 17 u |
| F | 14 ; 3 | 22 u |
| G | 14 ; 6 | 25 u |
| H | 17 ; 6 | 28 u |

Le trajet mesure 28 unités : sept segments de 4, 4, 5, 4, 5, 3 et 3 unités. Les virages orthogonaux servent de référence ; les arrondir imposerait de recalculer longueur et couvertures.

Le pont occupe C → D, de (6 ; 7) à (7 ; 7), soit de 10 à 11 unités parcourues. Il reste une partie ordinaire du chemin. La rivière est un décor ; aucun effet de terrain supplémentaire n’est défini.

### Distances et circulation validées
- Déplacement à vitesse constante le long de la ligne centrale, sans arrêt aux virages ; vitesses en unités par seconde.
- Distances euclidiennes entre centres, dans le plan logique, avant projection isométrique.
- Acquisition d’une cible principale à distance inférieure ou égale à la portée ; rayons secondaires et rebonds gardent leur règle strictement inférieure.
- Priorité au plus avancé selon la distance parcourue de A vers H ; égalités selon la section 21.
- Aucun blocage mutuel ni ralentissement de circulation pour l’essai initial. Les emplacements ne bloquent pas la route.
- Les décors ne bloquent pas les attaques. Les frontières servent au cadrage ; les portées peuvent les dépasser.

Les tailles graphiques ne modifient pas les distances. Largeur visuelle et empreintes restent à concevoir. Les projectiles sont visuels ; tir et effets hors portée suivent les sections 21 à 23. La fiche design/Proposition_Vallee_du_Gue.md conserve le protocole de vérification.

<a id="s19"></a>

## 19 Emplacements et couvertures

### Positions fixes
Les six emplacements sont disponibles dès le départ. Chacun accueille un défenseur de la faction choisie, sans restriction de classe — V. Deux exemplaires par type peuvent être déployés ; le seuil reste H. Coordonnées H ; intentions sans bonus d’emplacement.

| Repère | Coordonnées (x ; y) | Intention de positionnement |
| --- | --- | --- |
| E1 | 3 ; 1,5 | Entrée et premier virage |
| E2 | 2 ; 6 | Premier lacet et accès au pont |
| E3 | 6 ; 5 | Pont et cœur du premier lacet |
| E4 | 8 ; 9 | Sortie du pont et virage central |
| E5 | 11 ; 4,5 | Second lacet et approche finale |
| E6 | 15,5 ; 4,5 | Dernier virage et porte de la forteresse |

Les centres sont hors du trajet, à une distance minimale d’au moins 1,5 unité. E3 et E5 couvrent plusieurs segments : leur avantage potentiel est un risque d’équilibrage à tester. E6 conserve une dernière fenêtre de tir.

### Longueurs du trajet à portée
Valeurs calculées, en unités de chemin, à partir des coordonnées H. Le tableau additionne les portions situées dans un cercle centré sur l’emplacement. Il ne mesure ni les dégâts ni les éliminations. Affichage arrondi à deux décimales au maximum, sans arrondi intermédiaire par segment.

| Emplacement | Portée 3 | Portée 3,5 | Portée 4 | Portée 5 | Portée 6,5 |
| --- | --- | --- | --- | --- | --- |
| E1 | 4,93 u | 5,85 u | 6,37 u | 7,4 u | 11,79 u |
| E2 | 4,06 u | 8,83 u | 9,87 u | 10,9 u | 12,42 u |
| E3 | 8,47 u | 13,35 u | 14,93 u | 17,17 u | 20,18 u |
| E4 | 4,06 u | 5,23 u | 6,34 u | 8,9 u | 13,62 u |
| E5 | 8,33 u | 12,61 u | 13,83 u | 16,1 u | 19 u |
| E6 | 7,1 u | 7,66 u | 8,21 u | 9,27 u | 10,82 u |

Références : sapeur 3 ; mage et troll 3,5 ; archer 4 ; chaman 4,5 ; arbalétrier 5. Tireur de volée 3,5 ; Veilleur 5 ; Sentinelle 6,5. La portée 4,5 se calcule selon les mêmes conventions.

Pour un ennemi jamais éliminé, à vitesse constante v, le temps cumulé à portée vaut longueur couverte ÷ v. Plusieurs fenêtres peuvent être séparées. Cadence, premier tir, concurrence des cibles et dégâts perdus déterminent le résultat réel.

### Vérification proposée
Contrôler les cercles de portée puis comparer les emplacements à défenseur, niveau, branche et vague identiques. Noter temps de tir utile, éliminations et fuites. Tester les zones au pont, les ricochets et l’intérêt réel des branches de portée. Ne pas modifier simultanément carte, ennemis et défenseurs sans conserver une référence.

<a id="s20"></a>

## 20 Plan et temps de traversée

### Plan logique de référence
![Plan de La Vallée du Gué](design/Vallee_du_Gue_plan.png)

Le plan est vu du dessus pour mesurer la géométrie ; la présentation du jeu reste isométrique. Il ne fixe pas les assets ni le style graphique final.

### Traversée théorique sans combat
| Archétype | Vitesse du GDD | 28 ÷ vitesse |
| --- | --- | --- |
| Grouillant | 1,15 u/s | 24,35 s |
| Pillard | 1 u/s | 28 s |
| Sprinter | 1,65 u/s | 16,97 s |
| Brute | 0,7 u/s | 40 s |
| Maraudeur | 1,2 u/s | 23,33 s |
| Colosse | 0,5 u/s | 56 s |
| Élite | 0,75 u/s | 37,33 s |
| Seigneur de siège | 0,45 u/s | 62,22 s |

Calcul : 28 ÷ vitesse, sans élimination ni blocage. Le dernier Pillard de la vague 1 apparaîtrait à 22,5 s et arriverait à 50,5 s. Les horaires d’apparition restent ceux des sections 10 et 11. La cible de 8 à 12 minutes doit être mesurée avec les combats et préparations.

<a id="s21"></a>

## 21 Premier tir et ciblage

### Statut des règles
Les règles de résolution sont approuvées pour le premier prototype — V. Les statistiques H du GDD ne changent pas. Elles s’appliquent au combat de référence hors bonus ; leur catalogue est défini en sections 25 à 29.

### Premier tir et cadence
- Chaque défenseur est prêt à tirer au début d’une vague. Il ne tire que lorsqu’une cible admissible est présente à portée.
- Le premier tir a lieu dès que cette condition est remplie, sans délai initial supplémentaire.
- Après un tir à l’instant t, le prochain tir est autorisé au plus tôt à t + intervalle du défenseur. La cadence commence au tir réellement effectué.
- Si aucune cible n’est admissible lorsque ce délai se termine, l’unité reste prête. Elle tire dès l’acquisition suivante. Aucun tir, charge ou salve ne s’accumule pendant l’attente.
- Changer de cible ne remet pas le délai à zéro et ne permet pas un tir supplémentaire.
- Le début d’une nouvelle vague réinitialise la disponibilité. Construire, améliorer, choisir une branche et vendre restent interdits pendant les combats.
- Les horaires utilisent le temps de jeu. L’accélération doit accélérer aussi apparitions, déplacements, tirs et malédictions, sans changer leur ordre relatif. Ses multiplicateurs restent ouverts.

Exemple : archer prêt à t = 0, première cible admissible à t = 0,3 s. Il tire à 0,3 s, puis au plus tôt à 1,3 s. Si aucune cible n’est présente à 1,3 s et qu’une cible entre à 1,8 s, il tire à 1,8 s ; son prochain tir sera autorisé à 2,8 s. Il ne récupère pas le tir manqué.

Le pas de simulation du moteur n’est pas fixé par ces exemples. L’implémentation devra mesurer son erreur temporelle et préserver les règles ; aucun résultat ne doit dépendre de la fréquence d’affichage.

### Acquisition et égalités
Recalculer la cible principale avant chaque tir. Une cible encore vivante n’est pas verrouillée si une autre devient prioritaire. Cette précision résout l’ambiguïté entre « conserver sa cible » et la priorité déjà validée de l’ennemi le plus avancé.

Une cible principale est admissible si elle est vivante, présente sur le trajet et à distance de centre à centre inférieure ou égale à la portée. Un ennemi qui atteint exactement H à cet instant reste admissible jusqu’à la phase d’arrivée décrite en section 23.

Ordre de priorité principal :
1. Plus grande distance parcourue de A vers H.
2. En cas d’égalité exacte, plus ancien ordre d’apparition dans la partie.

L’ordre d’apparition est unique et croissant, y compris pour des ennemis apparus au même instant. Il suit l’ordre des groupes puis l’ordre interne de la vague. Aucun choix aléatoire n’est ajouté.

Pour les victimes secondaires :
1. Plus courte distance au centre de l’explosion ou à la victime précédente du rebond.
2. En cas d’égalité, plus grande progression sur le chemin.
3. En cas d’égalité persistante, plus ancien ordre d’apparition.

La règle de distance strictement inférieure au rayon ou à la distance de rebond reste celle du GDD. La cible principale est exclue des victimes secondaires ; les victimes déjà touchées par une même chaîne sont exclues des rebonds suivants.

<a id="s22"></a>

## 22 Impacts et malédictions

### Dégâts au moment du tir
Les dégâts sont résolus immédiatement au tir — V. Les projectiles peuvent être animés, mais leur trajet visuel ne retarde pas les dégâts et ne provoque aucun second impact. Leur vitesse visuelle n’est pas une statistique de combat. Ajouter ultérieurement de vrais projectiles en vol nécessiterait une révision.

La cible principale doit être à portée au moment du tir. Les dégâts sont appliqués à sa position actuelle dans ce même événement : il n’existe pas de seconde vérification de portée à un impact différé.

- Archer et arbalétrier : une cible, sans transfert des dégâts excédentaires.
- Mage et sapeur : explosion centrée sur la position actuelle de la cible principale ; choix des victimes secondaires à cet instant, selon rayon et plafond du défenseur ou de sa branche.
- Troll : première victime puis chaîne de rebonds résolue au même instant. Chaque étape utilise le centre de la dernière victime. Respecter le plafond et l’exclusion des victimes déjà visées.
- Chaman : dégâts directs immédiats et création ou renouvellement de sa malédiction si la cible survit à la phase de tirs.

Une victime secondaire peut être hors de la portée principale du défenseur : elle doit satisfaire le rayon de l’explosion ou la distance du rebond. La portée principale et le rayon secondaire ne sont pas additionnés pour l’acquisition.

Les morts provoquées dans une même phase ne déclenchent pas d’explosion ou d’effet supplémentaire non défini. Les dégâts excédentaires restent perdus ; ils ne se reportent pas sur une nouvelle cible.

### Malédictions hors portée
Une malédiction déjà appliquée continue à infliger ses dégâts à +1 s puis +2 s même si la cible sort de la portée du chaman. La portée conditionne le tir initial, pas le maintien de l’effet.

Les règles déjà validées restent applicables :
- Deux applications périodiques, avec les valeurs du niveau et de la branche du chaman au moment de l’application.
- Un seul effet par couple chaman–cible : une nouvelle attaque du même chaman renouvelle cet effet, remplace ses échéances futures et programme de nouvelles échéances à +1 s et +2 s.
- Au même instant, le dernier dégât périodique précède le renouvellement.
- Les effets de chamans différents sont indépendants.

La mort de la cible ou son retrait à la forteresse annule ses échéances futures. Aucun dégât ne s’applique à un ennemi retiré et aucune récompense supplémentaire n’est versée. Une malédiction ne prolonge pas une vague lorsqu’il ne reste plus d’ennemis présents.

<a id="s23"></a>

## 23 Ordre de résolution du combat

### Ordre des événements
Appliquer les événements selon leur instant de jeu. Lorsqu’ils partagent exactement le même instant, ordre commun validé :

| Phase | Résolution |
| --- | --- |
| 1 | Faire apparaître les ennemis prévus et calculer les positions à cet instant. Marquer ceux qui ont atteint H, sans les retirer encore. |
| 2 | Additionner et appliquer les dégâts des malédictions déjà programmées à cet instant ; retirer les morts et attribuer une seule récompense par mort. |
| 3 | Pour tous les défenseurs prêts, choisir les cibles sur le même état des survivants. Préparer les dégâts directs, explosions et chaînes, puis additionner et appliquer ces dégâts. Retirer les morts, verser leurs récompenses uniques et appliquer ou renouveler les malédictions sur les survivants visés. |
| 4 | Additionner les dégâts de forteresse de tous les survivants ayant atteint H, puis les retirer sans récompense et annuler leurs effets. |
| 5 | Vérifier la défaite, puis la fin de vague et la victoire selon les règles existantes. |

Pour la phase 3, toutes les cibles et chaînes sont déterminées avant l’application des dégâts de cette phase. Plusieurs défenseurs peuvent donc tirer sur le même ennemi et gaspiller une partie de leurs dégâts. Aucun ne bénéficie d’un ordre arbitraire de traitement des emplacements. Chacun consomme normalement son délai de tir.

Un ennemi déjà éliminé en phase 2 n’est pas candidat en phase 3. Une victime prévue dans une chaîne en phase 3 peut recevoir aussi les tirs d’autres défenseurs de cette phase ; les dégâts sont simplement additionnés. La récompense n’est jamais multipliée.

À la frontière de la forteresse, les dégâts de combat de cet instant sont résolus avant les dégâts d’arrivée. Un ennemi tué à cet instant rapporte son or et n’inflige aucun dégât à la forteresse. Cette priorité complète les règles de la v0.9.

Les dégâts d’arrivée simultanés sont additionnés avant le contrôle de défaite ; les PV de forteresse affichés sont bornés à zéro. La défaite est prioritaire si les PV sont nuls, même si la dernière vague vient d’être entièrement résolue. Les récompenses des autres ennemis réellement éliminés dans les phases précédentes restent uniques ; elles ne permettent toujours aucun achat en combat.

### Fractions et fin de vague
Conserver les fractions de dégâts et de PV pendant les calculs de référence, sans arrondi à chaque impact. Une cible meurt dès que ses PV deviennent inférieurs ou égaux à zéro. L’affichage peut être arrondi sans modifier le calcul ; son format reste à concevoir.

Exemple : quatre dégâts de rebond à 16,25 totalisent 65. Quatre valeurs arrondies à 16 ne seraient pas équivalentes. Le choix technique de représentation numérique et les tolérances de calcul sont à documenter lors de l’implémentation ; cette fiche définit les résultats mathématiques attendus.

La vague se termine quand toutes ses apparitions sont passées et que tous ses ennemis ont été éliminés ou retirés à la forteresse. Attendre la fin d’animations purement visuelles n’est pas nécessaire. La forteresse survivante passe à la préparation suivante ; après la vague 10, elle remporte la victoire. Les choix roguelite restent après les vagues 3, 6 et 9.

L’or reste attribué uniquement aux éliminations, une seule fois, y compris par malédiction. Aucun bonus de fin de vague, gain passif ou nouvelle monnaie n’est ajouté.

<a id="s24"></a>

## 24 Cas de référence du combat

### Vérifications du prototype
| Cas | Situation contrôlée | Résultat attendu |
| --- | --- | --- |
| C-01 | Archer prêt ; première cible à t = 0,3 s | Tir à 0,3 s ; prochain tir au plus tôt à 1,3 s |
| C-02 | Tir à t = 0,3 s ; aucune cible à 1,3 s ; acquisition à 1,8 s | Un tir à 1,8 s, aucun rattrapage ; prochain tir à 2,8 s |
| C-03 | Deux cibles à la même progression | Priorité à celle dont l’ordre d’apparition est le plus ancien |
| C-04 | Deux victimes secondaires à même distance | Départager par progression, puis ordre d’apparition |
| C-05 | Deux archers N1 prêts, un Pillard à 8 PV et un autre Pillard à portée moins avancé | Les deux visent le premier ; 16 dégâts cumulés, une récompense de 3 or ; aucun transfert vers le second |
| C-06 | Malédiction N1 déjà appliquée, cible vivante quittant la portée | 4,8 dégâts à chacune des deux échéances, tant qu’elle reste présente |
| C-07 | Chaman N1 tire à t = 0 puis à 2 s, cible toujours vivante | À 2 s : ancien tick de 4,8, puis tir direct de 12 ; nouvelle malédiction à 3 et 4 s |
| C-08 | Ennemi à 4,8 PV atteignant H au moment d’un tick de 4,8 | Mort par malédiction, récompense unique ; aucun dégât d’arrivée |
| C-09 | Forteresse à 3 PV ; deux survivants infligeant chacun 2 dégâts arrivent ensemble | 4 dégâts cumulés, PV bornés à 0, défaite |
| C-10 | Cible principale à la limite exacte de portée ; victime secondaire à la limite exacte du rayon | Cible principale admissible ; victime secondaire exclue par la règle stricte du rayon |
| C-11 | Dernier ennemi éliminé après la dernière apparition ; animations encore visibles | Fin de vague sans attendre les animations ; effets futurs annulés sur l’ennemi mort |
| C-12 | Plus aucun ennemi en vague 10 ; forteresse à 0 PV après les arrivées | Défaite, aucune victoire simultanée |

Ces cas décrivent des vérifications futures. Aucun prototype jouable ni test automatisé de combat n’est réputé avoir été exécuté par cette fiche.

<a id="s25"></a>

## 25 Bonus de combat et couverture

### Catalogue de référence
Douze bonus sont approuvés pour le prototype — V ; noms provisoires et valeurs H à tester. Les effets s’appliquent à la faction jouée, à ses unités présentes et futures, selon leurs conditions. Ils ne créent aucune unité supplémentaire.

| Code | Nom provisoire | Effet de référence — H | Limite et contrepartie de choix |
| --- | --- | --- | --- |
| R-01 | Armes affûtées | +10 % à tous les dégâts des défenseurs | Dégâts directs, secondaires et périodiques ; aucun gain de portée ou de cadence |
| R-02 | Exercice de tir | +12 % de fréquence d’attaque à l’archer, l’arbalétrier, le mage, le troll et le sapeur | Exclut explicitement le chaman pour préserver ses deux échéances de malédiction |
| R-03 | Postes d’observation | +0,5 unité à la portée principale de chaque défenseur | Ne modifie pas les rayons, rebonds, plafonds de victimes ou dégâts |
| R-04 | Éclats meurtriers | +20 % aux dégâts des victimes secondaires des explosions et rebonds | Mage, troll et sapeur ; aucun effet sur le dégât principal ou la malédiction |
| R-05 | Propagation | +0,2 unité aux rayons d’explosion et à la distance de chaque rebond | Mage, troll et sapeur ; plafonds de victimes et dégâts inchangés |
| R-06 | Impacts appuyés | +15 % aux dégâts directs de la cible principale | Tous les défenseurs, y compris le tir initial du chaman ; aucun effet secondaire ou périodique |

### Choix de composition
Ces six bonus renforcent dégâts, cadence, portée ou attaques de groupe. Les plafonds de victimes restent inchangés. R-02 exclut toutes les branches du chaman ; R-04 et R-05 concernent mage, troll et sapeur. Les formules précises sont en sections 27 et 28.

<a id="s26"></a>

## 26 Bonus de niveau survie et économie

### Niveau survie et dépenses
Ces six bonus complètent le catalogue. Toutes les valeurs sont H. Le choix consomme l’une des trois sélections de la partie ; les douze gains ne sont pas acquis simultanément.

| Code | Nom provisoire | Effet de référence — H | Limite et contrepartie de choix |
| --- | --- | --- | --- |
| R-07 | Recrues aguerries | +15 % à tous les dégâts des défenseurs actuellement N1 ou N2 | Le bonus cesse de s’appliquer à une unité dès son passage au N3 |
| R-08 | Vétérans | +12 % à tous les dégâts des défenseurs actuellement N3 ou N4 | Aucun effet sur les unités N1 ou N2 ; s’applique aussi aux branches N4 |
| R-09 | Maçonnerie renforcée | +4 PV maximum de forteresse et +4 PV actuels à la sélection | Nouveau maximum conservé jusqu’à la fin ; aucun soin automatique ultérieur |
| R-10 | Ateliers efficaces | −10 % au prix des améliorations N1→N2, N2→N3 et N3→N4 futures | Aucun remboursement rétroactif et aucun effet sur le prix d’achat |
| R-11 | Recrutement organisé | −10 % au prix des achats futurs de défenseurs | Aucun remboursement rétroactif et aucun effet sur les améliorations |
| R-12 | Chasse aux colosses | +20 % aux dégâts infligés aux Brutes, Colosses, Élites et au Seigneur de siège | Aucun effet contre Grouillants, Pillards, Sprinters et Maraudeurs ; ne modifie pas le ciblage |

R-07 et R-08 dépendent du niveau actuel. Une amélioration recalcule leur éligibilité ; aucun défenseur ne reçoit les deux effets simultanément. Le nouveau maximum de PV de R-09 reste actif jusqu’à la fin, sans soin automatique ultérieur. Les réductions de R-10 et R-11 portent uniquement sur les dépenses futures.

<a id="s27"></a>

## 27 Tirage et cumul des bonus

### Tirage et application
- Les douze bonus sont accessibles dès le premier choix aux deux factions, sans condition de déploiement, niveau ou branche. Chaque bonus a un bénéficiaire potentiel dans chaque roster.
- Tirer trois codes distincts, avec poids égaux, sans remise à l’intérieur de cette offre.
- Après sélection, retirer uniquement le bonus choisi du catalogue de la partie. Il ne peut plus être offert ni sélectionné une seconde fois.
- Les deux offres non choisies retournent dans le catalogue disponible et peuvent réapparaître plus tard.
- Pas de relance, de rareté, de coût de sélection ou de cumul de plusieurs copies du même bonus pour ce prototype.
- Choisir un seul bonus avant de reprendre la préparation et de lancer la vague suivante. Ses effets commencent dès la sélection, y compris les réductions de prix utilisables pendant cette même préparation.
- Réinitialiser tous les choix et effets à la fin de la partie.

Le catalogue disponible compte donc 12 bonus après la vague 3, 11 après la vague 6 et 10 après la vague 9, avant chacun de ces tirages. Il contient toujours au moins trois offres possibles. Ces nombres supposent les douze entrées actives et la sélection d’un seul bonus à chaque étape.

Un bonus de niveau ou d’attaque de groupe peut être proposé avant qu’une unité bénéficiaire soit recrutée : son intérêt futur doit être lisible dans sa description. Aucune promesse de rareté, garantie de catégorie ou adaptation cachée du tirage n’est ajoutée.

### Formules de dégâts
Calculer d’abord les statistiques de référence de l’unité à son niveau et, au N4, de sa branche. Ces valeurs constituent le socle avant bonus. Ne pas appliquer à nouveau × 3,25 aux valeurs finales spécialisées.

Pour chaque victime et chaque composante de dégâts :

Dégât final = dégât de référence de la composante × (1 + somme des pourcentages applicables).

Les pourcentages de R-01, du bonus de niveau applicable R-07 ou R-08, de R-12 selon le type de victime et du bonus de composante R-04 ou R-06 s’additionnent. Ils ne se multiplient pas successivement.

| Composante | Pourcentages applicables dans ce catalogue |
| --- | --- |
| Dégât principal direct | R-01 + R-06 + R-07 ou R-08 selon le niveau + R-12 selon la victime |
| Dégât secondaire d’explosion ou rebond | R-01 + R-04 + R-07 ou R-08 selon le niveau + R-12 selon la victime |
| Chaque dégât périodique de malédiction | R-01 + R-07 ou R-08 selon le niveau + R-12 selon la victime |

Les dégâts secondaires de référence se calculent avec le coefficient du niveau ou de la branche avant les bonus. Ils ne sont pas recalculés à partir d’un dégât principal déjà bonifié : R-06 ne se transmet donc pas aux explosions, rebonds ou malédictions.

R-12 se vérifie par victime : une explosion visant un Pillard bonifie la Brute secondaire, pas le Pillard. Le ciblage reste inchangé.

Les effets liés au niveau sont recalculés lors d’une amélioration entre les vagues. R-07 reste sélectionné après le passage d’une unité au N3, mais cesse d’affecter cette unité ; il peut encore bénéficier à d’autres unités N1/N2. Sélectionner R-07 et R-08 couvre les deux groupes de niveaux, sans les additionner sur une même unité.

Lorsqu’une malédiction est appliquée, conserver sa valeur calculée pour ses deux échéances selon les règles du GDD. Les bonus ne créent pas de dégâts supplémentaires après la mort ou le retrait de la cible.

Ces formules concernent le catalogue initial sans résistance ; ajouter les synergies selon la section 33. Résistances et effets hors catalogue restent ouverts.

<a id="s28"></a>

## 28 Paramètres et prix avec bonus

### Portée cadence et rayons
R-03 ajoute 0,5 à la portée principale de référence, après la branche éventuelle. Exemples : sapeur 3 → 3,5 ; Veilleur 5 → 5,5 ; Sentinelle 6,5 → 7. Le calcul des distances et la règle d’acquisition inclusive restent ceux de la carte.

R-05 ajoute 0,2 au rayon d’explosion ou à la distance de chaque rebond, après la branche. Exemples : explosion de base 1 → 1,2 ; Artificier des foules 1,4 → 1,6 ; rebond du troll 1 → 1,2. La comparaison de rayon reste strictement inférieure ; les plafonds de victimes et exclusions des chaînes restent inchangés.

R-02 modifie la fréquence d’attaque, et non directement le pourcentage de réduction de l’intervalle :

Nouvel intervalle = intervalle de référence ÷ 1,12.

L’archer de base passe de 1 s à environ 0,892857 s ; l’arbalétrier de 2,5 s à environ 2,232143 s. Ne pas utiliser intervalle × 0,88 : ce serait un autre réglage. Conserver la valeur non arrondie dans les calculs.

Le chaman est exclu de R-02 : un tir plus rapide peut renouveler sa malédiction avant le tick à +2 s et l’annuler. Sur une cible continue au N1, appliquer naïvement R-02 donnerait (12 + 4,8) ÷ (2 ÷ 1,12) = 9,408 DPS au lieu de 10,8. Son intervalle de 2 s reste donc inchangé.

Cette exclusion donne à R-02 trois bénéficiaires potentiels dans l’Alliance et deux dans la Horde. Son intérêt relatif entre factions doit être testé. Les bonus R-01, R-06, R-07/R-08, R-03 et R-12 peuvent renforcer le chaman selon leur effet propre ; R-04 et R-05 ne le concernent pas.

### Forteresse et économie
R-09 ajoute 4 au maximum et aux PV actuels, sans résurrection : 10/20 devient 14/24 et 20/20 devient 24/24. À 24 PV, l’arrivée du boss à 20 dégâts laisse 4 PV ; cet effet sur la victoire doit être testé.

Pour R-10 et R-11, appliquer la réduction au prix de référence puis arrondir le prix à l’entier supérieur, avec un coût minimal de 1 or. Ce minimum ne change aucun prix actuel. Les deux bonus concernent des opérations différentes et ne se multiplient donc pas sur un même prix.

| Opération | Prix de référence H | Prix avec son bonus de réduction |
| --- | --- | --- |
| Achat du défenseur à 50 or | 50 | 45 |
| Achat du défenseur à 75 or | 75 | 68 |
| Achat du défenseur à 100 or | 100 | 90 |
| Amélioration N1 vers N2 | 50 | 45 |
| Amélioration N2 vers N3 | 100 | 90 |
| Amélioration N3 vers N4 et choix de branche | 150 | 135 |

Les dépenses déjà payées ne changent pas. La vente reste à 70 % du montant réellement payé pour cette unité, achats et améliorations compris. Aucun remboursement ne se calcule sur un prix plein non payé ; aucune différence n’est rendue lors de la sélection d’un bonus de prix. La vente est arrondie à l’entier inférieur par exemplaire ; les prix réduits sont arrondis à l’entier supérieur.

Avec les deux bonus acquis avant l’achat et les améliorations d’un arbalétrier : 68 + 45 + 90 + 135 = 338 or investis ; vente de 236 or après arrondi inférieur. Ce calcul diffère du scénario sans bonus du GDD.

Les revenus maximaux des vagues ne changent pas : R-10 et R-11 réduisent des dépenses et n’ajoutent aucune récompense. Les budgets et DPS sans bonus du GDD demeurent des références, pas les résultats d’une partie avec bonus.

<a id="s29"></a>

## 29 Calculs et essais des bonus

### Exemples de calcul
| Cas | Calcul et résultat attendu |
| --- | --- |
| Archer N4 avec R-01 et R-06 | 26 × (1 + 0,10 + 0,15) = 32,5 dégâts par tir ; cadence inchangée |
| Mage N1 avec R-01 et R-06 | Principal : 27 × 1,25 = 33,75 ; secondaire : 10,8 × 1,10 = 11,88 par victime |
| Mage N1 avec R-01 et R-04 | Principal : 29,7 ; secondaire : 10,8 × 1,30 = 14,04 par victime |
| Archer N4 avec R-01 et R-02 | 28,6 dégâts, intervalle 1 ÷ 1,12 ; DPS continu 32,032 |
| Chaman N1 avec R-01 | 13,2 directs et deux ticks de 5,28 ; DPS continu 11,88 si cycle complet |
| Archer N2 avec R-07, puis passage N3 | N2 : 12 × 1,15 = 13,8 ; N3 : 18, R-07 ne s’applique plus |
| Archer N3 avec R-08 et R-12 contre une Brute | 18 × (1 + 0,12 + 0,20) = 23,76 dégâts ; contre un Pillard : 20,16 |

Ces calculs ne démontrent pas l’équilibre des offres. Le placement, les seuils d’élimination, les dégâts excédentaires et l’économie peuvent modifier fortement leur intérêt.

### Essais à mener
Vérifications proposées :
- Trois codes distincts par offre ; un code choisi absent des offres suivantes ; offres non choisies à nouveau possibles.
- Trois choix seulement, après les vagues 3, 6 et 9 ; catalogue restant de 12, 11 et 10 avant tirage.
- R-02 inactif sur toutes les branches du chaman et sans effet sur les échéances de malédiction.
- R-04/R-06 séparés : aucun double calcul du bonus principal dans les dégâts secondaires.
- R-07/R-08 recalculés au changement de niveau ; aucun cumul des deux sur la même unité.
- R-12 évalué par victime, sans priorité de ciblage supplémentaire.
- R-09 augmente maximum et PV actuels une seule fois ; les dégâts futurs restent normaux.
- R-10/R-11 sur les dépenses futures seulement ; investissement réel conservé pour les ventes.
- Comparer les bonus à même carte, faction, budget et composition, puis avec des compositions adaptées à chaque choix.
- Mesurer les fuites, les PV de forteresse, l’accès aux spécialisations et la réussite, en plus du DPS théorique.

Aucun essai jouable n’a validé ces réglages. Il faudra surveiller la supériorité éventuelle des bonus de prix acquis tôt, les emplacements centraux avec portée accrue et le poids de R-12 contre les dernières vagues.

<a id="s30"></a>

## 30 Cadre et diversité raciale des synergies

### Statut et périmètre
Les conditions, associations et règles de cumul sont approuvées — V ; noms provisoires et valeurs H. Aucun défenseur, classe, race, branche ou pouvoir actif n’est ajouté.

### Les trois mécanismes
Le socle valide trois axes : diversité de défenseurs d’une même race, choix de spécialisations et proximité entre certaines unités. La proposition les distingue :

| Axe | Condition de référence | Situation avec le roster actuel |
| --- | --- | --- |
| Diversité raciale | Au moins deux types de défenseurs distincts de la même race, déployés | Non activable : un seul type par race dans chaque faction |
| Proximité | Deux types partenaires dont les centres sont distants d’au plus 5 unités | Activable avec les défenseurs et emplacements existants |
| Spécialisations | Deux branches partenaires N4 présentes, sans condition de distance | Activable si le budget permet les deux spécialisations |

Les synergies s’activent automatiquement, sans coût ou choix supplémentaire. Elles ne permettent pas de mélanger les factions. Leurs effets restent actifs tant que leurs conditions sont réunies.

### Diversité raciale et prototype
Dans l’Alliance, les types actuels sont Archer elfe, Arbalétrier nain et Mage humain. Dans la Horde : Lanceur de haches troll, Sapeur gobelin et Chaman orc. Chaque race n’a donc qu’un type disponible.

Cadrage approuvé : conserver le volet racial, mais différer son activation jusqu’à l’approbation de plusieurs types d’une même race. Il ne fait pas partie des synergies activables à vérifier dans le premier prototype à six défenseurs. Cela n’approuve pas de nouvelles unités pour le rendre artificiellement accessible.

Contrat de conception approuvé pour cette activation future : deux types distincts déployés d’une même race donnent +8 % à tous les dégâts des défenseurs déployés de cette race, sans condition de distance. Un seul palier ; trois types ou plus ne donnent pas de gain supplémentaire dans ce contrat.

Compter l’identité du défenseur de base, pas son nombre d’exemplaires, son niveau ou sa branche. Deux archers elfes identiques, même spécialisés différemment, ne représentent pas deux types. Les deux exemplaires autorisés par type (seuil H) restent un seul type pour ce calcul. Aucun mélange de races ne satisfait ce seuil.

Le seuil et le gain restent H ; ce contrat devra être réexaminé avec le futur roster avant toute activation commerciale. Il ne valide ni un druide, ni des flèches empoisonnées.

<a id="s31"></a>

## 31 Synergies de proximité

### Proximité entre défenseurs
Distance approuvée : centre à centre, inférieure ou égale à 5 unités du plan logique. Elle est indépendante des portées d’attaque, rayons, rebonds et bonus R-03/R-05. Une portée augmentée ne crée donc pas un lien de proximité supplémentaire.

Aucune condition de niveau ou de branche pour ces six associations. Un défenseur peut bénéficier de plusieurs codes différents lorsque toutes leurs conditions sont remplies.

| Code | Partenaires requis à proximité | Effet de référence — H |
| --- | --- | --- |
| P-ALL-01 | Archer elfe + Arbalétrier nain | +8 % aux dégâts principaux directs des deux |
| P-ALL-02 | Archer elfe + Mage humain | Archer : +8 % aux dégâts principaux directs ; mage : +8 % aux dégâts secondaires |
| P-ALL-03 | Arbalétrier nain + Mage humain | Arbalétrier : +0,25 unité de portée principale ; mage : +6 % aux dégâts principaux directs |
| P-HOR-01 | Troll + Sapeur gobelin | +8 % aux dégâts secondaires de rebond et d’explosion, pour chacun |
| P-HOR-02 | Troll + Chaman orc | Troll : +8 % aux dégâts principaux directs ; chaman : +8 % à chaque dégât périodique |
| P-HOR-03 | Sapeur gobelin + Chaman orc | +8 % aux dégâts principaux directs des deux |

Les deux défenseurs d’une association reçoivent uniquement leur effet indiqué. Aucun bonus ne s’applique à toute la faction par simple présence d’une paire de proximité.

### Liens possibles sur La Vallée du Gué

À partir des coordonnées H approuvées, la distance de 5 unités autorise exactement les cinq paires d’emplacements suivantes, indépendamment de leur contenu :

| Paire | Distance calculée, affichée à trois décimales |
| --- | --- |
| E1 — E2 | 4,610 |
| E1 — E3 | 4,610 |
| E2 — E3 | 4,123 |
| E3 — E4 | 4,472 |
| E5 — E6 | 4,500 |

E3 — E5 mesure environ 5,025 unités et est donc exclue. Ne pas arrondir une distance à 5 avant de vérifier le seuil. Les dix autres paires d’emplacements ne satisfont pas la proximité de cette règle.

Le triangle E1/E2/E3 permet trois associations si les trois défenseurs distincts de la faction y sont installés. E2/E3/E4 n’en permet que deux, autour d’E3. E5/E6 offre une association près de la fin du trajet.

Ce résultat donne des choix de placement, mais peut renforcer excessivement le groupe de gauche. Comparer ses synergies au gain de couverture et à la défense finale avant de considérer le seuil comme équilibré.

<a id="s32"></a>

## 32 Synergies de spécialisations et budget

### Associations de branches
Deux branches partenaires N4 doivent être déployées. Aucune proximité n’est requise pour cet axe ; il récompense le choix de branches et l’investissement. Chaque branche du prototype figure dans une seule association de ce tableau.

| Code | Branches partenaires | Effet de référence — H |
| --- | --- | --- |
| S-ALL-01 | Veilleur des remparts + Sentinelle des tours | +0,25 unité de portée principale à chacun |
| S-ALL-02 | Tireur de volée + Arcaniste de concentration | +8 % aux dégâts principaux directs des deux |
| S-ALL-03 | Brise-siège + Maître des déflagrations | +6 % à toutes les composantes de dégâts des deux |
| S-HOR-01 | Fendeur de crânes + Chaman de guerre | +8 % aux dégâts principaux directs des deux |
| S-HOR-02 | Maître des ricochets + Artificier des foules | +8 % aux dégâts secondaires des deux |
| S-HOR-03 | Expert en démolition + Tisseur de malédictions | +6 % à toutes les composantes de dégâts des deux |

Les autres défenseurs ne bénéficient pas de cette association. Aucune branche n’est transformée ou débloquée par une synergie ; les choix N4 restent fixés jusqu’à la vente.

Une association de proximité et une association de spécialisations peuvent coexister sur les mêmes défenseurs. Leurs conditions sont vérifiées séparément. Un partenaire au N3 peut activer la proximité, mais ne peut jamais activer une association de spécialisations.

### Accès économique
Une association de proximité ne demande pas de niveau supplémentaire : seul le coût des deux achats et leur position comptent.

Sans bonus de prix :
- Les deux défenseurs à 50 et 75 or coûtent 125 or, dans les 150 or initiaux.
- Deux N4 distincts coûtent 725, 750 ou 775 or selon la paire, achat et améliorations compris.
- Les trois défenseurs distincts dont deux N4 et un N1 coûtent toujours 825 or. Le maximum brut avant le boss est de 816 or : il manque 9 or.
- Les trois défenseurs tous au N4 coûtent 1125 or. Ce total dépasse même les 920 or bruts maximaux de la partie, et les gains de la dernière vague ne financent pas les achats en combat.

Une composition à deux N4 est donc finançable avant le boss si le joueur renonce au troisième défenseur ou utilise des réductions de prix. Elle ne découle pas automatiquement du scénario initial, qui n’atteint qu’un N4.

Avec R-10 acquis avant toutes les améliorations de deux unités : 60 or d’économie, soit 665 or pour les N4 à 50 et 75 or, ou 765 or en ajoutant le troisième défenseur N1 à 100 or. Cette dernière composition devient finançable avant le boss ; la sélection de R-10 et les achats doivent réellement avoir eu lieu dans le bon ordre.

Les synergies ne modifient pas les revenus des vagues. Aucun or supplémentaire, niveau gratuit ou changement de prix non approuvé n’est ajouté.

<a id="s33"></a>

## 33 Cumul et recalcul des synergies

### Cumul et recalcul
- Pour un défenseur donné, chaque code de synergie s’applique au maximum une fois. Avoir plusieurs partenaires identiques ne multiplie pas ce même effet ; la limite de recrutement reste de deux exemplaires par type (H).
- Pour les copies autorisées, évaluer chaque bénéficiaire séparément selon ses propres partenaires et sa propre distance. Elles ne créent toujours pas de diversité raciale supplémentaire.
- Additionner les pourcentages de synergies aux pourcentages des bonus R déjà applicables à la même victime et à la même composante.
- Ajouter les gains de portée à la portée de référence de la branche, avec R-03. Ils ne changent ni distance de proximité, ni rayon secondaire, ni durée de malédiction.
- Ne pas augmenter la cadence du chaman. Les synergies de ce catalogue ne changent aucune cadence, échéance de malédiction, récompense ou dépense.
- Recalculer les conditions et les statistiques dérivées après construction, amélioration, choix de branche, vente et sélection d’un bonus. Repartir des valeurs de référence, sans ajouter les effets une seconde fois au résultat précédent.
- La vente retire le partenaire et les effets qui ne remplissent plus leurs conditions pendant cette même préparation. Elle ne modifie pas les dépenses historiques ni le remboursement à 70 % du montant payé.
- Aucun déplacement libre des défenseurs n’est introduit. Pendant une vague, leurs centres, niveaux et branches restent fixes et les conditions ne changent pas selon la position des ennemis.

Formule de dégâts étendue approuvée :

Dégât = référence de la composante × (1 + somme des bonus R applicables + somme des synergies applicables).

Le dégât secondaire reste calculé à partir de sa propre référence avant bonus. Une amélioration du dégât principal ne se transmet pas automatiquement au rebond, à l’explosion ou aux ticks. Une malédiction conserve la valeur calculée lors de son application, conformément au GDD.

Les résistances futures et les autres effets non définis restent ouverts.

<a id="s34"></a>

## 34 Calculs et essais des synergies

### Calculs de référence
| Situation | Résultat théorique |
| --- | --- |
| Archer N2 proche d’un arbalétrier et d’un mage, avec R-01 | 12 × (1 + 0,08 + 0,08 + 0,10) = 15,12 dégâts directs |
| Mage N1 proche d’un archer, avec R-04 | Secondaire : 10,8 × (1 + 0,08 + 0,20) = 13,824 par victime ; son dégât principal ne reçoit pas ces deux effets |
| Fendeur + Chaman de guerre proches, avec R-01 | Chaman : 58,5 × 1,18 = 69,03 directs ; chaque tick : 9,75 × 1,18 = 11,505 ; DPS complet 46,02 |
| Veilleur + Sentinelle présents, Sentinelle proche d’un mage, avec R-03 | Portée de Sentinelle : 6,5 + 0,25 + 0,25 + 0,5 = 7,5 |

Dans le troisième exemple, +8 % direct vient de S-HOR-01 et +8 % périodique vient de P-HOR-02 ; le même pourcentage total ne signifie pas le même effet. Dans le dernier, les deux gains de 0,25 viennent de S-ALL-01 et P-ALL-03.

Les présences et budgets nécessaires doivent être respectés. Ces exemples ne donnent pas gratuitement des niveaux ou des bonus et ne démontrent pas l’équilibre des compositions.

### Essais du prototype
Vérifications proposées :
1. Confirmer qu’aucune race du roster actuel ne peut remplir le seuil de deux types distincts.
2. Vérifier les cinq liens d’emplacement et l’exclusion E3/E5, sans utiliser la distance d’attaque.
3. Vérifier qu’un partenaire N1 active la proximité, mais pas une association N4.
4. Vérifier que chaque branche figure une seule fois dans les six associations de spécialisations.
5. Vérifier qu’un code ne se cumule pas plusieurs fois sur un même bénéficiaire et que les codes différents s’additionnent.
6. Vendre un partenaire et vérifier le retrait immédiat de l’effet ; recalculer sans dérive à chaque opération.
7. Vérifier les quatre calculs de référence avec les mêmes unités, branches et bonus.
8. Comparer le triangle de gauche au couple final E5/E6 sur les vagues 8 à 10, à budget égal.
9. Tester l’investissement en deux N4 avec et sans R-10, sans supposer une troisième unité gratuite.

Aucun essai jouable n’a validé ces règles ou les valeurs H. Les principaux risques sont la concentration des unités dans le triangle de gauche, la portée élevée de certaines combinaisons et l’accès tardif aux associations N4.

<a id="s35"></a>

## 35 Recrutement des exemplaires

Autoriser au maximum deux exemplaires déployés de chaque type de défenseur de base, dans la faction choisie, avec toujours six emplacements occupés au maximum.

Le type est Archer elfe, Arbalétrier nain, Mage humain, Lanceur de haches troll, Sapeur gobelin ou Chaman orc. Compter le type de base, quels que soient niveau et branche.

- Un troisième exemplaire du même type ne peut pas être acheté tant que deux sont déployés.
- Une vente libère immédiatement l’emplacement et une place dans la limite de ce type. Il n’existe pas de quota d’achats cumulés pendant la partie.
- Les exemplaires ont des niveaux, investissements, choix de branches et délais de tir indépendants. Ils utilisent les mêmes statistiques de référence à niveau et branche identiques.
- Chaque achat crée un défenseur N1, sans branche choisie. Les bonus de partie déjà acquis lui sont applicables selon leurs conditions.
- Deux exemplaires N4 peuvent choisir la même branche ou des branches différentes ; ils restent deux exemplaires du même type.
- Le recrutement exige à la fois un emplacement libre, une place dans la limite et assez d’or au prix courant. Une tentative impossible ne consomme pas d’or.
- Le joueur recrute dans le roster de sa faction. Aucun mélange de factions, réserve hors carte ou fusion d’unités n’est ajouté.

Le choix de deux copies permet de remplir les six emplacements avec les trois types du prototype, tout en limitant la répétition du défenseur le moins cher. Le seuil reste H : tester son intérêt avant de le traiter comme une règle commerciale définitive.

<a id="s36"></a>

## 36 Copies synergies et nouvelle construction

Les règles approuvées de la v0.12 continuent de s’appliquer :
- Deux exemplaires identiques ne créent jamais deux types pour la diversité raciale. Le volet racial reste donc non activable avec ce roster.
- Pour chaque bénéficiaire, un code de synergie ne s’applique qu’une fois, même si plusieurs partenaires satisfont sa condition.
- Deux exemplaires d’un même bénéficiaire peuvent chacun recevoir leur propre effet si leurs conditions sont remplies.
- Vendre un partenaire retire l’effet uniquement lorsqu’aucun autre partenaire admissible ne maintient la condition.
- Une association N4 exige les branches requises ; deux branches différentes d’un même type ne constituent pas à elles seules une association non listée.

Exemple : archer en E1, second archer en E2 et arbalétrier en E3. Les deux archers sont à moins de 5 unités de l’arbalétrier. P-ALL-01 donne +8 % directs à chaque archer et +8 % à l’arbalétrier, une seule fois pour chacun. Sans autre effet, un archer N1 inflige 8,64 et l’arbalétrier N1 25,92 par tir. Vendre un archer laisse l’effet actif pour l’arbalétrier tant que l’autre reste admissible.

Les attaques simultanées conservent le choix des cibles sur un état commun : deux copies peuvent gaspiller des tirs sur la même cible. Les malédictions de deux chamans restent indépendantes, et chaque ennemi éliminé ne rapporte toujours qu’une récompense. Aucune optimisation automatique des tirs n’est ajoutée.

### Vente et nouvelle construction
Une vente retire cet exemplaire et son niveau. Un achat ultérieur, sur cet emplacement ou un autre emplacement libre, repart au N1. Il ne récupère ni les améliorations ni la branche de l’exemplaire vendu.

Le prototype ne propose pas de déplacement gratuit ou d’échange de positions. Changer l’emplacement d’une unité passe par la vente et un nouvel achat, entre les vagues. La perte économique doit être visible dans le montant de remboursement avant la vente ; la présentation exacte reste à concevoir.

Exemple sans bonus : vendre un archer N4 acheté et amélioré pour 350 rend 245. Reconstituer un archer N4 coûte 350 : il faut 105 or nets supplémentaires. Cela permet de changer sa branche après une vente, en payant les coûts normaux et sans réinitialisation gratuite.

La vente recalcule les synergies pendant la préparation. Les bonus roguelite sélectionnés restent acquis pour la partie et s’appliquent aux nouvelles unités selon leurs règles. La forteresse ne perd pas les PV maximum de R-09 lorsqu’une unité est vendue.

<a id="s37"></a>

## 37 Vente et remboursements

Calculer pour chaque exemplaire vendu :

Remboursement = partie entière inférieure de (total réellement payé × 70 / 100).

Additionner d’abord l’achat et toutes les améliorations payées pour cet exemplaire ; appliquer les 70 % ; arrondir une seule fois, à la fin de cette vente. Ne pas arrondir séparément chaque dépense historique.

Le résultat est crédité immédiatement à l’or disponible, en entier. Le prix de rachat courant et les bonus acquis plus tard ne modifient pas l’investissement historique.

Deux ventes successives sont deux calculs distincts. Exemple : deux arbalétriers N1 achetés 75 chacun rendent 52 + 52 = 104 or, et non 105. Ne pas fusionner leurs investissements avant l’arrondi.

Les dégâts et PV conservent leurs fractions selon le GDD. Cette règle d’or ne s’applique pas aux statistiques de combat. L’arrondi des achats réduits reste à l’entier supérieur, comme déjà approuvé.

### Référence sans bonus de prix

| Prix d’achat du type | Investi N1 / vente | Investi N2 / vente | Investi N3 / vente | Investi N4 / vente |
| --- | --- | --- | --- | --- |
| 50 or — Archer ou Troll | 50 / 35 | 100 / 70 | 200 / 140 | 350 / 245 |
| 75 or — Arbalétrier ou Sapeur | 75 / 52 | 125 / 87 | 225 / 157 | 375 / 262 |
| 100 or — Mage ou Chaman | 100 / 70 | 150 / 105 | 250 / 175 | 400 / 280 |

Les améliorations coûtent toujours 50, 100 et 150 or avant bonus. Ces montants restent H ; le tableau applique le taux de 70 % existant et l’arrondi nouvellement validé.

### Référence avec réductions

| Historique réel de cet exemplaire | Total payé | Vente |
| --- | --- | --- |
| Archer N1 acheté avec R-11 | 45 | 31 |
| Arbalétrier N1 acheté avec R-11 | 68 | 47 |
| Mage N1 acheté avec R-11 | 90 | 63 |
| Arbalétrier N4, R-11 avant achat et R-10 avant toutes les améliorations | 68 + 45 + 90 + 135 = 338 | 236 |
| Arbalétrier N1 acheté avant l’acquisition de R-11 | 75 | 52 |

Le dernier cas rappelle l’absence d’effet rétroactif. Le bonus R-11 peut réduire le prix d’un prochain arbalétrier à 68, mais l’exemplaire déjà acheté conserve son investissement de 75.

Pour tout investissement positif, le remboursement demeure inférieur au montant payé. Acheter puis vendre ne crée donc pas d’or dans ce cadre ; une réduction ultérieure ne réécrit jamais une dépense passée.

<a id="s38"></a>

## 38 Compositions et budgets des copies

| Composition initiale sans bonus | Dépense | Solde sur 150 or | Admissible |
| --- | --- | --- | --- |
| Deux défenseurs à 50 or du même type | 100 | 50 | Oui, deux copies |
| Trois défenseurs à 50 or du même type | 150 | 0 | Non, limite de deux dépassée |
| Deux défenseurs à 75 or du même type | 150 | 0 | Oui, deux copies |
| Un défenseur à 75 et un à 50 | 125 | 25 | Oui |
| Un défenseur à 100 et un à 50 | 150 | 0 | Oui |

Trois exemplaires du même type ne sont pas admissibles ; la section 7 présente les compositions de référence corrigées.

Deux exemplaires de chaque type au N1 remplissent les six emplacements et coûtent 450 or, sans réduction ni vente. Avec toutes les éliminations, cette dépense devient finançable après la vague 6 : 480 or bruts, soit 30 de solde si aucun autre achat ou amélioration n’a été effectué. Avant cela, le budget brut maximal après la vague 5 est de 398.

Le DPS théorique de ces six N1 sur une cible est de 2 × (8 + 9,6 + 10,8) = 56,8, hors bonus et synergies, pour chaque faction. Le chaman exige ses cycles complets. Ce calcul ne prédit pas les dégâts effectifs ni la victoire.

À comparer au scénario du GDD avant le boss : trois défenseurs distincts N4/N3/N2, 725 or investis et 63,8 DPS théoriques sur une cible avant spécialisation. Les budgets, nombres d’emplacements, portées et attaques de groupe diffèrent. Les synergies peuvent modifier ces résultats.

Les six emplacements donnent une capacité de composition, pas la promesse de six N4. Deux exemplaires de chaque type au N4 coûteraient 2250 or sans bonus, largement au-delà des 920 or bruts maximaux de la partie. Les revenus de la dernière vague ne financent toujours aucun achat pendant son combat.

<a id="s39"></a>

## 39 Vérifications du recrutement et des ventes

| Cas | Résultat attendu |
| --- | --- |
| Deux copies déjà déployées, tentative d’achat d’une troisième | Achat impossible, aucun débit d’or |
| Vente d’une des deux copies, puis achat avec assez d’or | Achat à nouveau possible ; nouvel exemplaire N1 |
| Deux copies choisissent deux branches N4 différentes | Choix autorisés ; toujours deux exemplaires d’un seul type |
| Plusieurs partenaires identiques pour une même synergie | Un seul effet du code par bénéficiaire |
| Vente d’un partenaire, un autre partenaire admissible reste | Effet conservé pour les bénéficiaires encore éligibles |
| Arbalétrier payé 75, revendu sans amélioration | Crédit de 52 or |
| Deux arbalétriers payés 75 chacun, vendus successivement | Crédit total de 104 or |
| Arbalétrier payé 68, puis améliorations payées 45, 90 et 135 | Investissement 338 ; crédit de 236 or |
| R-11 sélectionné après l’achat d’une unité | Dépense passée et remboursement historique inchangés |
| Vente et rachat d’un défenseur spécialisé | Niveau et branche remis au N1 sans spécialisation ; bonus de partie conservés |
| Vente pendant une vague | Interdite selon le GDD |
| Tentative de troisième copie après achat des deux premières branches | Toujours interdite : la limite compte le type de base |

Ces cas sont des vérifications futures. Aucun prototype jouable n’a encore mesuré le rendement des copies, la difficulté ou l’équilibre des ventes.

<a id="s40"></a>

## 40 Présentation interface et validation du prototype

### Direction visuelle
L’univers médiéval-fantasy coloré et la vue isométrique de La Vallée du Gué constituent les références établies. Les deux illustrations figurant dans l’ancien échange sont des références d’ambiance, pas des assets définitifs ni une validation de leurs droits d’exploitation.

Les détails de production graphique, d’animation, de musique et de son ne sont pas définis. Le GDD ne fixe pas de technique 2D ou 3D à partir de la seule vue isométrique.

### Interface et lisibilité
Observer les combats, inspecter ses unités et accélérer le déroulement sont des interactions validées. L’interface de combat reste à concevoir. Les besoins d’information suivants sont proposés — P — pour rendre les systèmes existants compréhensibles, sans figer de maquette.

| Situation | Information à rendre compréhensible |
| --- | --- |
| Préparation | Or disponible, achat, niveau, coût d’amélioration et montant de vente |
| Combat | État de la forteresse, vague en cours et effet de l’accélération |
| Choix roguelite | Trois propositions et effet de chacune |
| Composition | Race, classe, spécialisation et conditions de synergie |

Les raccourcis, commandes exactes, multiplicateurs de vitesse, options d’accessibilité, pause et modalités de sauvegarde restent ouverts. Ces sujets ne sont pas des fonctionnalités approuvées par défaut.

### Cadre technique
Godot est le moteur envisagé et PC sur Steam la plateforme prioritaire. La version du moteur, le langage, l’organisation des scènes et le format des données restent ouverts. Aucun support multijoueur, mobile, console ou intégration de service supplémentaire n’est ajouté.

### Vérifications proposées avant extension du contenu
- Vérifier que construction, amélioration et vente sont bloquées pendant les combats.
- Vérifier les six coûts/DPS de référence, les trois paliers d’amélioration et le déblocage des deux branches au niveau 4.
- Vérifier le remboursement à 70 % selon la règle d’arrondi retenue et le recalcul des synergies après vente.
- Vérifier trois propositions aux vagues 3, 6 et 9 et la conservation des bonus jusqu’à la fin de la partie.
- Évaluer le plaisir de jeu, la lisibilité, la différence entre factions et l’économie, conformément à l’objectif du prototype.

Ces vérifications constituent un plan de validation — P. Les objectifs de performance, configurations matérielles et seuils d’acceptation chiffrés restent à définir.

<a id="s41"></a>

## 41 Périmètre commercial et feuille de route

### Comparaison des périmètres envisagés
| Élément | Prototype | Objectif commercial |
| --- | --- | --- |
| Factions | 2 | 2 |
| Défenseurs | 6, soit 3 par faction | 16, soit 8 par faction |
| Spécialisations | Deux branches débloquées au niveau 4 | Deux par défenseur |
| Cartes | 1 | 6 |
| Vagues | 10 | À définir par carte |
| Bonus roguelite | Douze, valeurs H | Environ 60 |
| Ennemis ordinaires | 7 archétypes, hors boss | Environ 12 familles |
| Boss | 1 | Environ 6 |
| Mode infini | Absent du prototype | Envisagé |

Ces objectifs sont des cibles de contenu — C — et non des engagements de production. Ils seront ajustés selon le temps de développement et les tests. Le modèle premium et le prix de 7,99 € sont envisagés ; la commercialisation, le budget, les ventes attendues et le calendrier ne sont pas arrêtés.

### Feuille de route proposée
| Jalon | Travail à effectuer | Condition de passage proposée |
| --- | --- | --- |
| J0 — Préparer | Définir le cahier de réalisation et les choix techniques | Plan de réalisation examiné |
| J1 — Construire | Carte du Gué, six emplacements, deux factions, six défenseurs | Boucle de préparation et combat jouable |
| J2 — Compléter | Dix vagues, économie, niveaux, spécialisations et bonus | Partie jouable du début à la fin |
| J3 — Tester | Lisibilité, factions, économie et durée | Résultats consignés et corrections priorisées |
| J4 — Réviser le périmètre | Examiner la cible commerciale selon les essais | Contenu, charge et priorités explicitement confirmés |

La feuille de route est une proposition d’organisation — P. Aucun délai, budget, responsable ou engagement de livraison n’est supposé. L’extension vers six cartes et seize défenseurs dépend de la validation du prototype.

### Nom de travail
For the Fortress! reste un nom de travail. Sa disponibilité juridique doit être confirmée avant de le retenir pour une commercialisation. Aucune recherche de marque, de titre de jeu ou de nom de domaine n’est réputée accomplie par ce GDD. Les noms de factions restent également provisoires.

<a id="s42"></a>

## 42 Registre des décisions

### Décisions de référence
| Identifiant | Décision | Statut |
| --- | --- | --- |
| DEC-001 | Solo fantasy ; deux factions distinctes | V |
| DEC-002 | Chemins fixes, emplacements prédéfinis, attaques automatiques | V |
| DEC-003 | Achat, amélioration et vente entre les vagues seulement | V |
| DEC-004 | Niveau maximum 4 ; choix entre deux spécialisations | V |
| DEC-005 | Un bonus parmi trois, actif jusqu’à la fin de la partie | V |
| DEC-006 | Diversité raciale, spécialisations et proximité pour les synergies | V |
| DEC-007 | Vente à 70 % du total investi et recalcul des synergies | V |
| DEC-008 | Choix roguelite après les vagues 3, 6 et 9 du prototype | V |
| DEC-009 | Rôles Alliance N1 et attaque de groupe du mage ; valeurs initiales en section 5 | V / H |
| DEC-010 | Cibler l’ennemi à portée le plus avancé ; nouvelle cible avant le prochain tir | V |
| DEC-011 | Essai N1 sans résistances, bonus raciaux ni spécialisations | V |
| DEC-012 | Horde N1 : rebond, explosion et malédiction ; réglages en section 6 | V / H |
| DEC-013 | Victimes secondaires : priorité aux plus proches du point d’impact | V |
| DEC-014 | Sept archétypes ordinaires et boss distinct en vague 10 ; valeurs en section 9 | V / H |
| DEC-015 | Or immédiat et unique à l’élimination ; aucun or en cas d’arrivée ; pas de prime de vague | V |
| DEC-016 | Séquence des dix vagues et accompagnants du boss ; quantités et intervalles H | V / H |
| DEC-017 | Première apparition à t = 0 ; séparation des groupes de 4 secondes H | V / H |
| DEC-018 | Fin de vague après toutes les apparitions et résolutions ; victoire après vague 10 si survie | V |
| DEC-019 | Progression de dégâts seuls ; courbe N1 × 1 / 1,5 / 2,25 / 3,25 | V / H |
| DEC-020 | Progression de base : même facteur sur tous les dégâts ; cadence et portée inchangées | V |
| DEC-021 | Choix N4 inclus, exclusif, fixé jusqu’à la vente ; accessible dès les essais | V |
| DEC-022 | Douze branches et rebonds successifs distincts du troll ; valeurs H | V / H |
| DEC-023 | Géométrie du Gué, distances et circulation sans blocage ; valeurs H | V / H |
| DEC-024 | Premier tir prêt, ciblage déterministe, impacts instantanés, malédictions hors portée | V |
| DEC-025 | Ticks avant tirs simultanés, puis arrivées ; récompense unique et défaite prioritaire | V |
| DEC-026 | Douze bonus, trois offres distinctes ; poids égaux, bonus choisis exclus | V / H |
| DEC-027 | Cumul par composante, chaman sans R-02, PV et réductions de prix définis | V / H |
| DEC-028 | Synergies de proximité et N4, cumul et recalcul ; volet racial différé | V / H |
| DEC-029 | Exemplaires indépendants ; limite de deux par type déployé (H) | V / H |
| DEC-030 | Vente : total réellement payé, 70 %, arrondi inférieur par exemplaire ; rachat N1 | V |

<a id="s43"></a>

## 43 Questions ouvertes et suivi

| Identifiant | Décision attendue | Dépendance principale |
| --- | --- | --- |
| O-001 | Types et résistances futures | Combat et statistiques par niveau |
| O-002 | Équilibrage des récompenses et de la limite de deux copies | Économie et recrutement |
| O-003 | Noms définitifs, interface du choix et équilibre des branches | Niveau 4 et synergies |
| O-006 | Équilibrage des vagues et capacités futures du boss | Partie complète |
| O-007 | Progression entre les parties et interface de combat | Expérience globale |
| O-008 | Moteur, prix final, périmètre commercial et nom | Plan de production |

<a id="s44"></a>

## 44 Sources et historique du GDD

### Sources et historique
S1 — GDD v0.1 dans « Texte collé.txt ». S2 — Cinq captures concordantes. S3 — Demande des livrables. S4 — Combat Alliance approuvé par « oui on fait comme ca ». S5 — Combat Horde approuvé par « très bien ». S6 — Ennemis, boss et récompenses approuvés par « ok pour ca ». S7 — Séquence des vagues et fiche détaillée approuvées par « ok go avec ca ». S8 — Progression approuvée par « ok on part la dessus ». S9 — Spécialisations approuvées par « on continu ». S10 — Géométrie du Gué approuvée par « ok on continu ». S11 — Résolution du combat approuvée par « ok c’est bon ». S12 — Bonus roguelite approuvés par « ok on continu ». S13 — Synergies approuvées par « ok on continu ». S14 — Recrutement et vente approuvés par « ok on continu ». Le lien partagé reste une référence d’origine.

Version 0.2 — 19 octobre 2026 : consolidation, statuts, calculs dérivés et feuille de route proposée ; aucune nouvelle fonctionnalité validée.

Version 0.3 — 19 octobre 2026 : combat Alliance N1, ciblage et essai initial validés par S4.

Version 0.4 — 19 octobre 2026 : combat Horde N1 et priorité des victimes secondaires validés par S5.

Version 0.5 — 19 octobre 2026 : sept archétypes, boss en vague 10 et règles de récompense validés par S6 ; statistiques H conservées.

Version 0.6 — 20 octobre 2026 : dix vagues, horaires, revenus et scénario de dépenses intégrés après validation S7 ; calculs dérivés distingués.

Version 0.7 — 20 octobre 2026 : progression N1 à N4, dégâts secondaires et coûts cumulés intégrés après validation S8.

Version 0.8 — 20 octobre 2026 : douze spécialisations et règles du choix intégrées après validation S9 ; noms provisoires.

Version 0.9 — 20 octobre 2026 : tracé du Gué, six emplacements, distances et circulation intégrés après validation S10 ; dimensions H et mesures dérivées distinguées.

Version 0.10 — 20 octobre 2026 : premier tir, ciblage, impacts instantanés, effets hors portée et ordre de résolution intégrés après validation S11 ; douze cas de référence ajoutés.

Version 0.11 — 20 octobre 2026 : douze bonus et règles de tirage, cumul, cadence, PV et prix intégrés après validation S12.

Version 0.12 — 20 octobre 2026 : proximité, associations N4, cumul et recalcul intégrés après validation S13 ; volet racial conservé sans activation et valeurs H maintenues.

Version 0.13 — 20 octobre 2026 : copies indépendantes, limite H de deux par type, remboursements entiers par exemplaire et budgets intégrés après validation S14.

<a id="s45"></a>

## 45 Maintenance du GDD

### Procédure de mise à jour proposée
Le Markdown est la référence éditoriale ; le Word en est la présentation. Actualiser les deux ensemble. Consigner identifiant, date, ancienne et nouvelle règle, statut, source et impact. Une hypothèse ou question ouverte devient validée uniquement après confirmation explicite du porteur du projet.

### Fiche de modification proposée
| Champ | Information à conserver |
| --- | --- |
| Référence | Identifiant DEC ou O concerné et version du GDD |
| Évolution | Ancienne règle, nouvelle règle et motif |
| Statut | V, H, C, O ou P ; date et source de confirmation |
| Incidences | Défenseurs, économie, vagues ou autres règles concernés |
| Vérification | Essai prévu, résultat observé et ajustement éventuel |

Conserver le statut H jusqu’aux essais d’équilibrage. Une validation de principe confirme le comportement, pas sa puissance. Consigner carte, vagues, unités, réglages et résultats pour comparer les essais.
