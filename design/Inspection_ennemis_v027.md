# Inspection des ennemis — v0.27

23 octobre 2026. Évolution de la lisibilité du combat : présenter les données des ennemis déjà utilisés par la simulation, sans ajouter de comportement ou modifier l’équilibrage.

## Informations affichées

Pendant le combat, survoler le personnage ou sa barre de vie affiche une fiche en haut à droite : nom, PV actuels et maximum, perte de PV à son arrivée et or rapporté s’il est éliminé. Le boss porte une mention explicite. Si les dégâts d’arrivée suffisent à détruire la forteresse dans son état actuel, la fiche le signale en couleur. Ce signal reste conditionnel à son arrivée ; il ne prédit pas qu’il survivra aux défenseurs.

Une malédiction active est signalée depuis les effets réellement présents. Un cercle doré et une barre de vie accentuée identifient l’ennemi inspecté. Les PV textuels sont arrondis au supérieur pour qu’un ennemi vivant ne soit jamais affiché à zéro ; la jauge utilise les PV réels et le calcul du combat ne change pas.

La fiche suit le survol, sans verrouiller un ennemi. Elle disparaît si l’ennemi meurt, s’éloigne du pointeur, quitte le jeu ou si une fenêtre modale est ouverte. Elle n’apparaît qu’en combat. Une indication de survol est présente lorsqu’aucun ennemi n’est inspecté.

## Interactions conservées

Inspecter ne change pas le défenseur sélectionné, ne choisit pas de cible d’attaque et ne suspend ni ne ralentit le combat. Le ×1/×2 reste applicable. Aucune récompense ou perte de PV n’est déclenchée par l’inspection. Les achats, améliorations, aperçus, délais de préparation et choix roguelite conservent leur comportement.

La détection utilise les dimensions affichées de chaque profil après projection isométrique. Les ennemis superposés sont départagés selon leur profondeur, avec un ordre déterministe en cas d’égalité. Le calcul de combat et ses priorités restent inchangés.

## Vérification

**2 041 contrôles réussis**, dont 78 dédiés à l’inspection : huit profils, PV fractionnaires, jauge et mise en page, danger conditionnel du boss à 20 ou 24 PV, malédictions, ennemis superposés, déplacement, suppression, phases et fenêtres modales, absence de mutation, horloges ×1/×2 et retour à la préparation.

L’archive Windows extraite est vérifiée avec quatorze lancements, dont une inspection d’ennemi ordinaire et une inspection du boss au budget normal. Les deux fiches sont inspectées visuellement dans l’exécutable final. Les campagnes de référence gardent leurs résultats. Rapport et empreintes : `Distribution_Windows_v027.json`.

Les coûts, ennemis, statistiques, vagues et règles restent inchangés ; le délai de préparation reste 30 secondes. Les GDD principaux Word et Markdown restent en v0.14 avec leurs compléments ; cette fiche décrit la présentation du prototype.
