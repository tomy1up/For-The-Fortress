# Infobulle après lancement — v0.53

26 octobre 2026. Correction de présentation après observation dans la partie native de contrôle v0.52.

## Comportement observé

Après un clic pour lancer une vague, le pointeur restait sur le bouton. L’infobulle de composition réapparaissait et recouvrait une partie des informations de défense alors que le combat était lancé. La composition restait correcte ; le problème concernait son affichage non sollicité après l’action.

## Changement

Quand une vague démarre sous le pointeur, l’aide de ce bouton est masquée jusqu’à ce que la souris le quitte. Revenir sur le bouton permet à nouveau de lire sa composition, y compris en combat. Un départ sans survol ne masque pas une future consultation volontaire. Un nouvel essai réinitialise cet état.

Les autres infobulles, les choix, le focus clavier, la vitesse et le décompte ne changent pas. Aucun délai de lancement, aucun clic supplémentaire et aucune dépense ne sont ajoutés.

## Vérification

29 suites, **14 350 contrôles Godot**, **15 tests Python** et contrats du GDD réussis. Les contrôles existants des aides dynamiques et des dialogues restent réussis. La vérification du paquet et l’essai natif de maintien puis de retour du pointeur sont consignés dans Distribution_Windows_v053.json. Aucun test permanent supplémentaire n’est ajouté pour cette correction de présentation.

GDD principal v0.14 ; nom de travail dont la disponibilité juridique reste à confirmer.

## Contrôle final dans l’exécutable

46 lancements automatisés réussis sur l’écran de droite et dix empreintes locales concordantes. Un essai natif séparé du même exécutable utilise Alliance sans défenseurs, en ×1, pour observer le comportement de l’aide sans achats. Après le clic de lancement, le pointeur est resté sur le bouton : aucune infobulle dans la capture à 34,6 secondes simulées. Après sortie puis retour volontaire, l’aide de composition de la prochaine vague est redevenue visible pendant la préparation.

[Après lancement](essais/captures/QA-v053_depart_sans_infobulle.jpg) · [Retour volontaire sur le bouton](essais/captures/QA-v053_retour_infobulle.jpg). Le journal dédié ne contient aucune erreur. Ce contrôle partiel ne constitue pas un essai d’équilibrage ; le jeu a été fermé après vérification.
