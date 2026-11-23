# Prototype v0.244 — Un affixe par biome, première étape

Décision du porteur du 23 novembre 2026. Valeurs de prototype à confirmer en partie réelle.

## Règles

- **Chaque biome aura son affixe sur ses deux chapitres**, et son chapitre pair un nouvel attaquant. Cette version réalise la première étape : les cinq affixes existants couvrent désormais les deux chapitres de leur biome, avec les mêmes valeurs.
  - Vents contraires : chapitres 3 et 4.
  - Éruptions : chapitres 7 et 8.
  - Tempête de sable : chapitres 11 et 12.
  - Éboulement : chapitres 13 et 14.
  - Brume marine : chapitres 17 et 18.
- **Éboulement sur une carte à une seule entrée** (missions 121, 122, 125 et 128) : l'entrée est bloquée, les ennemis attendent puis sortent groupés. La prévision de vague, le bandeau et le rapport en tiennent compte.
- La fiche de mission affiche « Nouveau » au premier chapitre du biome et « Affixe » au second.

## Équilibrage

- **50 missions recalibrées** pour rester dans la cible de 40 à 70 % de marge : 96 cas sur 100 y sont. Hors cible : Alliance 23 (38 %) et 61 (72 %), Horde 22 (73 %) et 23 (75 %).
- Sur décision du porteur, huit cas passent légèrement sous la courbe de PV de base : Alliance 63, 64, 65 (98 %), 66 (96 %), 68 (94 %), 69 (92 %), Horde 66 (96 %), 68 (98 %).
- Fiche : `design/Affixe_par_biome_v0244.md`.

## À venir

- Cinq nouveaux affixes : Gué (dès la mission 2), Marais, Citadelle, Îles flottantes, Nécropole.
- Cinq nouveaux attaquants : Ardoises, Volcan, Désert, Mines, Côtes.

## Contrôles

- **Régression complète** : 144 suites sur 144, 234 230 contrôles Godot, 17 tests Python. `test_rockfall.gd` (1 950 contrôles) vérifie l'Éboulement à une seule entrée (ordre des ennemis, sorties, prévision, bandeau, rejeu) et le même affixe sur les deux chapitres de chaque biome.
- **Mesure d'équilibre** : 9 000 parties sur les 50 missions, 30 compositions, trois tirages, première offre de bonus.
- **Paquet Windows vérifié** : 1 050 cas réussis, 650 contrôles de sources, empreinte `e41d6f83…d62b`.
- **Captures inspectées dans le paquet, deux factions** : 44 vues en combat des missions 24, 29, 63, 68, 105, 109, 121, 124, 125, 165 et 169, à l'annonce et pendant l'effet, dont l'Éboulement sur une seule entrée (121 et 125) et la sortie groupée.
