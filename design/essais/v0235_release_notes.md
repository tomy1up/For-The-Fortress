# Prototype v0.235 — Nouvelle référence de la Horde, signal de l'Éclaireur-observateur

Valeurs de prototype à confirmer en partie réelle.

## Difficulté de la Horde

- **Nouvelle composition de référence** des tests de campagne pour la Horde, décidée par le porteur le 21 novembre 2026 : deux sapeurs gobelins et un chaman orc, arbre Démolition, **à partir de la mission 71**. Jusqu'au chapitre 7, la référence reste deux lanceurs de haches et un chaman. Jusqu'ici, cette armée devait gagner toutes les missions, ce qui empêchait de durcir 89 missions trop faciles.
- Les suites des chapitres 4, 7 et 13 jouaient encore avec les anciennes règles de bonus (douze bonus, trois choix). Elles jouent maintenant avec les règles actuelles.
- PV d'ennemis de la Horde recalculés pour les missions 31 à 40 et 61 à 200 : coefficient moyen 126,7 % (122,2 % en v0.234), 100 missions relevées, 9 légèrement abaissées. L'Alliance ne change pas.
- Mesure sur 18 000 parties de la Horde (200 missions, 30 compositions, trois tirages) :
  - meilleure marge moyenne **58,7 %** (69,4 % en v0.234 ; Alliance 56,3 %) ;
  - **174 missions sur 200 dans la cible** de 40 à 70 % (108 en v0.234), 24 au-dessus, 2 en dessous ;
  - chapitre 7 : 57 % (90 % avant) ; chapitre 13 : 52 % (95 % avant).
- Fiche : `design/Rebalancage_v0235.md`. Les rapports des versions antérieures se rejouent avec leurs PV enregistrés.

## Animations

- **Éclaireur-observateur (type 31)** : garde à genou et signal au fanion de Codex (lot `88784cf`, geste complet validé par le porteur). 28 images sur 0,896 s ; le bras reste tendu 0,288 s avant le retour en garde.
- Le losange de marquage apparaît à 0,32 s, sur la première pose où l'Éclaireur pointe l'ennemi. La flèche héritée de sa famille n'est plus dessinée, et l'impact non plus. Ses 3 dégâts s'affichent au même moment.
- Une marque déjà visible reste affichée quand l'Éclaireur la renouvelle, y compris celle de Marque du chasseur. Une Marque du chasseur posée pendant le geste s'affiche aussitôt. Le marquage et son bonus de +55 % s'appliquent toujours dès le tir dans la simulation.

## Limites connues

- La Horde dépend davantage du tirage des bonus : sur le tirage le moins favorable, sans choisir ses bonus, 49 missions sont perdues par toutes les compositions testées (9 pour l'Alliance). Un joueur qui choisit ses bonus et utilise la relance fera mieux.
- Les chapitres 1, 3, 4 et 5 de la Horde gardent quelques missions au-dessus de 70 % (19 sur les 24 encore au-dessus de la cible).

## Contrôles

- Régression complète : 144 suites sur 144, 197 305 contrôles Godot et 17 tests Python. Les 15 suites de chapitre concernées passent avec la nouvelle référence.
- Nouveaux contrôles de l'Éclaireur-observateur dans `test_shop_effects.gd` : délai de 0,32 s, planche de 28 poses, absence de projectile, losange retardé, renouvellement et Marque du chasseur.
- Validateur des animations : 48 dossiers, aucun problème.
- Paquet Windows vérifié : 1 050 cas, 537 sources comparées.
- Contrôle visuel : 30 captures de l'Éclaireur (six emplacements de la Vallée du Gué, de 0,20 à 0,90 s) ; PV affichés des missions 75 et 125 conformes dans les deux factions.
