# Suivre le boss — v0.39

25 octobre 2026. Amélioration de lecture de la dernière vague ; règles et réglages inchangés.

Pendant le combat, le Seigneur de siège possède une jauge permanente en haut de l’aire de jeu, sans avoir à le survoler. Elle indique son nom, ses PV et la perte de PV de la forteresse s’il l’atteint. La mention **Défaite** dépend de la vie actuelle de la forteresse : elle ne s’affiche pas lorsque le passage à 20 dégâts peut être encaissé, par exemple contre 24 PV.

La jauge utilise la vie réelle sans arrondir le calcul. Le nombre affiché est arrondi vers le haut pour qu’un boss encore vivant à moins d’un PV ne soit pas annoncé à zéro. La fiche au survol reste disponible à droite pour sa récompense et son éventuelle malédiction. Les deux présentations peuvent coexister.

Le bandeau est placé au-dessus des ennemis à l’entrée du chemin. Il ne reçoit ni clic ni focus. Il se masque derrière les choix et récapitulatifs, hors combat ou lorsque le boss n’est plus présent. Sa disparition n’annonce pas la fin de la vague : les autres ennemis continuent d’être résolus selon les règles habituelles. Aucun temps d’affichage forcé, ralentissement, son ou événement de combat n’est ajouté.

**Validation : 14 004 contrôles réussis**, dont 52 ciblés sur la présence, les PV fractionnaires, les dégâts de forteresse, les écrans modaux et la remise à zéro. Les consultations ne changent ni état, ni ressources, ni générateur aléatoire. **46 lancements Windows**, avec lecture du bandeau dans les deux factions et vérification explicite de sa présence sans fiche au survol.

Les vues de dernière vague sont issues des campagnes de référence financées normalement. [Capture sans survol, Horde](essais/captures/QA-v039_boss_sans_survol.png). Essais graphiques sur le second écran à droite. Le boss conserve 600 PV, sa vitesse, sa récompense et ses 20 dégâts à la forteresse ; le GDD reste en v0.14.
