# Prototype v0.251 — Ours mieux espacés après l'Éboulement

Décision du porteur du 24 novembre 2026. Réglage de prototype à confirmer en partie réelle.

## Mines à une seule entrée (missions 121, 122, 125 et 128)

- Après un Éboulement, les ennemis retenus ressortent à **0,6 s d'écart** au lieu de 0,3 s. Les jauges des ours se séparent et on les compte mieux. Leurs corps se chevauchent encore en partie.
- Deux réglages devenus un peu trop faciles sont recalés à **+1 % de PV** : mission 121 de la Horde (marge 68 %) et mission 125 de l'Alliance (65 %). Les huit réglages de ces missions restent dans la cible de 40 à 70 %.

Fiche : `design/Missions_mines_ecart_eboulement_v0251.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 183 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 670 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- Captures du jeu exporté inspectées dans les deux factions sur les missions 121, 125 et 128 après la réouverture, et comparatif des écarts de 0,3, 0,6 et 1 s.
