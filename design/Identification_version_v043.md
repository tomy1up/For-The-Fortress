# Identification de la version — v0.43

25 octobre 2026. Amélioration de la traçabilité des essais, sans modification des règles de jeu.

## Comportement

Le titre natif de la fenêtre et le pied de l’écran affichent la version lue dans le projet embarqué. Le nom interne de l’application reste identique pour conserver le dossier local des rapports existants. Les captures peuvent ainsi montrer la version testée ; aucune donnée ni connexion réseau n’est ajoutée.

Les rapports contenaient déjà ce numéro. Le vérificateur de distribution contrôle désormais sa concordance avec VERSION.json, le nom du dossier extrait et la notice, puis avec la valeur annoncée par le programme lors des captures et celle des rapports exportés pour les deux factions. Il s’agit d’un contrôle de cohérence, pas d’une signature d’éditeur.

## Vérification

25 suites et **14 159 contrôles Godot**, **9 tests Python** et contrats du GDD réussis. Trois contrôles supplémentaires couvrent les rapports des deux factions et la persistance de l’identification visible après un nouvel essai. La validation du paquet Windows et l’inspection visuelle sont consignées dans Distribution_Windows_v043.json.

Les chiffres de combat, la préparation de 30 secondes, les bonus et les deux factions restent inchangés. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements du paquet réussis. Essai natif à droite : titre v0.43 et pied lisible après choix Alliance par Entrée, sans chevauchement du rappel clavier. [Capture](essais/captures/QA-v043_version_visible.jpg). Fenêtre fermée après vérification.
