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

## Visée du Tireur d’élite selon la hauteur à l’écran

Le 15 novembre, le porteur valide le geste et relève que la flèche plonge alors que l’arc reste horizontal. La nouvelle variante conserve le geste de la main, sa cadence et les appuis. Pendant l’armé, le tireur incline le haut du corps et l’arc vers la cible. Le bas du corps reste ancré. Au lâcher, l’origine du projectile tourne autour du même pivot que la flèche dessinée. Le trajet part dans la même direction que le trait puis rejoint le point d’impact.

[À taille native ×1](essais/gestes_combat/tireur_elite_elfe/visee/Tireur_visee_x1.gif) · [À taille native ×2](essais/gestes_combat/tireur_elite_elfe/visee/Tireur_visee_x2.gif) · [Vue agrandie](essais/gestes_combat/tireur_elite_elfe/visee/Tireur_visee_agrandie.gif)

Sept planches couvrent une visée horizontale ou des inclinaisons de ±8°, ±16° et ±24°. Les 154 poses ont été contrôlées pour le cadrage. Le départ et le retour de chacune reproduisent la garde. L’essai en combat couvre une inclinaison de +16° à droite et de −8° à gauche sur la mission 94, à ×1, ×2 et à temps figé. Dans les deux sens, la tangente mesurée au départ suit l’angle de la pose à moins de 0,6°. Validateur dans la copie d’essai : 28 dossiers, 0 problème. Bibliothèque : 169 contrôles.

Les planches de [la variante](essais/gestes_combat/tireur_elite_elfe/visee/) partagent le nouveau cadrage de 336 × 296. Le fichier `visees.json` documente le pivot, les angles et le lâcher à 0,27 s. L’intégration doit sélectionner une seule inclinaison, d’après le point touché à l’écran depuis le pivot à hauteur de flèche, et la conserver durant le geste et le départ du projectile. Les inclinaisons extrêmes ont été examinées sur les planches. Les cas en combat concernent les deux angles indiqués. Les planches additionnelles ont été chargées en local pour cet essai. Claude doit les brancher au format d’export pour le jeu.

Le 15 novembre, le porteur valide la visée corrigée (« propre, très bien »). Les planches du lot `a2cdab9` sont retenues pour l’intégration.

## Lancer du Javelinier troll

Le type 17 reprend sa garde basse. Il recule l’épaule et lève la javeline par-dessous le menton, puis fait avancer le buste avec le bras. La main s’ouvre dans le prolongement du geste et retrouve la garde à la fin du cycle. Les bottes restent ancrées. Les trois planches partagent la pose de garde, le point d’appui et 20 poses sur 0,60 s. La première et la dernière image de chaque lancer sont identiques à la garde.

[À taille native ×1](essais/gestes_combat/javelinier_troll/Javelinier_lancer_x1.gif) · [À taille native ×2](essais/gestes_combat/javelinier_troll/Javelinier_lancer_x2.gif) · [Vue agrandie](essais/gestes_combat/javelinier_troll/Javelinier_lancer_agrandi.gif)

La javeline dans la main et celle en vol proviennent du même dessin rigide. L’essai part sur la première pose à main vide à 0,24 s, selon l’inclinaison de la lance (−12°, 0° ou +12°). Les points de départ de la pointe par rapport aux pieds sont dans `lachers.json`. Le PNG `javeline.png` mesure 495 × 60, pivot de pointe (485, 28), échelle 0,12 pixel de jeu par pixel source. En jeu, le reflet à gauche conserve la place de l’éclairage dans la silhouette en vol. La visée et l’impact sont des effets de rendu. Les dégâts restent résolus à l’événement de combat.

