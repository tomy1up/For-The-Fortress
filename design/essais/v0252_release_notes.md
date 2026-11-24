# Prototype v0.252 — Renforts de vague pour les missions trop faciles

Demande du porteur du 24 novembre 2026. Quantités, types et vagues : réglages de prototype à confirmer en partie réelle.

## Dix-huit missions renforcées

- Sur dix-huit réglages trop faciles, des **renforts** s'ajoutent à certaines vagues : sprinters aux vagues 3, 5 et 7, un maraudeur aux vagues 4, 6 et 8 (mission 41 de la Horde) ou deux élites aux vagues 5, 7 et 9 (mission 11 de la Horde).
- Alliance : missions 16, 23, 33, 39, 72, 79, 105, 173, 178 et 180. Horde : missions 11, 22, 38, 41, 44, 79, 131 et 175.
- Le boss de la vague 10 ne change pas. Les renforts sont propres à chaque faction et apparaissent dans l'aperçu des vagues et dans la préparation de la mission.
- Sur toute la campagne, **392 réglages sur 398** sont dans la cible de difficulté (374 auparavant), aucun en dessous. Restent au-dessus : missions 2 et 3 des deux factions (prise en main), missions 23 et 39 de la Horde.

Fiche : `design/Missions_renforts_v0252.md`.

## Contrôles

- Régression complète : 147 suites sur 147, 237 586 contrôles Godot, 17 tests Python (nouvelle suite `test_wave_reinforcements.gd`).
- Paquet Windows vérifié : 1 050 cas et 670 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures du jeu exporté inspectées en combat : mission 180 dans les deux factions (renforts côté Alliance seulement), missions 11, 38 et 41 de la Horde.
