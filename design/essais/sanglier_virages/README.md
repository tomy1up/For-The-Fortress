# Sanglier — dessins de préparation des virages

3 novembre 2026. **Étude non approuvée, hors campagne et hors du paquet Windows.** La version jouable reste la v0.112.

## Problème traité

L’essai de traversée précédent conserve les proportions mais change immédiatement l’orientation ou le miroir du profil aux sommets du chemin. Une véritable transition exige des vues compatibles et des appuis raccordés. Ajouter des images par seconde ou déformer le profil ne fournit pas cette perspective.

Trois nouveaux dessins sont préparés avec ImageGen intégré, à partir de l’identité existante :

- `sanglier_face_source_v001.png` : face, quatre membres, utile pour étudier le passage d’une diagonale descendante à l’autre.
- `sanglier_trois_quarts_source_v001.png` : trois quarts avant, quatre membres, pour une direction vers le bas et la droite ; le miroir pourrait servir au sens symétrique.
- `sanglier_arriere_trois_quarts_source_v001.png` : trois quarts arrière, quatre membres, pour une direction qui s’éloigne vers le haut et la droite ; le miroir pourrait servir au sens symétrique.

Ces correspondances sont des **propositions de construction graphique**, pas des règles de rendu déjà intégrées. Les PNG sont copiés tels quels depuis les résultats retenus, avec leur transparence. Aucun étirement, recoloriage ou retouche du bitmap par script. Les [consignes et la provenance](PROMPTS.md) documentent aussi le premier dessin arrière rejeté et sa correction.

## Comparaison native

`Apercu_directions.png` montre les trois dessins et la référence de profil avec une hauteur visible commune de 28,9 pixels, puis un agrandissement ×5. Cette hauteur reprend l’ordre de grandeur du sanglier actuel, sans établir une taille commerciale définitive. Seules des échelles uniformes sont appliquées : la largeur de face reste naturellement différente de celle du profil.

Le profil de référence est **le calque des membres proches**, avec deux pattes visibles ; le cycle expérimental existant lui ajoute sa couche éloignée. Il ne faut pas prendre ce calque pour un animal final à deux pattes. Les trois nouveaux dessins montrent chacun les quatre membres, partiellement masqués selon la perspective. Ils ne constituent pas encore des calques prêts à animer.

Les pivots du comparatif alignent le bas visible sur une ligne de présentation. Ce ne sont pas des pivots anatomiques ou des contacts de marche approuvés. La vue de face a une médiane de fourrure plus sombre que celle du profil, tandis que le trois quarts avant est proche de sa médiane. Les surfaces de couleur projetées diffèrent ; ces mesures servent au diagnostic, pas à affirmer une palette visuellement identique.

## Autocontrôle

La première génération arrière comportait cinq sabots. Elle est écartée ; une correction ciblée ImageGen retire le membre sous le milieu du ventre. Le résultat conservé a quatre pattes visibles, rattachées au corps dans l’image examinée.

`preflight.py` vérifie les empreintes des sources, la présence d’alpha, les marges visibles, les dimensions et les tailles uniformes. `hoof_regions.py` compte les zones de reflets gris des sabots dans la moitié basse du dessin : quatre sur les nouvelles sources, deux sur le calque proche. Ce diagnostic est propre à ces couleurs ; il soutient le contrôle visuel et ne prouve ni le nombre de membres masqués ni la justesse des articulations.

Les huit placements natifs sont contrôlés sans cisaillement ni échelle différente entre axes. Les 75 sources déclarées et l’exécutable de la v0.112 restent identiques avant et après la comparaison. La capture complète et les trois dessins ont été examinés : aucun membre supplémentaire dans les sources retenues, ni rognage visible dans le comparatif. Les rapports `controle_sources.json`, `placements_natifs.json`, `controle_pipeline.json` et `QA_construction.json` détaillent les périmètres.

## Travail restant

- Définir les pivots anatomiques, les plans d’appui et la correspondance des quatre membres entre vues.
- Construire les cycles de marche propres à ces perspectives, avec épaules et bassin, puis raccorder les phases de poussée et de retour.
- Dessiner ou construire des poses intermédiaires de virage. Un fondu de deux silhouettes, une simple alternance de dessins statiques ou un étirement ne sera pas considéré comme une transition naturelle.
- Éprouver une traversée normale du Gué, les virages, la pause, l’accélération et les impacts, avec un sol fixe et le survol.
- Faire valider le naturel du résultat par le porteur avant intégration.

La capture fournie est statique. **Elle ne démontre pas une animation fluide et ne remplace pas le précédent cycle.** Aucun schéma de profil, gain, coût, statistique ou fichier du jeu n’est modifié.

## Reproduction

Depuis la racine du dépôt, avec Python, NumPy et Pillow disponibles :

```powershell
python design/essais/sanglier_virages/build_comparison.py
```

Le moteur Godot est lancé minimisé sur l’écran de droite (`--screen 1`). Le script réutilise les sources enregistrées ; aucun appel de génération n’est effectué. Le paquet v0.112 et ses 75 sources doivent correspondre au projet courant. Les copies originales sous le dossier personnel de génération sont comparées si elles existent ; leurs empreintes enregistrées restent contrôlées sur un autre ordinateur.

For the Fortress! reste un nom de travail, disponibilité juridique à confirmer.

## Cycle de trois quarts avant sur le Gué

L’essai utilise le déplacement normal du sanglier sur la première diagonale. Les deux paires diagonales alternent leur appui et le corps monte légèrement pendant la reprise. J’ai retenu une foulée expérimentale de 8,5 pixels et une levée de 1,2 pixel. La cadence et la silhouette restent à juger en mouvement.

Le rendu Godot sur l’écran de droite a produit 144 images à 60 images/s, toutes décodées dans la vidéo. L’interpolation initiale repliait des triangles entre les pattes. Avec les poids répartis entre sabots voisins, l’aire signée minimale échantillonnée représente 17,5 % de l’aire au repos. La dérive maximale des sommets servant de repères d’appui est de 0,00013 pixel. Cette mesure porte sur ces quatre repères. La forme du sabot peut encore varier autour d’eux.

La vidéo couvre une diagonale et constitue un essai hors campagne. Le raccord au virage et les cycles des autres vues restent à construire.

Depuis la racine du dépôt, lancer Godot avec `--screen 1 --minimized --path prototype --script` suivi du chemin absolu de `render_gait.gd`. Les images sont écrites dans `captures/gait/` et les mesures dans `controle_cycle_avant.json`. La vidéo `cycle_trois_quarts_avant.mp4` a été encodée à 60 images/s avec FFmpeg.
