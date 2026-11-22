# Prototype v0.236 — Fin du recalibrage, sept gestes de boutique animés

Valeurs de prototype à confirmer en partie réelle.

## Difficulté

- Recalibrage terminé pour les deux factions (demande du porteur du 21 novembre 2026). Douze missions de l'Alliance remontent, surtout aux chapitres 7 et 13, que bridaient les anciennes règles de bonus de leurs tests. Neuf missions de la Horde remontent de 1 à 3 points.
- Mesure sur 36 000 parties :
  - **Alliance** : meilleure marge moyenne 54,7 %, 185 missions sur 200 dans la cible (174 en v0.235), 8 au-dessus ;
  - **Horde** : 58,5 %, 174 dans la cible, 24 au-dessus (inchangé) ;
  - chapitres 7 et 13 de l'Alliance : 54 et 50 % (63 et 70 % avant).
- **Nouvelle mesure, le choix de bonus guidé.** Le joueur simulé essaie chaque offre et la relance avant de choisir, en voyant leur issue : c'est une borne haute d'un joueur qui choisit bien.
  - La meilleure composition finit alors vers 90 % de marge dans les deux factions.
  - Aucune mission n'est perdue, même sur le tirage le moins favorable.
  - La forte dépendance de la Horde au tirage venait donc de la stratégie de test qui prend toujours la première offre.
- Fiche : `design/Rebalancage_v0236.md`.

## Animations (lots de Codex validés par le porteur)

- **Prêtre guerrier (type 32)** : trois visées (20 poses sur 0,8 s). L'éclat doré part de la paume avancée à 0,32 s et file en ligne droite ; impact seul si la cible est derrière la paume. La vue est choisie selon l'angle dessiné le plus proche du trajet.
- **Chamane des marais (type 33)** : rituel de 33 poses sur 0,88 s. La volute du feu follet part de la main à 0,40 s, debout, en ligne droite, retournée avec la pose, sans éclair de famille. Ralentissement et malédiction inchangés.
- **Totem de guerre (type 34)** : l'impulsion part de la gemme à 0,30 s, en ligne droite. Le premier losange posé par le Totem apparaît à son arrivée, à 0,42 s. Les marques déjà visibles et celles de Marque du chasseur s'affichent comme avant.
- **Ancien des tribus (type 35)** : frappe du tambour (22 poses sur 0,88 s). L'onde cuivrée part à 0,36 s au contact de la mailloche, en ligne droite.
- **Marchand mercenaire (type 36)** : la pièce part à 0,40 s du repère de Codex, en ligne droite. Pillage inchangé.
- **Piégeur nain (type 37)** : la cartouche part de la main ouverte à 0,36 s et fait un tour complet sur un arc de 16 px.
- **Alchimiste gnome (type 39)** : la fiole ambrée part de la main ouverte à 0,40 s (image 20) et fait un tour complet sur l'arc existant. Volatilité et réaction en chaîne inchangées.
- Dégâts, cadences et effets de ces unités ne changent pas.

## Contrôles

- Régression complète : 144 suites sur 144, 197 379 contrôles Godot et 17 tests Python.
- Validateur des animations : 55 dossiers, aucun problème.
- Nouveaux contrôles dans `test_shop_effects.gd` (93 contrôles au total) : instants de départ, repères retournés, vues du Prêtre, vols rectilignes ou en arc, losange différé du Totem. `test_shop_art.gd` vérifie désormais le repère de l'animation pour les unités qui en ont un.
- Paquet Windows vérifié : 1 050 cas, 568 sources comparées.
- Contrôle visuel : 126 captures des sept gestes (six emplacements de la Vallée du Gué, avant, pendant et après le départ) ; PV affichés de la mission 125 conformes dans les deux factions (Alliance 278 %, Horde 343 %).
