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

## Garde serrée · panneau lisible de dos

Le porteur a relevé que le bouclier des vues de dos était trop masqué et que la proposition avec un bras déporté ne respectait pas la garde approuvée. Les deux vues de dos ont été reprises avec le coude gauche rentré et le bouclier à hauteur de l’épaule et du genou, au contact de la silhouette. Le corps occulte la partie intérieure du panneau tout en laissant son bord extérieur continu. La bande rouge, le bord d’acier et les deux rivets qui restent visibles permettent de le reconnaître. Les deux vues de face réutilisent leurs PNG à l’identique.

[Comparatif de la garde](essais/garnison/orientations/v3/Capitaine_bouclier_garde.png) · [Virages sur la chaussée](essais/garnison/orientations/v3/Capitaine_bouclier_en_virage.gif)

Les vues ont été examinées en grand pour le contour et la prise, puis sur les quatre segments des Coulées Figées à taille native et aux deux coins du banc d’essai. Les 213 contrôles de la suite des visuels ennemis passent. Le 15 novembre 2026, le porteur juge cette garde « bien mieux ». La v3 sert de référence pour animer les appuis et les virages. Le changement de vue des captures est direct et la marche n’est pas animée.

## Premier cycle de marche sur quatre diagonales

Les quatre vues de garde sont utilisées avec un cycle de 24 poses chacune. Les semelles alternent une phase d’appui, qui compense l’avancée sur le chemin, et une phase de retour avec une levée modérée du pied. Les genoux suivent les bottes. Les épaules, le bouclier tenu serré et la lame suivent un balancement court du corps. Le même moment de la foulée est conservé entre les quatre vues. Le changement de vue au coin reste direct.

[Marche et pivots à taille native](essais/garnison/orientations/marche/Capitaine_marche_sur_route.gif)

Le [cadrage d’essai](essais/garnison/orientations/marche/cadrage.json) utilise des cadres de 320 × 288 px et une foulée de 10,5 px projetés à l’échelle de base, soit 16,8 px pour le capitaine. La phase est calculée à partir de la distance projetée. Aucun miroir. Les quatre planches ont passé le contrôle de découpe, 96 poses au total.

Captures sur deux coins des Coulées Figées (mission 62), à ×1 et ×2, sur copie v0.208. Le Capitaine avance sur la chaussée existante à sa vitesse de référence de 0,6 unité logique par seconde à ×1. Les captures contrôlées à distance figée restent identiques. Les tests des visuels ennemis (213) et de la bibliothèque d’animations (157) passent sur la copie d’essai. Les planches restent dans le dossier de design. Leur sélection pour les quatre orientations requiert un branchement spécifique avec conservation de la phase. Un essai de transition entre les vues reste à produire.

## Appuis resserrés et bottes dans l’axe

Le porteur a signalé une démarche en canard. Les quatre poses de base ont été redessinées avec les bottes plus près de l’axe du corps et orientées davantage vers la marche. Le dessin conserve le coude gauche rentré, le bouclier près du torse et la lame à droite. Les pas sont plus courts, avec une reprise progressive de la jambe libre. La foulée reste liée à la distance parcourue.

[Comparatif avant et après sur la chaussée](essais/garnison/orientations/marche_axe/Capitaine_demarche_avant_apres.gif)

Variante de 24 poses par orientation, cadres 320 × 288, ancre (160, 254), foulée de base 7 px projetés (11,2 px pour le Capitaine). Les 96 poses passent le contrôle de découpe. Comparaison sur les mêmes coins de la mission 62 et à la même vitesse de déplacement. La copie v0.208 a été vérifiée à ×1 et ×2 et à distance figée. Les 213 contrôles des visuels ennemis passent. Les virages utilisent encore un changement de vue direct. Cette démarche reste proposée à la revue du porteur.

## Foulée allongée · diagonale descendante vers la droite

Le test à pas courts donne une impression de piétinement. Sur cette diagonale, un cycle complet couvre 14,2 px projetés à l’échelle de base, soit 22,7 px pour le capitaine. Cette amplitude réduit le nombre de pas à vitesse égale. La jambe porteuse recule à la vitesse d’avancée du personnage pendant l’appui. La botte libre se dégage puis se repose devant. Le bassin monte et redescend légèrement au passage du poids d’une jambe à l’autre. Le dessin de la garde est conservé, bouclier serré devant le torse et lame à la main droite.

[Comparatif à ×1](essais/garnison/orientations/marche_foulee/Capitaine_foulee_x1.gif) · [Comparatif à ×2](essais/garnison/orientations/marche_foulee/Capitaine_foulee_x2.gif)

Les deux versions ont été capturées sur le même segment de la mission 62 à taille native dans la copie v0.208. La vitesse de base du capitaine reste à 0,6 unité logique par seconde. L’image reste identique à distance figée. Les 24 poses tiennent dans leurs cadres. Les tests du rendu ennemi (213 contrôles) et de la bibliothèque d’animations (157 contrôles) passent. Essai sur une seule diagonale, à valider par le porteur avant de décliner la marche.

