# Aperçu de portée avant achat — v0.25

23 octobre 2026. Demande du joueur : visualiser le rayon d’action d’un défenseur avant de le recruter sur un emplacement, afin de comparer l’intérêt du placement.

## Comportement

Sélectionner un emplacement libre puis survoler un bouton de recrutement affiche le cercle bleu de portée et surligne en bleu les portions du chemin couvertes. Le focus clavier permet aussi la comparaison ; le survol est prioritaire et sa fin revient au choix au clavier s’il existe. Sortir du bouton sans focus retire l’aperçu.

Le panneau indique le défenseur, son niveau initial, la portée effective et le prix courant. Les bonus acquis et les synergies de portée apportées par les voisins sont inclus. Les explosions et rebonds ne sont pas ajoutés au rayon principal : la route surlignée représente les positions où une cible principale peut être visée.

L’aperçu reste disponible en cas de manque d’or ou de quota atteint ; le motif d’interdiction reste affiché et l’achat reste bloqué. Seul le clic d’achat valide recrute. Aucun or n’est dépensé, aucune instance créée, aucun tirage effectué et aucun bonus réel n’est activé par l’unité virtuelle.

L’achat ramène à l’inspection du défenseur réel. Le départ d’une vague, les fenêtres de choix ou de récapitulatif, les fins de partie et la réinitialisation retirent l’aperçu. La lecture ne suspend pas le délai de 30 secondes. Les emplacements et règles de combat restent inchangés.

## Réalisation et vérification

Le modèle calcule les statistiques de la recrue virtuelle à l’aide du calcul effectif existant, avec un candidat de niveau 1. Les partenaires de proximité sont recherchés avec les mêmes distances que dans le jeu ; les associations de spécialisations ne s’activent pas pour une recrue de niveau 1. La vue réutilise la projection isométrique du cercle et les fenêtres réelles de couverture. Elle conserve les virages du chemin et ne relie pas les fenêtres disjointes.

408 contrôles spécifiques comparent les aperçus aux achats réels pour les six défenseurs, les six emplacements, avec et sans bonus, et vérifient l’absence de mutation. Ils couvrent aussi la géométrie, le survol, le focus, le manque d’or, les changements de phase, le clic unique et le décompte. Total : **1 606 contrôles réussis**. Les références des deux campagnes restent inchangées.

L’archive Windows extraite est vérifiée avec dix lancements, dont deux aperçus d’achat, puis des captures supplémentaires des portées du sapeur et du chaman. Les quatre vues d’achat sont inspectées. Le rapport d’export et les empreintes figurent dans `Distribution_Windows_v025.json`.

Les GDD principaux Word et Markdown restent en v0.14. Cette fiche précise l’interface du prototype ; elle ne change aucun coût, dégât, portée de référence ou règle de synergie.
