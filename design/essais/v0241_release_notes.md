# Prototype v0.241 — Rafales des Vents contraires, dégâts des forteresses, bandeau d'affixe en haut de l'écran

Valeurs et placements de prototype à confirmer en partie réelle.

## Visuels de Codex validés par le porteur

- **Rafales au sol des Vents contraires** (chapitre 4, lot 208a6aa) : des traînées gris bleuté rasent le plateau de droite à gauche, sous le décor et les unités, pendant le combat. La planche de 60 images boucle en 2,5 s, suit le temps de combat et s'arrête avec la pause. La règle ne change pas : les défenseurs attaquent 10 % moins souvent. Les anciennes traînées ne servent plus que de repli.
- **Dégâts des forteresses** (lot c81b52a) : la forteresse endommagée (50 % des PV ou moins), en danger (25 % ou moins) puis détruite reçoit un calque de dégâts dessiné pour sa faction. Ce calque remplace la fissure générique. Les fissures de l'Alliance suivent les joints de pierre, les fentes de la Horde suivent les montants en bois. La fumée, le roi, la bannière et les seuils de PV ne changent pas.
- **Décor refait du chapitre 15** (îles flottantes, missions 141 à 150, lot 60d2efe) : les placements adaptés aux routes refondues sont activés.
- Restent inactifs en attendant l'avis du porteur : le décor refait des chapitres 10 (garnison) et 16 (aire de l'aigle), et celui des côtes et de la nécropole (chapitres 17 à 20). Les bassins et ruines des missions 41 à 45 sont fusionnés mais pas branchés.

## Interface

- **Place commune du bandeau d'affixe** (signalé par le porteur via Codex). Sur les missions 36 et 39, le bandeau des Vents contraires masquait la route et des ennemis. Au total, il descendait sur le plateau dans 14 cas sur 12 missions, aux chapitres 4, 8, 12, 14 et 18.
- Le bandeau a désormais une place fixe, la même pour tous les affixes et toutes les cartes : en haut de l'écran, entre le titre et le bloc d'informations de droite. Il ne touche plus ni le plateau, ni les étiquettes d'entrée, ni le panneau du boss.
- L'annonce de vague et le compte à rebours de la vague suivante utilisent la même bande : le bandeau s'efface pendant qu'ils sont affichés. La ligne d'affixe à gauche reste visible. Fiche : `design/Place_bandeau_affixe_v0241.md`.

## Décision consignée

- O-028 : le porteur garde la cible de difficulté (40 à 70 % de marge pour la meilleure composition, mesurée avec la première offre de bonus). Aucune mission n'est recalibrée (MAJ-79).

## Contrôles

- **Régression complète** : 144 suites sur 144, 206 730 contrôles Godot, 17 tests Python.
  - `test_affix_banner.gd` vérifie la place commune sur toutes les missions à affixe, au combat et en préparation, et le lien avec l'annonce de vague.
  - `test_headwinds.gd` vérifie la planche des rafales, son rectangle, l'image donnée par le temps de combat et l'ordre de dessin.
  - `test_fortress_condition.gd` vérifie les six calques, leur cadre et l'ordre de dessin.
- **Paquet Windows vérifié** : 1 050 cas réussis, 620 contrôles de sources, empreinte `cfbd4b39…34b1`.
- **Captures inspectées dans le paquet** :
  - les quatre états de la forteresse dans les deux factions ;
  - les vingt cartes du chapitre 15 ;
  - 28 captures supplémentaires dans les deux factions, avec les rafales et le bandeau des missions 31, 36, 39 et 40 à la vague 3, puis le bandeau des missions 74, 80, 114, 132, 138, 173, 174, 177, 178 et 180 à l'annonce et pendant l'effet.
- **Limite** : le mode capture fait avancer le combat sans afficher l'annonce de vague. L'effacement du bandeau pendant l'annonce est donc vérifié par le test seulement.
