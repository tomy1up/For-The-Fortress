# For the Fortress!

Jeu solo de Tower Defense roguelite dans un univers médiéval-fantasy coloré. Le joueur choisit entre l’Alliance des Royaumes et la Horde des Cendres, installe ses défenseurs sur des emplacements fixes et protège sa forteresse contre des vagues d’ennemis.

**Nom de travail : disponibilité juridique à confirmer.** Les noms des factions sont provisoires.

## Documents

- [GDD Word](For_the_Fortress_GDD.docx) : présentation structurée avec sommaire et tableaux.
- [GDD Markdown](For_the_Fortress_GDD.md) : référence éditoriale adaptée au versionnement Git.
- Version documentaire : **0.10 — 20 octobre 2026**, intégrant le socle, les combats, les ennemis, les dix vagues, la progression par niveau, les spécialisations, la géométrie du Gué et la résolution du combat approuvées.

## Mécaniques établies

- Deux factions jouables avec races, classes et orientations distinctes.
- Chemins fixes, emplacements prédéfinis et attaques automatiques.
- Achats, améliorations et ventes uniquement entre les vagues.
- Quatre niveaux par défenseur ; deux branches de spécialisation au niveau 4.
- Un bonus parmi trois propositions aléatoires, actif jusqu’à la fin de la partie.
- Synergies de diversité raciale, de spécialisation et de proximité.
- Revente à 70 % du total investi, suivie du recalcul des synergies.

## Prototype de référence

La Vallée du Gué : une carte isométrique, six emplacements et dix vagues. Six défenseurs, trois par faction. Capital initial de travail : 150 or ; forteresse : 20 PV. Choix roguelite après les vagues 3, 6 et 9. Durée ciblée : 8 à 12 minutes. Sept archétypes ordinaires sont retenus : Grouillant, Pillard, Sprinter, Brute, Maraudeur, Colosse et Élite. Le boss provisoire Seigneur de siège est prévu en vague 10. Leurs statistiques figurent dans le GDD comme réglages à tester.

Les coûts d’achat de 50, 75 et 100 or, les DPS de 8, 9,6 et 10,8 et les améliorations de 50, 100 et 150 or restent des **hypothèses non équilibrées**.

## Intentions commerciales

PC sur Steam en priorité ; Godot envisagé ; modèle premium avec prix de travail de 7,99 €. Cibles envisagées : deux factions, seize défenseurs, six cartes, environ soixante bonus, douze familles d’ennemis et six boss. Le mode infini est seulement envisagé. Ces cibles ne constituent pas des engagements de production.

## Séquence de référence des dix vagues

La [séquence détaillée des dix vagues](design/Proposition_dix_vagues.md) est approuvée pour le prototype et intégrée au GDD v0.6. Quantités et intervalles restent des réglages H. Elle prévoit 182 ennemis, 770 or de récompenses maximales et 4 min 33,1 s de fenêtres d’apparition, hors fins de combat et préparations.

## Progression approuvée

La [progression des niveaux 2 à 4](design/Proposition_progression_niveaux.md) est intégrée au GDD v0.7 : dégâts × 1 / 1,5 / 2,25 / 3,25 du N1 au N4, cadence et portée inchangées. Le principe est validé ; les valeurs restent des hypothèses H à tester. Les tableaux couvrent les six défenseurs, leurs effets secondaires et leurs coûts cumulés.

## Spécialisations approuvées

La [fiche des douze spécialisations](design/Proposition_specialisations.md) est intégrée au GDD v0.8. Le choix est inclus dans le coût du N4, exclusif et fixé jusqu’à la vente. Les effets sont approuvés ; les noms restent provisoires et les valeurs sont des hypothèses H à tester.

## Carte approuvée

La [fiche de La Vallée du Gué](design/Proposition_Vallee_du_Gue.md) est intégrée au GDD v0.9 : trajet de 28 unités et six emplacements, avec [plan](design/Vallee_du_Gue_plan.svg), couvertures et temps de traversée. Le tracé et les conventions sont approuvés ; les dimensions restent des valeurs H à tester. Le plan présente la géométrie vue du dessus, avant projection isométrique.

## Résolution du combat approuvée

La [fiche de résolution du combat](design/Proposition_resolution_combat.md) est intégrée au GDD v0.10 : premier tir, égalités, dégâts instantanés, malédictions hors portée et événements simultanés, avec douze cas de référence. Ces règles sont approuvées pour le prototype.

## Bonus roguelite proposés

La [proposition des douze bonus roguelite](design/Proposition_bonus_roguelite.md) couvre dégâts, cadence, portée, zones, niveaux, forteresse et prix. Elle précise le tirage des trois offres, le cumul et l’exclusion du chaman du bonus de cadence. **Statut P — à valider** ; le GDD approuvé reste en v0.10.

## Statuts et suivi

Le GDD utilise **V** validé, **H** hypothèse, **C** cible, **O** ouvert et **P** proposition. La feuille de route et les conventions de suivi sont proposées, sans nouvelle fonctionnalité approuvée. Les calculs économiques dérivés sont identifiés.

Le combat Alliance au niveau 1 est précisé dans le GDD : archer à 8 dégâts par seconde, arbalétrier à 24 dégâts toutes les 2,5 secondes et mage à 27 dégâts toutes les 2,5 secondes, avec jusqu’à deux cibles secondaires à 40 %. Portées initiales : 4, 5 et 3,5 unités. Les rôles et le ciblage de l’ennemi le plus avancé sont validés ; les nombres restent à tester.

Le combat Horde est également validé pour les essais : troll avec rebond, sapeur avec explosion et chaman avec malédiction. Leurs DPS théoriques sur une cible restent 8, 9,6 et 10,8. Les victimes secondaires les plus proches du point d’impact sont prioritaires. Tous les nouveaux réglages numériques restent provisoires.

Les éliminations rapportent immédiatement une récompense unique, identique pour les deux factions, y compris par malédiction. Un ennemi atteignant la forteresse inflige ses dégâts puis quitte la partie sans récompense. Aucune prime de fin de vague pour le premier essai.

Prochain travail proposé : définir les premiers bonus roguelite et leur tirage. Trancher aussi les arrondis, les synergies et les bonus avant les essais d’équilibrage. La progression entre les parties reste ouverte.

Mettre à jour le Markdown et le Word dans une même révision. Documenter toute modification avec un identifiant, une date, un statut, une source et son impact. Une valeur manquante reste « À définir » et ne vaut pas zéro.

Ce dossier contient des documents de conception ; il ne constitue pas encore un projet Godot jouable.
