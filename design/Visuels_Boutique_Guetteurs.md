# Boutique · guetteurs et tireurs d’élite

Le porteur a demandé de retrouver le style des unités existantes, puis a jugé les nouvelles proportions meilleures. La troisième planche conserve les visages expressifs, les aplats et les membres de l’archer elfe et des trolls de référence.

La sentinelle porte une capuche ivoire, un manteau bleu pétrole à pans droits et une tresse sombre, en boutique comme sur le plateau. En boutique, elle tient sa longue-vue à deux mains, avec l’arc en bandoulière. Sur le plateau, elle se tient droite, arc court tenu bas en diagonale et longue-vue à la ceinture. L’archer elfe de base est blond et tire debout, en tunique verte. Le tireur d’élite est proposé un genou à terre, en armure bordeaux, avec un grand arc renforcé de bronze. Le veilleur tient une hache.

Le 14 novembre 2026, le porteur a approuvé la sentinelle, le tireur d’élite à genou et la nouvelle silhouette du javelinier. Pour le distinguer du lanceur de haches de base, le javelinier a une silhouette plus fine, une tresse claire, la peau mauve et un long pan ocre. Il tient la javeline en diagonale sous le visage.

[Comparaison avec l’archer de base et le tireur d’élite](essais/boutique_guetteurs/Archer_sentinelle_tireur_elite.jpg) · [Comparaison des trois trolls](essais/boutique_guetteurs/Troll_haches_javelinier_veilleur.jpg) · [Illustrations et rendu sur le plateau](essais/boutique_guetteurs/Quatre_unites.jpg) · [Boutique Alliance](essais/boutique_guetteurs/Boutique_Alliance.jpg) · [Boutique Horde](essais/boutique_guetteurs/Boutique_Horde.jpg)

| Type | Fichier | Cadre | Pied | Hauteur du cadre | Départ du projectile proposé |
| --- | --- | --- | --- | ---: | --- |
| 10 | `sentinelle_elfe_v001.png` | `Rect2(0,0,543,871)` | `(232, 871)` | 59 | `(11.0, -22.5)` |
| 11 | `tireur_elite_elfe_v001.png` | `Rect2(0,0,1284,1110)` | `(445, 1110)` | 56 | `(29.25, -32.25)` |
| 16 | `veilleur_cendres_v001.png` | `Rect2(0,0,1174,1029)` | `(600, 1029)` | 57 | `(-3.25, -8.0)` |
| 17 | `javelinier_troll_v001.png` | `Rect2(0,0,894,1031)` | `(347, 1031)` | 64 | `(-3.25, -25.5)` |

Le veilleur des cendres a une posture basse et large, avec un manteau de plumes charbon, une écharpe orange et un visage gris. Le portrait `veilleur_cendres_guet_v001.png` (1288 × 1031) le montre à la longue-vue, hachette à la ceinture. Le sprite du plateau le montre hachette basse en main, longue-vue rangée. Le porteur a validé les deux poses fixes le 14 novembre 2026. Les types 10, 11, 16 et 17 sont prêts à intégrer.

Une copie d’essai v0.197 a affiché les quatre portraits en boutique. Les quatre unités ont été achetées sur des profils isolés, recrutées au Gué et observées jusqu’au premier tir. L’archer et le lanceur de haches de base ont été capturés au même emplacement. Le test visuel de boutique étendu sur la copie passe ses 40 contrôles. Pour le type 10, utiliser `sentinelle_elfe_guet_v001.png` (543 × 858) comme portrait et inclure ce PNG dans les listes d’export. Les tirs utilisent encore le rendu générique des familles dans la copie, dont le carreau de la famille arbalétrier pour le tireur d’élite et la hache pour le javelinier. Associer les projectiles à l’arc et à la javeline lors du branchement des unités correspondantes.

## Tir du Tireur d’élite elfe

Le sprite du type 11 garde le genou au sol et l’arc de bronze. En garde, la corde est détendue et le trait reste en réserve. Le tireur encoche, tire la corde vers la joue, puis lâche. La corde revient et oscille brièvement pendant que la main accompagne le geste. La première et la dernière image sont identiques à la garde. L’attaque compte 22 poses sur 0,66 s.

[À taille native à ×1](essais/gestes_combat/tireur_elite_elfe/Tireur_elite_x1.gif) · [À taille native à ×2](essais/gestes_combat/tireur_elite_elfe/Tireur_elite_x2.gif) · [Vue agrandie](essais/gestes_combat/tireur_elite_elfe/Tireur_elite_agrandi.gif)

Sur la copie v0.216, le tireur est acheté sur un profil d’essai et recruté à La Grande Salle (mission 94). Un Capitaine orc est placé sur la route haute comme cible de contrôle. Le tir réel est vérifié depuis E1 à droite et E2 à gauche, à ×1, à ×2 et à temps figé. Le Capitaine survit au premier tir. Validateur : 28 dossiers, 0 problème. Bibliothèque : 169 contrôles. Présentation des défenseurs : 63 contrôles.

La flèche quitte la planche sur la première image sans flèche, à 0,27 s. Le `muzzle` de la description donne le point de départ à (±38,20 ; −33,44) pixels depuis le pied. Dans l’essai, le trait conserve d’abord l’orientation de la flèche dessinée, puis s’incline vers la cible et retrouve sa longueur habituelle au cours du vol. Le décalage concerne l’apparition du projectile et de son impact. Les dégâts restent résolus à l’instant du tir. [Planches en revue](essais/gestes_combat/tireur_elite_elfe/defender.alliance.marksman/).