## Jambes raccourcies · même foulée

Le porteur trouve la foulée plus naturelle et les jambes encore trop longues. Le bassin est abaissé de 7 px dans la planche, soit environ 1,7 px sur le plateau. Les cuisses et les tibias absorbent cet écart. Le torse et la garde gardent leurs proportions. La trajectoire des bottes, l’amplitude et la phase du cycle sont reprises de l’essai précédent.

[Comparatif à ×1](essais/garnison/orientations/marche_foulee_compacte/Capitaine_jambes_x1.gif) · [Comparatif à ×2](essais/garnison/orientations/marche_foulee_compacte/Capitaine_jambes_x2.gif)

Les 24 poses sont cadrées. Comparatif à taille native sur le même segment de la mission 62 dans la copie v0.208, à ×1 et ×2. Le contrôle à distance figée passe aux deux vitesses. La variante reste limitée à la diagonale descendante vers la droite.

## Marche dans les quatre directions

Le 15 novembre, le porteur juge la version aux jambes raccourcies « bien mieux ». La planche qui descend vers la droite est reprise telle quelle. Trois cycles distincts complètent la garde v3 avec le même rythme, le même cadrage et le même enchaînement gauche-droite. Les jambes sont dessinées à partir de leur propre vue. Le bouclier reste porté par le bras gauche, serré devant le torse, et la lame dans la main droite.

[Déplacement à ×1](essais/garnison/orientations/marche_quatre_diagonales/Capitaine_quatre_diagonales_x1.gif) · [Déplacement à ×2](essais/garnison/orientations/marche_quatre_diagonales/Capitaine_quatre_diagonales_x2.gif) · [Deux virages directs](essais/garnison/orientations/marche_quatre_diagonales/Capitaine_virages_directs.gif)

Contrôle à taille native sur quatre segments et deux coins de la mission 62 dans la copie v0.208, à ×1 et ×2 et à distance figée. Les 96 poses tiennent dans leurs cadres. La phase est calculée sur la distance projetée totale, avec un changement direct d’orientation aux coins. Les trois nouvelles vues attendent l’avis du porteur. Les poses intermédiaires de virage et la mort du capitaine restent à produire.

## Appuis séparés dans les quatre vues

Le porteur a signalé que les jambes semblaient se croiser. Chaque pied a maintenant sa propre trajectoire de part et d’autre du sens de marche. En phase d’appui, le recul de la botte dans le dessin compense le déplacement sur le sol. Le pied libre se soulève moins. Le cycle couvre 13,26 px projetés à l’échelle de base, contre 14,19 px dans l’essai précédent. Le bassin conserve sa hauteur abaissée et les quatre gardes conservent leurs équipements.

J’ai contrôlé les axes de chaque jambe, de la hanche au genou puis à la cheville, sur les 96 poses. Les deux chaînes restent distinctes. Vérification du cadrage et du rendu à taille native et agrandi sur la mission 62, à ×1 et ×2. La capture à distance figée reste identique. Les suites du rendu ennemi (213 contrôles) et de la bibliothèque d’animations (157 contrôles) passent sur la copie v0.208. Les quatre vues restent en revue avant branchement.

[Boucle native ×1](essais/garnison/orientations/marche_appuis_separes/Capitaine_appuis_x1.gif) · [Boucle native ×2](essais/garnison/orientations/marche_appuis_separes/Capitaine_appuis_x2.gif) · [Vue agrandie à vitesse normale](essais/garnison/orientations/marche_appuis_separes/Capitaine_appuis_agrandis.gif)

## Appuis resserrés

Le porteur juge les appuis séparés plus cohérents et les jambes trop écartées. L’écart latéral des deux trajectoires d’appui est réduit de 17 %. Le pied libre revient dans la même ligne, sous le bassin. La foulée est légèrement raccourcie, à 11,54 px projetés à l’échelle de base. La vitesse de déplacement du capitaine, la hauteur du bassin et les proportions des jambes sont conservées.

Les axes des jambes restent distincts sur les 96 poses vérifiées. La marche est contrôlée à taille native, à ×1 et ×2, et à distance figée sur la mission 62 dans la copie v0.208. Les tests du rendu ennemi (213 contrôles) et de la bibliothèque d’animations (157 contrôles) passent.

[Avant-après à vitesse normale](essais/garnison/orientations/marche_appuis_compacts/Capitaine_appuis_avant_apres.gif) · [Appuis resserrés à ×2](essais/garnison/orientations/marche_appuis_compacts/Capitaine_appuis_compacts_x2.gif)

Le 15 novembre, le porteur juge cette version « bien mieux ». Les quatre planches du lot `9fe2608` sont retenues pour le branchement dans le prototype avec un changement direct de vue aux virages.
