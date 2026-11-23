# Prototype v0.245 — Un affixe par biome, deuxième étape

Décisions du porteur du 23 novembre 2026. Ampleur des effets et PV : réglages de prototype à confirmer en partie réelle.

## Cinq nouveaux affixes

- **Crue** (Gué, dès la mission 2) : pendant 4 s, les ennemis avancent 10 % plus vite.
- **Vapeurs toxiques** (Marais) : pendant 4 s, les défenseurs infligent 20 % de dégâts en moins.
- **Cor d'alarme** (Citadelle) : toutes les 15 s, les ennemis présents reçoivent un bouclier de 10 % de leurs PV maximum.
- **Courants ascendants** (Îles flottantes) : toutes les 15 s, les ennemis présents bondissent d'une case vers la forteresse.
- **Drain d'âmes** (Nécropole) : pendant 4 s, chaque ennemi éliminé soigne ses voisins blessés de 10 % de leurs PV maximum, boss exclus.

Chaque biome a désormais son affixe sur ses deux chapitres. La mission 1 reste sans affixe. Ces effets sont dessinés par le code en attendant l'habillage de Codex.

## Rythme resserré

Une vague dure environ 44 à 71 s : les anciens affixes se déclenchaient trop rarement. Sur décision du porteur, les effets durent 4 s toutes les 12 s, l'Éboulement 5 s toutes les 12 s, le Cor d'alarme et les Courants ascendants se déclenchent toutes les 15 s. Les Vents contraires, permanents, ne changent pas.

## Équilibrage

- **199 missions recalibrées** : 379 réglages sur 398 sont dans la cible de 40 à 70 % de marge, aucun en dessous.
- Sur décision du porteur, 20 réglages passent ou descendent sous la courbe de PV de base, de 94 à 98 %. 27 réglages sont désormais sous cette courbe.
- Fiche : `design/Affixe_par_biome_v0245.md`.

## Visuel

- Relève du Revenant redessinée en seize images complètes (Codex, validée par le porteur).

## À venir

- Cinq nouveaux attaquants : Ardoises, Volcan, Désert, Mines, Côtes.

## Outils

- La vérification du paquet et les captures tournent désormais sur un bureau Windows caché : aucune fenêtre de jeu n'apparaît et le clavier et la souris restent au joueur.

## Contrôles

- Régression complète : 145 suites sur 145, 236 108 contrôles Godot, 17 tests Python.
- Paquet Windows : 1 050 cas et 650 contrôles de sources, sans aucune fenêtre du jeu détectée sur le bureau du joueur.
- 88 captures de combat des dix affixes inspectées dans les deux factions.
