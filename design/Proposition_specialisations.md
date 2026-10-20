# For the Fortress! — Proposition des spécialisations du prototype

Proposition du 20 octobre 2026, fondée sur le GDD v0.7.

**Statut P — proposition à valider.** Les noms, règles de choix et comportements décrits ici sont proposés. Tous les réglages chiffrés sont des hypothèses H à tester. Le GDD approuvé reste en version 0.7. Cette fiche ne valide ni nouvelles unités, ni bonus roguelite, ni synergies supplémentaires.

## 1. Cadre du choix proposé

Le niveau maximum 4 et le choix entre deux branches sont déjà validés. Pour rendre ce choix exploitable, proposition :

- Choisir une branche au passage N3 vers N4, pendant la préparation entre deux vagues.
- Les 150 or du passage au N4 comprennent le choix : aucun surcoût de spécialisation pour le prototype.
- Une seule branche par unité. Le choix reste fixé jusqu’à la vente ; une nouvelle unité repart au N1 selon les règles d’achat habituelles. La possibilité d’acheter des copies demeure ouverte.
- Les deux branches sont accessibles dès les essais du prototype, sans déblocage persistant ni prérequis racial ajouté.
- Le choix se termine avant le lancement de la vague suivante. La présentation de cette interaction reste à concevoir.
- Aucun effet n’est rétroactif sur une attaque ou une malédiction déjà appliquée.

Le coût total au N4 reste ainsi de 350, 375 ou 400 or selon le défenseur. La vente théorique à 70 % reste de 245, 262,5 ou 280 or, avant la règle d’arrondi encore ouverte.

## 2. Lecture des statistiques

Les tableaux donnent des **valeurs finales au N4 spécialisé**, hors bonus et résistances. Ne pas leur appliquer à nouveau le multiplicateur N4 de × 3,25. Le N4 de base reste la référence de comparaison du GDD ; les spécialisations dérogent uniquement aux paramètres explicitement listés dans leur fiche.

Tout paramètre non remplacé conserve sa valeur du GDD : ciblage principal sur l’ennemi à portée le plus avancé, priorité aux victimes secondaires les plus proches, éliminations et revenus, et règles propres à chaque attaque. Les DPS supposent des attaques continues sur des ennemis ayant assez de PV. Les plafonds de groupe supposent toutes les victimes admissibles en permanence.

L’ordre d’application des futurs bonus et résistances reste ouvert. Ces tableaux ne règlent pas cette question.

## 3. Alliance des Royaumes

### Archer elfe — portée ou cadence

N4 de base : 26 dégâts toutes les 1 s, portée 4, soit 26 DPS sur une cible.

| Branche proposée | Dégâts par tir | Intervalle | Portée | DPS sur une cible |
| --- | --- | --- | --- | --- |
| A — Veilleur des remparts | 39 | 1,5 s | 5 | 26 |
| B — Tireur de volée | 19,5 | 0,6 s | 3,5 | 32,5 |

**Veilleur :** couvrir un segment plus long et frapper plus fort par impact. La cadence plus lente augmente les dégâts perdus sur les petites cibles. Le gain de portée peut accroître le temps de tir réel sans modifier le DPS continu.

**Tireur de volée :** attaques fréquentes et meilleur DPS continu, contre une portée réduite et un dégât par impact plus faible. Les tirs restent dirigés sur une seule cible ; « volée » ne signifie pas attaque de zone.

### Arbalétrier nain — puissance ou couverture

N4 de base : 78 dégâts toutes les 2,5 s, portée 5, soit 31,2 DPS sur une cible.

| Branche proposée | Dégâts par tir | Intervalle | Portée | DPS sur une cible |
| --- | --- | --- | --- | --- |
| A — Brise-siège | 117 | 3 s | 5 | 39 |
| B — Sentinelle des tours | 78 | 2,5 s | 6,5 | 31,2 |

**Brise-siège :** tirs puissants pour les ennemis endurants ; cadence plus lente, dégâts excédentaires perdus. À 117 dégâts, il n’élimine pas une Brute à 120 PV en un impact sans autre effet.

