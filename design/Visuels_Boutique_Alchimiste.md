# Boutique · Alchimiste

Proposition du 14 novembre 2026 pour le type 39 (`alliance.alchemist`). Le porteur a préféré la troisième version, avec des boucles cuivrées, un sourire en coin, une pose de lancer et un porte-fioles visible. Dessin réalisé avec le générateur intégré, en prenant le servant gnome de la Balliste royale comme référence de style et de race.

![Premier lancer et repère de volatilité](essais/boutique_guetteurs/Alchimiste_gnome_volatilite.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du lancer d’essai |
| --- | --- | --- | ---: | --- |
| `alchimiste_gnome_v001.png` | `Rect2(0,0,1188,1257)` | `(511,1257)` | 53 px | `(26,-32)` |

Sur la copie v0.200, une fiole ambrée touche un ennemi. L’étoile orange `volatile.png` apparaît au-dessus des PV pendant `volatile_until`. Si la cible est éliminée dans les 4 s, elle inflige 80 dégâts autour d’elle dans un rayon de 1,4 case. Portrait, déblocage sur profil d’essai, recrutement et première application de la volatilité vérifiés en combat. Les 141 contrôles d’illustrations et les 49 contrôles du lot 4 passent, dont le déclenchement unique des explosions en chaîne. Le visuel de l’explosion à la mort reste à relier et à vérifier en jeu. L’anneau bleu d’impact hérité du mage est encore visible sur la copie.

Pour l’animation, retirer la fiole du sprite au lâcher, suivre le mouvement du poignet et reprendre une fiole au porte-fioles. La fiche de combat doit indiquer la fenêtre de 4 s et le déclenchement de l’explosion à l’élimination.
