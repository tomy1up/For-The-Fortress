# Boutique · Totem de guerre

Visuel fixe du type 34 (`horde.wartotem`) validé par le porteur le 14 novembre 2026. Le Totem est un défenseur fixe en bois sculpté, sur trois appuis. La gemme rose reprend la forme du losange qui signale la cible marquée. Dessin réalisé avec le générateur intégré à partir du Chaman orc comme référence de contours et d’aplats.

![Vérification du premier marquage](essais/boutique_guetteurs/Totem_guerre_marquage.jpg)

| PNG | Cadre | Pied | Hauteur | Origine de l’impulsion d’essai |
| --- | --- | --- | ---: | --- |
| `totem_guerre_v001.png` | `Rect2(0,0,675,1282)` | `(317,1282)` | 56 px | `(0,-46.5)` |

Sur la copie v0.199, une impulsion rose part de la gemme et le repère `mark.png` apparaît au-dessus des PV de la cible. L’action inflige 3 dégâts de base et la marque dure 4 s. Les autres défenseurs infligent +55 % de dégâts à la cible marquée. Portrait, déblocage, recrutement et premier marquage vérifiés. Les 121 contrôles d’illustrations et les 41 contrôles du troisième lot de la boutique passent.

Le texte de combat hérite encore de « Rebonds entre ennemis proches ». Remplacer ce libellé par une description du marquage. Animer la gemme au déclenchement en gardant la structure posée sur ses appuis.

## Charge de la gemme et impulsion

La gemme de l’illustration fixe s’éclaircit progressivement. Elle émet une impulsion rose à 0,30 s, puis revient à sa couleur d’origine. La structure de bois conserve les trois appuis et le même cadrage sur les 24 images du cycle de 0,72 s. Une impulsion en losange suit un trajet direct et le premier badge de marquage apparaît à son arrivée, à 0,42 s dans cette copie d’essai.

[Essai en jeu](essais/gestes_combat/totem_guerre/Totem_guerre_en_jeu.gif) · [Charge et impulsion](essais/gestes_combat/totem_guerre/Planche_totem_guerre.png)

Le fichier signal.json décrit le délai, le centre de la gemme et le pivot de l’impulsion. Dix tirs contrôlés en mission 94 sur copie instrumentée de la v0.235, aux deux vitesses et dans les deux sens. Pause, trajet et apparition du losange testés. Le modèle applique le marquage à son instant actuel. Les marques déjà visibles lors d’un renouvellement et les marques autonomes de Marque du chasseur restent visibles. 49 dossiers valides, 190 contrôles d’animation, 77 des effets d’unités et 28 des effets de boutique réussis. Le porteur a validé l’essai. Lot b36a4eb prêt à intégrer.

Construction graphique. Réutiliser le Totem de guerre validé. Modifier la couleur des facettes de la gemme et ajouter une lueur rose en charge, avec une onde fine au départ. L’impulsion reprend le losange du marquage et utilise uniquement cette palette.