**Sentinelle :** étendre la couverture depuis un emplacement fixe, sans gain de dégâts ou de cadence. Son intérêt dépend fortement du tracé de la carte. Aucun changement de priorité vers les boss ou ennemis à forts PV n’est ajouté.

### Mage humain — concentration ou dispersion

N4 de base : 87,75 dégâts principaux, deux victimes secondaires à 35,1 chacune, intervalle 2,5 s, portée 3,5, rayon 1. DPS : 35,1 sur une cible ; 63,18 au plafond de trois victimes.

| Branche proposée | Dégâts principaux | Par victime secondaire | Maximum secondaire | Rayon |
| --- | --- | --- | --- | --- |
| A — Arcaniste de concentration | 110 | 22 (20 %) | 2 | 1 |
| B — Maître des déflagrations | 70 | 28 (40 %) | 4 | 1,3 |

Intervalle 2,5 s et portée 3,5 pour les deux branches.

**Concentration :** 44 DPS sur une cible et 61,6 au plafond de trois victimes. Renforce la cible principale ; réduit l’efficacité de zone.

**Déflagrations :** 28 DPS sur une cible et 72,8 au plafond de cinq victimes. Agrandit la zone et le nombre de victimes, au prix du dégât principal. Une même victime n’est touchée qu’une fois par explosion.

## 4. Horde des Cendres

### Lanceur de haches troll — impact ou chaîne

N4 de base : 52 dégâts principaux, un rebond à 26, intervalle 2 s, portée 3,5, distance de rebond 1. DPS : 26 sur une cible ; 39 sur deux.

| Branche proposée | Dégâts principaux | Par rebond | Nombre maximal de rebonds | Distance par rebond |
| --- | --- | --- | --- | --- |
| A — Fendeur de crânes | 65 | 16,25 (25 %) | 1 | 1 |
| B — Maître des ricochets | 46 | 23 (50 %) | 3 | 1 |

Intervalle 2 s et portée 3,5 pour les deux branches.

**Fendeur :** 32,5 DPS sur une cible et 40,625 sur deux. Meilleur impact principal, mais rebond plus faible que celui du N4 de base.

**Ricochets :** 23 DPS sur une cible et 57,5 au plafond de quatre victimes. Les rebonds sont successifs : à chaque étape, chercher l’ennemi admissible le plus proche de la dernière victime, à une distance strictement inférieure à 1. Chaque rebond inflige 50 % du dégât principal initial, sans réduction supplémentaire d’étape en étape. Une attaque ne touche jamais deux fois le même ennemi ; elle s’arrête faute de cible. Les égalités de distance restent à trancher avec les règles générales de ciblage.

### Sapeur gobelin — charge concentrée ou large explosion

N4 de base : 78 dégâts principaux et trois victimes secondaires à 31,2, intervalle 2,5 s, portée 3, rayon 1. DPS : 31,2 sur une cible ; 68,64 sur quatre.

| Branche proposée | Dégâts principaux | Par victime secondaire | Maximum secondaire | Rayon |
| --- | --- | --- | --- | --- |
| A — Expert en démolition | 104 | 26 (25 %) | 3 | 1 |
| B — Artificier des foules | 65 | 26 (40 %) | 5 | 1,4 |

Intervalle 2,5 s et portée 3 pour les deux branches.

**Démolition :** 41,6 DPS sur une cible et 72,8 au plafond de quatre victimes. Renforce le point d’impact en sacrifiant les dégâts par victime secondaire.

**Foules :** 26 DPS sur une cible et 78 au plafond de six victimes. Plus de couverture et de victimes possibles, mais moins de dégâts sur la cible principale et sur chaque victime que le N4 de base. Aucune mine, zone persistante ou explosion en chaîne n’est ajoutée. Chaque victime n’est touchée qu’une fois par attaque.

### Chaman orc — dégâts immédiats ou malédiction

N4 de base : 39 dégâts immédiats et deux applications à 15,6, à +1 s et +2 s. Intervalle 2 s, portée 4,5. DPS complet sur une cible survivante : 35,1.

