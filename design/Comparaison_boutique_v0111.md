# Comparaison des unités de boutique — prototype v0.111

3 novembre 2026. For the Fortress! est un nom de travail, disponibilité juridique à confirmer.

## Lecture des fiches

Les fiches gardent le rôle, le compromis, le coût de recrutement, les tirs principaux et les éventuels rebonds ou explosions. La cadence est formulée « Un tir toutes les … s ». Le rappel des talents nomme la famille concernée. Les mentions internes de réglage sont retirées de cet écran joueur ; les valeurs restent des hypothèses dans le GDD.

Le bouton « Comparer les chiffres » ouvre un tableau facultatif entre l’alternative et son défenseur de départ. Coût en or de combat, dégâts principaux, temps entre tirs et portée figurent côte à côte. Pour les deux unités de la Horde, les dégâts secondaires, le nombre d’autres ennemis et la distance ou le rayon sont également présentés. Les dégâts de l’explosion sur chaque voisin sont distingués de ceux du tir principal.

Les valeurs sont celles du niveau 1, sans talents, bonus ni synergies. Les colonnes proviennent des statistiques du modèle de combat, sans calcul d’un classement global de puissance. Le pied de tableau distingue les PO du déblocage permanent et l’or dépensé pour chaque recrue. Consulter ne débloque, n’achète et ne sélectionne aucune unité.

## Commandes et isolement

Le comparatif masque et bloque les commandes de boutique derrière lui. Échap revient à la boutique et replace le focus sur le bouton de comparaison utilisé ; un autre Échap peut fermer la boutique. Fermer la boutique efface le comparatif. Changer de faction ne conserve pas une ancienne comparaison.

Les achats, leurs prix, les statistiques et la sélection de la quatrième unité pendant toute la mission restent inchangés. La comparaison est disponible avant acquisition. Elle reste limitée à la famille de la faction ouverte. Les profils de contrôle sont isolés et ne remplacent pas la progression du joueur.

## Vérification

La suite dédiée contrôle les quatre alternatives, les prix comparés, les deux monnaies, les actions derrière la fenêtre, les retours au clavier, le changement de faction et l’absence de mutation de la progression. Des captures natives montrent la boutique avant et après acquisition ainsi que les quatre comparatifs. Résultat : **94 suites Godot, 39 724 contrôles et 17 tests Python réussis** ; **18 cas Windows ciblés sur 275**, comparaison de **74 sources** et examen des **17 captures**. Le premier passage a dépassé le délai de 30 secondes sur la simulation du chapitre 1 ; le passage complet avec une limite de 60 secondes réussit. Les rapports `essais/v0111_regression.json` et `Distribution_Windows_v0111.json` conservent les résultats. La fidélité des statistiques, des sauvegardes et du loup est vérifiée dans `essais/v0111_fidelite_sources.json`. Ces essais automatisés ne constituent pas une campagne jouée par une personne.
