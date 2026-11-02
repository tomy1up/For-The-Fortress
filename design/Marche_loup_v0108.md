# Marche du loup — prototype v0.108

2 novembre 2026. Nom de travail : For the Fortress!, disponibilité juridique à confirmer.

## Décision validée

Le porteur approuve la démarche de droite du comparatif « thorax et bassin » : « La démarche me convient pour le prototype ». Cette approbation porte sur le loup et ne vaut pas validation des futures animations des autres unités.

La v0.108 intègre ce cycle aux vingt missions et à l’atelier des routes convergentes, dans les deux factions. Le loup reste une unité neutre. Aucun paramètre de combat, récompense, talent ou sauvegarde n’est modifié.

## Rendu intégré

Le dessin et les courbes proviennent de [l’étude approuvée](essais/loup_transfert_poids/README.md). Une surface commune relie les membres proches au corps ; les membres éloignés sont dessinés derrière. Épaules et bassin suivent leurs attaches propres ; tête et queue accompagnent le corps.

Le paquet contient le dessin transparent et les courbes compilées : 1 057 sommets, 1 682 triangles, 129 poses de contrôle incluant la fermeture. Entre ces poses, les sommets libres suivent les courbes cubiques de l’atelier ; les sommets contraints suivent leur interpolation linéaire. Il ne s’agit pas d’une lecture saccadée de 129 images.

Le cycle dépend de la distance parcourue à l’écran, de la longueur de foulée et de la taille affichée. Le ralentissement et les vitesses de simulation affectent donc aussi la cadence ; une position immobile conserve sa pose. Les loups sont déphasés individuellement. Le rendu conserve le tri de profondeur du plateau et les réactions aux dégâts existantes.

Une transformation commune de toute la silhouette adapte les appuis aux diagonales du sol isométrique. Elle évite de déformer chaque patte indépendamment. Le filtrage avec niveaux de détail réduit le scintillement du dessin réduit. Les maillages sont réutilisés pendant la présence de chaque loup puis libérés à sa disparition.

## Contrôles et limites

- Test automatisé des appuis dans les quatre directions isométriques, fermeture du cycle, cadence, pause, indépendance des loups, survol et absence de modification du modèle sur vingt missions et deux factions.
- Contrôle de géométrie : 256 instants par direction ; aucun triangle retourné dans les cas examinés. Ce contrôle échantillonné complète les contrôles continus de l’étude source.
- Mesure native séparée du coût de calcul et d’envoi des sommets pour 1, 16, 48 et 96 loups. Ces mesures ne sont pas des mesures du nombre d’images par seconde d’une partie complète.
- Lecture des sommets du maillage natif pour vérifier que les mises à jour correspondent aux courbes calculées.
- Captures Windows ciblées dans les deux factions ; profils de contrôle isolés de la progression du joueur.

Les routes actuelles utilisent des diagonales compatibles avec ce profil. Une future route vue presque de face conserve provisoirement le profil plat : une véritable vue frontale reste à dessiner. La transition d’orientation aux angles reste immédiate. Les autres attaquants ne reçoivent pas le cycle du loup.

Les rapports de vérification de cette version sont conservés dans `essais/v0108_regression.json`, `essais/v0108_wolf_geometry.json`, `essais/v0108_wolf_cpu.json` et `Distribution_Windows_v0108.json`. Leur périmètre exact fait foi ; les captures techniques ne remplacent pas le retour du joueur sur une partie.

Résultat final : **92 suites Godot, 39 504 contrôles et 17 tests Python réussis**. Le test complet du premier chapitre a dépassé le délai initial de 30 secondes ; relancé seul avec 120 secondes, il a réussi en 44,688 secondes sur les mêmes empreintes de sources. Les deux tentatives sont conservées et le rapport final consolide leurs résultats.

Le paquet Windows passe **14 cas ciblés sur 263**, avec comparaison de **74 sources**. Huit captures du paquet ont été examinées. La vidéo `essais/v0108_loups_en_jeu.mp4` montre 144 images à 60 images/s avec la scène réelle et un déplacement imposé ; ce contrôle visuel isolé ne simule pas une partie complète.

Sur la machine d’essai, la mesure native du calcul des courbes et de l’envoi des sommets donne un coût médian de 1,556 ms pour 16 loups, 4,806 ms pour 48 et 9,410 ms pour 96. La lecture de contrôle des sommets du premier loup retrouve exactement les coordonnées calculées. Ces chiffres excluent le reste du jeu.
