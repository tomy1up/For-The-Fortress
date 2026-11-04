# Arbalétrier nain

La pose de réarmement a été générée à partir du sprite Alliance existant. Une main tire la corde, l'autre soutient l'arme et le fût s'abaisse. Le dessin conserve le format de 1 261 × 1 247 px et le bas de la silhouette à y = 1 185 px. Le contour des bottes varie légèrement. Vérifier leur stabilité à l'échelle du plateau avant intégration. Vérifier aussi que la pointe métallique au bout de l'arme se lit comme une pièce de l'arbalète pendant le réarmement.

Source de référence dans le prototype, sous assets/units/alliance/arbaletrier_v001.png. Pose d'essai avec fond transparent générée avec ImageGen.

## Essai au Gué

La [planche de contrôle](cycle_sur_le_gue.png) compare quatre moments du tir, vers la gauche en E1 et vers la droite en E2, avec un agrandissement ×2. Le contour des bottes reste visuellement stable et le geste se lit par la main au-dessus du fût et l'arme abaissée. À cette taille, l'absence de carreau chargé est plus discrète que le mouvement de la main.

La capture Godot lance une vague et utilise son premier tir réel. Elle échantillonne ensuite le rendu autour de ce tir, avec la pose d'essai entre 0,14 et 0,62 seconde. L'option `-- --right` choisit E2. Chaque capture contient 60 images. Les durées sont provisoires et la capture ne teste pas un enchaînement de plusieurs tirs.
