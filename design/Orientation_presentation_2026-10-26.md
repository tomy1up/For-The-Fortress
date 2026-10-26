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
