# Prototype v0.250 — Crue et Vapeurs toxiques dessinées

Dessins de Codex, validés par le porteur le 24 novembre 2026 et intégrés à sa demande.

## Crue (Gué, missions 2 à 20)

- Des **filets d'eau** annoncent la crue sur la chaussée.
- Une **lame d'eau** monte au centre de la route, avec des rides et de l'écume qui descendent vers la forteresse, puis se retire. Sur la carte du Gué, le pont passe par-dessus.

## Vapeurs toxiques (Marais, missions 41 à 60)

- Les **bassins fument** pendant l'annonce.
- Pendant l'effet, des **nappes vertes** s'élèvent des bassins et une **volute** s'installe au pied de chaque défenseur, puis se dissipe.

Les règles, les durées et l'équilibrage ne changent pas. Fiches : `design/Visuels_Crue_Gue.md` et `design/Visuels_Vapeurs_Toxiques.md`.

## Contrôles

- Régression complète : 146 suites sur 146, 237 182 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 670 contrôles de sources, sur bureau Windows caché, sans aucune fenêtre du jeu sur le bureau du joueur.
- Captures de combat du jeu exporté inspectées dans les deux factions sur les missions 4, 11, 51 et 58 : annonce, montée, retrait, pont du Gué et défenseurs dans les vapeurs.
