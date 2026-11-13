# Lanceur de haches troll

**Retour du porteur, 12 novembre 2026.** Le premier essai publié en v0.179 lui paraît raide et manque de vie. La version retravaillée est proposée ci-dessous pour avis.

Le troll ouvre la main au départ de la hache, accompagne le lancer de l’avant-bras et reprend sa garde une fois le rebond terminé. Les pieds gardent leur point d’appui. La planche `prototype/assets/animations/defender.horde.axe/attack.png` contient douze images de 320 × 288 px sur 0,48 s. La hache en vol et son rebond restent dessinés par le jeu. Les points de départ, les cibles, les dégâts et la cadence conservent leurs réglages actuels.

[Animation en combat](essais/troll_lancer/Lancer_et_rebond.gif) · [Étapes du lancer](essais/troll_lancer/Lancer_etapes.png)

Le contrôle utilise la vague 4 du Gué, lancée directement sur l’écran de droite avec un profil isolé. Quatre tirs avec un rebond enregistré ont été capturés. Le troll lance vers la gauche en E1 et vers la droite en E4, à ×1 et ×2. La capture échantillonne les douze images à ×1 et six à ×2. La main vide se distingue pendant le vol. Le rebond est plus facile à suivre à ×1 dans la meute. Le validateur passe sur les sept dossiers d’animation. Les quatre suites ciblées passent avec 511 contrôles Godot et 17 tests Python. L’animation attend un avis artistique.

## Consignes de génération des poses

Deux poses ont été générées avec l’outil d’image intégré à partir du sprite Horde existant, puis alignées sur son ancre de pied pour la planche.

- **Lâcher.** Retirer entièrement le fer et le manche. Ouvrir légèrement les doigts autour de l’ancien point de prise, sans déplacer le poignet ni le bras. Garder la caméra, la crête, le visage, les couleurs, la silhouette, les bottes et le fond transparent.
- **Fin de geste.** Retirer la hache. Ramener légèrement l’avant-bras gauche à l’écran devant le torse vers la droite, main vide aux doigts épais, en conservant le brassard et le raccord à l’épaule. Garder la pose de l’autre main, les appuis, la palette, le cadrage et le fond transparent.

## Lancer retravaillé

Le troll fléchit la jambe avant, tourne les épaules et accompagne la hache avec tout le haut du corps. Le bras libre recule pour contrebalancer le geste. Pendant la récupération, il reprend la hache à hauteur de la hanche avant de la relever. La planche contient 24 images de 336 × 288 px sur 0,80 s simulée. Le jeu conserve le point de départ, le rebond et la cadence du tir.

[Comparatif animé à vitesse normale](essais/troll_lancer/Lancer_troll_comparatif.gif) · [Comparatif image par image](essais/troll_lancer/Lancer_troll_comparatif.png)

Les deux versions ont été capturées aux mêmes instants de combat sur la vague 4 du Gué. Quatre tirs avec rebond ont été vérifiés, à gauche et à droite, à ×1 et ×2. La capture échantillonne 24 images à ×1 et 12 à ×2. La mesure du bas de la silhouette donne au maximum 1,42 px de dérive horizontale et 0,27 px de dérive verticale à taille de jeu. L’amplitude du mouvement du corps est surtout visible après le lâcher. Le moteur déclenche la planche au départ du projectile. Une anticipation avant ce point demanderait un signal de préparation distinct. Les transitions entre poses restent perceptibles en agrandissement.

Le validateur et les quatre suites ciblées passent (511 contrôles Godot, 17 tests Python). Le nouveau rendu est en attente de l’avis du porteur avant intégration.

### Consignes pour les deux nouvelles poses

Les poses ont été générées avec l’outil d’image intégré à partir du sprite du troll. Les raccords ont été calculés entre des repères de silhouette et de joints, puis contrôlés en jeu.

- **Transfert de poids.** Après le lancer, fléchir le genou avant à droite, tourner et incliner le torse vers la cible, tendre la main vide et ramener l’autre bras vers l’arrière. Conserver les appuis, le cadrage, la palette et le fond transparent.
- **Reprise de la hache.** Abaisser le coude du bras au premier plan, reprendre la même hache près de la hanche, lame basse et manche orienté vers le bas. Conserver le visage, le poing opposé, les appuis et le fond transparent.

