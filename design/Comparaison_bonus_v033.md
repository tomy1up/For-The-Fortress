# Comparaison des bonus roguelite — v0.33

24 octobre 2026. Aide à la décision dans le choix existant, complément du GDD v0.14.

## Réalisé

Chaque offre après les vagues 3, 6 et 9 conserve sa description et présente ses effets chiffrés avant/après sur les défenseurs actuels, classés par emplacement. Seuls les champs modifiés sont affichés. Chaque colonne possède une zone défilante pour les compositions longues ; les boutons de choix restent en dehors du défilement.

| Bonus | Comparaison |
| --- | --- |
| R-01, R-04, R-06, R-07, R-08 | Dégâts directs, explosions, rebonds ou malédictions réellement modifiés selon type et niveau |
| R-02 | Intervalle entre attaques, chaman exclu |
| R-03 | Portée effective, synergies actuelles incluses |
| R-05 | Rayon d’explosion ou distance de rebond, sans nouvelle victime promise |
| R-09 | PV actuels et maximum, avant/après |
| R-10 | Prix des prochains niveaux 2, 3 et spécialisations ; aucune rétroactivité |
| R-11 | Prix futurs des trois recrues de la faction, arrondis effectifs |
| R-12 | Dégâts modifiés uniquement contre Brutes, Colosses, Élites et boss ; condition explicitement affichée |

L’absence de bénéficiaire actuel est signalée sans qualifier le bonus d’inutile : une future recrue ou amélioration peut devenir admissible. Le récapitulatif des bonus acquis garde son format compact et ne présente pas un gain hypothétique supplémentaire.

## Contrat technique

La requête bonus_preview construit une liste locale des bonus projetés. Elle réutilise les calculs communs de statistiques, dégâts conditionnels et prix. Elle ne modifie ni défenseurs, ni fenêtres de couverture, ni or, ni PV, ni générateur, ni offre. Les résultats retournés sont indépendants de la partie. Un bonus invalide ou déjà acquis est refusé.

La validation demeure le choix existant, atomique et unique. Les trois offres, leur génération, leurs descriptions et leurs effets ne sont pas changés. Les 30 secondes commencent toujours après le choix d’une vraie fin de vague ; aucune sélection automatique n’est ajoutée.

## Statut et validation

Présentation réalisée ; règles et valeurs d’équilibrage conservent leur statut précédent. La lisibilité de listes longues et la compréhension par un nouveau joueur restent à évaluer en essai humain.

8 752 contrôles ciblés comparent les projections à de vrais choix dans 96 configurations de contrôle : deux factions, branches variées, niveaux 1 à 4, bonus précédents actifs ou non, dégâts conditionnels sur les quatre familles et prix arrondis. Ces configurations utilisent un budget et des cumuls imposés uniquement pour vérifier les interactions, jamais comme preuve d’équilibrage. 11 574 contrôles au total ; campagnes de référence inchangées. Le paquet Windows comprend 30 lancements de contrôle, dont des comparaisons à six défenseurs et une comparaison économique identifiées comme fixtures à budget imposé.
