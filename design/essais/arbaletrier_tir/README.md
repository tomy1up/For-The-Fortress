# Arbalétrier nain

La pose de réarmement a été générée à partir du sprite Alliance existant. Une main tire la corde, l'autre soutient l'arme et le fût s'abaisse. Le dessin conserve le format de 1 261 × 1 247 px et le bas de la silhouette à y = 1 185 px. Le contour des bottes varie légèrement. Vérifier leur stabilité à l'échelle du plateau avant intégration. Vérifier aussi que la pointe métallique au bout de l'arme se lit comme une pièce de l'arbalète pendant le réarmement.

Source de référence dans le prototype, sous assets/units/alliance/arbaletrier_v001.png. Pose d'essai avec fond transparent générée avec ImageGen.

## Essai au Gué

La [planche de contrôle](cycle_sur_le_gue.png) compare quatre moments du tir, vers la gauche en E1 et vers la droite en E2, avec un agrandissement ×2. Le contour des bottes reste visuellement stable et le geste se lit par la main au-dessus du fût et l'arme abaissée. À cette taille, l'absence de carreau chargé est plus discrète que le mouvement de la main.

La capture Godot lance une vague et utilise son premier tir réel. Elle échantillonne ensuite le rendu autour de ce tir, avec la pose d'essai entre 0,14 et 0,62 seconde. L'option `-- --right` choisit E2. Chaque capture contient 60 images. Les durées sont provisoires et la capture ne teste pas un enchaînement de plusieurs tirs.

La pose est maintenant intégrée au rendu du prototype. Elle commence après la fin du recul, à 0,26 s, et se termine au plus tard à 0,72 s, avec une limite liée au délai de récupération. La planche ci-dessus illustre le réglage d'atelier antérieur. La capture `-- --repeat` vérifie trois cycles complets à vitesse ×2 avec le bonus de cadence, en passant par le rendu normal.

## Tir par planche sur les sources de la v0.178

**Retour du porteur, 11 novembre 2026.** Le tir et le réarmement lui paraissent bien d’après l’aperçu.

La planche `defender.alliance.crossbow/attack.png` reprend le sprite de visée et la pose de réarmement illustrée. Le carreau part depuis la pose de visée, le haut du corps recule, puis la main saisit la corde avant de ramener l’arbalète à sa position de départ. Les appuis gardent le même ancrage. La planche contient 18 images de 272 × 256 px sur 0,72 s simulée. La durée rejoint la limite de l’ancienne pose de réarmement, pour éviter qu’elle réapparaisse à la fin. La pose fixe reprend ensuite le relais.

[Animation issue de vrais tirs au Gué](Tir_arbaletrier.gif) · [Étapes du tir à ×1](Tir_arbaletrier_etapes.png)

Le rendu a été capturé en vague 1 avec un profil isolé sur l’écran de droite. Le tir part à droite depuis E4 et à gauche depuis E1, avec 18 images de la planche échantillonnées à ×1 et 9 à ×2. Le départ du carreau est visible au bout de l’arme dans les deux sens. À ×2 avec le bonus de cadence, trois cycles complets ont également été vérifiés avant le tir suivant. Le passage entre les poses illustrées reste perceptible en agrandissement. L’animation est prête pour avis artistique.

Le validateur relève zéro problème. Les quatre suites ciblées sur les animations, le tir, les défenseurs et les projectiles passent (509 contrôles Godot, 17 tests Python). La cadence, l’ancrage du projectile et le calcul des dégâts restent ceux du jeu. Ce lot couvre le tir et le réarmement.
