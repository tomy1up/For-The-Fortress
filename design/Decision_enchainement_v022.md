# D-2026-10-23-01 — Enchaînement automatique des vagues

23 octobre 2026 · Appliqué dans le prototype v0.22.

## Source et statut

Demande explicite du porteur du projet dans le chat : compte à rebours entre les vagues pour jouer automatiquement après le premier lancement, avec attente de son choix aux améliorations. Durée précisée ensuite par le porteur du projet : **60 secondes**.

**V — Décision validée pour cette implémentation.** Ce complément remplace la règle de relancement manuel systématique du GDD principal v0.14. Les fichiers Word et Markdown du GDD principal restent conjointement en v0.14 ; cette décision séparée est la référence actuelle pour le lancement des vagues et devra être intégrée à leur prochaine révision commune.

## Comportement

| Situation | Comportement v0.22 |
| --- | --- |
| Avant la vague 1 | Préparation sans limite de temps ; premier départ manuel |
| Après une vague ordinaire, de 1 à 9 | Décompte visible de 60 secondes, puis lancement automatique de la suivante |
| Pendant le décompte | Achats, améliorations et ventes autorisés ; aucun achat ou niveau automatique |
| Clic sur le bouton de départ | Lance immédiatement la suivante, sans attendre le reste du délai |
| Choix roguelite après vagues 3, 6, 9 | Attend un choix sans limite de temps ; un délai complet de 60 secondes commence après la sélection |
| Choix de branche N4 | Suspend le délai restant ; confirmer ou annuler le reprend au même point |
| Lecture volontaire de « Bonus acquis » pendant la préparation | Suspend le délai pendant l’affichage des améliorations ; le reprend à la fermeture |
| Lecture de « Bonus acquis » pendant le combat | Le combat continue, comme auparavant |
| Vitesse ×1 / ×2 | Modifie seulement le combat ; les 60 secondes restent des secondes réelles |
| Victoire ou défaite | Aucun délai ni vague supplémentaire |
| Nouvel essai | Annule l’automatisme ; le premier départ redevient manuel |

Le décompte s’affiche dans le panneau de préparation et le bouton de départ. Les fenêtres d’amélioration signalent que le choix attend le joueur. Les niveaux, branches et bonus restent choisis par le joueur ; seule la succession des vagues devient automatique.

## Implémentation et vérifications

Le contrôleur de scène gère l’armement du flux, la vague associée et le temps restant. Le modèle de combat conserve ses transitions explicites, ce qui permet de tester les règles sans horloge d’interface. À l’expiration, le contrôleur utilise les mêmes transactions de préparation et de départ que le bouton existant.

Une image longue terminant un combat arme un délai complet : le temps de combat excédentaire n’est pas retranché à la préparation. Les choix modaux suspendent la consommation du délai. Aucun temps n’est passé à une vague supplémentaire dans l’image qui la lance ; sa première apparition reste à t = 0.

106 contrôles ciblés couvrent première attente manuelle, affichage, échéance, ×2, choix roguelite sans expiration, confirmation et annulation N4, lecture du récapitulatif, départ anticipé, réinitialisation et fins de partie. Deux campagnes au budget normal utilisent un seul lancement initial manuel et retrouvent leurs résultats de référence. Total avec régressions : **1 075 contrôles réussis**.

## Impact sur la durée

Neuf attentes complètes représentent 540 secondes, soit 9 minutes de préparation, avant les temps de choix supplémentaires. Avec environ 6 à 6,5 minutes de combat simulé des références à ×1, attendre systématiquement les 60 secondes dépasse l’ancienne cible indicative de 8 à 12 minutes. Le départ anticipé et le ×2 permettent des parties plus courtes. La durée de 60 secondes est la demande explicite actuelle ; l’objectif de durée globale devra être réexaminé avec les essais.

Ce changement ne modifie aucun nombre de combat, coût, bonus ou composition de vague. Le candidat boss à 900 PV reste une proposition non appliquée.
