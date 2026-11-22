# Prototype v0.240 — Étiquettes d'entrée lisibles en préparation

Valeurs de prototype à confirmer en partie réelle.

## Interface

- **Étiquettes d'entrée écartées les unes des autres** (correction demandée par le porteur le 22 novembre 2026). En préparation, chaque étiquette d'entrée affiche le nombre d'ennemis annoncés. Les étiquettes d'entrées voisines se recouvraient alors sur 38 missions des chapitres 6 à 20 (46 cas). Par exemple, sur la mission 134, « Entrée 2 » cachait le nombre d'ennemis de « Entrée 1 · principale ». Le survol d'une étiquette recouverte pouvait aussi mettre en évidence le mauvais trajet.
- Les étiquettes sont posées dans l'ordre des entrées. Une étiquette qui en touche une autre se place juste à côté, au-dessus ou au-dessous d'elle, à 4 px d'écart et au plus près de sa place d'origine. Elle reste dans la zone de carte et hors du bloc d'informations en haut à droite. La couleur de chaque étiquette reste celle de son point d'entrée.
- En pratique, les étiquettes forment un escalier au-dessus des départs. Le plus grand déplacement est inférieur à 40 px, et presque tous les déplacements sont verticaux. Au combat, les étiquettes, plus courtes, gardent leur place à 1 px près, et le bandeau d'affixe ne bouge pas.

## Contrôles

- Régression complète : 144 suites sur 144, 206 454 contrôles Godot, 17 tests Python. `test_affix_banner.gd` passe à 4 113 contrôles. Le test couvre toutes les missions à plusieurs entrées, au combat et en préparation, pour chaque entrée principale possible et sans entrée principale. Il vérifie l'absence de chevauchement, l'écart de 4 px, la zone de carte et un déplacement de 40 px au plus. Les étiquettes ne bougent pas au combat.
- Paquet Windows vérifié : 1 050 cas, 597 sources comparées, empreinte `0675c6dc…0a247`.
- Captures inspectées : préparation des 38 missions touchées dans les deux factions, dans le paquet ; 20 captures depuis les sources (missions 60, 70, 84, 97, 117, 134, 138, 170, 186 et 200).
