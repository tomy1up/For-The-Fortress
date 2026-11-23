# Prototype v0.246 — Un attaquant par chapitre pair

Décisions du porteur du 23 novembre 2026. Statistiques et PV : réglages de prototype à confirmer en partie réelle.

## Cinq nouveaux attaquants

- **Bouquetin des crêtes** (Ardoises, missions 31 à 40) : sous la moitié de ses PV, il charge une fois, 70 % plus vite pendant 2 s.
- **Golem de magma** (Volcan, missions 71 à 80) : à sa mort, il éclate en deux Braises rapides.
- **Scorpion des dunes** (Désert, missions 111 à 120) : il avance deux fois plus vite pendant la Tempête de sable.
- **Taupe des galeries** (Mines, missions 131 à 140) : elle parcourt une case sur trois sous terre, où elle est intouchable.
- **Crabe pilleur** (Côtes, missions 171 à 180) : s'il atteint la forteresse, il vole 20 or en plus des dégâts.

Chaque biome a désormais son affixe et son attaquant. Ces créatures utilisent des silhouettes provisoires teintées, en attendant les dessins de Codex.

## Équilibrage

- **50 missions recalibrées** : sur toute la campagne, 371 réglages sur 398 sont dans la cible de 40 à 70 % de marge, aucun en dessous.
- Sur décision du porteur, trois réglages de l'Alliance passent sous la courbe de PV de base : missions 113 (96 %), 118 (92 %) et 180 (94 %).
- Fiche : `design/Attaquants_par_biome_v0246.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 110 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 651 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- 30 captures de combat des cinq attaquants inspectées dans les deux factions, et contrôle rapproché de la charge, de l'éclatement, de la course dans la tempête, du passage sous terre et du vol d'or.
