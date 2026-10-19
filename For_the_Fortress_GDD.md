# For the Fortress!

Game Design Document — Version 0.4 — 19 octobre 2026

Document de référence pour concevoir, prototyper et faire évoluer le jeu. Cette version consolide le GDD v0.1 fourni, ses cinq captures et les règles de combat des deux factions approuvées ensuite. Elle conserve les choix établis, les valeurs provisoires et les questions ouvertes, tout en ajoutant des outils de suivi explicitement proposés.

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
9. [9 Ennemis vagues et difficulté](#s9)
10. [10 Présentation interface et validation du prototype](#s10)
11. [11 Périmètre commercial et feuille de route](#s11)
12. [12 Registre des décisions](#s12)
13. [13 Sources et maintenance du GDD](#s13)

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
La destruction de la forteresse met fin à la partie — V. Le seuil opérationnel de destruction, les dégâts infligés par un ennemi qui atteint l’objectif et le traitement des arrivées simultanées restent ouverts — O. Terminer les dix vagues avec une forteresse survivante est la condition de victoire proposée pour le prototype — P ; la règle exacte de fin de vague et de victoire doit être confirmée.

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

La lecture séquentielle des trois coûts correspond aux trois améliorations jusqu’au niveau 4. Les niveaux 2 à 4 n’ont pas de multiplicateurs de dégâts, de portée ou de cadence définis. Il n’existe pas de statistique finale de spécialisation validée.

### Paramètres manquants
| Domaine | Données à définir — O |
| --- | --- |
| Attaque | Niveaux 1 précisés en sections 5 et 6 ; niveaux supérieurs ouverts |
| Résolution des dégâts | Types, résistances hors essai initial, ordre de calcul et arrondis |
| Spécialisations | Noms, effets, conditions et éventuel coût distinct |
| Niveaux | Gains exacts et interaction avec les bonus roguelite |

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
L’or finance les achats et les améliorations — V. La boucle prévoit de récupérer de l’or après les combats, mais le détail des sources, des montants et de leur versement reste ouvert. Le capital initial de référence est de 150 or — H. Aucun revenu passif ni monnaie supplémentaire n’est validé.

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
Définir les gains par ennemi ou par vague, leur calendrier, l’arrondi des ventes et les éventuelles limites de recrutement. Tester ensuite si les revenus permettent des choix réels entre élargir une défense et atteindre une spécialisation. Aucun montant de récompense ni objectif de rentabilité par vague n’est inventé.

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

## 9 Ennemis vagues et difficulté

### Contenu prévu
Le prototype vise sept archétypes d’ennemis et un boss — C. Leurs noms, statistiques et comportements ne sont pas décrits dans les sources. La cible commerciale est d’environ douze familles d’ennemis et six boss — C. La correspondance entre « archétype » et « famille » devra être fixée avant d’utiliser ces nombres comme inventaire de production.

### Calendrier des dix vagues
| Vague | Composition et statistiques | Sélection roguelite après la vague |
| --- | --- | --- |
| 1 | À définir — O | Non |
| 2 | À définir — O | Non |
| 3 | À définir — O | Oui — trois propositions |
| 4 | À définir — O | Non |
| 5 | À définir — O | Non |
| 6 | À définir — O | Oui — trois propositions |
| 7 | À définir — O | Non |
| 8 | À définir — O | Non |
| 9 | À définir — O | Oui — trois propositions |
| 10 | À définir — O | Aucun choix prévu dans le socle |

La présence d’un boss à la vague 10 n’est pas confirmée. La vague d’apparition du boss, les délais entre ennemis, les groupes d’apparition et les récompenses sont ouverts. Le tableau réserve le calendrier sans inventer sa composition.

### Schéma de fiche ennemi proposé
| Champ | Contenu attendu |
| --- | --- |
| Identité | Identifiant stable, nom, archétype ou famille |
| Résistance et déplacement | PV, vitesse, résistances, règles de cheminement |
| Impact sur la partie | Dégâts à la forteresse et récompense en or |
| Comportement | Règle spéciale éventuelle, priorité et conditions |
| Traçabilité | Statut, source, version et résultats des essais |

Ce schéma est une proposition documentaire — P. Un champ de comportement spécial ne signifie pas que chaque ennemi doit posséder une capacité particulière.

### Validation de la difficulté proposée
Observer les vagues qui causent des pertes, les compositions utilisées, l’or disponible et la durée des parties. Comparer les deux factions sur la même carte. Les taux de victoire cibles, multiplicateurs de difficulté et courbes de croissance des ennemis restent à fixer ; aucun mode de difficulté supplémentaire n’est validé.

<a id="s10"></a>

## 10 Présentation interface et validation du prototype

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

<a id="s11"></a>

## 11 Périmètre commercial et feuille de route

### Comparaison des périmètres envisagés
| Élément | Prototype | Objectif commercial |
| --- | --- | --- |
| Factions | 2 | 2 |
| Défenseurs | 6, soit 3 par faction | 16, soit 8 par faction |
| Spécialisations | Deux branches débloquées au niveau 4 | Deux par défenseur |
| Cartes | 1 | 6 |
| Vagues | 10 | À définir par carte |
| Bonus roguelite | Sélection réduite | Environ 60 |
| Ennemis | 7 archétypes | Environ 12 familles |
| Boss | 1 | Environ 6 |
| Mode infini | Absent du prototype | Envisagé |

Ces objectifs sont des cibles de contenu — C — et non des engagements de production. Ils seront ajustés selon le temps de développement et les tests. Le modèle premium et le prix de 7,99 € sont envisagés ; la commercialisation, le budget, les ventes attendues et le calendrier ne sont pas arrêtés.

### Feuille de route proposée
| Jalon | Travail à effectuer | Condition de passage proposée |
| --- | --- | --- |
| J0 — Clarifier | Arbitrer dégâts, ciblage, revenus, synergies et ennemis | Règles nécessaires au prototype documentées |
| J1 — Construire | Carte du Gué, six emplacements, deux factions, six défenseurs | Boucle de préparation et combat jouable |
| J2 — Compléter | Dix vagues, économie, niveaux, spécialisations et bonus | Partie jouable du début à la fin |
| J3 — Tester | Lisibilité, factions, économie et durée | Résultats consignés et corrections priorisées |
| J4 — Réviser le périmètre | Examiner la cible commerciale selon les essais | Contenu, charge et priorités explicitement confirmés |

La feuille de route est une proposition d’organisation — P. Aucun délai, budget, responsable ou engagement de livraison n’est supposé. L’extension vers six cartes et seize défenseurs dépend de la validation du prototype.

### Nom de travail
For the Fortress! reste un nom de travail. Sa disponibilité juridique doit être confirmée avant de le retenir pour une commercialisation. Aucune recherche de marque, de titre de jeu ou de nom de domaine n’est réputée accomplie par ce GDD. Les noms de factions restent également provisoires.

<a id="s12"></a>

## 12 Registre des décisions

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

### Questions ouvertes prioritaires
| Identifiant | Décision attendue | Dépendance principale |
| --- | --- | --- |
| O-001 | Niveaux supérieurs et résistances après l’essai initial | Combat et statistiques par niveau |
| O-002 | Revenus, versement, arrondis et copies d’unités | Économie et recrutement |
| O-003 | Noms et effets des spécialisations ; coût distinct éventuel | Niveau 4 et synergies |
| O-004 | Seuils raciaux, proximité, cumul et recalcul | Système de synergies |
| O-005 | Catalogue, tirage, éligibilité et doublons des bonus | Choix roguelite |
| O-006 | Sept archétypes, boss, composition des vagues et victoire | Partie complète |
| O-007 | Progression entre les parties et interface de combat | Expérience globale |
| O-008 | Moteur, prix final, périmètre commercial et nom | Plan de production |
| O-009 | Échelle, premier tir, égalités, projectiles et portée après application d’un effet | Combat des deux factions |

<a id="s13"></a>

## 13 Sources et maintenance du GDD

### Sources et historique
S1 — GDD v0.1 dans « Texte collé.txt ». S2 — Cinq captures concordantes. S3 — Demande des livrables. S4 — Combat Alliance approuvé par « oui on fait comme ca ». S5 — Combat Horde approuvé par « très bien ». Le lien partagé reste une référence d’origine.

Version 0.2 — 19 octobre 2026 : consolidation, statuts, calculs dérivés et feuille de route proposée ; aucune nouvelle fonctionnalité validée.

Version 0.3 — 19 octobre 2026 : combat Alliance N1, ciblage et essai initial validés par S4 ; valeurs H conservées.

Version 0.4 — 19 octobre 2026 : combat Horde N1 et priorité des victimes secondaires validés par S5 ; valeurs H conservées.

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
