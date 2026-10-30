# Flèches de talents droites — v0.89

30 octobre 2026. For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Demande validée

Remplacer les détours et zigzags par des liens droits, en laissant des espaces libres entre les talents reliés, selon la référence d’architecture fournie par le porteur du projet.

## Réalisation

Chaque parent est aligné dans la même colonne que son enfant. Les flèches descendent en une seule ligne verticale, sans coude. Les cases intermédiaires restent vides ; aucun lien ne traverse une autre icône. Les sept paliers sont visibles simultanément pour les six arbres.

La grille possède exactement quatre colonnes par spécialisation. Les sept paliers sont présentés sur huit rangées : le palier de 20 points regroupe deux rangées avec une accolade et un seul seuil commun. Cette disposition conserve les conditions de déblocage et réserve des couloirs aux liens qui sautent une ligne. Les noms et effets restent consultables dans l’encart commun à la sélection ; les couleurs grises et dorées gardent leur signification de prérequis.

## Périmètre

Exactement quatre colonnes, selon la précision du 30 octobre 2026. Correction visuelle uniquement : mêmes 21 talents par arbre, identifiants, liens de parenté, rangs, effets, exclusions et seuils. L’enfant exige toujours le rang maximal du parent ET le palier de sa ligne. Plafond de 51 points par faction, XP et PO inchangés, reset gratuit. Aucun changement de schéma de sauvegarde ni réinitialisation des investissements de v0.88.

Les positions précises restent des choix de présentation du prototype. Le catalogue [actualisé](Catalogue_talents_lies_v089.md) décrit les cellules et prérequis. La campagne au-delà du Gué et la boutique restent en développement.

## Validation

67 suites et **21 994 contrôles Godot**, 16 tests Python et contrats du GDD réussis. Les tests vérifient que chaque parent et enfant partagent une colonne, que chaque flèche est un segment vertical unique et qu’aucune icône étrangère ne coupe le trajet. Les sept paliers restent visibles.

Le paquet Windows passe **149 lancements et 148 captures**, avec 43 sources comparées. Le palier 20 partage deux rangées accolées, sans modifier son seuil. Les six arbres complets et les contrôles de prérequis des deux factions sont inspectés visuellement. Les **40 scénarios de combat** restent identiques à v0.88 (rapports, aléas, événements et dégâts). Aucun essai humain d’équilibrage ajouté pour ce correctif de présentation.

[Régression](essais/v089_regression.json), [comparaison](essais/v089_comparaison_combat.json), [distribution](Distribution_Windows_v089.json). Exemples : [Horde](essais/captures/QA-v089_horde_expanded_tree_0.png), [Alliance](essais/captures/QA-v089_alliance_expanded_tree_1.png).
