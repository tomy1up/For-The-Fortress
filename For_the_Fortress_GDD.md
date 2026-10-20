# For the Fortress!

Game Design Document — Version 0.7 — 20 octobre 2026

Document de référence pour concevoir, prototyper et faire évoluer le jeu. Cette version consolide le GDD v0.1 fourni, ses cinq captures et les règles de combat des deux factions, les ennemis, les récompenses les dix vagues et la progression par niveau approuvés ensuite. Elle conserve les choix établis, les valeurs provisoires et les questions ouvertes, tout en ajoutant des outils de suivi explicitement proposés.

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
14. [14 Présentation interface et validation du prototype](#s14)
15. [15 Périmètre commercial et feuille de route](#s15)
16. [16 Registre des décisions](#s16)
17. [17 Sources et maintenance du GDD](#s17)

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
La destruction de la forteresse met fin à la partie — V. Les dégâts d’arrivée sont définis par ennemi en section 9, avec des valeurs H ; le traitement des arrivées simultanées reste ouvert. La victoire survient lorsque la vague 10 est entièrement résolue et que la forteresse survit — V. Les règles de résolution figurent en section 10.

Le tracé détaillé, les distances et les positions des six emplacements restent ouverts. Les portées initiales des deux factions figurent en sections 5 et 6 ; leur échelle reste à calibrer. Aucun placement libre n’est ajouté.

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

La version commerciale envisage huit défenseurs par faction, chacun doté de deux spécialisations — C. Les dix défenseurs supplémentaires, leurs races, leurs classes et leurs branches restent à définir. La possibilité de mélanger les deux factions dans une même partie n’est pas spécifiée — O.

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

La lecture séquentielle des trois coûts correspond aux trois améliorations jusqu’au niveau 4. La progression approuvée augmente uniquement les dégâts : × 1,5 au N2, × 2,25 au N3 et × 3,25 au N4, relativement au N1 — valeurs H. Cadence, portée, rayons, plafonds de victimes et horaires des effets restent inchangés — V. Les tableaux complets figurent en sections 12 et 13. Il n’existe pas de statistique finale de spécialisation validée.

### Paramètres manquants
| Domaine | Données à définir — O |
| --- | --- |
| Attaque | Comportements en sections 5 et 6 ; valeurs N1 à N4 en section 12 |
| Résolution des dégâts | Types, résistances hors essai initial, ordre de calcul et arrondis |
| Spécialisations | Noms, effets, conditions et éventuel coût distinct |
| Niveaux | Interaction et ordre de calcul avec les bonus roguelite |

Un coût distinct de spécialisation ne doit pas être supposé nul ni ajouté sans décision. Les effets ne sont pas déduits des seuls noms de classe. Les dégâts secondaires du mage constituent une décision explicite documentée en section 5 ; critiques, soins, invocations et contrôle restent non définis.

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

Les distances n’imposent pas de grille de placement. L’échelle de l’unité de carte sera calibrée sur La Vallée du Gué — O. DPS = dégâts par attaque ÷ intervalle entre attaques ; il s’agit d’un débit théorique en régime continu, sans déplacement de cible ni temps perdu.

### Rôles et comportements validés
L’archer elfe est une défense économique à cadence régulière. Il tire sur une seule cible, sans effet secondaire au niveau 1. Sa faiblesse est l’absence de dégâts de zone et des dégâts modestes par tir.

L’arbalétrier nain est un tireur lent à longue portée. Il touche une seule cible ; les dégâts dépassant les PV restants sont perdus. Le premier essai ne lui attribue ni perforation ni bonus contre les armures. Sa faible cadence rend un tir gaspillé plus pénalisant.

Le mage humain est spécialisé contre les groupes, avec une portée plus courte. Sa cible principale reçoit 27 dégâts. Jusqu’à deux autres ennemis situés à moins d’une unité du point d’impact reçoivent chacun 40 % des dégâts principaux, soit 10,8 dégâts. Chaque ennemi reçoit au maximum une application par attaque. Le rayon, le plafond et le coefficient sont des réglages H ; le principe de cette attaque est V.

Le DPS total théorique du mage atteint (27 + 10,8 + 10,8) ÷ 2,5 = 19,44 lorsque trois ennemis sont constamment regroupés. Cette valeur dérivée ne remplace pas son DPS de 10,8 sur une cible.

### Règles communes validées pour le premier essai
- Cibler automatiquement l’ennemi à portée le plus avancé sur le chemin vers la forteresse.
- Commencer une attaque uniquement avec une cible valide à portée ; sélectionner une nouvelle cible si la précédente est éliminée avant le prochain tir.
- Tester sans réduction de dégâts liée aux résistances, sans bonus raciaux et sans spécialisations, afin de comparer les niveaux 1.

Les victimes secondaires les plus proches du point d’impact sont prioritaires — V. Les égalités de ciblage, le premier délai de tir, les projectiles en vol et la règle de portée à l’impact restent ouverts. Le premier test comparera des ennemis isolés puis regroupés sur le même tronçon de route ; aucun test jouable n’est encore réalisé.

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

L’unité de distance est commune aux factions et reste à calibrer. Les DPS supposent des attaques continues et des cibles survivant assez longtemps.

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
La cible principale reste l’ennemi à portée le plus avancé. Pour les rebonds et explosions, priorité aux victimes secondaires les plus proches du point d’impact — V ; égalités ouvertes. Comparer les deux factions sur la même carte avant de conclure à leur équilibre.

<a id="s7"></a>

## 7 Économie et calculs de référence

### Règles et paramètres
L’or finance les achats et les améliorations — V. Pour le premier essai, chaque élimination rapporte immédiatement une récompense unique, selon le tableau de la section 9. Les montants sont H. Le capital initial de référence est de 150 or — H. Aucun revenu passif ni monnaie supplémentaire n’est validé.

### Récompenses validées pour le premier essai
- Créditer l’or immédiatement à la mort d’un ennemi, une seule fois, y compris après des dégâts de malédiction.
- Appliquer les mêmes récompenses aux deux factions.
- Lorsqu’un ennemi atteint la forteresse, appliquer ses dégâts puis le retirer de la partie, sans récompense.
- Ne pas attribuer de prime de fin de vague pendant ce premier essai.

Une unité peut être vendue uniquement entre les vagues contre 70 % de l’or total investi — V. Les synergies sont alors recalculées — V. La règle d’arrondi et le traitement d’éventuels modificateurs de prix restent à préciser — O.

### Achat et améliorations cumulés
Le total au niveau 4 ci-dessous additionne l’achat et les trois coûts provisoires de 50, 100 et 150 or. Il exclut tout éventuel coût distinct de spécialisation, encore ouvert. Les remboursements sont des calculs à 70 %, avant toute règle d’arrondi.

| Défenseurs concernés | Investi N1 | Investi N4 | Vente N1 / N4 |
| --- | --- | --- | --- |
| Archer elfe ; Lanceur de haches troll | 50 | 350 | 35 / 245 |
| Arbalétrier nain ; Sapeur gobelin | 75 | 375 | 52,5 / 262,5 |
| Mage humain ; Chaman orc | 100 | 400 | 70 / 280 |

Formules dérivées : investissement = achat + améliorations payées ; remboursement théorique = investissement × 0,70. La perte théorique lors d’une vente représente 30 % de cet investissement. Ces calculs dépendent des hypothèses de coût et n’attestent pas leur équilibre.

### Exemples de budget initial
| Composition dans une seule faction | Dépense en or | Solde sur 150 or |
| --- | --- | --- |
| Trois défenseurs à 50 | 150 | 0 |
| Deux défenseurs à 75 | 150 | 0 |
| Un défenseur à 100 et un à 50 | 150 | 0 |
| Un défenseur à 75 et un à 50 | 125 | 25 |

Ces exemples vérifient seulement l’arithmétique. La duplication d’un même type d’unité n’est pas explicitement encadrée dans le socle ; les deux premières compositions dépendent donc de cette décision — O. Aucune composition n’est présentée comme stratégie optimale.

### Décisions d’équilibrage à prendre
Tester les gains par ennemi retenus en section 9, décider l’arrondi des ventes et les éventuelles limites de recrutement. Les plafonds de revenus et un scénario de dépenses figurent en sections 10 et 11. Vérifier en jeu les choix entre élargir une défense et atteindre une spécialisation ; les gains réels dépendent des éliminations.

<a id="s8"></a>

## 8 Bonus roguelite et synergies

### Améliorations pendant une partie
Après certaines vagues, le joueur choisit une amélioration parmi trois propositions aléatoires — V. Les bonus obtenus restent actifs jusqu’à la fin de la partie — V. Pour le prototype, les sélections ont lieu après les vagues 3, 6 et 9 — V, soit trois moments de choix.

Le catalogue du prototype est une sélection réduite — C ; aucun nombre précis ni bonus détaillé n’est fourni. La cible commerciale est d’environ 60 bonus — C. Une sélection de trois propositions ne signifie pas que la sélection de doublons, les relances ou les raretés sont approuvées.

| Règle de génération | État |
| --- | --- |
| Trois propositions par choix | V |
| Tirage aléatoire | V |
| Poids, raretés et conditions d’éligibilité | O |
| Doublons dans un tirage et entre tirages | O |
| Cumul et ordre d’application des effets | O |
| Comportement si moins de trois bonus sont éligibles | O |

### Les trois mécanismes de synergie
| Mécanisme validé | Intention | Règles ouvertes |
| --- | --- | --- |
| Diversité de défenseurs d’une même race | Récompenser une composition raciale diversifiée | Décompte des unités distinctes, seuils et effets |
| Spécialisations | Créer des interactions entre choix de branches | Combinaisons, cumul et exclusivité |
| Proximité entre certaines unités | Valoriser la disposition des défenseurs | Distance, voisinage, nombre de bénéficiaires |

La diversité ne doit pas être assimilée automatiquement au nombre total d’unités d’une race. La présence de copies, les conditions de seuil et la relation entre classe et diversité restent à définir.

### Exemple non contractuel
Le socle illustre une interaction possible par un archer elfe placé près d’un druide qui pourrait recevoir des flèches empoisonnées. Cet exemple n’approuve ni le druide comme défenseur, ni une valeur de poison, ni une portée de voisinage. Il sert uniquement à expliquer le principe.

### Recalcul et progression persistante
Le recalcul des synergies après une vente est validé. Les déclencheurs après construction, amélioration, spécialisation ou retrait d’un bonus doivent être explicités — O. La progression entre les parties demeure ouverte : aucune monnaie persistante, arbre de talents ou amélioration permanente n’est approuvé.

<a id="s9"></a>

## 9 Ennemis et boss du prototype

### Périmètre et statut des valeurs
Sept archétypes ordinaires et un boss distinct sont retenus pour le prototype — V. Leurs noms restent provisoires. Les PV, vitesses, dégâts à la forteresse et récompenses sont des réglages initiaux — H. Les premiers essais distinguent les ennemis par leur endurance, leur vitesse et leur nombre, sans résistances ni capacités spéciales supplémentaires.

### Statistiques initiales
Les vitesses utilisent l’unité de carte commune aux portées des défenseurs, dont l’échelle reste à calibrer. La récompense est exprimée en pièces d’or et créditée uniquement à l’élimination. Tous les nombres de ce tableau sont H.

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
Exemple pour les trois défenseurs distincts de chaque faction, sans vente ni doublon et avec toutes les éliminations. Les soldes incluent les vagues intermédiaires sans achat. Les prix restent H ; le scénario démontre seulement la capacité de financement.

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
Pièces d’or, achat et améliorations compris ; hors éventuel coût distinct de spécialisation. Les trois passages coûtent 50, 100 et 150 or.

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
Pour l’archer, les améliorations coûtent 50 or pour +4 DPS, 100 or pour +6 et 150 or pour +8 et le choix de spécialisation. Le rendement marginal diminue ; les six emplacements et les branches doivent rendre la concentration de puissance intéressante. La possibilité de recruter des copies reste ouverte.

Le scénario de la section 11 investit 350 + 225 + 150 = 725 or avant le boss, avec un solde maximal de 91 or. La fiche design/Proposition_progression_niveaux.md rassemble les calculs. Les noms, effets et éventuel coût distinct des branches restent ouverts.

<a id="s14"></a>

## 14 Présentation interface et validation du prototype

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

<a id="s15"></a>

## 15 Périmètre commercial et feuille de route

### Comparaison des périmètres envisagés
| Élément | Prototype | Objectif commercial |
| --- | --- | --- |
| Factions | 2 | 2 |
| Défenseurs | 6, soit 3 par faction | 16, soit 8 par faction |
| Spécialisations | Deux branches débloquées au niveau 4 | Deux par défenseur |
| Cartes | 1 | 6 |
| Vagues | 10 | À définir par carte |
| Bonus roguelite | Sélection réduite | Environ 60 |
| Ennemis ordinaires | 7 archétypes, hors boss | Environ 12 familles |
| Boss | 1 | Environ 6 |
| Mode infini | Absent du prototype | Envisagé |

Ces objectifs sont des cibles de contenu — C — et non des engagements de production. Ils seront ajustés selon le temps de développement et les tests. Le modèle premium et le prix de 7,99 € sont envisagés ; la commercialisation, le budget, les ventes attendues et le calendrier ne sont pas arrêtés.

### Feuille de route proposée
| Jalon | Travail à effectuer | Condition de passage proposée |
| --- | --- | --- |
| J0 — Clarifier | Finaliser les spécialisations, les synergies et les distances | Règles nécessaires au prototype documentées |
| J1 — Construire | Carte du Gué, six emplacements, deux factions, six défenseurs | Boucle de préparation et combat jouable |
| J2 — Compléter | Dix vagues, économie, niveaux, spécialisations et bonus | Partie jouable du début à la fin |
| J3 — Tester | Lisibilité, factions, économie et durée | Résultats consignés et corrections priorisées |
| J4 — Réviser le périmètre | Examiner la cible commerciale selon les essais | Contenu, charge et priorités explicitement confirmés |

La feuille de route est une proposition d’organisation — P. Aucun délai, budget, responsable ou engagement de livraison n’est supposé. L’extension vers six cartes et seize défenseurs dépend de la validation du prototype.

### Nom de travail
For the Fortress! reste un nom de travail. Sa disponibilité juridique doit être confirmée avant de le retenir pour une commercialisation. Aucune recherche de marque, de titre de jeu ou de nom de domaine n’est réputée accomplie par ce GDD. Les noms de factions restent également provisoires.

<a id="s16"></a>

## 16 Registre des décisions

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
| DEC-011 | Essai N1 sans résistances, bonus raciaux ni spécialisations | V — essai initial |
| DEC-012 | Horde N1 : rebond, explosion et malédiction ; réglages en section 6 | V / H |
| DEC-013 | Victimes secondaires : priorité aux plus proches du point d’impact | V |
| DEC-014 | Sept archétypes ordinaires et boss distinct en vague 10 ; valeurs en section 9 | V / H |
| DEC-015 | Or immédiat et unique à l’élimination ; aucun or en cas d’arrivée ; pas de prime de vague | V — essai initial |
| DEC-016 | Séquence des dix vagues et accompagnants du boss ; quantités et intervalles H | V / H |
| DEC-017 | Première apparition à t = 0 ; séparation des groupes de 4 secondes H | V / H |
| DEC-018 | Fin de vague après toutes les apparitions et résolutions ; victoire après vague 10 si survie | V |
| DEC-019 | Progression de dégâts seuls ; courbe N1 × 1 / 1,5 / 2,25 / 3,25 | V / H |
| DEC-020 | Même facteur pour dégâts directs, secondaires et périodiques ; cadence et portée inchangées | V |

### Questions ouvertes prioritaires
| Identifiant | Décision attendue | Dépendance principale |
| --- | --- | --- |
| O-001 | Résistances, arrondis et ordre de calcul avec les bonus | Combat et statistiques par niveau |
| O-002 | Équilibrage des récompenses, arrondis et copies d’unités | Économie et recrutement |
| O-003 | Noms et effets des spécialisations ; coût distinct éventuel | Niveau 4 et synergies |
| O-004 | Seuils raciaux, proximité, cumul et recalcul | Système de synergies |
| O-005 | Catalogue, tirage, éligibilité et doublons des bonus | Choix roguelite |
| O-006 | Équilibrage des vagues et capacités futures du boss | Partie complète |
| O-007 | Progression entre les parties et interface de combat | Expérience globale |
| O-008 | Moteur, prix final, périmètre commercial et nom | Plan de production |
| O-009 | Échelle, premier tir, égalités, projectiles et portée après application d’un effet | Combat des deux factions |

<a id="s17"></a>

## 17 Sources et maintenance du GDD

### Sources et historique
S1 — GDD v0.1 dans « Texte collé.txt ». S2 — Cinq captures concordantes. S3 — Demande des livrables. S4 — Combat Alliance approuvé par « oui on fait comme ca ». S5 — Combat Horde approuvé par « très bien ». S6 — Ennemis, boss et récompenses approuvés par « ok pour ca ». S7 — Séquence des vagues et fiche détaillée approuvées par « ok go avec ca ». S8 — Progression approuvée par « ok on part la dessus ». Le lien partagé reste une référence d’origine.

Version 0.2 — 19 octobre 2026 : consolidation, statuts, calculs dérivés et feuille de route proposée ; aucune nouvelle fonctionnalité validée.

Version 0.3 — 19 octobre 2026 : combat Alliance N1, ciblage et essai initial validés par S4 ; valeurs H conservées.

Version 0.4 — 19 octobre 2026 : combat Horde N1 et priorité des victimes secondaires validés par S5 ; valeurs H conservées.

Version 0.5 — 19 octobre 2026 : sept archétypes, boss en vague 10 et règles de récompense validés par S6 ; statistiques H conservées.

Version 0.6 — 20 octobre 2026 : dix vagues, horaires, revenus et scénario de dépenses intégrés après validation S7 ; réglages H et calculs dérivés distingués.

Version 0.7 — 20 octobre 2026 : progression N1 à N4, dégâts secondaires et coûts cumulés intégrés après validation S8 ; valeurs H conservées.

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

Conserver une valeur H tant qu’elle n’a pas été équilibrée par des essais. Une validation de principe autorise le comportement décrit ; elle n’établit pas sa puissance relative. Les résultats futurs doivent préciser la carte, les vagues, les unités et les réglages employés pour permettre une comparaison utile.
