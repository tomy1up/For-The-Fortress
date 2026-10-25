# Échap dans les panneaux — v0.48

25 octobre 2026. Raccourci d’interface ; aucun changement des choix, règles de combat ou coûts.

## Comportement

Échap ferme le récapitulatif des bonus et le bilan de fin de partie. Pendant le choix de spécialisation, la touche déclenche l’annulation existante : le défenseur garde son niveau 3 et aucun or n’est dépensé. Le temps de préparation reprend avec le délai restant, sans être remis à 30 secondes. Les boutons de fermeture et d’annulation rappellent ce raccourci.

Le choix initial de faction et les offres obligatoires après les vagues 3, 6 et 9 restent ouverts. Échap ne choisit aucun bonus, ne lance aucune vague, ne rejoue pas et ne ferme pas le jeu. Hors panneau facultatif, la touche ne déclenche aucune action du jeu. Les combinaisons Ctrl/Alt/système, relâchements et répétitions sont ignorés.

La fermeture utilise les mêmes gestionnaires que les boutons. Un focus utilisable revient au jeu ou au bouton du bilan. En combat, consulter puis fermer le récapitulatif ne suspend pas la simulation ; pendant la préparation, la suspension se termine à la fermeture.

## Vérification

**28 suites, 14 313 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **30 contrôles dédiés** envoient la touche au vrai système d’interface pour les deux factions : absence d’effet sur les choix obligatoires, fermeture des trois panneaux, annulation sans paiement, délai restant conservé puis repris, absence de mutation ou relance derrière le panneau, combinaisons et répétitions ignorées, texte des trois boutons sans débordement.

Le compte rendu du paquet et de l’essai natif figure dans Distribution_Windows_v048.json. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

## Contrôle natif final — 26 octobre 2026

Paquet compilé le 25 octobre, contrôlé dans le jeu le 26 sur l’écran de droite : Échap conserve le choix de faction ; Entrée choisit Alliance ; le récapitulatif ouvert affiche Fermer · Échap, puis Échap revient à la préparation avec 150 or, 20 PV et aucune vague lancée. Fenêtre fermée après vérification. [Panneau](essais/captures/QA-v048_echap_panneau.jpg) · [Retour au jeu](essais/captures/QA-v048_retour_echap.jpg). Les 46 lancements automatisés et les dix empreintes locales sont concordants.
