# Annonces de début de vague — v0.75

28 octobre 2026. Lot de lisibilité des combats et de l’enchaînement automatique. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Repère de départ

Chaque lancement réussi affiche une annonce brève dans l’en-tête : numéro de vague, effectif et rappel de défense. La dixième vague indique « Vague finale » et le nom du boss du camp adverse. L’encart se situe entre le titre et l’indication de faction, au-dessus de la jauge du boss ; il ne masque pas la carte.

L’annonce dure deux secondes réelles aux trois vitesses, avec une apparition puis une extinction progressive. Elle accompagne aussi les départs automatiques après préparation. Le combat commence immédiatement : aucun délai, pause, clic ou focus supplémentaire. Un appel de lancement refusé ne relance pas l’annonce.

## Règles conservées

Premier départ manuel, trente secondes de préparation entre les vagues et attente d’un choix aux vagues 3, 6 et 9. L’annonce se retire à la fin du combat, pendant les fenêtres de lecture ou à la remise à zéro. Elle ne modifie aucun ennemi, statistique, récompense, talent ou sauvegarde. Les dissipations v0.74 sont conservées.

## Validation

52 suites et 17 112 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 78 nouveaux contrôles couvrent départ manuel, trois vitesses et durée réelle, combat immédiat, lecture sans mutation, absence de clic/focus, refus de double départ, extinction, nettoyage, départ automatique à la trentième seconde, fenêtres de bonus, boss adverse et absence de recouvrement de sa jauge.

Le ZIP Windows passe 118 lancements, produit 117 captures et correspond à 37 sources locales. Le modèle, la vue des unités et effets, les vagues, les statistiques, les talents et le profil ont les mêmes empreintes source que v0.74.

Captures inspectées : départ [Alliance](essais/captures/QA-v075_alliance_wave_start.png) et [Horde](essais/captures/QA-v075_horde_wave_start.png), finale [Alliance](essais/captures/QA-v075_alliance_final_start.png) et [Horde](essais/captures/QA-v075_horde_final_start.png). [Régression](essais/v075_regression.json) et [distribution](Distribution_Windows_v075.json). Profils isolés ; aucun nouvel essai humain d’équilibrage.
