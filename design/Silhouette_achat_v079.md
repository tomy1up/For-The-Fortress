# Silhouette avant recrutement — v0.79

28 octobre 2026. Amélioration de la lecture du placement dans le style cartoon existant. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Prévisualisation

Survoler une offre ou lui donner le focus clavier affiche le défenseur en transparence sur l’emplacement libre sélectionné. La silhouette utilise l’illustration de sa classe et rejoint le tri de profondeur des acteurs de la carte. Le repère E1 à E6 passe sous ses pieds pour rester lisible.

La portée et les synergies prévues restent celles de l’aperçu existant. La mention « Aperçu avant achat » distingue la projection d’une vraie recrue. Un achat indisponible conserve la possibilité de comparer, avec une silhouette plus discrète et le bouton toujours interdit. Quitter l’offre, occuper l’emplacement, commencer le combat ou repartir à l’accueil retire la silhouette.

## Séparation du dessin et du jeu

La vue refuse un type de l’autre faction et un aperçu périmé pendant le combat. Aucun défenseur, cible, tir, coût ou paiement supplémentaire n’est créé. Après achat, une seule unité réelle est présente. Les illustrations existantes sont réutilisées, sans nouveau fichier d’image. Le modèle de combat, les prix et le profil restent inchangés.

## Validation

56 suites et 17 426 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 186 nouveaux contrôles couvrent les six classes dans les six emplacements, position, disponibilité, dessin sans achat ni instance, sortie de survol, clavier, budget nul, achat unique, type adverse rejeté, combat et nouvelle partie.

Le ZIP Windows passe 130 lancements, produit 129 captures et correspond à 37 sources locales. Le modèle, les vagues, les statistiques, les talents, le profil et les rapports ont les mêmes empreintes source que v0.78. Captures inspectées : [archer](essais/captures/QA-v079_alliance_purchase.png), [arbalétrier](essais/captures/QA-v079_alliance_crossbow_purchase.png), [mage](essais/captures/QA-v079_alliance_mage_purchase.png), [lanceur de haches](essais/captures/QA-v079_horde_purchase.png), [sapeur](essais/captures/QA-v079_horde_sapper_purchase.png) et [chaman](essais/captures/QA-v079_horde_shaman_purchase.png). [Régression](essais/v079_regression.json) et [distribution](Distribution_Windows_v079.json). Profils isolés ; aucun nouvel essai humain d’équilibrage.
