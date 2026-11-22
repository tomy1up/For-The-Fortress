# Boutique · Poseur de mines

Visuel fixe du type 42 validé par le porteur (`horde.minelayer`). La gobeline s’appuie sur un genou, retient sa caisse sur la hanche et tient un disque de pierre runique. La posture basse, la caisse et le disque la distinguent du Sapeur et du Pillard au même emplacement. Dessin réalisé avec le générateur intégré à partir du comparatif du Pillard pour les contours et les aplats.

![Comparaison au même emplacement E2](essais/boutique_guetteurs/Poseur_mines_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du lancer d’essai |
| --- | --- | --- | ---: | --- |
| `poseur_mines_v001.png` | `Rect2(0,0,1101,1001)` | `(473,1001)` | 53 px | `(27,-23.5)` |

Le type 42 touche une cible. Ses dégâts sont multipliés par 1,8 au premier tiers du trajet et par 0,4 au dernier tiers. Sur la copie v0.202, le disque reprend la forme et la rune du sprite. Le disque sert de projectile visuel puis disparaît à l’impact. Portrait, déblocage sur profil d’essai, recrutement et premier lancer vérifiés au Gué. Les 176 contrôles d’illustrations et les 49 contrôles du quatrième lot passent.

Pour l’animation, préparer le lancer à hauteur de hanche, ouvrir la main au départ du disque et reprendre un disque dans la caisse. L’essai conserve le disque dans la main du sprite fixe pendant le tir.

## Lancer du disque

La gobeline cale sa caisse et ramène le disque contre la hanche. Elle pousse l’avant-bras, ouvre la main à 0,40 s, puis revient vide vers la caisse pour reprendre un disque. Douze dessins distincts sur 48 images et 0,96 s. L’image 20 à partir de zéro est la première à main ouverte. Le genou et l’appui avant sont calés. La garde mesure 59 px.

[Essai en jeu](essais/gestes_combat/poseur_mines/Poseur_mines_en_jeu.gif) · [Planche des douze poses](essais/gestes_combat/poseur_mines/Planche_poseur_mines.png)

Le disque de pierre à rune orange fait un tour sur l’arc visuel de 15 px existant. Le repère dans lâcher.json est mesuré au bout de la main et suit le retournement. Le disque disparaît à l’impact. Cinq tirs en mission 94 sur copie v0.236, dans les deux sens à ×1 et ×2 avec pause. L’essai confirme les trois multiplicateurs selon l’avancée de la cible. Validateur à zéro problème sur 56 dossiers, 197 contrôles d’animation, 77 des effets et 93 de boutique réussis. L’essai attend l’avis du porteur.

Consignes au générateur intégré. Garder la gobeline à genou, ses cheveux violets, son pantalon vert et sa caisse. Une main cale la caisse. L’autre arme à la hanche, pousse le disque, lâche et revient vide. Garder les appuis et la silhouette. Dessiner le disque de vol avec le même contour et la même rune.
