# Sanglier — étude de peau continue

Étude du 2 novembre, complétée le 3 novembre 2026. **Essai non approuvé, hors du jeu distribué.** La v0.109 demeure la version jouable ; ce dossier ne modifie aucun script de production, profil, talent, récompense ou valeur de combat.

## Intention

Préparer une animation du sanglier neutre, commun aux deux factions, avec un dessin continu aux épaules et aux hanches. La démarche du loup reste sa propre référence approuvée ; elle n’est pas simplement appliquée à cette silhouette plus compacte.

La base `sanglier_proche_source_v001.png` a été produite avec l’outil ImageGen intégré, à partir de l’identité du sanglier de `prototype/assets/enemies/rosters/neutres_v001.png`. [Consigne et provenance](PROMPTS.md). Elle contient le tronc, la tête, la queue et les deux membres proches sur une seule couche. Les membres éloignés sont reconstruits derrière cette couche pendant le rendu ; le personnage animé possède bien quatre membres.

L’allure est une proposition chorégraphiée, pas un mouvement échantillonné d’un sanglier réel. Les appuis alternent par paires diagonales. La foulée de 700 pixels source, les amplitudes et les phases sont des réglages d’essai. Le rendu respecte la vitesse actuelle du profil Sprinter : 1,65 unité de carte/s, soit environ 49,81 pixels/s sur une diagonale du plateau. À la taille actuelle, le cycle dure environ 0,462 seconde. Il n’y a pas de modification de cette vitesse dans le jeu.

## Construction et limites

La peau est déformée par un calcul ARAP à contraintes de surface, avec ancrages du corps et des sabots. Les repères internes de coude et de jarret enrichissent la topologie mais ne sont pas des points imposés à la peau : leur première utilisation comme contraintes rigides retournait le raccord du membre. Le résultat n’est donc pas une garantie de respect des longueurs des os sous le dessin. L’anatomie apparente doit encore être jugée visuellement.

Les sommets libres sont interpolés par courbes cubiques à tangentes communes ; les ancrages suivent des trajectoires linéaires par morceaux. Le début et la fin des appuis sont placés sur la grille temporelle d’export, afin de ne pas mélanger un morceau de phase d’appui avec le début du retour du sabot. Une première durée d’appui de 60 % produisait une erreur de contact de 0,226 pixel source à la frontière des phases ; la durée actuelle de 38/64 du cycle aligne ces frontières. Ce choix est une hypothèse d’animation, pas une règle de gameplay.

La couche éloignée utilise un masque propre au sanglier et un assombrissement modéré. Les textures sont filtrées avec des niveaux de détail dans le rendu réduit. Le premier atelier est horizontal, avec repères défilants. Un second atelier montre quatre diagonales sur sol fixe, une pause, une accélération et un impact imposé. Ce sont des dispositifs isolés, pas des missions jouées. Aucune validation artistique du porteur n’est déduite des contrôles mathématiques.

## Livrables à examiner

- `sanglier_allure_rapide_essai.mp4` : 144 images, 60 images/s, 2,4 secondes, deux sens et aperçu à la taille du plateau.
- `sanglier_routes_essai.mp4` : 240 images à 60 images/s, quatre diagonales, taille du jeu et agrandissement ×2, vitesse normale puis ×2, pause et impact imposé.
- `sanglier_proche_source_v001.png` : source transparente, conservée sans modification après génération.
- `smooth_walk.json` et `smooth_walk_far.json` : courbes finales expérimentales ; elles ne sont pas exportées dans le programme du jeu.
- `controle_pipeline.json`, `controle_interpolation_lissee.json` et `controle_appuis_rendu.json` : périmètres et résultats techniques exacts.

Les aperçus retenus et les observations d’autocontrôle sont consignés dans `QA_etude.json`. Les contrôles de maillage, d’appui et de cadence servent à éliminer des défauts ; ils ne prouvent pas à eux seuls le naturel de la démarche.

Le candidat courant comporte 1 309 sommets et 2 280 triangles par couche, sur 128 intervalles cubiques. Le certificat indépendant ne relève ni aire négative ni intervalle indéterminé. La lecture native compare 41 888 coordonnées de sommets sur seize phases par couche, avec un écart maximal d’environ 0,000069 pixel source. Le contrôle des appuis compare 78 016 positions de sabots sur deux cycles ; aucun écart n’est mesuré sur ces échantillons. Ces chiffres décrivent le contrôle géométrique, pas l’anatomie.

## Placement sur les diagonales

Le second atelier utilise les quatre directions projetées du plateau avec une rotation rigide du profil et un miroir selon le sens. Aucune transformation de cisaillement n’est appliquée. Le grand aperçu agrandit ensemble le personnage, sa distance et sa vitesse de déplacement. Les sabots restent ainsi comparables aux repères fixes du sol.

Le contrôle des 80 états natifs conserve des axes perpendiculaires et de même longueur. Il compare 2 816 positions de sommets des sabots en appui hors impact : erreur maximale inférieure à 0,000008 pixel affiché. Il vérifie aussi l’arrêt des pas pendant la pause et leur cadence à vitesse doublée. Ces échantillons ne constituent pas un contrôle de tous les sommets à tous les instants.

La réaction utilise le signal de perte de PV et la courbe temporelle du prototype. Le montage expérimental oriente le recul avec la route ; ce placement reste une proposition hors production. Les appuis sont volontairement décalés pendant cette brève réaction. Aucun dégât, ralentissement ou recul logique n’est appliqué.

