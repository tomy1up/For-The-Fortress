# Progression permanente par faction — proposition du 27 octobre 2026

**Suivi :** le porteur du projet a ensuite demandé de poursuivre le développement. Une première réalisation jouable est décrite dans [Progression et talents v0.67](Progression_factions_v067.md), avec des valeurs explicitement provisoires. Le cadrage ci-dessous conserve l’état de la discussion avant cette réalisation.

Statut : cadrage à discuter, non implémenté et non équilibré. La respécialisation payante à coût croissant puis plafonné est explicitement validée par le porteur du projet le 27 octobre 2026 ; les montants et le nombre de resets avant plafond restent à définir. La version jouable reste v0.66. Cette note conserve la nouvelle orientation exprimée par le porteur du projet et distingue ses décisions des recommandations proposées. Elle ne transforme pas les exemples en fonctionnalités approuvées.

## Origine de la demande

Le porteur du projet souhaite désormais une progression roguelite permanente : accumuler une ressource en jouant, acheter des points de talent et les investir dans trois arbres par faction. Chaque arbre comprendrait des spécialités. Un point investi ne doit jamais bénéficier simultanément aux deux factions. Le joueur envisage plus précisément deux ressources obtenues exclusivement en jouant leur faction respective.

Il souhaite des premières parties très difficiles et une progression permettant ensuite d’affronter des difficultés supérieures. Il demande également d’autres usages possibles de ces ressources.

Cette orientation fait évoluer la décision du 26 octobre « aucune progression permanente pour l’instant ». Celle-ci décrit toujours le comportement de la version jouable actuelle ; son historique n’est pas réécrit. L’existence d’une progression permanente est maintenant demandée, mais les règles ci-dessous restent des propositions.

## Architecture recommandée, à valider

| Élément | Proposition |
| --- | --- |
| Ressource Alliance | Gagnée uniquement lors de parties Alliance ; nom thématique à choisir |
| Ressource Horde | Gagnée uniquement lors de parties Horde ; nom thématique à choisir |
| Conversion | Aucune conversion entre les deux réserves |
| Achat de points | Chaque réserve achète uniquement les points de sa faction |
| Affectation | Un point affecté à un rang de talent n’est plus disponible ailleurs |
| Réattribution | Faible coût en ressource de la faction concernée, validé par le porteur du projet ; proposition d’accès entre les parties |
| En partie | Configuration des talents verrouillée du lancement à la fin de la tentative |
| Progression de difficulté | À définir séparément des talents ; ne pas confondre expérience acquise et carte/difficulté débloquée |

Les points achetés sont possédés durablement ; les investir les immobilise, sans les détruire. Réinitialiser un arbre rend seulement les points correspondants à cette même faction. Cela respecte l’interdiction de partager un point entre Horde et Alliance et autorise l’expérimentation.

### Décision validée : respécialisation payante

Le porteur du projet précise : « l’action de réinitialisation des talents coûtera un peu de ressource au joueur », puis demande un tarif incrémentiel sur les premiers resets et un tarif fixe après X resets, pour éviter une augmentation sans limite. Ces décisions remplacent les recommandations initiales de gratuité, puis de tarif fixe dès le départ. Le coût croissant puis plafonné est validé ; le prix initial, les augmentations, le plafond, X et la portée de la réinitialisation (un arbre ou les trois arbres de la faction) restent ouverts.

Application proposée : utiliser la ressource de la faction concernée et rendre ses points investis disponibles sans les faire racheter, sans transfert vers l’autre faction. Afficher le coût et les points restitués avant confirmation ; ne rien prélever si la réinitialisation échoue ou qu’aucun point n’est investi.

**Décision validée par le porteur du projet : compteur de respécialisations séparé par faction.** Une réinitialisation Alliance fait avancer uniquement le compteur Alliance ; elle ne renchérit pas les resets Horde, et inversement. Chaque faction progresse indépendamment dans le barème croissant jusqu’au plafond. Les valeurs de ce barème restent à définir.

Le barème peut être représenté par une liste finie de prix : le premier reset utilise le premier prix, les suivants progressent dans la liste, puis tous les resets ultérieurs utilisent son dernier prix. Le compteur n’avance qu’après une réinitialisation réellement effectuée. Les prix et le plafond doivent rester compatibles avec le revenu d’une partie pour permettre l’expérimentation. Aucune valeur numérique n’est fixée ici.

## Structure proposée des six arbres

Noms et effets ci-dessous : exemples de conception, sans valeurs ni approbation individuelle. Aucun nouveau défenseur n’est ajouté par cette proposition.

| Faction | Arbre proposé | Orientation | Exemples de spécialités |
| --- | --- | --- | --- |
| Alliance | Bastion | Forteresse et marge de survie | Résistance / Préparation |
| Alliance | Maîtrise du tir | Archers et arbalétriers | Tirs concentrés / Couverture du terrain |
| Alliance | Arts arcaniques | Mages et leurs explosions | Puissance directe / Dégâts de zone |
| Horde | Fureur de guerre | Lanceurs de haches et rebonds | Cible prioritaire / Ricochets |
| Horde | Voie des maléfices | Chamans et malédictions | Impact initial / Usure |
| Horde | Démolition | Sapeurs et explosions | Bombes concentrées / Couverture de zone |

