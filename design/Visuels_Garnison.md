# Capitaines de garnison — propositions du 11 novembre 2026

Le capitaine humain de l’Alliance se reconnaît à son casque bas sans plumet, à sa hallebarde et aux deux chevrons de son tabard. Le capitaine orc de la Horde porte un bouclier rectangulaire à bande rouge et une lame courte. Les formes distinctives sont visibles à l’échelle du plateau. Les noms de prototype sont conservés dans cette fiche.

![Comparatif des capitaines avec les gardes et les boss](essais/garnison/Comparatif_Garde_Garnison_Boss.png)

Le porteur a demandé un manche parfaitement droit, puis a signalé des trous apparents et des raccords incomplets dans le premier montage. Le guide droit a servi de base à une retouche continue des gants, du manche et de la tête. Le contrôle sur fond clair permet de lire les contacts entre le bois et les gants, ainsi que la continuité de la douille et du fer. Les neuf points relevés sur les trois sections de bois s’écartent d’environ un pixel au maximum de leur droite d’ajustement, à la définition du dessin. [Contrôle des raccords](essais/garnison/Controle_raccords_hallebarde.png) · [Contrôle de l’axe](essais/garnison/Controle_axe_hallebarde.png)

Les dessins de départ ont été produits avec les atlas des factions comme références. Consignes artistiques : humain trapu en acier et cobalt, hallebarde à deux mains, casque bas et chevrons dorés. Orc trapu en fer sombre et rouge brique, bouclier rectangulaire à bande rouge et lame courte. Les deux profils regardent à droite. Le miroir est montré sur la maquette pour vérification.

| Identité du jeu | Vue par le joueur | Sprite PNG transparent | Cadre complet | Pied dans le cadre |
| --- | --- | --- | --- | --- |
| `enemy.alliance.garrison` | Horde | [Capitaine humain](essais/garnison/capitaine_humain_v001.png) | 1 295 × 1 179 px | `(478, 1173)` |
| `enemy.horde.garrison` | Alliance | [Capitaine orc](essais/garnison/capitaine_orc_v001.png) | 1 084 × 1 005 px | `(559, 999)` |

Contrôle de lisibilité sur des captures de La Brèche (mission 91), avec les tailles de référence du jeu : garde 44,2 px, capitaine 54,4 px et boss 57,8 px. Le matériel du capitaine peut dépasser la largeur du boss. La différence à lire est la forme de l’arme ou du bouclier, la silhouette moins haute et l’absence du grand plumet ou des cornes du boss. Le montage permet de comparer ces formes dans les deux factions. [Maquette sur le plateau](essais/garnison/Garnisons_sur_la_Breche.png)

**Retour du porteur, 11 novembre 2026.** Il juge la version corrigée du capitaine humain « propre ». Ce retour concerne son illustration fixe. L’orc reste une proposition à examiner.

Pour un essai intégré, Claude Code peut associer les PNG aux deux identités ci-dessus avec la hauteur de base de 34 px et le facteur de taille 1,6 déjà utilisé par la Garnison. Les portraits, la prévision de vague et l’affichage sur le plateau sont à contrôler dans les deux factions. La marche et la mort feront l’objet d’un lot après validation des silhouettes.

## Lisibilité du capitaine humain sur le plateau

Le capitaine apparaissait crénelé à environ 54 px de haut sur le plateau. Les images réduites générées à l’import (mipmaps) permettent au filtre déjà utilisé par le plateau d’échantillonner le dessin à une définition proche de celle affichée. Le réglage s’applique à `capitaine_humain_v001.png.import`. Le PNG approuvé, le cadre et l’ancre du pied restent identiques.

La comparaison couvre les missions 91, 94, 98 et 100, côté Horde, en vague 5. Douze paires de captures ont les mêmes positions, PV et temps de simulation avant et après réimport. Godot charge bien une texture avec mipmaps. La hallebarde et le bord de l’armure paraissent plus continus à taille de jeu. Le filtrage adoucit aussi certains petits détails du visage. [Comparatif en jeu](essais/capitaine_rendu/Capitaine_avant_apres.png)

Le validateur d’animations et les suites ciblées des visuels ennemis et de la Garnison passent, avec 4 741 contrôles Godot et 17 tests Python. La comparaison porte sur le rendu en combat. La marche et la mort restent des lots séparés.

## Marche du capitaine humain

Le cycle utilise le sprite fixe retenu par le porteur. Le capitaine avance d’un pas court, avec un léger transfert de poids dans les épaules. La hallebarde reste rigide et suit les deux gants tout au long de la boucle.

Les trois planches de `enemy.alliance.garrison` contiennent chacune 24 poses de 376 × 324 px. Le cycle couvre 21 px projetés à l’échelle de base. La dérive résiduelle mesurée sur les semelles isolées pendant l’appui va de 0,08 à 0,35 px à cette échelle.

À La Brèche (mission 91, vague 5, côté Horde), les trois diagonales du trajet ont été parcourues à ×1 et ×2, avec les 24 poses jouées à chaque vitesse. La scène de contrôle figée donne deux captures identiques autour du capitaine à 0,65 s d’intervalle. Le validateur et les quatre suites ciblées du lot passent. La marche du capitaine humain attend le retour visuel du porteur. L’illustration du capitaine orc reste à valider.

[Extrait en combat](essais/capitaine_marche/Capitaine_en_combat.gif) · [Diagonales de La Brèche](essais/capitaine_marche/Capitaine_diagonales.jpg)

## Capitaine orc à taille native — essai v0.208

L’étude au bouclier rectangulaire a été branchée sur une copie de la v0.208 pour `enemy.horde.garrison`. Sur la Grande Salle (mission 94, Alliance), cinq instants des vagues 5, 7 et 10 ont été rejoués avec les mêmes temps et nombres d’ennemis. À 24 secondes de la vague 10, les deux capitaines se distinguent du chef de guerre à taille native par le bouclier à bande rouge et le casque bas. Le comparatif est un recadrage de l’affichage 1 280 × 800.

[Comparatif avant et après](essais/garnison/Capitaine_orc_sur_le_plateau.png)

Le PNG destiné au jeu est `prototype/assets/enemies/rosters/capitaine_orc_v001.png`. Import avec mipmaps, cadre `Rect2(0,0,1084,999)`, pied `Vector2(559,999)`, hauteur de base 34 px, soit 54,4 px avec le facteur du capitaine. Sur la copie d’essai, 213 contrôles des visuels ennemis et 4 546 du chapitre de la Garnison passent. L’illustration fixe est proposée à la validation du porteur. Le branchement et l’export reviennent à Claude après ce retour. Le cycle de marche et la mort restent à produire.
