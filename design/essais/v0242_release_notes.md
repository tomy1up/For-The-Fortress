# Prototype v0.242 — Décors refaits et dessinés (Ardoises, marais, chapitres 10 et 16 à 20), repères compacts, relève du Revenant

Habillages de Codex validés par le porteur le 22 novembre 2026. Rendu seulement : aucune règle de jeu ne change.

## Décor

- **Décor refait des chapitres 10 et 16 à 20** (validation du porteur : « tous ») :
  - la garnison, missions 91 à 100 (lot 60d007d) ;
  - l'aire de l'aigle, missions 151 à 160 (lot a1ba5d3) ;
  - les côtes et récifs, missions 161 à 180 (lot 8fb925c) ;
  - la nécropole, missions 181 à 200 (lot 8fb925c).
- Les placements de Codex, adaptés aux routes refondues, sont activés. Toutes les cartes refondues ont désormais leur décor.

## Ardoises, missions 21 à 40

- **Pins et rochers dessinés** (lot 6ecb5d3) : six pièces dessinées remplacent les formes géométriques : deux pins, un cairn, des éboulis, des dalles et des dalles à lichen. Chaque carte a sa sélection, et les pièces sont parfois réduites ou retournées en miroir. Les crêtes reçoivent un pin incliné, les cairns marquent les portes et les passages. Les positions, les routes et les emplacements ne changent pas.
- Le décor du Gué (missions 1 à 20) est livré par Codex et attend l'avis du porteur.

## Marais, missions 41 à 60

- **Bassins dessinés** (lots 5ae3c06, 65638f3 et 933da20) : chaque carte reçoit un calque de bassins aux berges irrégulières, avec une eau plus profonde au centre, des rides et des feuilles flottantes. Il remplace les bassins géométriques, sous la chaussée.
- **Objets dessinés** : saules et roseaux, plus deux ruines, une petite arche et un pan de mur effondré. Ils remplacent les formes géométriques, dans les mêmes cadres. Le Cloître submergé garde l'arche, la Nef effondrée reçoit le mur effondré.
- Les positions des bassins, des objets, des routes et des emplacements ne changent pas.
- Aux missions 51 à 60, l'eau des bassins reste plus sombre que la chaussée inondée, où Gueule-de-Vase se régénère : les deux restent faciles à distinguer. Les calques des tronçons inondés ne changent pas.

## Effets de boutique

- **Repères compacts** (lots 815fc15 et eb15ffb) : une cible isolée garde ses pastilles rondes (marque, pillage, volatilité). Quand une autre cible porteuse d'un état passe à moins de 64 px, les cercles s'effacent au profit d'une rangée de symboles sur fond sombre, reliée à la jauge de PV. La rangée est complète à 40 px.
- Quand l'état d'une cible voisine apparaît, expire ou disparaît avec elle, le passage se fait en un quart de seconde de combat, sans saut. Il suit la vitesse du jeu et s'arrête avec la pause. Les bornes de distance et la durée sont des réglages de prototype à confirmer.

## Revenant

- **Relève sans glissement** (signalé par Codex, lot 7cdfeaf). Le Revenant continue d'avancer pendant ses 0,72 s de relève : la règle de combat ne change pas, et il se relève toujours avec 50 % de ses PV. Ses premières poses basses glissaient pourtant d'environ 20 px sur la route.
- Son appui reste maintenant au point de chute pendant les poses basses (0,27 s). Il rejoint ensuite progressivement sa position de marche le long de la route, virages compris. Les tirs et le survol gardent sa position réelle. Réglage de prototype à confirmer.

## Garnison

- **Éclat d'élimination des capitaines** (lot 17c7c760) : quand un capitaine de garnison, humain ou orc, tombe, un éclat ambré de 0,25 s marque le sol à ses pieds, au moment où le projectile arrive. Il remplace les particules génériques. Le capitaine garde sa flexion, son fondu ou sa planche de mort.
- Des capitaines tombés presque ensemble, à moins de 43 px et 45 ms d'écart, partagent un seul éclat centré, un peu plus grand. Les seuils sont des réglages de prototype à confirmer.

## Contrôles

- **Régression complète** : 144 suites sur 144, 232 019 contrôles Godot, 17 tests Python.
  - `test_decor_art.gd` (38 827 contrôles) vérifie les calques des marais et les pièces des Ardoises par rapport aux implantations de Codex. Il vérifie aussi les marges de toutes les pièces de décor, désormais aux chapitres 13 à 20 compris.
  - `test_shop_effects.gd` (174) vérifie les repères compacts et leur raccord quand un état voisin apparaît, expire ou disparaît, en pause et à une nouvelle vague.
  - `test_revenant.gd` (44) vérifie l'appui tenu puis raccordé pendant la relève, avec une règle de combat inchangée.
  - `test_elimination_effects.gd` (55) vérifie l'éclat des capitaines et leur regroupement.
- **Paquet Windows vérifié** : 1 050 cas réussis, 643 contrôles de sources, empreinte `977baf0f…fd46`.
- **Captures inspectées dans le paquet** : préparation des missions 23 à 40 (Ardoises), 41 à 60 (marais), 91 à 100, 151 à 160, 161 à 180 et 181 à 200.
- **Limite** : les repères compacts, la relève du Revenant et l'éclat des capitaines ne sont pas couverts par les captures automatiques. Ils sont vérifiés par les tests seulement.