La copie v0.216 met le Javelinier en E1 et E2, côté Horde, sur la mission 94, avec un Capitaine humain comme cible de contrôle. Les tirs incliné de +12° vers la droite et incliné de −12° vers la gauche ont été observés à ×1 et ×2 et à temps figé. La direction initiale du projectile suit l’axe de l’arme à moins de 0,6°. Les 60 poses tiennent dans leurs cadres. Validateur : 29 dossiers, 0 problème. Bibliothèque : 170 contrôles. Les planches attendent la revue du porteur. Les variantes d’angle et le dessin du projectile sont hors des ressources de la version publiée et doivent être branchés avec la garde et le lancer neutre.

## Lancer du Javelinier avec transfert de poids

Le 15 novembre, le porteur juge le premier lancer peu naturel. La reprise fait porter le geste par le bassin et les épaules. Le troll charge son appui arrière pendant l’armé, pousse vers le pied avant en levant son talon arrière, puis laisse son bras continuer sa course après le lâcher. La main libre se replie pour libérer la lecture du geste. Les extrémités du cycle reprennent la pose de garde à l’identique.

La durée passe à 0,64 s, avec 20 poses par inclinaison. Le projectile commence à 0,288 s sur la première pose à main ouverte. La dernière pose tenue sert à caler la pointe et l’axe de départ. Les points recalés sont dans `transfert_poids/lachers.json`. La javeline en vol réutilise le dessin `javeline.png` du dossier parent.

[Avant-après à ×1](essais/gestes_combat/javelinier_troll/transfert_poids/Javelinier_comparatif_x1.gif) · [Lancers corrigés à ×2](essais/gestes_combat/javelinier_troll/transfert_poids/Javelinier_corrige_x2.gif)

Les 60 cadres contiennent l’arme et le personnage. Comparaison sur la mission 94, avec un Capitaine humain comme cible sur la route haute. Vérification en jeu à ×1 et ×2 du lancer descendant à droite et montant à gauche, de l’axe visuel au départ et de la stabilité des pixels à temps figé pendant l’armé et l’accompagnement. Validateur : 29 dossiers, 0 problème. Bibliothèque : 170 contrôles. Le porteur juge cette reprise « bien mieux » le 15 novembre. Le lot `7e715d8` est retenu pour intégration.

## Tir de la Sentinelle elfe

Le porteur valide le geste de tir et la reprise avec transfert de poids (`b9aecf9`). la Sentinelle engage son poids au lever de l’arc, recule l’épaule de corde à pleine tension, puis ramène le buste vers l’avant avec un léger retard de la tête. Le bassin accompagne le mouvement et les semelles restent ancrées. Les planches commencent et se terminent sur le dessin de garde à l’identique.

[Comparatif avant et après à ×1](essais/gestes_combat/sentinelle_elfe/Sentinelle_elfe_avant_apres.gif) · [Boucle en jeu à taille native](essais/gestes_combat/sentinelle_elfe/Sentinelle_elfe_en_jeu.gif)

Type 10, `defender.alliance.sentinel`. Le [dossier d’essai](essais/gestes_combat/sentinelle_elfe/) fournit la garde et trois angles (−12°, 0°, +12°), à 23 poses sur 0,92 s. La 14e pose est la première sans flèche. Le départ visuel se fait à 0,52 s, depuis la pointe indiquée dans `lachers.json` pour l’angle retenu. Choisir la pose dont l’angle est le plus proche du trajet depuis sa propre pointe. Relier cette pointe à l’impact en ligne droite et conserver cet axe de vol. La pointe de la flèche dessinée par le moteur doit coïncider avec le repère au départ.

Sur une copie de la v0.220, contrôle de cinq tirs sur la mission 94 à ×1 et ×2 vers la droite (+12°) et la gauche (0°). Vérification de 17 points sur chaque trajet et de la pose à temps de combat figé. L’angle montant a été contrôlé sur planche. Les 69 poses sont cadrées et les semelles identiques à chaque image. Le validateur signale 33 dossiers et 0 problème, et la bibliothèque passe 174 contrôles. Les règles et valeurs de combat restent celles du jeu.
