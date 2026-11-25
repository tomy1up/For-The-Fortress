# Prototype v0.257 — Difficultés : le socle de l'Héroïque

Lot 1 du cadrage des difficultés, lancé par le porteur le 25 novembre 2026. Hausse de PV et PO de l'Héroïque : réglages de prototype à confirmer.

## Ce qui change

- L'écran de campagne a **trois onglets : Normal, Héroïque, Mythique**. Chaque difficulté a sa propre progression, faction par faction.
- **L'Héroïque s'ouvre** quand les 100 premières missions du Normal sont réussies. Tant qu'il est fermé, l'onglet affiche où vous en êtes (par exemple 99 / 100).
- **L'Héroïque se joue sur les mêmes 200 missions**, débloquées une à une, avec 30 % de PV ennemis en plus (provisoire) et des PO majorées de moitié à la première victoire, sans XP. La mention « Héroïque » apparaît en partie et dans le bilan.
- **Le Mythique** a son onglet, mais il n'est pas encore jouable (course par chapitre en préparation).
- Votre progression actuelle est intacte : elle reste celle du Normal.

À venir dans les prochains lots : champions mutants, cumul des nouveautés des biomes, bonus héroïques, calibrage de l'Héroïque, puis le Mythique.

Fiche : `design/Difficultes_socle_v0257.md`.

## Contrôles

- Régression complète : 151 suites sur 151, 249 930 contrôles Godot, 17 tests Python (nouvelle suite `test_difficulties.gd`).
- Paquet Windows vérifié : 1 050 cas et 670 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées, depuis les sources et le jeu exporté : onglets Normal, Héroïque (ouvert et verrouillé) et Mythique, partie héroïque (titre et récompense).
