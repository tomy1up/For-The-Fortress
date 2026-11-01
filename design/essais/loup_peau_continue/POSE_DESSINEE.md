# Guide de correction de la pose de passage

## Origine et statut

`pose_passage_dessinee_v001.png` est une retouche produite par l’outil ImageGen intégré, à partir de la source du loup et de la capture de la pose 8/12. Copie sans modification du résultat `exec-33da3159-86f4-452d-a38e-1dea7fd5c510.png`.

Dimensions : 1 586 × 992, RGBA, alpha de 0 à 255 ; 80,99 % des pixels entièrement transparents. Empreinte SHA-256 : `6c7ef34c5fb6d0cfbe8cc6feaa9c07eb04e72e4ef4e3bbb30ad71ade43e91f96`.

**Statut : guide artistique seulement, non validé et non interchangeable avec une image du cycle.** La hanche retrouve une masse continue au lieu du pincement actuel. L’image change cependant le cadrage et les proportions tête/corps. Ses appuis ne sont pas enregistrés sur les cibles du squelette. La transparence effective ne garantit ni la fidélité du dessin ni l’absence de franges.

Une deuxième édition plus localisée (`exec-1414820a-3676-46ae-b783-6560f607228e.png`) a encore redimensionné le sujet malgré la consigne. Elle n’est pas retenue comme asset et reste à son emplacement de génération. Il serait incorrect d’empiler de telles images dans un spritesheet en affirmant qu’elles constituent une marche cohérente.

## Inspection native

`compare_drawn_pose.gd` affiche la pose de déformation à gauche et le guide à droite, avec un ajustement de taille de présentation explicitement distinct d’un recalage pour l’animation. Exécuté dans Godot 4.7.2, sur l’écran de droite en fenêtre minimisée, sans chargement de profil joueur. La capture locale est `captures/comparaison_pose_dessinee.png`.

L’inspection visuelle confirme une continuité plus lisible de la cuisse, mais aussi la dérive de proportions. Ce contrôle est fixe ; aucune validation de la fluidité ni des appuis n’est déduite de cette image.

## Conséquence pour la fabrication

La génération sert ici à proposer une forme de hanche. Pour fabriquer une véritable correction de pose, il faut conserver la tête, la colonne, les pieds et le cadrage du cycle, et ne reprendre que les volumes de la zone concernée dans une source éditable ou une correction de forme du maillage. Les images générées actuelles n’offrent pas cette conservation stricte. La prochaine reprise doit donc travailler avec les ancrages existants, et vérifier les transitions autant que les poses isolées.

Les deux consignes exactes figurent dans [PROMPTS.md](PROMPTS.md). Aucun achat, changement de moteur ou outil payant n’a été ajouté.
