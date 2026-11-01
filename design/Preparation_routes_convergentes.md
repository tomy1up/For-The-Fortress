# Préparation des routes convergentes

État du 1 novembre 2026 : **socle géométrique en développement**, sans nouvelle mission et sans combat multitrajet encore jouable. La demande de varier les entrées, jonctions et sorties vient du porteur. Ce premier lot prépare plusieurs entrées vers **une seule forteresse** ; il ne décide pas les règles des futures cartes à plusieurs forteresses.

## Première étape réalisée

`prototype/scripts/route_geometry.gd` centralise les calculs de position, de distance et de couverture auparavant contenus dans le modèle de combat. Les fonctions publiques historiques du modèle restent disponibles et délèguent ces calculs au composant. Les vingt missions actuelles gardent leurs trajets, leurs rencontres et leur économie.

Le composant prépare aussi un réseau de trajets identifiés, chacun avec ses points et sa longueur. Il vérifie les coordonnées, les longueurs, l'absence de segments nuls et l'unicité des identifiants. Une vérification distincte impose une sortie commune pour le futur atelier à forteresse unique. Une route inconnue n'est jamais remplacée silencieusement par la première.

## Pourquoi une distance par route

Deux ennemis ayant parcouru sept mètres depuis deux entrées ne sont pas nécessairement voisins. Après leur jonction, deux ennemis au même endroit peuvent au contraire avoir parcouru des distances différentes. Les rebonds, explosions et protections doivent comparer leurs positions réelles.

Le cas synthétique de test utilise deux chemins de 12 et 14 unités, réunis en (4 ; 4) puis terminés en (10 ; 4). Ce sont des coordonnées de test, pas une nouvelle carte approuvée. Un défenseur près du tronc commun possède une fenêtre de couverture différente sur chacun des deux chemins. Les comparaisons à la frontière des rayons conservent les composantes float 64 bits.

## Étapes restant nécessaires avant une version jouable

- Affecter chaque apparition à un trajet, conserver cet identifiant pendant la mission et calculer son arrivée sur sa propre longueur.
- Relier ciblage, couverture des défenseurs, rebonds, explosions, malédictions et protection de la Gardienne à la bonne géométrie.
- Dessiner tous les chemins, leurs entrées et leurs couvertures ; adapter le survol et l'orientation des personnages.
- Conserver les trajets et affectations dans les rapports, puis vérifier leur relecture déterministe.
- Construire un atelier jouable isolé avant de proposer une mission de campagne ; comparer les deux factions et les vitesses de simulation.
- Tester, exporter et publier le lot complet seulement après ces raccordements. Le présent socle ne permet pas d'annoncer cette fonctionnalité comme livrée.

## Modalités encore ouvertes

Le partage des apparitions entre entrées, la règle de ciblage entre routes de longueurs différentes et le premier tracé jouable restent à préciser. La règle historique « ennemi le plus avancé » n'est pas transposée automatiquement à une distance absolue depuis deux entrées différentes.

Les cartes à plusieurs forteresses restent un chantier ultérieur : PV partagés ou distincts, conditions de défaite et éventuelle réorientation ne sont pas tranchés ici. Aucun numéro de mission, biome, difficulté supplémentaire ou nouvelle récompense n'est ajouté.

## Vérification

La suite `prototype/tests/test_route_geometry.gd` couvre les deux entrées, la jonction, les fenêtres de portée propres à chaque chemin, les réseaux invalides, les copies isolées et les frontières strictes de proximité : **30 contrôles réussis**. La suite historique des cartes passe ses 126 contrôles. La régression complète passe **90 suites Godot, 37 992 contrôles et 17 tests Python** ; [rapport avec empreintes des sources](essais/routes_convergentes_socle_verification.json). L'import de l'éditeur Godot se termine sans erreur. Ces résultats ne valident pas l'équilibrage d'une future carte.
