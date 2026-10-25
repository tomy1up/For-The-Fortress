# Consignes selon la situation — v0.49

26 octobre 2026. Correction de clarté, sans changement des mécaniques, du rythme ou des statistiques.

## Problème

Le panneau de gauche affichait en permanence « Lancez la première vague », y compris en combat, après une victoire ou une défaite. Cette instruction ne correspondait plus à la situation affichée.

## Affichage

Les trois lignes suivent désormais le choix de faction, la préparation initiale, les préparations suivantes, le combat, le décompte automatique, le choix de bonus, la spécialisation et la fin de partie. Elles indiquent les actions possibles. Les lectures de récapitulatif précisent si le combat continue ou si la préparation est suspendue.

Une préparation avec décompte annonce le départ automatique ; une préparation sans automatisme demande un lancement explicite. La victoire et la défaite orientent vers le bilan et un nouvel essai. Les consignes utilisent l’état existant et n’activent aucune commande.

Le compteur « Combat simulé » conserve sa valeur cumulative exacte. Son aide au survol indique qu’il exclut les préparations et les choix et qu’en ×2/×10 il avance plus vite que le temps réel. Il ne mesure toujours pas la durée réelle de session. Le bilan et les rapports conservent leurs explications.

## Vérification

28 suites, **14 313 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. La sonde de mise en page vérifie douze états : faction, première vague, préparation suivante, combat, décompte, lancement manuel suivant, bonus, spécialisation, lectures en préparation et en combat, victoire et défaite. Les textes utilisent trois lignes de 60 px sur les 76 disponibles, avec une largeur maximale de 213 px sur 238 à la police effective de 14 px. Aucun nouveau test permanent n’est ajouté pour cette modification de texte.

Le contrôle du paquet et les captures inspectées figurent dans Distribution_Windows_v049.json. GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

46 lancements Windows réussis sur l’écran de droite, dix empreintes locales concordantes. Captures de préparation, victoire Horde et bilan de défaite inspectées. [Préparation](essais/captures/QA-v049_preparation.png) · [Victoire](essais/captures/QA-v049_victoire.png).
