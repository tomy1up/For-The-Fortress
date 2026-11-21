# Boutique · Marchand mercenaire

Visuel fixe validé par le porteur le 14 novembre 2026 pour le type 36 (`alliance.mercenary`). La grande sacoche bordeaux, le manteau à revers ocre et la pièce levée distinguent sa silhouette des archers de sa famille. Dessin réalisé avec le générateur intégré en prenant les contours et les aplats de l’Alliance comme référence.

![Premier tir et repère de pillage](essais/boutique_guetteurs/Marchand_mercenaire_pillage.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `marchand_mercenaire_v001.png` | `Rect2(0,0,857,1006)` | `(446,1006)` | 55 px | `(16,-44)` |

L’attaque touche une cible et le pillage lui fait rapporter +120 % d’or de combat si elle est éliminée dans les 4 s. Sur la copie v0.199, une pièce tourne en vol et l’icône `loot.png` apparaît au-dessus des PV de la cible pendant `loot_until`. Le premier tir et le repère sur la cible ont été vus en combat. Portrait, déblocage sur profil d’essai et recrutement vérifiés. Les 131 contrôles d’illustrations et les 49 contrôles du quatrième lot passent. La coexistence de la marque et du pillage sur un même ennemi reste à vérifier en jeu.

Le sprite fixe conserve sa pièce en main pendant le tir. Pour l’animation, ouvrir les doigts au départ, laisser la main vide pendant le retour du poignet, puis reprendre une pièce à la sacoche. Prévoir une mention du pillage dans la fiche de combat, qui affiche encore « Tirs rapides sur une cible ».

## Lancer de la pièce

Le Marchand tient sa sacoche d’une main. De l’autre, il prend la pièce, lève le poignet et ouvre les doigts à 0,40 s. La main revient vide et les semelles restent calées. Huit poses distinctes sur 22 images et 0,88 s. La hauteur du personnage est réglée sur les 61 px du sprite fixe actuel.

[Essai en jeu](essais/gestes_combat/marchand_mercenaire/Marchand_mercenaire_en_jeu.gif) · [Planche des huit poses](essais/gestes_combat/marchand_mercenaire/Planche_marchand_mercenaire.png)

Le fichier lacher.json donne le point de départ depuis le pied. La pièce existante part depuis ce repère, retourné avec la pose, et tourne en vol sur un segment direct. Six tirs en mission 94 sur copie v0.235, à gauche et à droite, à ×1 et ×2 avec pause. Le test confirme le badge de pillage, le bonus de +120 % de la cible et le trajet. Le badge apparaît dès le déclenchement du tir dans l’essai, conformément au rendu actuel. Le porteur a validé la planche le 21 novembre 2026.

Contrôles en jeu et tests ciblés. 49 dossiers d’animation valides, 190 contrôles de bibliothèque, 77 des effets d’unités et 28 de boutique réussis. Godot signale des ressources encore en mémoire à la fermeture du banc d’essai. Le banc se termine avec son marqueur de réussite.

Consignes au générateur intégré. Garder le manteau à revers ocre, les tempes grises, la moustache, la sacoche bordeaux et les appuis. Une main tient la sacoche sur les huit dessins. L’autre prend, arme, lance et revient vide. Monter la pièce derrière le pouce et l’index avant le lâcher.
