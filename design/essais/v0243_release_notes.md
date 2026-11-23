# Prototype v0.243 — Décor du Gué dessiné

Habillage de Codex validé par le porteur le 23 novembre 2026 (lot 3feb9b09). Rendu seulement : aucune règle de jeu ne change.

## Décor

- **Missions 1 à 20** : sur les dix cartes des chapitres 1 et 2, cinq pièces dessinées remplacent les formes géométriques. Ce sont deux silhouettes de pin, une roche moussue, un buisson fleuri et des fougères. Les arbres fixes des cartes en profitent aussi. Les pièces gardent leurs places, et certaines sont légèrement réduites ou retournées en miroir.
- **Carte d'ouverture** (missions 1 et 11) : la rivière dessinée passe sous la chaussée, et le pont au-dessus, avant les unités. Le franchissement reste au même endroit.
- Toutes les cartes de la campagne ont désormais un décor dessiné.

## Contrôles

- **Régression complète** : 144 suites sur 144, 232 399 contrôles Godot, 17 tests Python. `test_decor_art.gd` (39 207 contrôles) vérifie les pièces et les calques par rapport à l'implantation de Codex, les cadres, et la couverture de l'ancienne rivière et de l'ancien pont.
- **Paquet Windows vérifié** : 1 050 cas réussis, 650 contrôles de sources, empreinte `d9487950…4612`.
- **Captures inspectées dans le paquet** : missions 1 à 10 en préparation, dans les deux factions. Les missions 11 à 20 réutilisent les mêmes cartes et n'ont pas de capture de jeu dédiée.
