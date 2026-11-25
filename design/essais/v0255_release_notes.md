# Prototype v0.255 — Armée de référence en joueur avisé

Décisions du porteur du 25 novembre 2026 (« Joueur avisé d'abord », puis « Garantie des tests seulement »). La cible de difficulté ne change pas. Coefficients : réglages de prototype à confirmer en partie réelle.

## Ce qui change

- Dans les tests, l'armée de référence, qui doit gagner chaque mission, **choisit ses bonus comme un joueur avisé** : elle prend la carte la mieux notée pour sa faction et relance une offre faible. Sa garantie ne dépend presque plus du tirage : sur trois tirages, elle gagne 193 à 200 missions sur 200, contre 89 à 198 avant.
- **21 missions de la Horde** retrouvent les PV ennemis qu'elles avaient dû perdre en v0.254, quand la référence dépendait d'Exercice de tir au premier choix (missions 21 à 50, 81 à 91, 120, 141 à 177).
- Sur toute la campagne, **386 réglages sur 398** sont dans la cible (379 en v0.254). Restent au-dessus : missions 2 et 3 des deux factions (prise en main), Alliance 13, 33, 40 et 132, Horde 34 et 43. Juste en dessous : Alliance 67 et Horde 40.

Fiche : `design/Reference_avisee_v0255.md`.

## Contrôles

- Régression complète : 150 suites sur 150, 249 833 contrôles Godot, 17 tests Python (nouvelle suite `test_reference_wise.gd`).
- Garde des 28 suites de campagne avec l'armée de référence avisée : aucune défaite ; campagne remesurée sur les 398 réglages.
- Paquet Windows vérifié : 1 050 cas et 670 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur). Aucun visuel ne change dans cette version.
