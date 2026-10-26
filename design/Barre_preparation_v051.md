# Barre de préparation — v0.51

26 octobre 2026. Ajout d’un repère visuel pour le délai existant ; aucune règle de temps modifiée.

## Affichage

Une barre de quatre pixels sous le bouton de lancement représente le temps de préparation restant sur les 30 secondes. Elle se vide avec le compteur existant ; le texte du bouton continue d’indiquer les secondes. Sa teinte habituelle est dorée, elle devient orangée dans les cinq dernières secondes et grisée pendant une suspension. La couleur ne remplace pas l’information textuelle.

La barre est absente avant le lancement manuel initial, pendant les combats et choix obligatoires, et après victoire ou défaite. Le choix de bonus réarme le délai complet de 30 secondes. Le récapitulatif et la spécialisation la figent avec le même délai restant que le bouton. Les vitesses ×2/×10 n’accélèrent pas ce délai. Elle ne capte aucun clic et ne reçoit pas le focus clavier.

## Vérification

**29 suites, 14 350 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les **onze contrôles ajoutés** à la suite d’enchaînement couvrent premier départ manuel, délai complet, seconde restante en ×2, départ automatique, lecture suspendue, choix obligatoire, reprise après bonus, nouvel essai, spécialisation et fin des deux campagnes. La suite d’enchaînement compte 117 contrôles.

Le compte rendu du paquet et de la vérification visuelle figure dans Distribution_Windows_v051.json. Combat, revenus, boss à 600 PV et préparation de 30 secondes conservés. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements Windows réussis sur l’écran de droite, dix empreintes locales concordantes. [Capture du paquet à 30 s](essais/captures/QA-v051_trente_secondes.png) inspectée : barre pleine sous le bouton sans chevauchement. Un contrôle séparé du projet source utilise la référence Horde après vague 8 : un appel de traitement de 25 s amène le délai à 5 s, puis le rendu est figé pour inspection. [Barre orangée au sixième](essais/captures/QA-v051_cinq_secondes.jpg), texte cohérent et bouton lisible. Ce contrôle de mise en page n’est pas une mesure de temps réel ni un nouvel essai humain ; fenêtre fermée après vérification.
