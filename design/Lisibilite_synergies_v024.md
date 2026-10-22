# Lisibilité des synergies — v0.24

23 octobre 2026. Mise en œuvre des informations d’inspection déjà prévues dans le cahier du prototype, après les essais joueurs et les clarifications de libellés. Aucun nouvel effet de synergie.

## Comportement livré

Sélectionner un défenseur affiche ses liens actifs sur la carte : traits dorés pour la proximité, traits bleus pour les spécialisations. Seuls les partenaires satisfaisant les conditions actuelles sont reliés. Quand deux associations concernent la même paire, les traits sont légèrement décalés pour rester distinguables.

La ligne au-dessus de la fiche affiche le nombre de synergies actives. Son survol donne, pour chaque association possible du type sélectionné :

- le partenaire et ses emplacements lorsqu’il est présent et admissible ;
- le statut actif ou inactif et l’effet pour le défenseur sélectionné ;
- les emplacements compatibles pour une association de proximité ;
- les spécialisations nécessaires et l’absence de limite de distance pour une association de spécialisations.

Les codes techniques restent dans les données et documents ; l’aide du jeu emploie les noms des défenseurs et les effets en clair. Les infobulles ont un fond opaque et une taille de texte adaptée. Elles ne suspendent pas le combat ni le délai de préparation. Les choix roguelite et de spécialisation gardent leur fonctionnement précédent.

## Règles conservées

Le calcul et l’affichage consultent la même recherche des partenaires, y compris pour les aperçus de spécialisation. La proximité utilise toujours la distance logique au carré ≤ 25 ; E3/E5 reste exclu même avec une portée augmentée. La spécialisation exige les deux branches correspondantes, sans condition de distance. Plusieurs partenaires peuvent être reliés mais un même code n’accorde son effet qu’une fois par bénéficiaire. Vente et réinitialisation retirent les liens devenus invalides.

Les coûts, bonus, statistiques, vagues et conditions d’activation ne changent pas. Le délai de préparation reste 30 secondes réelles. Les synergies raciales restent différées. Le GDD principal Word et Markdown reste en v0.14, complété par les décisions d’enchaînement ; cette livraison précise la présentation des règles existantes.

## Vérification

1 198 contrôles réussis, dont 123 pour partenaires multiples, non-cumul, ventes, frontière E3/E5, proximité E3/E4, spécialisation à distance, aperçu sans validation, mauvaise branche, descriptions des deux factions et réinitialisation. Les campagnes de référence au budget normal gardent leurs résultats : Alliance 14 PV / 192 or ; Horde 12 PV / 189 or.

Les captures des liens et de l’aide sont inspectées dans les deux factions. Les captures de toutes les branches utilisent un budget de contrôle explicitement distinct des essais d’équilibrage. Le contrôle de l’archive Windows comprend huit lancements, dont deux vues de combat avec synergies financées au budget normal. Les empreintes et résultats d’export sont dans `Distribution_Windows_v024.json`.