Quatre images natives ont été examinées au départ, à l’accélération, pendant l’impact et à la fin ; le cadrage initial coupé en bas a été corrigé. La vidéo finale a été entièrement décodée sans erreur. Le rendu préserve la silhouette sur les images inspectées ; le naturel du mouvement doit encore recevoir le retour du porteur. Les virages, les directions frontales, le survol et les interactions visuelles dans une véritable mission restent à vérifier avant intégration. Les 74 sources et le binaire de la v0.109 restent identiques.

`controle_routes.json`, `controle_routes_pipeline.json` et `QA_routes.json` conservent les contrôles, les empreintes et le périmètre de cette étude.

## Reproduire l’étude

Depuis la racine du dépôt, exécuter avec Python et NumPy disponibles :

```powershell
python design/essais/sanglier_peau_continue/build_study.py
```

Le script accepte `--engine` et `--ffmpeg` si les outils sont ailleurs. Il utilise Godot 4.7.2 standard et lance les fenêtres graphiques minimisées sur `--screen 1`. Aucun appel à un service de génération d’image n’est effectué pendant cette reconstruction. Le dessin source déjà enregistré est réutilisé.

Le calcul reprend les outils géométriques de l’étude du loup sans les modifier. Les entrées et fichiers intermédiaires volumineux sont régénérés dans `captures/` ou à côté des courbes, puis ignorés par Git ; les courbes finales et leurs rapports sont conservés. Le script arrête le traitement si un journal Godot contient une erreur, même lorsque le moteur renvoie le code de sortie zéro.

Après reconstruction des courbes, l’atelier de placement se reproduit séparément :

```powershell
python design/essais/sanglier_peau_continue/build_routes.py
```

Ce second script utilise les mêmes options `--engine` et `--ffmpeg`, lance Godot minimisé sur l’écran de droite et contrôle les sources du paquet Windows avant et après le rendu. Il ne recompile pas le jeu.

For the Fortress! est un nom de travail dont la disponibilité juridique reste à confirmer.

## Traversée du vrai tracé du Gué — 3 novembre 2026

Deux vidéos de douze secondes à 60 images/s montrent trois sangliers de contrôle sur les sept segments du Gué : `sanglier_sur_le_gue_alliance.mp4` et `sanglier_sur_le_gue_horde.mp4`. Le modèle de déplacement, le terrain, le tri des personnages, les barres de PV et les forteresses proviennent du jeu. Seul le dessin du sanglier est remplacé dans une sous-classe de rendu utilisée par l’étude. Aucune modification des scripts de production ni du ZIP v0.112.

La séquence d’apparition de trois animaux et l’impact de 4 PV sont imposés pour l’observation. Aucun défenseur ne tire ; il ne s’agit pas d’une mission de campagne jouée. Le premier passage est à vitesse normale ; une pause de 0,4 seconde précède le doublement de vitesse. Le cadre de gauche agrandit trois fois les pixels du même rendu, avec le sol ; ce n’est pas une deuxième simulation ni un dessin plus détaillé.

Le contrôle indépendant compare la route, la position projetée, la phase et les axes du dessin sur les 1 440 images. Les 18 changements de segment de chaque traversée correspondent aux six virages franchis par chacun des trois sangliers. Les simulations neutres sont identiques dans les deux factions. La pause conserve 25 états successifs identiques, puis les pas suivent la vitesse doublée. Les 126 656 positions comparées de sommets de sabot en appui présentent une dérive maximale de 0,000077 pixel affiché **sur les portions droites, hors impact**. Cette mesure combine les coordonnées de placement lues dans le rendu natif et les ancrages des courbes ; elle n’est pas une mesure vidéo de chaque pixel ni une approbation de l’anatomie.

Les deux vidéos sont entièrement décodées : 720 images chacune, sans erreur. Les planches `Apercu_contexte_cycle.png` et `Apercu_contexte_virages.png` montrent douze instants d’un cycle droit et les vues juste avant/après chacun des six virages. Des images complètes couvrent aussi le départ, l’impact, la reprise et le contexte Horde. Le relevé `QA_contexte.json` précise ce qui a été examiné ; aucune lecture humaine complète des vidéos n’est prétendue.

**Limites :** l’orientation et le miroir de profil changent instantanément au sommet d’un virage. Il n’y a pas de pose dessinée de rotation, ni de vue frontale nouvelle. Les contacts ne sont donc pas certifiés pendant ce changement ni pendant la réaction d’impact. L’anatomie perçue, le naturel global et les changements de direction restent à valider artistiquement. Le survol, la cohabitation avec des défenseurs et les contraintes de performance de la campagne ne sont pas livrés par cet atelier. Les maillages expérimentaux sont reconstruits pour l’observation ; ce montage n’est pas un moteur d’animation prêt à intégrer.

Pour reproduire ce nouveau contrôle depuis la racine du dépôt :

```powershell
python design/essais/sanglier_peau_continue/build_context.py
```

La commande rend les deux factions sur l’écran de droite, minimisées, contrôle les traces et encode/décode les vidéos. `--reuse-frames` réutilise seulement des captures déjà présentes. Le paquet v0.112 et ses 75 sources doivent correspondre au projet courant avant et après l’essai. Les commandes historiques des sections précédentes restent liées à leur état de référence v0.109 ; ce nouveau pipeline constitue la reproduction adaptée au dépôt actuel.
