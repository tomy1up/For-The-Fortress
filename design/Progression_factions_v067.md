# Progression permanente par faction — prototype v0.67

27 octobre 2026. Première réalisation de l’orientation roguelite demandée par le porteur du projet, à partir du [cadrage](Proposition_progression_factions_2026-10-27.md). Ce complément remplace, pour la progression entre parties, l’ancienne règle temporaire de départs à égalité. Le GDD principal conserve sa version v0.14 ; les décisions et limites ci-dessous font foi pour ce lot.

## Décisions et hypothèses

| Élément | Statut |
| --- | --- |
| Progression permanente, points et trois arbres par faction | Orientation demandée, mise en prototype |
| Points consommés par une affectation, sans double utilisation entre factions | Règle demandée |
| Ressources et points séparés selon la faction jouée | Variante proposée par le porteur du projet, retenue pour ce premier lot à la suite de sa demande de poursuivre |
| Respécialisation payante, coût croissant puis plafonné | Décision explicitement validée |
| Compteurs de respécialisation séparés par faction | Décision explicitement validée |
| Prix, effets, prérequis, portée du reset et rythme des gains | Hypothèses de prototype, modifiables après essais |
| Première victoire presque impossible sans talent | Intention de difficulté à étudier ; aucun durcissement des vagues dans ce lot |

## Parcours du joueur

Au choix de faction, deux accès ouvrent les talents Alliance et Horde. Le joueur voit sa ressource, les points disponibles et les trois arbres du camp choisi. Acheter un point puis investir un rang sauvegarde immédiatement l’opération. Les talents sont appliqués au moment de choisir la faction et restent figés pendant toute la tentative.

Après chaque vague terminée, les ressources gagnées sont sauvegardées et indiquées dans la barre latérale. Une défaite ne reprend pas les gains précédemment enregistrés. L’or de recrutement reste propre à la tentative et distinct des ressources permanentes. Aucun gain n’est attribué au temps passé, aux victimes individuelles ou à la simple relance d’une partie. Une vague perdue ne rapporte pas de récompense de vague terminée.

Pour changer de talents, le joueur revient au choix de faction via un nouvel essai, entre deux vagues ou après le résultat. Les modifications ne sont pas proposées pendant une tentative. Aucune sauvegarde de la partie en cours n’est ajoutée.

## Barème d’essai

| Opération | Valeur provisoire |
| --- | --- |
| Vague terminée | Son numéro en ressources du camp joué : 1, 2, …, 10 |
| Prime de victoire | +5 ressources de ce même camp |
| Campagne complète | 60 ressources au total |
| Achat d’un point | 10 ressources de sa faction |
| Réinitialisation n°1 à n°5 | 2, 4, 6, 8, 10 ressources |
| Réinitialisations suivantes | 10 ressources, plafond fixe |
| Coût d’un rang | 1 point |
| Base de chaque arbre | 3 rangs maximum |
| Spécialités | 1 rang chacune ; trois rangs de base requis ; choix exclusif entre les deux |
| Points achetables dans ce premier contenu | 12 par faction, correspondant à tous les rangs simultanément investissables |

Le premier point est accessible après quatre vagues terminées dans une tentative, ou grâce aux gains cumulés de plusieurs défaites. Le plafond de douze points évite un achat sans utilité dans le contenu actuel ; il ne préjuge pas d’un plafond de progression à long terme ni d’un futur système de configurations.

## Arbres Alliance

| Arbre | Base, par rang | Spécialité A | Spécialité B |
| --- | --- | --- | --- |
| Bastion | Remparts renforcés : +1 PV maximum | Résistance : +3 PV maximum | Vigilance : +0,15 de portée de tous les défenseurs |
| Maîtrise du tir | Entraînement : +3 % aux tirs de l’archer et de l’arbalétrier | Tirs concentrés : +8 % à leurs tirs | Couverture : +0,3 à leur portée |
| Arts arcaniques | Étude des arcanes : +3 % aux dégâts directs et secondaires du mage | Puissance directe : +8 % au tir principal du mage | Déflagration : +15 % aux explosions du mage |

## Arbres Horde

| Arbre | Base, par rang | Spécialité A | Spécialité B |
| --- | --- | --- | --- |
| Fureur de guerre | Entraînement : +3 % au tir principal du lanceur de haches | Frappe précise : +8 % à son tir principal | Ricochets : +15 % à ses rebonds |
| Voie des maléfices | Rituels : +3 % aux tirs et malédictions du chaman | Choc initial : +8 % au tir principal du chaman | Usure : +15 % à ses malédictions |
| Démolition | Explosifs : +3 % aux tirs et explosions du sapeur | Impact : +8 % au tir principal du sapeur | Détonation : +15 % à ses explosions |

