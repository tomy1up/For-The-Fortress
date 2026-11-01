# Atelier à deux entrées — v0.107

## Comportement

Lancer `Lancer_atelier_routes.cmd` depuis le paquet Windows puis choisir Alliance ou Horde. Le choix mène directement à la préparation de l’atelier, sans ouvrir un parcours de campagne indisponible. Aucun profil joueur n’est chargé et aucun gain persistant n’est accordé.

Avant chaque vague, les deux entrées portent des repères distincts. Les quantités sont annoncées par entrée ; le survol des groupes détaille leur affectation et leurs horaires. Le calcul réutilise exactement l’affectation des apparitions du combat. L’alternance continue entre les groupes, sans repartir à zéro pour chaque nouveau groupe. Les annonces se recalculent pour la vague, la faction et les rencontres choisies. Elles disparaissent au combat.

## Décision de ciblage validée

Le porteur a choisi : **« Celui qui arrivera le plus tôt, selon sa vitesse »**, pour des ennemis à portée sur des routes de longueurs différentes. Le temps restant est donc la distance propre à la route, divisée par la vitesse de l’ennemi. En cas d’égalité, l’ennemi apparu le premier est prioritaire. Les règles historiques des cartes à trajet unique sont conservées.

La géométrie de La Confluence et l’alternance des apparitions restent des propositions de prototype. Ce lot n’ajoute pas de mission de campagne ni de forteresse supplémentaire.

## Compatibilité des rapports

Les nouveaux rapports multitrajets au format 2 enregistrent `route_target_policy=arrival_time`. Les rapports historiques de la v0.106 sans ce champ sont rejoués avec `remaining_distance`. La règle est fixée avant toute action et ne peut pas changer au cours de la partie. Les valeurs inconnues sont refusées. Les rapports des cartes à trajet unique gardent leur structure.

Deux rapports de référence ont été produits et vérifiés avec le paquet Windows v0.106 lui-même, avec défenseurs et ennemis de vitesses différentes. Leur relecture avec la nouvelle règle produit effectivement un résultat différent ; les tests prouvent donc la sélection de la règle historique, au-delà d’un simple cas sans combat.

## Validation et limites

Les contrôles couvrent la prévision comparée aux apparitions réellement observées dans les deux factions, les rencontres du Gué et des berges, les égalités de ciblage, les rapports historiques et la navigation de l’atelier. Résultat : **92 suites Godot, 39 452 contrôles et 17 tests Python réussis**. Résultats détaillés dans `essais/v0107_regression.json`.

Le paquet Windows compilé passe **13 cas ciblés sur 259 disponibles**, avec comparaison de 73 sources. Les captures de préparation et de combat de l’atelier, ainsi que celles du parcours neuf, ont été examinées dans les deux factions. Elles ne constituent pas une validation native exhaustive ni un test d’équilibrage humain complet. Rapport : `Distribution_Windows_v0107.json` ; exemples : `essais/captures/QA-v0107_routes_forecast_alliance.png` et `QA-v0107_routes_forecast_horde.png`.

L’équilibrage humain de ce terrain reste à éprouver. Les cartes à plusieurs sorties et forteresses restent à concevoir. Les essais du loup à 24 poses et à appuis articulés ne sont pas intégrés : ils attendent la validation artistique du porteur avant extension aux autres unités.

For the Fortress! est un nom de travail dont la disponibilité juridique reste à confirmer.
