# Loup — appuis pilotés par la distance

**Retour du porteur après essai : pattes validées, corps jugé trop rigide.** Ce dossier conserve la référence de déplacement des pattes. [Le nouvel essai du corps](../animation_loup_corps/README.md) reprend ces trajectoires et ajoute une liaison animée entre membres, épaules, bassin, dos, tête et queue. La démarche complète reste à valider.

**Essai technique du 1 novembre 2026, non approuvé artistiquement et non intégré au jeu publié.**

## Voir et comparer

Ouvrir `Voir_essai_appuis_loup.cmd` : une fenêtre sur le deuxième écran montre un loup seul sur le trajet de la Vallée du Gué. Commandes : vitesse ×0,5 / ×1 / ×2, pause, taille du jeu / zoom ×5, appuis et recommencer. Échap ferme la fenêtre. L’atelier n’utilise aucun profil joueur et n’accorde aucune récompense.

`Loup_appuis_essai.mp4` montre 5 secondes à taille du jeu, 5 secondes agrandies et 5 secondes agrandies à vitesse doublée. Capture contrôlée à 60 images/s, pas une mesure des performances du jeu. Le lanceur dépend du moteur Godot installé dans `C:\Projet\.tools` et du paquet v0.106 déjà présent dans `dist`.

## Changement testé

Le précédent candidat de 24 dessins utilisait une cadence liée à la distance, mais les positions dessinées des pattes ne garantissaient pas leur appui au sol. Ce nouvel atelier teste des jambes entières articulées, avec une pose calculée continûment :

- Cycle de 0,6 unité de trajet, valeur d’essai. À 1,15 unité/s : environ 1,92 cycle/s ; à vitesse doublée : 3,83. La longueur de foulée reste identique.
- Chaque patte conserve son point d’appui dans le plateau pendant 60 % de son cycle.
- La phase de retour relie les deux appuis avec une transition douce et une levée de patte.
- La position dépend exclusivement de la distance : un arrêt fige aussi la marche.
- Petit transfert vertical du corps. Les membres conservent leur longueur ; un déplacement limité de l’attache cachée sous la fourrure, plafonné à 3,3 pixels du plateau, permet d’absorber certains changements de direction.
- Le retournement utilise encore deux orientations miroir. Le rendu des transitions et le changement de rôle des membres aux virages restent à juger visuellement.

## Contrôle et limites

`test_contacts.gd` parcourt 0–28 unités par pas de 0,01 pour 16 décalages de cycle, en réutilisant le trajet et la projection du paquet v0.106. Il mesure les références des pattes réellement résolues par l’articulation, après limite de portée, et non seulement les appuis demandés. `controle_appuis.json` contient le résultat. Les contrôles mathématiques ne prouvent ni une anatomie parfaite ni une animation naturelle.

Avant toute intégration : contrôle visuel des poses, appuis, membres éloignés, virages, répétition du cycle et comparaison de vitesse ; validation finale par le porteur du projet. Ne pas étendre ce rendu aux autres unités avant cette validation. Ce module est un atelier pour un loup seul, pas encore un remplacement complet du rendu de combat (impacts, malédictions, inspection).

## Source graphique

`loup_pieces_essai.png` est une copie inchangée du résultat ImageGen `exec-86e1775d-cea4-4cd0-ac58-ca5ac2535608.png` : 1280 × 1280, alpha, corps/tête/queue entiers sans jambes en haut, jambe avant entière en bas à gauche et jambe arrière entière en bas à droite. Les membres éloignés réutilisent ces deux jambes avec une teinte plus sombre. L’image est un support expérimental ; elle ne remplace pas un asset approuvé.

Consigne de génération conservée : reprendre l’identité et la palette du loup cartoon neutre de référence ; corps trapu, grosses pattes, fourrure épaisse ; trois pièces complètes distinctes, pas de segments fins ou détachés, transparence réelle, aucun texte, grille, ombre ou décor. Ces consignes sont des objectifs, pas une validation du résultat.

Résultat du contrôle livré : 107 584 échantillons d’appui, dérive maximale mesurée nulle ; erreur résiduelle de portée de 0,00000242 pixel (arrondi numérique). Commandes de pause, vitesse, zoom, appuis et redémarrage vérifiées par leurs boutons. 900 images capturées sans erreur moteur et vidéo décodée intégralement sans erreur. Inspection de poses en taille agrandie effectuée ; transitions miroir encore à apprécier en mouvement. Aucune validation artistique déduite de ces chiffres.
