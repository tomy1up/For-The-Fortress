# Prototype v0.247 — Marches de la Tortue et de l'Ours

Dessins de Codex, validés par le porteur le 23 novembre 2026 et intégrés à sa demande.

## Nouvelles marches

- **Tortue gardienne des berges** : une planche de 60 images par foulée (lot `d5ed8d75`). Elle remplace l'illustration fixe.
- **Ours sauvage** : deux planches de 60 images, à plat ou en descente et en montée (lot `5a9e4c1e`). Il remplace aussi son illustration fixe.
- **Inclinaison sur le chemin** : les deux créatures penchent de 13,3° selon la pente et le sens du trajet (lot `a6951c04`). Seule la silhouette tourne autour de son ancre : l'ombre, la jauge et la phase de marche restent en place.

Les règles, les PV, les vitesses et l'équilibrage ne changent pas. Le Scorpion, le Crabe et la Taupe gardent leur silhouette provisoire fixe, en attendant leurs dessins.

Fiches : `design/Visuels_Marche_Tortue_Gardienne.md` et `design/Visuels_Marche_Ours.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 135 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 656 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- Validateur d'animations : 66 dossiers, aucun problème.
- Captures du jeu exporté inspectées dans les deux factions : Tortue et Ours en descente, en montée et au virage, inspection du gardien protégé.
