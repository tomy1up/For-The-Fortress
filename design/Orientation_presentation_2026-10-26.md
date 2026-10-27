# Orientation du prototype — 26 octobre 2026

Complément de conception au GDD v0.14, établi à partir des réponses explicites du porteur du projet après la livraison du prototype v0.53. Les décisions ci-dessous cadrent le prochain lot ; la proposition d’interface décrit un travail à réaliser.

## Décisions validées

| Sujet | Décision | Conséquence pour la suite |
| --- | --- | --- |
| Priorité | Améliorer la présentation du prototype : visuels, animations et sensations de combat | Le prochain lot travaille le contenu jouable existant |
| Compréhension | Condenser ou mieux expliquer les encarts trop chargés pour éviter de perdre les joueurs | La hiérarchie des informations fait partie du travail de présentation |
| Direction visuelle | Fantasy cartoon, avec les codes reconnaissables des races et classes ; World of Warcraft cité comme référence | Développer des personnages originaux aux silhouettes, proportions et équipements immédiatement reconnaissables |
| Entre les parties | Aucune progression permanente pour l’instant ; chaque partie repart à égalité | Aucun gain de puissance ou déblocage permanent à introduire dans ce lot |
| Difficulté | Jeu exigeant, où plusieurs défaites avant une première victoire sont normales | Construire une difficulté stratégique et explicable ; évaluer les premières parties de joueurs |

La variation des parties continue de venir des décisions prises pendant la partie, des offres de bonus et des compositions de défense. L’apprentissage du joueur peut se conserver entre les essais. Les rapports de débogage existants restent des relevés techniques.

L’absence de progression permanente s’applique au périmètre actuel. Une éventuelle évolution ultérieure demanderait un nouveau choix de conception. Le mot roguelike employé par le porteur du projet exprime ici cette orientation de parties exigeantes repartant à égalité.

## Principes de lisibilité pour le prochain lot

Présenter d’abord l’information qui permet de décider : effet principal, bénéficiaires, prix ou conséquence immédiate. Expliquer les conditions qui changent réellement la décision. Garder les chiffres précis consultables sans les imposer tous au premier regard.

Employer des mots de joueur, des phrases courtes et des libellés cohérents avec la faction. Les icônes et silhouettes pourront accompagner les textes ; les informations importantes doivent aussi rester compréhensibles par leurs libellés. Les conditions, limites de cibles et composantes de dégâts restent exactes dans les détails.

La difficulté attendue concerne la stratégie, les placements et les choix de développement de la défense. Les explications doivent permettre de comprendre un échec et de modifier son plan à la partie suivante.

## Analyse de l’existant v0.53

Ces observations viennent de la revue du prototype par l’agent. Le joueur a signalé une densité excessive dans certains encarts sans identifier précisément lesquels dans ce retour.

| Écran | Charge de lecture constatée | Proposition de traitement |
| --- | --- | --- |
| Choix de bonus | Trois colonnes cumulent nom, description, exceptions et listes de valeurs avant/après par défenseur, parfois défilantes | Premier chantier : effet principal immédiatement visible, bénéficiaires résumés, comparaison complète à la demande |
| Spécialisation | Deux branches réunissent description, coût, trois statistiques comparées et effets secondaires | Mettre en avant le rôle de chaque branche et son compromis ; conserver les valeurs détaillées dans un niveau secondaire |
| Recrutement et amélioration | Encarts et infobulles mélangent rôle, statistiques, solde futur, investissement et synergies | Hiérarchiser rôle et achat, puis évolution, puis détail des calculs |
| Bilan | Données nombreuses mais consultées après la partie, avec deux onglets existants | Priorité ultérieure : résumé du résultat puis analyse détaillée |

Référence d’implémentation : `prototype/scripts/main.gd`, notamment les constructeurs des panneaux et `_bonus_impact_text`. La revue n’établit pas de mesure du temps de compréhension d’un joueur.

## Proposition concrète du prochain lot

Commencer par le choix de bonus, selon trois niveaux de lecture :

1. **Effet principal** : nom court et gain identifiable.
2. **Bénéficiaires et condition utile** : unités concernées de la faction, ou effet économique/de forteresse.
3. **Détails facultatifs** : chiffres avant/après, exceptions et règles de calcul déjà disponibles.

Exemple de contenu à prototyper pour l’Alliance, sans changement de l’effet de R-06 :

> **Impacts appuyés**
>
> **+15 % aux dégâts des tirs directs**
>
> Les explosions restent inchangées.
>
> Consulter l’effet sur ma défense.

Cet exemple est une proposition de présentation, pas un écran déjà livré ni une nouvelle formule de dégâts. Le nombre de bénéficiaires, lorsqu’il sera affiché, devra venir de la défense réelle. La manière d’ouvrir les détails reste à prototyper ; aucune touche ni règle de pause supplémentaire n’est décidée ici.

La passe suivante pourra reprendre les spécialisations, puis les aides de recrutement et d’amélioration. Les animations et effets de combat devront mettre en évidence l’action, l’impact et la conséquence utiles au joueur.

## Critères de revue proposés

- Repérer l’effet principal de chaque offre sans parcourir une liste de statistiques.
- Comprendre quels défenseurs peuvent en bénéficier, y compris les futures recrues lorsque c’est pertinent.
- Retrouver les valeurs exactes au besoin, avec les mêmes résultats et les mêmes restrictions qu’actuellement.
- Reconnaître les unités par leurs silhouettes et équipements, au-delà de leur seule couleur.
- Comprendre ce qui a fragilisé la défense et disposer d’une piste pour le prochain essai.

Ces critères devront être confrontés à des essais joueurs ; aucun résultat de compréhension n’est présumé.

