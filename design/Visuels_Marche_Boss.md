# Marche du maréchal et du chef de guerre

Le maréchal avance épée droite, avec un haut du corps stable et une cape qui suit l’alternance des appuis. Le chef de guerre transfère davantage son poids d’une jambe à l’autre. Sa hache et sa prise à deux mains suivent le torse en bloc. Le tissu derrière les jambes a été redessiné sur les deux sprites pour couvrir le passage des bottes.

| Unité | Identifiant | Planches | Poses par planche | Cadre d’une pose | Déplacement par cycle à l’échelle de base |
| --- | --- | --- | ---: | --- | ---: |
| Maréchal de l’Alliance | `enemy.alliance.marshal` | `walk`, `walk_up`, `walk_down` | 24 | 312 × 372 px | 22 px |
| Chef de guerre orc | `enemy.horde.warchief` | `walk`, `walk_up`, `walk_down` | 24 | 352 × 340 px | 26,5 px |

La phase du pas suit la distance parcourue sur le plateau. La montée et la descente ont chacune leurs poses. Le miroir couvre le sens gauche.

## Contrôles en combat

Aux Coulées Figées (mission 62, vague 10), les deux boss ont parcouru quatre diagonales à ×1 et ×2. Les 24 poses ont défilé à chaque vitesse. À ×1, la scène de contrôle figée a produit deux captures identiques autour du boss à 0,65 s d’intervalle.

Sur les semelles isolées, la dérive résiduelle mesurée pendant la portion d’appui se situe entre 0,07 et 0,28 px pour le maréchal et entre 0,09 et 0,34 px pour le chef de guerre, à l’échelle de base du rendu. Cette mesure contrôle le mouvement de la semelle. Le rendu des articulations et du poids se juge dans les extraits en combat.

- **Maréchal** · [Extrait en combat](essais/boss_marche/Marechal_en_combat.gif) · [Quatre diagonales](essais/boss_marche/Marechal_quatre_diagonales.jpg)
- **Chef de guerre** · [Extrait en combat](essais/boss_marche/Chef_de_guerre_en_combat.gif) · [Quatre diagonales](essais/boss_marche/Chef_de_guerre_quatre_diagonales.jpg)

Le validateur couvre 18 dossiers d’animation, sans problème détecté. Les suites ciblées couvrent la bibliothèque, les visuels ennemis, la marche et le chapitre de la Garnison. Les deux cycles sont proposés à la validation artistique du porteur.