Pour la première réalisation, préférer peu de talents lisibles à six arbres très étendus. Plusieurs rangs peuvent améliorer un talent ; des choix majeurs doivent changer la manière de composer sa défense. Éviter un arbre qui impose un seul type de défenseur et rend les synergies sans intérêt.

Un budget limité de points actifs est recommandé à terme : posséder de nombreux talents ne permettrait pas d’activer simultanément toutes les spécialités finales. Le plafond, les prérequis, les exclusions et le nombre de rangs restent ouverts. Ne pas créer dès maintenant des arbres très longs uniquement pour allonger le temps de collecte.

## Acquisition recommandée des ressources

1. Récompense pour chaque vague terminée, conservée même après une défaite ultérieure.
2. Bonus de palier pour les vagues importantes, afin que progresser rapporte davantage que recommencer systématiquement le tout début.
3. Récompense supplémentaire de victoire et gratification de première victoire par carte/difficulté/faction, lorsque ces contenus existent.
4. Rendement supérieur pour les difficultés supérieures, à équilibrer selon leur durée et leur taux de réussite.

La ressource permanente est distincte de l’or de recrutement utilisé pendant une partie. Aucun gain au simple temps passé, aucun paiement pour recommencer, aucune nécessité de gagner pour obtenir sa toute première progression. Un abandon ne doit pas donner de récompense additionnelle ; seules les étapes réellement accomplies peuvent compter.

Les montants, prix des points, vitesse de progression des coûts et multiplicateurs ne sont pas fixés. Mesurer notamment les ressources par minute, le revenu d’une défaite et l’intérêt de continuer une tentative après un mauvais départ. Préférer une collecte liée à la progression réellement accomplie plutôt qu’au nombre brut de victimes, pour limiter les stratégies de répétition artificielle.

La première amélioration devrait être accessible après une tentative significative. Cela reste un objectif de rythme à tester, pas une durée ou un nombre de parties validé.

## Dépenses complémentaires possibles

| Usage proposé | Intérêt | Réserve de conception |
| --- | --- | --- |
| Points de talent | Progression principale de la faction | Prix et plafond à définir |
| Réinitialisation des talents | Dépense de ressource pour changer de stratégie — coût croissant puis plafonné validé | Prix initial, paliers, plafond, nombre de resets avant plafond et portée à définir |
| Nouvelles options de préparation | Variantes de départ à sélectionner, par exemple une orientation de recrutement | Nouveau système éventuel ; alternatives avec compromis, à concevoir séparément |
| Nouvelles offres de bonus de partie | Variété des compositions possibles | Nouveau système éventuel ; ne pas diluer les tirages ni affaiblir le joueur qui débloque une offre |
| Éléments cosmétiques de faction | Dépense facultative à long terme | Contenu à produire ; aucun effet de combat |

Ne pas cumuler paiement d’ouverture d’un arbre, paiement de chaque talent et paiement de ses points pour le même progrès. Ne pas ajouter de consommables permanents obligatoires à dépenser à chaque tentative. La respécialisation payante demandée doit rester une petite dépense ; son prix est à confronter au revenu des parties pour ne pas rendre les essais de stratégies excessivement coûteux.

## Difficulté et intérêt à long terme

Recommandation : une première victoire rare mais possible sans talent, sans verrou numérique imposant une durée minimale de collecte. Les talents augmentent la marge d’erreur et ouvrent des stratégies ; le placement, l’économie, les synergies et les bonus de partie doivent continuer à décider de la réussite.

La progression permanente peut avoir une fin. La rejouabilité au-delà vient ensuite de la diversité des configurations, des factions, des cartes et difficultés effectivement produites. Deux monnaies ne doublent pas à elles seules la quantité de contenu : l’attrait de la seconde faction dépend de ses différences de jeu et du rythme de son nouveau départ.

## Prochain cadrage avant implémentation

- Confirmer les deux ressources et les points strictement propres à leur faction.
- Définir le prix initial, les augmentations et le plafond de la respécialisation payante validée, ainsi que le nombre de resets avant plafond, sa portée et son accès entre les parties. Les compteurs par faction sont validés ; un futur budget limité de points actifs reste à confirmer.
- Détailler un petit ensemble de talents dans les six arbres, leurs prérequis et leurs interactions avec les bonus actuels.
- Fixer un premier barème de ressources et de prix comme hypothèse d’équilibrage.
- Concevoir ensuite la sauvegarde du profil et la restitution claire des gains au bilan ; vérifier qu’un même gain ne peut être crédité deux fois.
- Préserver une référence sans talent pour mesurer l’effet réel de la progression ; ajuster la difficulté sur des essais humains.

Aucune modification du code, des statistiques ou de la distribution Windows n’accompagne cette note. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.
