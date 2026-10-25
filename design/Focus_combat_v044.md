# Focus pendant les changements de phase — v0.44

25 octobre 2026. Correction d’un état d’interface ; aucun changement de règle ou de statistique.

## Défaut reproduit

En v0.43, le bouton de lancement reste sélectionné au clavier lorsqu’il devient désactivé au début du combat. La sonde constate simultanément `start_disabled=true`, `focus_is_start=true` et `focus_disabled=true`. Entrée se retrouve ainsi sur une commande indisponible.

## Correction

Le rafraîchissement ne conserve un bouton sélectionné que s’il est visible et disponible. Pendant le combat, le récapitulatif des bonus fournit le point de départ de repli ; fermer ce récapitulatif revient à une commande utilisable. Une sélection encore disponible, par exemple la vitesse, est conservée. Aucun panneau ne s’ouvre sans action du joueur.

Le lancement automatique libère aussi le focus d’un achat ou d’une amélioration devenu indisponible. Le décompte conserve ses 30 secondes, sans effet des vitesses sur la préparation. Les règles de pause et le choix obligatoire restent identiques.

## Vérification

**25 suites, 14 171 contrôles Godot**, **9 tests Python** et contrats du GDD réussis. Les 12 ajouts couvrent les deux factions, les événements Entrée dans le vrai système d’interface, l’ouverture et la fermeture en combat sans mutation de la simulation, le focus de vitesse conservé, et le lancement automatique après 30 secondes. La suite des panneaux comporte désormais 88 contrôles.

Les contrôles du paquet et l’essai visuel sont consignés dans Distribution_Windows_v044.json. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements Windows réussis. Essai natif Alliance sans défenseurs sur l’écran de droite : Entrée choisit la faction et lance la vague, le focus rejoint le récapitulatif. Entrée l’ouvre puis le ferme, tandis que le combat avance de 0,4 à 9,3 secondes simulées. Fenêtre fermée avant toute arrivée ; aucun résultat d’équilibrage déduit. [Capture](essais/captures/QA-v044_focus_combat.jpg).
