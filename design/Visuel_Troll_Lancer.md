# Lanceur de haches troll

Le troll ouvre la main au départ de la hache, accompagne le lancer de l’avant-bras et reprend sa garde une fois le rebond terminé. Les pieds gardent leur point d’appui. La planche `prototype/assets/animations/defender.horde.axe/attack.png` contient douze images de 320 × 288 px sur 0,48 s. La hache en vol et son rebond restent dessinés par le jeu. Les points de départ, les cibles, les dégâts et la cadence conservent leurs réglages actuels.

[Animation en combat](essais/troll_lancer/Lancer_et_rebond.gif) · [Étapes du lancer](essais/troll_lancer/Lancer_etapes.png)

Le contrôle utilise la vague 4 du Gué, lancée directement sur l’écran de droite avec un profil isolé. Quatre tirs avec un rebond enregistré ont été capturés. Le troll lance vers la gauche en E1 et vers la droite en E4, à ×1 et ×2. La capture échantillonne les douze images à ×1 et six à ×2. La main vide se distingue pendant le vol. Le rebond est plus facile à suivre à ×1 dans la meute. Le validateur passe sur les sept dossiers d’animation. Les quatre suites ciblées passent avec 511 contrôles Godot et 17 tests Python. L’animation attend un avis artistique.

## Consignes de génération des poses

Deux poses ont été générées avec l’outil d’image intégré à partir du sprite Horde existant, puis alignées sur son ancre de pied pour la planche.

- **Lâcher.** Retirer entièrement le fer et le manche. Ouvrir légèrement les doigts autour de l’ancien point de prise, sans déplacer le poignet ni le bras. Garder la caméra, la crête, le visage, les couleurs, la silhouette, les bottes et le fond transparent.
- **Fin de geste.** Retirer la hache. Ramener légèrement l’avant-bras gauche à l’écran devant le torse vers la droite, main vide aux doigts épais, en conservant le brassard et le raccord à l’épaule. Garder la pose de l’autre main, les appuis, la palette, le cadrage et le fond transparent.
