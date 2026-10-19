# For the Fortress!

Jeu solo de Tower Defense roguelite dans un univers médiéval-fantasy coloré. Le joueur choisit entre l’Alliance des Royaumes et la Horde des Cendres, installe ses défenseurs sur des emplacements fixes et protège sa forteresse contre des vagues d’ennemis.

**Nom de travail : disponibilité juridique à confirmer.** Les noms des factions sont provisoires.

## Documents

- [GDD Word](For_the_Fortress_GDD.docx) : présentation structurée avec sommaire et tableaux.
- [GDD Markdown](For_the_Fortress_GDD.md) : référence éditoriale adaptée au versionnement Git.
- Version documentaire : **0.4 — 19 octobre 2026**, consolidée à partir du GDD v0.1, de cinq captures et des règles de combat approuvées pour les deux factions.

## Mécaniques établies

- Deux factions jouables avec races, classes et orientations distinctes.
- Chemins fixes, emplacements prédéfinis et attaques automatiques.
- Achats, améliorations et ventes uniquement entre les vagues.
- Quatre niveaux par défenseur ; deux branches de spécialisation au niveau 4.
- Un bonus parmi trois propositions aléatoires, actif jusqu’à la fin de la partie.
- Synergies de diversité raciale, de spécialisation et de proximité.
- Revente à 70 % du total investi, suivie du recalcul des synergies.

## Prototype de référence

La Vallée du Gué : une carte isométrique, six emplacements et dix vagues. Six défenseurs, trois par faction. Capital initial de travail : 150 or ; forteresse : 20 PV. Choix roguelite après les vagues 3, 6 et 9. Durée ciblée : 8 à 12 minutes. Sept archétypes d’ennemis et un boss sont visés, avec leurs détails encore à définir.

Les coûts d’achat de 50, 75 et 100 or, les DPS de 8, 9,6 et 10,8 et les améliorations de 50, 100 et 150 or restent des **hypothèses non équilibrées**.

## Intentions commerciales

PC sur Steam en priorité ; Godot envisagé ; modèle premium avec prix de travail de 7,99 €. Cibles envisagées : deux factions, seize défenseurs, six cartes, environ soixante bonus, douze familles d’ennemis et six boss. Le mode infini est seulement envisagé. Ces cibles ne constituent pas des engagements de production.

## Statuts et suivi

Le GDD utilise **V** validé, **H** hypothèse, **C** cible, **O** ouvert et **P** proposition. La feuille de route et les conventions de suivi sont proposées, sans nouvelle fonctionnalité approuvée. Les calculs économiques dérivés sont identifiés.

Le combat Alliance au niveau 1 est précisé dans le GDD : archer à 8 dégâts par seconde, arbalétrier à 24 dégâts toutes les 2,5 secondes et mage à 27 dégâts toutes les 2,5 secondes, avec jusqu’à deux cibles secondaires à 40 %. Portées initiales : 4, 5 et 3,5 unités. Les rôles et le ciblage de l’ennemi le plus avancé sont validés ; les nombres restent à tester.

Le combat Horde est également validé pour les essais : troll avec rebond, sapeur avec explosion et chaman avec malédiction. Leurs DPS théoriques sur une cible restent 8, 9,6 et 10,8. Les victimes secondaires les plus proches du point d’impact sont prioritaires. Tous les nouveaux réglages numériques restent provisoires.

Prochain travail proposé : définir les ennemis et revenus nécessaires au premier essai. Trancher ensuite les arrondis, spécialisations, synergies, bonus et vagues. La progression entre les parties reste ouverte.

Mettre à jour le Markdown et le Word dans une même révision. Documenter toute modification avec un identifiant, une date, un statut, une source et son impact. Une valeur manquante reste « À définir » et ne vaut pas zéro.

Ce dossier contient des documents de conception ; il ne constitue pas encore un projet Godot jouable.
