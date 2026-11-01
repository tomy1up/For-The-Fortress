# Loup â€” appuis pilotÃ©s par la distance

**Essai technique du 1 novembre 2026, non approuvÃ© artistiquement et non intÃ©grÃ© au jeu publiÃ©.**

## Voir et comparer

Ouvrir `Voir_essai_appuis_loup.cmd` : une fenÃªtre sur le deuxiÃ¨me Ã©cran montre un loup seul sur le trajet de la VallÃ©e du GuÃ©. Commandes : vitesse Ã—0,5 / Ã—1 / Ã—2, pause, taille du jeu / zoom Ã—5, appuis et recommencer. Ã‰chap ferme la fenÃªtre. Lâ€™atelier nâ€™utilise aucun profil joueur et nâ€™accorde aucune rÃ©compense.

`Loup_appuis_essai.mp4` montre 5 secondes Ã  taille du jeu, 5 secondes agrandies et 5 secondes agrandies Ã  vitesse doublÃ©e. Capture contrÃ´lÃ©e Ã  60 images/s, pas une mesure des performances du jeu. Le lanceur dÃ©pend du moteur Godot installÃ© dans `C:\Projet\.tools` et du paquet v0.106 dÃ©jÃ  prÃ©sent dans `dist`.

## Changement testÃ©

Le prÃ©cÃ©dent candidat de 24 dessins utilisait une cadence liÃ©e Ã  la distance, mais les positions dessinÃ©es des pattes ne garantissaient pas leur appui au sol. Ce nouvel atelier teste des jambes entiÃ¨res articulÃ©es, avec une pose calculÃ©e continÃ»ment :

- Cycle de 0,6 unitÃ© de trajet, valeur dâ€™essai. Ã€ 1,15 unitÃ©/s : environ 1,92 cycle/s ; Ã  vitesse doublÃ©e : 3,83. La longueur de foulÃ©e reste identique.
- Chaque patte conserve son point dâ€™appui dans le plateau pendant 60 % de son cycle.
- La phase de retour relie les deux appuis avec une transition douce et une levÃ©e de patte.
- La position dÃ©pend exclusivement de la distance : un arrÃªt fige aussi la marche.
- Petit transfert vertical du corps. Les membres conservent leur longueur ; un dÃ©placement limitÃ© de lâ€™attache cachÃ©e sous la fourrure, plafonnÃ© Ã  3,3 pixels du plateau, permet dâ€™absorber certains changements de direction.
- Le retournement utilise encore deux orientations miroir. Le rendu des transitions et le changement de rÃ´le des membres aux virages restent Ã  juger visuellement.

## ContrÃ´le et limites

`test_contacts.gd` parcourt 0â€“28 unitÃ©s par pas de 0,01 pour 16 dÃ©calages de cycle, en rÃ©utilisant le trajet et la projection du paquet v0.106. Il mesure les rÃ©fÃ©rences des pattes rÃ©ellement rÃ©solues par lâ€™articulation, aprÃ¨s limite de portÃ©e, et non seulement les appuis demandÃ©s. `controle_appuis.json` contient le rÃ©sultat. Les contrÃ´les mathÃ©matiques ne prouvent ni une anatomie parfaite ni une animation naturelle.

Avant toute intÃ©gration : contrÃ´le visuel des poses, appuis, membres Ã©loignÃ©s, virages, rÃ©pÃ©tition du cycle et comparaison de vitesse ; validation finale par le porteur du projet. Ne pas Ã©tendre ce rendu aux autres unitÃ©s avant cette validation. Ce module est un atelier pour un loup seul, pas encore un remplacement complet du rendu de combat (impacts, malÃ©dictions, inspection).

## Source graphique

`loup_pieces_essai.png` est une copie inchangÃ©e du rÃ©sultat ImageGen `exec-86e1775d-cea4-4cd0-ac58-ca5ac2535608.png` : 1280 Ã— 1280, alpha, corps/tÃªte/queue entiers sans jambes en haut, jambe avant entiÃ¨re en bas Ã  gauche et jambe arriÃ¨re entiÃ¨re en bas Ã  droite. Les membres Ã©loignÃ©s rÃ©utilisent ces deux jambes avec une teinte plus sombre. Lâ€™image est un support expÃ©rimental ; elle ne remplace pas un asset approuvÃ©.

Consigne de gÃ©nÃ©ration conservÃ©e : reprendre lâ€™identitÃ© et la palette du loup cartoon neutre de rÃ©fÃ©rence ; corps trapu, grosses pattes, fourrure Ã©paisse ; trois piÃ¨ces complÃ¨tes distinctes, pas de segments fins ou dÃ©tachÃ©s, transparence rÃ©elle, aucun texte, grille, ombre ou dÃ©cor. Ces consignes sont des objectifs, pas une validation du rÃ©sultat.

Résultat du contrôle livré : 107 584 échantillons d’appui, dérive maximale mesurée nulle ; erreur résiduelle de portée de 0,00000242 pixel (arrondi numérique). Commandes de pause, vitesse, zoom, appuis et redémarrage vérifiées par leurs boutons. 900 images capturées sans erreur moteur et vidéo décodée intégralement sans erreur. Inspection de poses en taille agrandie effectuée ; transitions miroir encore à apprécier en mouvement. Aucune validation artistique déduite de ces chiffres.
