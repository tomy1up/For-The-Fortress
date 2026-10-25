# Sélection au clavier — v0.41

25 octobre 2026. Navigation dans les six emplacements existants, sans nouvelle mécanique de combat.

Les touches **1 à 6** de la rangée supérieure ou du pavé numérique sélectionnent **E1 à E6**, comme un clic sur la carte. La touche physique est prise en compte pour les claviers AZERTY, y compris sans Maj. Un chiffre produit avec Maj reste accepté. Les combinaisons avec Ctrl, Alt ou la touche système sont ignorées, ainsi que les répétitions et relâchements.

La sélection affiche la place libre ou les statistiques du défenseur présent et met en évidence son emplacement. Elle ne recrute, ne vend, n’améliore et ne lance aucune vague. Les boutons conservent leurs actions habituelles. Le combat reste automatique et le décompte de préparation continue.

Le choix de faction, la spécialisation, le choix roguelite, le récapitulatif et le bilan bloquent ces sélections derrière leur panneau. En combat, les touches permettent d’inspecter les défenseurs ; les dépenses restent verrouillées. Un nouvel essai efface la sélection. Le bas de l’écran rappelle les touches disponibles.

Les raccourcis utilisent le traitement des touches non consommées par l’interface. Aucune nouvelle commande n’est affectée à Espace ou Échap ; les interactions clavier habituelles des boutons restent celles de l’interface.

## Vérification

- **24 suites et 14 072 contrôles Godot**, dont 68 ciblés sur la sélection, plus **9 tests Python** du lanceur.
- Les deux factions, les six places, le pavé numérique, le cas AZERTY, les modificateurs, les répétitions, les panneaux et la préparation sont couverts. La sélection laisse les ressources, les unités, les événements, le temps simulé et le générateur inchangés.
- **46 lancements Windows** du paquet vérifiés, sur l’écran de droite.
- Essai interactif sur le même paquet : Alliance choisie, touche 6 vers E6, pavé numérique 2 vers E2, Ctrl+6 laissant E2 sélectionné. Toujours 150 or, 20 PV et aucune unité recrutée. [Capture](essais/captures/QA-v041_selection_clavier.jpg). Fenêtre située sur le second écran puis fermée.

Le GDD reste en v0.14 et les réglages conservent leur statut antérieur. Le comportement de la souris passe par la même fonction de sélection pour maintenir la cohérence entre les deux entrées.
