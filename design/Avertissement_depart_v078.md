# Avertissement de départ automatique — v0.78

28 octobre 2026. Complément de l’enchaînement automatique et des annonces v0.75. For the Fortress! reste un nom de travail dont la disponibilité juridique reste à confirmer.

## Dernières secondes de préparation

Pendant les cinq dernières secondes du délai, l’en-tête rappelle la prochaine vague et les secondes restantes, arrondies au supérieur comme le bouton de lancement. Avant la dixième vague, il indique la finale et le nom du boss adverse. Le repère ambré reste sans clic ni focus et laisse la carte libre.

À zéro, le combat commence au même instant qu’auparavant ; l’avertissement est remplacé par l’annonce de début de vague. Le premier départ reste manuel, sans avertissement de faux lancement automatique.

## Pauses et conservation des règles

La lecture des bonus ou un choix de spécialisation cachent l’avertissement pendant que le délai existant est suspendu. Les choix obligatoires après les vagues 3, 6 et 9 n’annoncent aucun départ avant réponse. Fermer une lecture reprend le même temps restant, sans réarmer trente secondes.

Le délai demeure trente secondes réelles à toutes les vitesses. Aucun ennemi, coût, gain, talent, soin, sauvegarde ou règle de combat n’est modifié. L’affichage reflète le compte à rebours existant et ne le pilote pas.

## Validation

55 suites et 17 240 contrôles Godot, 16 tests Python et contrats du GDD réussis. Les 66 nouveaux contrôles couvrent premier départ manuel, délai initial, seuil exact de cinq secondes aux trois vitesses, arrondi, lecture sans mutation, pause/reprise, déclenchement à zéro, absence de clic/focus, boss adverse, choix obligatoire et défaite.

Le ZIP Windows passe 130 lancements, produit 129 captures et correspond à 37 sources locales. Le modèle, le rendu des unités et forteresses, les vagues, les statistiques, les talents, le profil et les rapports ont les mêmes empreintes source que v0.77. Captures inspectées : avertissement [Alliance](essais/captures/QA-v078_alliance_countdown_warning.png) et [Horde](essais/captures/QA-v078_horde_countdown_warning.png), finale [Alliance](essais/captures/QA-v078_alliance_countdown_final.png) et [Horde](essais/captures/QA-v078_horde_countdown_final.png). [Régression](essais/v078_regression.json) et [distribution](Distribution_Windows_v078.json). Profils isolés ; aucun nouvel essai humain d’équilibrage.
