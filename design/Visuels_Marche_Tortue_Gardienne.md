# Tortue gardienne des berges · Premier cycle de marche

Proposition du 23 novembre 2026. La tortue soulève et pose ses pattes à tour de rôle. Sa tête accompagne les appuis et la carapace conserve son volume de rocher moussu. Les douze poses complètes ont été dessinées avec le générateur d’images à partir du sprite actuel. La planche a ensuite été réduite image par image à 96 × 72 pour adoucir les contours à taille de jeu. La hauteur et l’ancrage ont été réglés en comparaison directe avec l’illustration fixe.

![Illustration fixe et cycle de marche sur la mission 11, à taille réelle et agrandie](essais/tortue_marche_v0243/Comparatif_taille.jpg)

## Essai en combat

Mission 11, vague 2, avec l’Alliance et la Horde sur une copie de la v0.243. Les captures à ×1 et ×2 couvrent la première portion droite et le premier virage. La tortue garde la même cadence de pas par distance parcourue. Les douze poses ont été observées et la phase reste continue au passage de l’angle. Le jeu utilise une vue de trois quarts avec miroir selon le côté. Le virage change donc de vue d’une image à l’autre. Une vue de dos et un geste de virage demanderaient des poses dédiées.

![Tortue en combat à ×1, taille native et agrandissement dans chaque exemple](essais/tortue_marche_v0243/Tortue_en_combat_x1.gif)

[Voir l’essai à ×2](essais/tortue_marche_v0243/Tortue_en_combat_x2.gif).

## Contrôles et fichiers

146 captures, dont deux avec l’illustration fixe. À temps de combat égal, les poses et les positions consignées correspondent à ×1 et ×2 dans les deux factions. Le validateur relève zéro problème sur 65 dossiers. Quatre suites ciblées passent. `test_bank_guardian.gd` (699), `test_guardian_inspection.gd` (36), `test_enemy_walk.gd` (1 278) et `test_animation_library.gd` (206).

Les fichiers [animation.json](essais/tortue_marche_v0243/animation.json) et [walk.png](essais/tortue_marche_v0243/walk.png) forment la planche `enemy.neutral.turtle/walk`. Mode par distance, foulée de 13 px à l’échelle du cadre, ancre (50, 69) et hauteur de cadre 39. La proposition attend l’avis du porteur. La copie d’essai utilise les mêmes règles de combat et de protection que la v0.243.
