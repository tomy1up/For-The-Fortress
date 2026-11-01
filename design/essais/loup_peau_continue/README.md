# Loup — changement de construction de l’animation

## Diagnostic après le retour du porteur

Les appuis du loup ont été approuvés, et le corps animé est jugé meilleur, mais les membres donnent encore une impression de pièces rapportées. L’essai précédent utilisait un maillage pour le corps et quatre autres pour les membres, chacun avec sa propre image. Les déformations étaient continues dans chaque pièce, mais leurs contours peints et leur superposition restaient séparés aux épaules et aux hanches. Les corrections de portée déplaçaient aussi les attaches sous le corps.

Changer seulement la cadence, l’amplitude du corps ou le nombre de poses ne résout pas ce raccord graphique. La piste retenue pour l’étude est une **peau continue pour tronc et membres proches, entraînée par des os avec influences partagées**, puis des corrections dessinées des poses qui se déforment mal. C’est une proposition technique, pas une approbation de l’animation par le porteur.

## Base de dessin

`loup_proche_source_v001.png` est une nouvelle base expérimentale : tronc, tête, queue et deux membres proches forment un dessin continu. Les membres éloignés sont volontairement absents de cette couche ; ils devront être préparés derrière elle pour retrouver un animal complet à quatre pattes. Cette image ne représente pas un nouveau personnage à deux pattes.

Le dessin reprend le loup gris et crème existant. Il reste à contrôler sa fidélité et à nettoyer une frange semi-transparente autour de sa silhouette. Il ne remplace aucun asset approuvé.

Production avec l’outil ImageGen intégré, référence : premier animal de `prototype/assets/enemies/rosters/neutres_v001.png`. Résultat original : `exec-0e1112a2-e64d-4ec7-829f-c471fefe05a2.png`, 1536 × 1024 RGBA, copié sans modification. Une tentative de nettoyage ultérieure n’a pas assez préservé le cadrage et laisse encore une frange ; elle n’est pas sélectionnée.

Consigne de génération : conserver l’identité, les proportions trapues, les yeux jaunes, la palette grise/crème et les contours noirs du premier loup de référence ; produire une seule pose debout orientée à droite ; tronc, épaule/patte avant proche et hanche/patte arrière proche dessinés comme un animal continu ; deux pattes proches seulement, pattes éloignées retirées pour la préparation du rig ; pas de contour du ventre traversant les racines des membres, de capsules d’articulation, de membres détachés ou de sockets ; pattes larges et anatomie canine ; transparence, sans décor, grille, texte ni ombre. Ces consignes sont des objectifs ; elles ne prouvent pas leur réussite.

## Preuve technique native, limitée à la flexion

`continuous_skin.gd` construit un `Polygon2D` unique, 513 sommets partagés et 896 triangles, lié à cinq `Bone2D` d’un `Skeleton2D`. Les sommets des jonctions sont communs aux surfaces du tronc et des membres. Ce modèle ne superpose pas une image de patte sur une image de corps au raccord proche.

`check_native.gd` contrôle la connexité de tous les sommets, les chemins des os et la somme des influences. Il a été exécuté dans Godot 4.7.2 standard, en mode sans fenêtre puis avec rendu graphique sur l’écran de droite. Le test de flexion produit trois poses contrôlées. Le maillage est connecté, les cinq os sont résolus, et l’erreur maximale de normalisation des poids est de 0,000000032.

**Ce test n’est pas un cycle de marche.** Il ne valide ni les appuis, ni la silhouette sur une foulée complète, ni les performances en combat. Les appuis approuvés serviront de référence de comportement ; leur calibration doit être adaptée aux proportions de la nouvelle peau. Ne pas annoncer des trajectoires identiques tant que cette nouvelle calibration n’a pas été contrôlée.

## Suite de fabrication

Une référence de démarche effectivement examinée doit guider les poses, en distinguant marche, trot et galop. Le cycle 3D « Walk » du loup Quaternius a maintenant été examiné sur douze poses et mesuré sur 65 échantillons. La vidéo YouTube fournie n’a pas pu être visionnée ; aucune analyse de cette vidéo n’est revendiquée.

1. Préparer une topologie anatomique et les membres éloignés, conserver le même personnage et ses proportions.
2. Régler les influences communes épaules/tronc et hanches/tronc ; vérifier les grandes flexions sans pincement ni étirement artificiel.
3. Construire les poses de contact, appui, passage et retour d’un seul cycle dans une direction ; conserver le mouvement d’appui au sol et la cadence liée à la distance.
4. Dessiner les corrections des volumes ou silhouettes que le squelette déforme mal, notamment aux épaules, aux hanches et lors des recouvrements.
5. Contrôler le cycle en déplacement à taille réelle dans le jeu, puis obtenir la validation du porteur avant intégration et extension aux autres unités.

Le recours à l’image par image reste une alternative si les corrections du rig deviennent plus compliquées que le dessin des poses. Le choix final doit suivre le résultat visuel, pas le seul nombre de contrôles réussis.

## Résultat de l’étude de marche — 1er novembre 2026

**Statut : recherche non validée, hors du jeu publié.** Voir [BILAN_MARCHE.md](BILAN_MARCHE.md) pour les résultats, les limites et la reproduction. Le nouveau cycle utilise 19 os et une peau proche continue. Les appuis calculés sont stables ; la déformation des volumes échoue encore sur certaines poses. Les corrections géométriques automatiques conservées ici sont des essais, pas des corrections dessinées abouties.

## Boucle continue — 2 novembre 2026

Une nouvelle boucle suit la déformation au cours du temps plutôt que de réparer les poses isolément. Elle passe désormais le contrôle indépendant de toutes les transitions et de la fermeture, tout en conservant les ancrages. Une vidéo native de travail de trois cycles est disponible localement. **Le naturel et les volumes restent à valider** ; ce succès numérique ne vaut pas approbation artistique. Voir [MARCHE_CONTINUE.md](MARCHE_CONTINUE.md) pour les mesures, l’aperçu et la reproduction.

## Références consultées

- [Spine — influences des os sur les sommets](https://en.esotericsoftware.com/spine-weights) : principe des influences partagées ; la documentation ne garantit pas la qualité artistique d’un rig.
- [Godot — Polygon2D](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html) et [Bone2D](https://docs.godotengine.org/en/stable/classes/class_bone2d.html) : mécanisme natif effectivement testé ici. Le tutoriel général de squelette 2D consulté porte un avertissement de mise à jour pour Godot 4.7 ; l’essai vérifie donc directement le fonctionnement dans le moteur installé.
- Le lien Toon Boom sur les poses clés et la vidéo YouTube fournis par le porteur n’ont pas pu être examinés ; aucune analyse de leur contenu n’est revendiquée.