Les pourcentages s’ajoutent aux autres bonus de dégâts sur la référence de chaque composante ; ils ne se multiplient pas entre eux. Les bonus de portée s’ajoutent à la portée réelle. Les PV supplémentaires sont accordés au début de la tentative et ne soignent pas en cours de combat. Les prévisions, dégâts réels, synergies et comparaisons de bonus utilisent ces mêmes statistiques.

Ces arbres reprennent les orientations du cadrage avec des effets volontairement limités aux systèmes existants. Leurs noms, effets et asymétries sont des propositions jouables ; aucune conclusion d’équilibrage ou de durée de vie n’est présumée.

## Respécialisation

Le reset porte sur les trois arbres de la faction affichée. Une confirmation présente le prix et le nombre de points rendus. Confirmer prélève la ressource de cette faction, rend ses points disponibles et incrémente uniquement son compteur. Les points déjà achetés ne sont ni détruits ni à racheter. Le profil de l’autre faction est inchangé.

Annuler, manquer de ressources, réinitialiser des arbres vides ou rencontrer un échec d’enregistrement ne prélève rien et ne fait pas avancer le compteur.

## Persistance et rapports

Le profil local `user://progression_factions_v1.json` conserve deux banques, leurs points, leurs rangs, leurs compteurs de resets et l’identifiant du dernier parcours de gains. Une vague déjà créditée ou un identifiant de tentative ancien ne peut pas donner de nouveau gain. Le dernier parcours remplace le précédent ; aucun journal illimité de tentatives n’est accumulé.

Chaque mutation est préparée dans une copie, écrite dans un fichier temporaire puis publiée en mémoire après remplacement réussi du profil. Le fichier `.bak` conserve l’état principal valide précédent. Un principal illisible peut être récupéré depuis ce secours ; si les deux sont invalides, la progression est bloquée et les fichiers sont préservés. Ce mécanisme vise les erreurs d’écriture et corruptions simples ; il ne garantit pas l’intégrité après toute panne de disque ou coupure d’alimentation. Le profil local n’est pas un dispositif anti-triche.

Les tests et captures utilisent un profil éphémère ou des fichiers dédiés, jamais le profil réel. Les rapports de partie avec talents incluent un cliché des neuf rangs de la faction ; leur rejeu utilise ce cliché sans charger le profil utilisateur. Les rapports historiques sans talents gardent le comportement de référence.

## Limites et suite

Ce premier lot ne comprend pas de nouvelles cartes, nouveaux niveaux de difficulté, cosmétiques, consommables ou autres dépenses permanentes. La puissance sans talent et les vagues sont conservées comme référence. Les talents ne sont pas encore équilibrés pour rendre la première victoire exceptionnellement rare ; mesurer cet objectif nécessite des essais humains.

La suite doit mesurer les revenus par minute, le rythme d’achat des premiers points, le coût ressenti de la respécialisation, l’intérêt des spécialités et les écarts entre factions. Le nombre final de talents, leurs prérequis, leurs effets majeurs et les autres usages de la ressource restent ouverts.

For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Validation

41 suites et 16 147 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 173 nouveaux contrôles couvrent les banques séparées, gains uniques, achats, prérequis, spécialités exclusives, prix plafonné, compteurs indépendants, annulation, reprise du profil, secours, refus d’écrasement d’un profil illisible, échec d’écriture, effets exacts des six défenseurs, absence d’effet sur les unités adverses, intégration de l’interface et rejeu d’un rapport avec talents.

Le paquet final a passé 92 lancements et produit 91 captures ; ses 35 sources correspondent au projet local. [Arbres Alliance](essais/captures/QA-v067_alliance_talents.png), [arbres Horde](essais/captures/QA-v067_horde_talents.png), confirmations [Alliance](essais/captures/QA-v067_alliance_talents_reset.png) et [Horde](essais/captures/QA-v067_horde_talents_reset.png) inspectées. Les quatre captures de talents utilisent des profils éphémères ; les tests de persistance emploient des fichiers dédiés.

Les campagnes de référence sans talent conservent leurs résultats. Aucun nouveau retour humain ni campagne humaine complète avec talents n’est revendiqué. [Régression](essais/v067_regression.json) et [distribution](Distribution_Windows_v067.json).