## Raccords du bras et de la hache

Le 12 novembre 2026, le porteur trouve le lancer plus convaincant et signale encore du clipping. Les 24 images laissaient de la marge autour de la silhouette. À l’examen image par image, le raccord du bras et de l’épaule se déformait pendant la rotation et la hache passait trop vite de la hanche à la garde.

Deux poses intermédiaires reprennent ces passages. Les déplacements locaux de l’image ont aussi été bornés pour empêcher les replis dans la silhouette. La planche conserve son ancre, ses 24 images et sa durée de 0,80 s. La marge transparente minimale vérifiée est de 16 pixels. Certaines transitions restent perceptibles au ralenti.

[Comparatif animé à ×1](essais/troll_lancer/Troll_raccords_avant_apres.gif) · [Détail des raccords](essais/troll_lancer/Troll_raccords_etapes.png)

Les quatre tirs avec rebond ont été rejoués au Gué dans les deux sens, à ×1 et ×2. Les positions de départ, de cible et de rebond concordent avant et après. Validateur et quatre suites ciblées au vert (511 contrôles Godot, 17 tests Python). L’intégration attend le retour du porteur.

### Consignes pour les poses intermédiaires

Deux images ont été générées avec l’outil intégré. La première reprend les poses de main vide et de transfert du poids, avec une rotation intermédiaire du torse, une main ouverte devant la poitrine et un bras arrière continu. La seconde reprend les poses de hache basse et de garde, avec une seule hache droite à mi-hauteur, le poignet au niveau du bas du torse et le manche bien saisi. Les deux consignes conservent le cadrage, les appuis, la palette et le fond transparent.

## Synchronisation du geste et du projectile

Le 12 novembre 2026, le porteur signale que la hache semble quitter la main avant le geste. Dans `valley_view.gd`, la planche d’attaque et le projectile démarrent sur le même évènement de tir. La main est déjà vide à la première image de la planche. Le bras poursuit son mouvement pendant le vol.

L’essai ajoute six poses de préparation sur les 0,20 s avant le tir. La hache reste en main pendant cette phase. La planche RGBA est composée de cellules de 336 × 288 px, avec le pied ancré en (152, 269) et une hauteur affichée de 76 px. Ces valeurs servent à l’essai. La planche reste dans le dossier d’études.

Le comparatif a été capturé avec le rendu Godot sur la vague 4 du Gué, dans les deux sens à ×1 et ×2. L’aperçu connaît à l’avance l’instant du tir grâce à une première exécution de la vague. Le modèle, le départ réel du projectile et son rebond restent identiques dans la comparaison.

Cette piste a été abandonnée après clarification du retour du porteur. Voir la correction de la planche ci-dessous.

[Comparatif animé](essais/troll_lancer/Troll_armement_comparatif.gif) · [Étapes du geste](essais/troll_lancer/Troll_armement_etapes.png) · [Planche de préparation](essais/troll_lancer/Troll_armement_prototype.png)

## Prise de la hache pendant le geste

Le 12 novembre 2026, le porteur précise que son retour concerne la hache dessinée dans la main. Sur les nouvelles poses, il relève aussi un tranchant à l’envers et une lame dont la silhouette change.

Les sept premières images gardent la hache en main, de la garde jusqu’au bras tendu. La huitième reprend la pose de main ouverte. La lame et les extrémités du manche viennent du sprite d’origine. Elles suivent la prise de la main, avec le tranchant tourné vers l’avant sur la fin du mouvement. Les trois poses de prise ont été préparées à partir du troll de référence et de la pose de main ouverte, puis recalées sur l’ancre de la planche. La planche conserve ses 24 images sur 0,80 s.

[Comparatif du sprite au ralenti](essais/troll_lancer/Troll_prise_comparatif.gif) · [Huit premières images](essais/troll_lancer/Troll_prise_etapes.png)
