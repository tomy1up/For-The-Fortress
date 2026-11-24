# Prototype v0.249 — Éboulement et Drain d'âmes dessinés

Dessins de Codex, validés par le porteur le 24 novembre 2026 et intégrés à sa demande.

## Éboulement (Mines, missions 121 à 140)

- Les rochers **tombent en cinq chutes successives** dès l'activation (0,68 s), forment le tas, puis **se dégagent** sur les 0,54 dernières secondes du blocage.
- Les horaires de blocage et de réouverture ne changent pas.

## Drain d'âmes (Nécropole, missions 181 à 200)

- Des **volutes violettes** montent près des bords du plateau pendant l'annonce et pendant l'effet.
- À chaque soin, un **éclat** marque la chute de l'ennemi, une **âme** file vers chaque ennemi soigné et un **éclat d'absorption** suit ce dernier pendant sa marche.
- Le soin reste appliqué à l'élimination, avec la même valeur.

Les règles, les PV et l'équilibrage ne changent pas. Fiches : `design/Visuels_Transitions_Eboulement.md` et `design/Visuels_Drain_Ames.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 160 contrôles Godot, 17 tests Python.
- Validateur d'animations : 67 dossiers, aucun problème.
- Paquet Windows : 1 050 cas et 664 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- Captures de combat du jeu exporté inspectées dans les deux factions sur les missions 121, 134, 181 et 191, et contrôle rapproché de la chute, du dégagement et du transfert des âmes.
