# Économie de campagne — cadrage du 29 octobre 2026

**Révision la plus récente :** les points de talent proviennent désormais de l’XP des missions ; les PO sont destinées à la boutique. La référence de 510 PO pour les talents ci-dessous est historique et remplacée. [Décision et courbe XP](Experience_talents_2026-10-29.md).

Ce document consigne les dernières précisions du porteur du projet et sépare les contraintes acquises des pistes à tester. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Règles acquises

| Sujet | Règle |
| --- | --- |
| Acquisition | Chaque mission donne des PO à sa première victoire ; rejouer cette mission ne redonne pas cette récompense. |
| Continuité | Les missions après la 100e continuent de donner leurs PO de première victoire. |
| Repère des 100 missions | Leurs gains doivent suffire pour acheter le nombre maximal de points autorisés, si ces gains sont consacrés aux points ; cette référence exclut la boutique et les autres dépenses facultatives. |
| Liberté de dépense | Acheter en boutique peut retarder le maximum de points ; le repère de la mission 100 ne garantit pas simultanément tous les achats. |
| Talents | Trois arbres enrichis, un plafond de points partagé imposant des choix ; ni le plafond ni les prix définitifs ne sont fixés. |
| Boutique | Des unités ouvrant des possibilités stratégiques, avec forces et faiblesses ; pas de remplaçantes systématiquement supérieures. |
| Difficulté | Éviter une impasse après des achats et conserver un défi même avec une bonne répartition des dépenses. |
| Respécialisation | Réinitialisation gratuite entre les missions ; talents fixés pendant la mission. Aucun farm de PO n’est requis pour financer les resets. |
| Persistance | Les acquisitions et PO déjà versées restent conservées ; comptes des factions distincts. |

La boutique est une orientation de conception ; les offres, prix, unités et règles de déverrouillage restent à définir. Aucun portefeuille réservé aux talents, conversion de monnaies, remboursement d’achat ou gain répétable n’est approuvé par ces échanges.

## Ce que la référence budgétaire signifie

Pour un plafond P et un prix c(k) du k-ième point, le cumul des récompenses des missions 1–100 doit couvrir la somme de c(1) à c(P), sans autres dépenses. Si le joueur emploie une partie de ces PO en boutique, il peut acheter moins de points à la mission 100 et poursuivre leur acquisition avec les gains des missions suivantes.

Cette équation ne prouve pas qu’un joueur peut atteindre les récompenses futures. Un parcours peut disposer théoriquement d’assez de PO sur toute sa durée et pourtant comporter un blocage plus tôt. Il faut donc vérifier les courbes de difficulté et les trajectoires d’achat mission par mission.

## Cadre de boutique confirmé

Une nouvelle unité doit proposer une autre réponse à un problème : cibles groupées ou isolées, couverture, cadence ou coût de recrutement, par exemple. Ces axes décrivent des comparaisons à construire avec les mécaniques existantes, pas des effets nouveaux déjà approuvés.

On comparera les unités à conditions équivalentes : faction, coût temporaire de recrutement et d’amélioration, niveau, talents, emplacement et type de vague. Une unité peut exceller dans un contexte et céder du terrain dans un autre. Augmenter son prix en PO ne suffit pas à justifier qu’elle domine partout une unité de départ.

Les unités initiales doivent conserver un intérêt. Le nombre d’unités débloquées n’est pas une puissance directement cumulable sur le plateau : les emplacements et le budget de combat imposent déjà des choix dans le prototype. Leur extension dans la campagne reste à cadrer.

## Programme d’équilibrage proposé

| Trajectoire de test | Risque à examiner |
| --- | --- |
| Priorité aux points | Les gains permanents rendent-ils trop de missions triviales ? Une même configuration domine-t-elle tout ? |
| Priorité à la boutique | Les outils débloqués offrent-ils des réponses viables malgré un retard de points ? Une dépense peut-elle rendre le prochain progrès impossible ? |
| Répartition mixte | Existe-t-il plusieurs combinaisons utiles, ou une dépense obligatoire et évidente ? |
| Respécialisations gratuites | Le joueur peut-il explorer et corriger ses choix entre les missions sans exploiter un changement de talents pendant le combat ? |
| Joueur sans achat récent | Peut-il apprendre et modifier sa stratégie avec son contenu déjà disponible ? |
| Missions après 100 | Les nouveaux gains restent-ils utiles sans provoquer une accumulation de puissance incontrôlée ? |

Les résultats devront être comparés à des essais humains et à plusieurs placements, types d’ennemis et configurations. Un simple nombre de points ou une victoire de référence ne garantit pas la viabilité de toutes les dépenses.

## Pistes restant à examiner

- Tarifs et déverrouillages progressifs, en fonction de la valeur stratégique et de la progression.
- Plafond de puissance des talents et compromis de répartition, sans augmentation automatique du budget pour chaque nouveau talent ajouté.
- Présentation claire des conséquences d’un achat et possibilité d’examiner les unités avant de dépenser.
- Si les tests révèlent une impasse : réviser difficulté, coût, disponibilité des réponses ou éventuellement proposer un mécanisme de correction d’achat. Aucun remboursement ou autre mécanisme de secours n’est déjà choisi.

Les montants, formules de difficulté et seuils de puissance restent des hypothèses à établir. Les ajouts de contenu et la courbe doivent être conçus ensemble ; il ne faut pas remplacer les choix de dépenses souhaités par une réserve de PO obligatoire sans nouvelle décision.

## Respécialisation — décision finale de cet échange

Après avoir comparé reset payant avec revenu renouvelable et reset gratuit, le porteur du projet a choisi le **reset gratuit entre les missions**. La réinitialisation restitue les points sans débiter les PO ; les talents restent fixés pendant la mission. Cette décision remplace le tarif progressif plafonné auparavant retenu.

Elle est réalisée dans la [v0.84](Reset_gratuit_v084.md). Les points restent limités et les talents demandent des arbitrages ; la gratuité ne permet pas de tout remplir simultanément. Les PO restent destinées aux points et aux achats de boutique selon l’économie à définir. Un éventuel revenu répétable pour un futur mode infini reste une question distincte, sans obligation de l’ajouter pour financer les resets.

## Hypothèse de chiffrage à 51 points

Le plafond de prototype demandé est de 51 points par faction. Au prix provisoire de 10 PO, la cible de financement hors boutique est de 510 PO sur les missions 1–100. Exemple non activé : 5 PO par première victoire et +1 PO aux missions multiples de 10. Les prix et récompenses restent à valider ; la gratuité des resets est acquise. [Détail](Orientation_talents_2026-10-29.md).
