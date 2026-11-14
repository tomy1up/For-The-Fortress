# Boutique · Chaman des marais

Visuel fixe du type 33 (`horde.swampshaman`) validé par le porteur le 14 novembre 2026. La chamane trolle porte un mantelet de roseaux et canalise sa malédiction dans un bol de terre cuite. Le bol levé et la silhouette élancée la distinguent du Chaman orc et du Brûleur de cendres au même emplacement.

![Comparatif et premier ralentissement en combat](essais/boutique_guetteurs/Chaman_marais_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `chaman_marais_v001.png` | `Rect2(0,0,1096,1246)` | `(482,1246)` | 58 px | `(23,-52.5)` |

Sur la copie v0.199, l’attaque vise un ennemi, le maudit et le ralentit de 40 % pendant 3 s. Le tir d’essai ajoute un feu follet turquoise au départ du bol. Le repère `slow.png` est dessiné au sol pendant le ralentissement, en complément de l’anneau violet de la malédiction. Portrait, déblocage, recrutement et premier ralentissement vérifiés. Les 116 contrôles d’illustrations et les 41 contrôles du troisième lot de la boutique passent.

Pour l’animation, le bol reste soutenu par la paume tandis que l’autre main canalise le feu follet. La volute du sprite fixe reste visible pendant le tir. Prévoir son départ à l’image de lâcher et son retour après le geste.

Dessin réalisé avec le générateur intégré. Le Chaman orc a servi de référence pour les contours et les aplats. La silhouette proposée associe une trolle élancée, un mantelet de roseaux, une crête corail et un bol en terre cuite.
