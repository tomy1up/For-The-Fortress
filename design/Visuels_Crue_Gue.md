# Crue du Gué · Montée et retrait des eaux

Proposition du 24 novembre 2026 sur la v0.247 pour les missions 2 à 20. Quelques filets d’eau annoncent la crue. La lame d’eau s’élargit au centre de la chaussée, puis des rides et de l’écume descendent la route vers la forteresse. L’eau se retire progressivement. Les bords de la route et les emplacements de défense restent visibles. Sur la carte du Gué, le pont recouvre le courant.

- [GIF de la montée et du retrait en mission 11](essais/crue_v0247/Crue_du_Gue_en_combat.gif)
- [Comparatif avec l’effet actuel et aperçu des virages](essais/crue_v0247/Crue_du_Gue_comparatif.jpg)

## Planches et réglages essayés

`prototype/assets/animations/effect.flood/` contient deux planches transparentes. Cadre de 88 × 48, ancre (44 ; 24), hauteur affichée de 48 px à l’échelle 1.

| État | Planche | Utilisation |
| --- | --- | --- |
| `warning` | 28 images en mode `progress` | Pendant les 3 s d’annonce, filets fins, sur la même chaussée que l’eau active. |
| `storm` | 32 images à 32 IPS en mode `time` | Rides et écume pendant les 4 s de crue. |

Dans l’essai, l’effet se dessine après la chaussée et son surlignage, avant le pont, les décors, les emplacements et les unités. Les tronçons projetés identiques sont dédupliqués. L’eau couvre au maximum 16,1 px des 20 px de largeur de la chaussée, avec un raccord arrondi à chaque virage. Sa teinte (0,10 ; 0,47 ; 0,57) atteint 0,62 d’opacité. La montée dure 0,52 s et le retrait commence 0,62 s avant la fin de la fenêtre active. Les textures transparentes suivent l’angle projeté de chaque tronçon, avec un fondu aux extrémités pour que l’écume ne saute pas d’un virage à l’autre. Les positions et phases viennent du temps de combat.

Le branchement a été essayé dans une copie isolée. Repli possible sur le repère actuel si l’une des deux planches manque. L’annonce par le bandeau et la vitesse des ennemis sont celles du jeu publié.

## Contrôles

145 captures des missions 2, 4, 11 et 20 sur les deux factions. Deux cycles de crue contrôlés, dont la transition sous le pont de la mission 11 et les virages de la mission 4. Le GIF présente la fin de l’annonce, la montée et le retrait. La partie centrale de la crue est raccourcie dans le GIF. Validateur à zéro problème sur 68 dossiers. 232 contrôles de bibliothèque d’animations et 1 160 contrôles d’affixes réussis. Proposition en attente de validation avant branchement par Claude Code.
