# Loup — continuité des déformations

Date : 2 novembre 2026. **Étude isolée, validation artistique toujours ouverte.** La version jouable ne contient pas ces essais.

## Problème traité

La boucle précédente conservait les ancrages et empêchait les inversions de triangles, mais sa déformation était linéaire par morceaux. Une position continue ne garantit pas une vitesse continue. Certaines petites parties de peau changeaient trop brusquement de vitesse, notamment autour des articulations.

`smooth_motion.py` rééchantillonne cette boucle sur 128 intervalles uniformes, filtre deux fois les trajectoires des sommets libres, puis construit des courbes cubiques avec des tangentes partagées. Les positions sont réellement lissées : ce n’est pas seulement un ajout d’intermédiaires entre des images inchangées. Les tangentes sont communes de part et d’autre des clés, y compris à la fermeture.

Les 348 sommets contraints de chaque couche, dont les pieds, conservent leur chemin linéaire d’origine. **La continuité de vitesse concerne les sommets libres, pas l’ensemble du personnage.** Les variations restantes des ancrages et les raccords graphiques restent à examiner. Ne pas annoncer une marche totalement naturelle ou dépourvue de saccades sur la seule base de ces contrôles.

## Résultats mesurés

| Mesure | Couche proche | Membres éloignés visibles |
| --- | --- | --- |
| Sommets libres pris en compte | 423 | 234 |
| Variation seconde RMS avant, pixels source sur la grille d’étude | 0,67014 | 1,03900 |
| Variation seconde RMS après | 0,35788 | 0,50063 |
| Réduction de cet indicateur | environ 47 % | environ 52 % |
| Déplacement libre maximal par rapport à la boucle précédente, couche complète | 4,652 pixels source | 6,989 pixels source |

Cet indicateur mesure les variations des trajectoires discrètes ; il ne constitue pas une note de fluidité ressentie. Le dessin, les UV, la cadence de référence et les ancrages restent identiques à ceux de l’étude précédente.

Les courbes cubiques peuvent retourner un triangle même si toutes leurs poses clés sont correctes. Six couples intervalle/face étaient initialement en défaut sur la couche éloignée. Ils ont été repris avec des tangentes et des clés communes aux intervalles voisins. La correction de position supplémentaire maximale est de 0,973 pixel source ; aucun sommet contraint n’a été déplacé par cette correction.

## Vérification indépendante

`check_smooth_motion.py` ne réutilise pas les fonctions du générateur. Il exprime les mouvements en contrôles de Bézier, puis certifie la positivité des aires par bornes de Bernstein et subdivision lorsque nécessaire. Tout intervalle non résolu est refusé. Trois cas de contrôle couvrent une constante positive, une courbe négative entre des extrémités positives et une courbe positive nécessitant une subdivision.

- 128 intervalles cubiques par couche, 1 255 triangles par intervalle : aucun échec ni intervalle non résolu.
- Borne inférieure certifiée du rapport d’aire : 0,04746 proche ; 0,02974 éloignée. Cela ne certifie ni les volumes artistiques ni l’absence de recouvrements non locaux.
- Erreur maximale par rapport aux ancrages sources : moins de 0,000001 pixel source proche ; moins de 0,000031 éloigné.
- Position à la fermeture : identique. Vitesse des sommets libres à la fermeture : identique.
- Les ancrages conservés restent linéaires par morceaux ; leurs variations de vitesse sont enregistrées, pas masquées.

`check_native_smooth.gd` lit ensuite les coordonnées réellement présentes dans les `ArrayMesh` de Godot, à 16 phases par couche, dont des phases hors des clés et la fermeture. Le vérificateur les compare à une évaluation indépendante par de Casteljau : **24 672 positions de sommets comparées**, écart maximal inférieur à 0,000069 pixel source. Le rapport lie les données et le script de rendu par leurs empreintes.

## Comparaison native

`compare_smooth_motion.gd` affiche la boucle précédente à gauche et les nouvelles trajectoires à droite. Les deux utilisent la même image et les mêmes conditions. Le rendu de travail a été exécuté dans Godot 4.7.2 sur l’écran de droite, en fenêtre minimisée, sans scène de jeu ni profil joueur.

Vidéo locale : `captures/loup_comparaison_lissage_2026-11-02.mp4`.

La comparaison contient trois cycles, 192 images à 60 images/s, en 1 280 × 800. En haut, les deux loups sont agrandis ; en bas, ils se déplacent à une hauteur nominale de 34 pixels. Les poses 0, 24, 40 et 56 ont été inspectées. Cette inspection de poses et les contrôles numériques ne remplacent pas l’appréciation perceptuelle de la vidéo par le porteur.

Le MP4 a été décodé intégralement sans erreur ; le nombre d’images, le format et la durée ont été confirmés. `QA_lissage_2026-11-02.json` conserve les empreintes de la vidéo, des données et des scripts utilisés.

Les limites restent les raccords de fourrure aux épaules et aux hanches, le naturel de la démarche, la calibration sur les routes isométriques, et les performances avec une meute en situation réelle. Aucune extension aux autres unités ni intégration dans une version distribuée n’est validée à ce stade.

## Reproduction

1. Conserver les données et contraintes de la boucle décrite dans [MARCHE_CONTINUE.md](MARCHE_CONTINUE.md).
2. Exécuter `smooth_motion.py`, puis `check_smooth_motion.py`.
3. Exécuter `check_native_smooth.gd` avec le Godot standard, le pack v0.106 figé et le chemin absolu du script, `--screen 1 --minimized`, avec un plafond de 300 images moteur.
4. Exécuter `check_smooth_motion.py --native` : les empreintes des données et du script doivent correspondre à la lecture native.
5. Exécuter `compare_smooth_motion.gd` avec le même environnement, un plafond de 2 000 images moteur et l’écran de droite. Il refuse des données ou un rendu différents de ceux du rapport vérifié.
6. Encoder `captures/compare_smooth_movie/pose_%04d.png` à 60 images/s, 192 images, H.264, sans redimensionnement ; décoder le MP4 intégralement pour confirmer son format et son nombre d’images.

Le rendu simple existant accepte aussi `--smooth` à la place de `--periodic`, avec `--movie` pour les 192 images. Les données intermédiaires et vidéos sont locales ; les scripts, rapports et courbes finales sont versionnés.