## Équilibrage et périmètre

Le niveau d’exigence est une intention désormais validée. Les réglages numériques restent à éprouver : ce retour ne fixe ni taux de victoire, ni nombre précis de défaites, ni nouvelle statistique du boss. Les futurs ajustements devront distinguer un problème de compréhension d’un problème de difficulté et documenter les mesures avant/après.

Ce complément consigne l’orientation et prépare le lot de présentation. La version jouable de référence reste v0.53. Les documents principaux du GDD conservent leur version v0.14 ; ce complément fait foi pour les points précisés ici.

For the Fortress! reste un nom de travail dont la disponibilité juridique est à confirmer.

## Premier lot réalisé — v0.54

Le porteur du projet a demandé la réalisation de cette proposition. La lecture progressive des bonus et des spécialisations est livrée dans la [v0.54](Lecture_progressive_v054.md). Les décisions d’orientation ci-dessus restent la référence pour les prochaines passes.

## Deuxième lot réalisé — v0.55

Les six silhouettes et les mouvements de tir sont livrés dans la [présentation des défenseurs v0.55](Presentation_defenseurs_v055.md). Aucun changement de progression ou d’équilibrage.

## Troisième lot réalisé — v0.56

Les projectiles et impacts distincts sont livrés dans la [présentation des attaques v0.56](Presentation_attaques_v056.md). Les déplacements visuels ne modifient pas le moment des dégâts ni les autres règles de combat.

## Quatrième lot réalisé — v0.57

La [lecture du recrutement et des améliorations v0.57](Lecture_recrutement_v057.md) reprend la hiérarchie par rôle, gain et prix avec chiffres complets à la demande. Les portées et règles de jeu sont conservées.

## Cinquième lot réalisé — v0.58

Le [bilan essentiel v0.58](Bilan_essentiel_v058.md) présente une première lecture du résultat et des pertes, puis les tableaux détaillés à la demande. Aucun changement de simulation.

## Sixième lot réalisé — v0.59

Les [huit silhouettes ennemies v0.59](Presentation_ennemis_v059.md) complètent les défenseurs cartoon, sans changement des caractéristiques ou règles.

## Précision de style — 27 octobre 2026

Le porteur du projet a précisé la direction avec une référence illustrée : formes compactes, grandes têtes et mains, contours épais, couleurs franches, ombres simples et peu de détails. Les races, rôles et équipements des unités existantes restent la référence. La [première planche Horde](concepts/Direction_cartoon_Horde_v001.md), créée à partir de cette direction, a ensuite été retenue explicitement comme référence de style ; voir la validation ci-dessous. Elle n’est pas encore intégrée au jeu. Version jouable conservée : v0.59.

### Validation de la planche Horde — 27 octobre 2026

Le porteur du projet a explicitement choisi le style de cette planche. Elle devient la référence artistique validée pour les prochains personnages : contours épais, couleurs franches, silhouettes expressives, formes compactes et équipements immédiatement reconnaissables. Les assets individuels et leur lisibilité à la taille du plateau restent à réaliser et à vérifier. La planche n’est pas encore intégrée au jeu ; version jouable conservée : v0.59.

## Première adaptation de la planche validée — v0.60, 27 octobre 2026

Les [trois assets individuels Horde](Assets_Horde_v060.md) sont intégrés au plateau avec transparence et tailles distinctes. Une pose illustrée par classe avec recul bref ; badges de niveau et de branche conservés. Les caractéristiques de combat ne changent pas.

## Adaptation du style à l’Alliance — v0.61, 27 octobre 2026

Les [trois assets individuels Alliance](Assets_Alliance_v061.md) complètent les trois personnages Horde. Cette déclinaison applique la direction artistique retenue ; les identités individuelles proposées restent ajustables après retour joueur. Aucun changement des règles ni des statistiques. Une pose par classe et recul bref au tir.

## Animation des six illustrations — v0.62, 27 octobre 2026

L’[orientation et les mouvements d’attaque](Animations_attaque_v062.md) rendent les tirs plus explicites : les défenseurs s’orientent à gauche ou à droite selon leur dernier tir et bougent selon leur classe. Les dégâts sont toujours immédiats, les bonus et règles restent identiques. Les armes ne sont pas encore articulées indépendamment.

## Réaction des ennemis aux coups — v0.63, 27 octobre 2026

La [réaction aux dégâts](Reaction_degats_v063.md) relie visuellement les pertes de PV aux impacts et aux dégâts périodiques existants : éclaircissement court du corps et portion perdue de la jauge qui s’efface. Aucun chiffre flottant ni changement d’équilibrage.

## Premier lot d’ennemis illustrés — v0.64, 27 octobre 2026

Les [trois profils courants](Assets_Ennemis_v064.md), Grouillant, Pillard et Sprinter, sont déclinés dans le style illustré des défenseurs. Les apparences individuelles restent ajustables après retour joueur. Brute, Maraudeur, Colosse, Élite et Seigneur de siège restent procéduraux dans ce lot. Aucun changement de règles ou d’équilibrage.

## Correction prioritaire : origine des attaquants — 27 octobre 2026

Le porteur du projet rappelle que seuls les ennemis neutres sont communs aux deux campagnes. Les attaquants spécifiques viennent du camp adverse : Alliance contre un joueur Horde et Horde contre un joueur Alliance. Leur catalogue doit rester distinct des défenseurs à construire. Cette règle est confirmée ; la [répartition proposée à sa demande](Origine_ennemis_2026-10-27.md) reste à valider. Le paquet v0.64 ne l’implémente pas encore et ses trois images d’ennemis sont provisoires. La définition du catalogue précède la suite des illustrations.
