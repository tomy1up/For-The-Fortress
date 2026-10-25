# Commandes derrière les dialogues — v0.42

25 octobre 2026. Correction d’une interaction au clavier, sans modification du combat ou des valeurs d’équilibrage.

## Défaut reproduit

En v0.41, le bouton **Nouvel essai** restait activé et pouvait recevoir le focus derrière un choix roguelite. Une activation forcée de ce bouton réinitialisait la partie alors que le panneau de choix était visible. Le même fond de jeu restait parcourable au clavier derrière certains récapitulatifs.

La reproduction sans fenêtre constate `reset_disabled=false`, `background_focus=true`, puis le retour à la préparation initiale et au choix de faction après activation. Cette reproduction concerne un état d’interface contrôlé ; elle n’est pas présentée comme un nouveau retour joueur.

## Correction

Pendant le choix de faction, la spécialisation, le choix roguelite, le récapitulatif ou le bilan, les commandes de fond perdent leur focus et ne sont plus accessibles par Tab. Elles sont désactivées tant que leur panneau les couvre. Les boutons appartenant au panneau visible restent accessibles : choix, annulation, fermeture, onglets et export du bilan.

Le redémarrage et le changement de vitesse sont également gardés dans leurs gestionnaires : même un signal forcé depuis le fond n’agit pas pendant ces écrans. Le redémarrage redevient possible après fermeture du récapitulatif ou du bilan, annulation/confirmation de la spécialisation ou validation du choix obligatoire.

Les modes de focus normaux sont restaurés à la fermeture. Aucun choix n’est validé automatiquement et aucun dialogue supplémentaire n’est ajouté. Les règles de lecture sont conservées : le combat continue pendant le récapitulatif, la préparation y suspend son décompte, et le choix roguelite attend le joueur.

## Vérification

**25 suites et 14 156 contrôles Godot réussis**, plus **9 tests Python** et les contrats du GDD. Les 76 contrôles dédiés couvrent les deux factions et les cinq panneaux, les activations forcées de commandes de fond, les boutons propres au panneau, l’absence de dépenses/redémarrage/changement de vitesse et le retour des commandes après fermeture.

Les contrôles existants de vitesse et de défilement ont été enrichis : un redémarrage demandé pendant le choix obligatoire est désormais refusé ; ils valident d’abord le bonus puis vérifient toujours le retour en ×1 et la remise à zéro du défilement.

**46 lancements Windows** du paquet contrôlés sur le second écran à droite. Le GDD principal reste en v0.14 ; les statistiques de combat et l’économie restent inchangées.

## Navigation réelle au clavier

Le panneau reçoit un focus initial : premier choix de faction ou de bonus, bouton Fermer pour les récapitulatifs et Annuler pour la spécialisation. Les rafraîchissements préservent la sélection du joueur. À la fermeture, le focus revient à une commande de jeu disponible. Entrée ne valide rien sans action du joueur.

Les 76 contrôles dédiés comprennent l’envoi de vrais événements Tab et Entrée à l’interface : passage de l’Alliance à la Horde, validation de cette faction, parcours du récapitulatif et fermeture, sans lancer de vague ni dépenser d’or.

Essai natif sur l’écran de droite : Tab sélectionne la Horde, Entrée confirme ; le récapitulatif garde le focus sur Fermer, puis Entrée revient à la préparation avec 150 or et 20 PV. Deux démarrages du paquet final affichent correctement le choix de faction, dont un depuis la racine du projet avec position explicite. Un écran vide avait été observé sur un paquet intermédiaire ; sa cause n’a pas été établie et le phénomène ne s’est pas reproduit sur ces deux démarrages finaux.

[Focus dans le panneau](essais/captures/QA-v042_focus_panneau.jpg) · [Retour au jeu](essais/captures/QA-v042_retour_jeu.jpg).
