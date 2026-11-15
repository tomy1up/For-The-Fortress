# Marche des attaquants · quatre directions

Le porteur demande que l’attaquant regarde dans le sens de chaque diagonale du chemin et que ses équipements restent du même côté anatomique au virage. Un bouclier porté à gauche reste dans la main gauche. Il pourra apparaître à droite de l’image, derrière le corps ou partiellement masqué selon la vue.

Le rendu reçoit déjà la direction du segment projeté et la distance parcourue. Pour les planches, il choisit une variante en montée ou en descente puis utilise un miroir pour le sens horizontal. Le miroir inverse aussi les accessoires asymétriques. Le loup utilise son propre maillage et garde son cycle approuvé.

## Essai proposé

Prendre le Capitaine orc et son bouclier comme pilote. Dessiner quatre vues cohérentes pour les diagonales ↖, ↗, ↙ et ↘, avec le même côté d’équipement, le même pivot au sol et les mêmes moments d’appui. Vérifier d’abord un changement de vue au coin avec conservation de la phase de marche. Comparer ensuite le même coin avec une ou deux poses intermédiaires de transfert d’appui et de rotation des épaules. Choisir leur durée d’après la perception en jeu à ×1 et ×2. Pour une production plus large, évaluer un personnage articulé ou un modèle rendu en sprites si le nombre de transitions dessinées devient trop coûteux.

La sélection de la direction et les poses intermédiaires restent des décisions de rendu. Vérifier les deux sens de virage, la continuité des appuis, la pause, l’absence de cisaillement et la lisibilité au milieu d’une vague. La position logique reste sur le chemin actuel. Le pilote est une proposition, sans modification du moteur ni du maillage du loup dans ce lot.

## Capitaine orc · orientations fixes du pilote

Les quatre vues utilisent des cadres de 288 × 256 px, une ancre commune (144, 238) et environ 54 px de haut sur le plateau, comme le capitaine actuel. La vue ↘ vient du visuel approuvé. Les vues de dos et la vue de face ↙ ont été dessinées avec le générateur intégré d’après ce visuel. La première proposition de face ↙ regardait vers la droite et a été remplacée.

[Comparatif des quatre directions](essais/garnison/orientations/Capitaine_quatre_directions.png)

La vue varie selon les signes de la direction projetée. Le bouclier reste du côté gauche du corps dans les images de face et de dos. En remontant vers la droite, il est davantage vu sur la tranche. La lame reste à la main droite. Les quatre sélections ont été testées avec le rendu du plateau dans une copie v0.208 et un trajet de contrôle par direction. Le test ciblé des visuels ennemis passe, 213 contrôles. Ce lot propose des orientations fixes. Il reste à dessiner la marche et à comparer en mouvement le changement de direction sec avec une transition.

## Bouclier plat porté devant · contrôle sur la chaussée

Le porteur a demandé de conserver le bouclier devant le torse, sur le même avant-bras gauche, lors de tous les pivots. Les deux vues de dos ont été redessinées d’après le sprite de face approuvé. Le bouclier est un panneau plat. En montant vers la gauche, seule une partie de la face intérieure dépasse de l’épaule. En montant vers la droite, l’armure masque presque tout le panneau. La lame reste près de la hanche droite. Le casque, les épaulières, le foulard et la ceinture servent de repères de continuité entre les vues.

[Les quatre segments à taille native](essais/garnison/orientations/v2/Capitaine_quatre_directions_sur_route.png) · [Deux virages en mouvement](essais/garnison/orientations/v2/Capitaine_pivots_sur_route.gif)

L’essai utilise la chaussée réelle de la mission 62, Les Coulées Figées. Un Capitaine attaquant est placé sur le trajet existant dans la copie v0.208 puis avancé par sa distance le long de la route. La mission sert ici de banc d’essai car elle contient les quatre diagonales. Les quatre vues sont contrôlées en jeu à taille native. Deux virages sont rejoués en changement direct de pose. Le cycle de marche et les poses de transition restent à produire. Les 213 contrôles ciblés des visuels ennemis passent.
