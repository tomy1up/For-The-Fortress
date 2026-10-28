# Données des cartes — v0.80

28 octobre 2026. Préparation des futures cartes, sans ajout d’une carte jouable ni modification de l’équilibrage. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Comportement

La définition de La Vallée du Gué regroupe son identifiant, son titre, ses dimensions, le tracé, sa longueur, six emplacements, les arbres et le type de décor. Le modèle possède sa propre copie. Les positions, fenêtres de tir, proximités, rebonds, explosions, arrivées et effets utilisent la géométrie de cette partie. La vue et les clics lisent les mêmes données ; la forteresse est attachée à la dernière extrémité du chemin.

Les anciennes constantes du Gué et signatures des outils géométriques restent compatibles avec les tests historiques. Le pont et la rivière sont conservés comme décor propre au Gué, sans collision. Aucun terrain généré, sélection de carte ou enchaînement de missions n’est ajouté.

Une définition invalide bloque le démarrage et les achats. Les contrôles portent sur les champs requis, coordonnées finies et bornées, segments non nuls, longueur mesurée, six emplacements distincts et décor reconnu. Bornes techniques : dimensions de 1 à 64 par axe, 512 points de chemin au maximum et 128 arbres ; elles ne garantissent pas qu’un grand plateau entre dans la fenêtre. La caméra et la disposition des futures cartes restent à adapter et valider.

## Rapports et progression

Les rapports du Gué gardent leur format exact. Une autre géométrie injectée pour les tests ajoute une définition sérialisée facultative ; la relecture la valide avant de construire le modèle. Une définition mal formée est refusée. Les scripts de test sont exclus du paquet Windows.

Le nom interne de l’application, qui détermine le dossier de sauvegarde, reste inchangé. Le titre de fenêtre suit le titre de la carte. Aucun changement du profil, de ses protections, des gains, des talents, des règles de fin de partie ou du coût de respécialisation.

## Suite de conception

La [feuille de route long terme](Feuille_de_route_long_terme.md) consigne la nouvelle vision de campagne et distingue décisions, cibles et propositions de l’ancienne réponse. Le passage de l’économie actuelle aux PO de première réussite, les 200 missions et le mode infini ne sont pas implémentés par cette refonte. Les règles de transition et de récompense restent à cadrer avant développement dépendant.

## Validation

57 suites et 17 552 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 126 nouveaux contrôles vérifient les définitions, leur copie par partie, les positions et virages, la couverture et son recalcul, les arrivées à la longueur exacte, les clics et silhouettes des deux camps, l’inspection, le reset, les rapports et les refus de données invalides.

Les 16 scénarios comparés à v0.79 conservent exactement les rapports, états aléatoires, événements, dégâts et éliminations du Gué : deux factions, zéro ou 33 points de talents, deux graines et deux pas de simulation. La version de projet est normalisée à 0.80 dans les deux environnements isolés. [Comparaison](essais/v080_comparaison_geometrie.json).

Le paquet Windows passe 130 lancements, produit 129 captures et correspond à 38 sources locales. [Régression](essais/v080_regression.json) et [distribution](Distribution_Windows_v080.json). Les statistiques, vagues, talents et sources du profil ont les mêmes empreintes que v0.79. Aucun nouvel essai humain d’équilibrage.

Captures du paquet final : [Alliance](essais/captures/QA-v080_alliance_purchase.png), [Horde](essais/captures/QA-v080_horde_purchase.png), [forteresse Alliance](essais/captures/QA-v080_alliance_fortress.png), [forteresse Horde](essais/captures/QA-v080_horde_fortress.png). Géométrie exclusivement destinée aux tests source : [Alliance](essais/captures/QA-v080_synthetic_alliance.png) et [Horde](essais/captures/QA-v080_synthetic_horde.png). Tous les essais utilisent des profils isolés et l’écran de droite.