| Branche proposée | Dégâts immédiats | Dégâts à +1 s | Dégâts à +2 s | DPS complet |
| --- | --- | --- | --- | --- |
| A — Chaman de guerre | 58,5 | 9,75 | 9,75 | 39 |
| B — Tisseur de malédictions | 26 | 29,25 | 29,25 | 42,25 |

Intervalle 2 s et portée 4,5 inchangés. Guerre inflige 78 dégâts sur un cycle complet ; Malédictions en inflige 84,5.

**Guerre :** davantage de dégâts dès l’impact, moins de dégâts différés. Utile lorsque la cible risque d’atteindre rapidement la forteresse.

**Malédictions :** chaque application périodique devient plus forte, contre un impact initial plus faible. Les effets déjà appliqués suivent les règles de renouvellement du GDD ; au même instant, le dernier dégât périodique précède le renouvellement. Aucun cumul supplémentaire, ralentissement, transfert de malédiction ou réduction de résistance n’est proposé.

Guerre élimine un Pillard à 40 PV dès l’impact ; Malédictions élimine un Sprinter à 24 PV dès l’impact, mais doit attendre la suite de l’effet pour dépasser le total de Guerre. Le maintien des effets après sortie de portée reste ouvert, conformément au GDD ; il faudra le trancher avant les essais. Le gain total de Malédictions donne une contrepartie mesurable à son impact initial réduit. Les synergies et bonus futurs restent ouverts.

## 5. Compatibilité économique et vagues

L’absence proposée de surcoût conserve le scénario de dépenses du GDD : avant la vague 10, un défenseur à 50 or au N4, celui à 75 or au N3 et celui à 100 or au N2 ; 725 or investis et 91 or de solde maximal.

| Composition avant le boss | DPS théorique sur une cible |
| --- | --- |
| Alliance : Veilleur N4 + Arbalétrier N3 + Mage N2 | 63,8 |
| Alliance : Tireur de volée N4 + Arbalétrier N3 + Mage N2 | 70,3 |
| Horde : Fendeur N4 + Sapeur N3 + Chaman N2 | 70,3 |
| Horde : Ricochets N4 + Sapeur N3 + Chaman N2 | 60,8 |

Les dégâts secondaires ne sont pas inclus. La portée, la cadence et les dégâts différés empêchent d’assimiler ces compositions en combat réel.

Dans ce scénario, les branches des défenseurs à 75 et 100 or ne sont pas atteintes. Les tester avec d’autres allocations du même budget ; ne pas leur attribuer gratuitement des niveaux ou de l’or dans une comparaison de difficulté.

| Essai proposé | Vagues de référence | Observation à recueillir |
| --- | --- | --- |
| Couverture et cadence | 3, 5 et 8 | Temps de tir utile, fuites de Sprinters, dégâts excédentaires |
| Zone et ricochets | 4 et 8 | Nombre réel de victimes, effets perdus, positionnement |
| Cible unique | 6, 7, 9 et 10 | Élimination des ennemis endurants et du boss |
| Temporalité du chaman | 3 et 10 | Éliminations avant la forteresse, dégâts périodiques perdus |
| Économie | Partie complète | Vague d’accès au N4 et conséquences sur le reste de la défense |

Comparer chaque branche à son N4 de base, puis les branches entre elles, à carte, budget, choix roguelite et règles identiques. Mesurer les PV de forteresse perdus et la réussite, pas seulement le DPS. Aucun test jouable n’a encore établi l’équilibre de ces propositions.

## 6. Décisions demandées et suites

À examiner avant intégration au GDD :
1. Les six paires de rôles et leurs effets.
2. Le choix sans surcoût, exclusif et fixé jusqu’à la vente.
3. Les rebonds successifs et distincts du troll spécialisé.
4. Les valeurs H comme points de départ des essais.

Les noms restent provisoires même après un accord de principe. Une approbation de cette fiche ne signifie pas que les valeurs sont équilibrées. L’interface du choix, les égalités de ciblage, les arrondis, les interactions avec bonus/résistances et les synergies restent à définir.

Après validation, intégrer ces règles au GDD Word et Markdown dans une même version. Étape proposée ensuite : fixer la géométrie de La Vallée du Gué et les six emplacements pour donner un sens mesurable aux portées et zones.
