# Prototype v0.248 — Trois missions de la Horde durcies

Décision du porteur du 24 novembre 2026. Réglages de prototype à confirmer en partie réelle.

## Équilibrage

- **Mission 34** : +1 % de PV, meilleure marge de 72 à 48 %.
- **Mission 37** : +1 % de PV, meilleure marge de 93 à 70 %.
- **Mission 64** : +1 % de PV, meilleure marge de 75 à 68 %.

Sur toute la campagne, 374 réglages sur 398 sont dans la cible de 40 à 70 %, aucun en dessous et 24 au-dessus. Les 24 restants ne peuvent pas rejoindre la cible par les PV sans faire perdre l'armée de référence ou sans tomber sous 40 %.

Fiche : `design/Missions_trop_faciles_v0248.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 135 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 656 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- Captures de combat du jeu exporté inspectées côté Horde sur les missions 34, 37 et 64.
