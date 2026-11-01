# Loup — boucle de travail continue

Date : 2 novembre 2026. **Étude isolée, non approuvée artistiquement, non intégrée au jeu publié.**

## Changement de méthode

Le premier calcul réparait chaque pose séparément. Il pouvait donc réussir sur les images clés et échouer pendant leur interpolation. Ajouter des clés entre ces poses n’a pas résolu ce défaut : les corrections indépendantes pouvaient choisir des déformations incompatibles.

`bake_followed_motion.py` suit maintenant les ancrages depuis la pose précédente, étend leur déplacement aux sommets libres et résiste à l’écrasement des faces. Chaque mouvement accepté est contrôlé sur tout son intervalle, et le pas de temps est réduit lorsque nécessaire. Le dessin et ses UV restent ceux de la peau continue ; aucune nouvelle illustration n’est insérée entre deux poses.

Le calcul brut n’aboutit pas spontanément à une fermeture parfaite. `close_followed_motion.py` distribue explicitement son écart sur tout le cycle, puis corrige ensemble les clés voisines, en conservant les sommets contraints. La première et la dernière pose deviennent une seule variable périodique. Cette étape de fabrication est mesurée et conservée dans les rapports ; elle ne consiste pas à remplacer la dernière image pour masquer un saut.

## Résultats vérifiés

| Contrôle indépendant | Couche proche | Couche éloignée |
| --- | --- | --- |
| Clés de phase, borne finale incluse | 133 | 143 |
| Triangles | 1 255 | 1 255 |
| Faces inversées aux clés | 0 | 0 |
| Intervalles avec inversion entre clés | 0 | 0 |
| Erreur maximale par rapport aux ancrages sources | < 0,000001 pixel source | < 0,000031 pixel source |
| Écart de fermeture final | 0 | 0 |
| Déplacement maximal distribué pour fermer | 1,480 pixel source | 2,288 pixels source |
| Correction commune maximale des clés voisines | 0,276 pixel source | 0,512 pixel source |

Le contrôle de transition calcule le minimum exact de l’aire de chaque triangle sur chaque intervalle linéaire. Il ne se limite pas à quelques images échantillonnées. `controle_interpolation_periodique.json` donne les résultats et les empreintes des données réellement contrôlées. Le rendu refuse des fichiers différents de ceux du rapport réussi.

Le contrôle de l’ancien calcul reste en échec, avec 26 et 31 occurrences intervalle/face. Ce cas sert à vérifier qu’un succès aux poses clés ne suffit toujours pas à obtenir un résultat positif.

**Ces chiffres ne valident pas le naturel du mouvement ni la préservation artistique des volumes.** Certaines faces proches peuvent encore changer fortement de surface, jusqu’à un rapport de 7,64. Les raccords de fourrure à l’épaule et à la hanche restent à reprendre visuellement. Les contrôles d’ancrage ne constituent pas une mesure des pixels des coussinets sur une route isométrique.

La position est continue, mais l’interpolation reste linéaire par morceaux : **la vitesse de déformation n’est pas continue aux clés**. Le contrôle enregistre désormais aussi les sauts de vitesse des sommets. Sur les données complètes, le maximum est d’environ 2 259 pixels source/cycle pour la couche proche et 6 533 pour la couche éloignée ; à la fermeture, environ 515 et 442. Ces valeurs concernent aussi des sommets non visibles de la couche éloignée. Aucun succès de contrôle géométrique ne doit être présenté comme une correction définitive des saccades ressenties. La prochaine reprise doit traiter les tangentes temporelles ou lisser les trajectoires libres tout en conservant les appuis et en recontrôlant l’absence d’inversion sur les nouvelles courbes.

## Aperçu natif

Vidéo locale : `captures/loup_peau_continue_cycle_travail_2026-11-02.mp4`.

- Rendu Godot 4.7.2, écran de droite, fenêtre minimisée, sans scène de jeu ni profil joueur.
- 192 images natives, trois cycles, 60 images/s, 1 280 × 800, durée 3,20 secondes.
- En haut : agrandissement avec sol défilant ; en bas : déplacement sur sol fixe, hauteur nominale de 34 pixels sur la pose de référence. Cette hauteur reprend la valeur actuelle de `prototype/scripts/enemy_walk_art.gd` et reste uniforme sur toute la boucle.
- La vitesse est une vitesse d’atelier. Il reste à calibrer le rendu sur la projection isométrique et les vitesses effectives en mission.
- Les images 0, 8, 16, 24, 32, 40, 48 et 56 de la première capture ont été inspectées. Après recalage de l’échelle et du sol, les images 0, 40, 63 et 64 ont été inspectées à nouveau. Le MP4 a été décodé intégralement sans erreur : 192 images, durée et cadence confirmées. Cette inspection de poses ne remplace pas la validation perceptuelle de la fluidité par le porteur.

La vidéo et les captures restent des sorties locales de travail. Leur manifeste `QA_boucle_continue_2026-11-02.json` conserve l’empreinte de la vidéo et des données. Aucune version Windows du jeu n’est annoncée comme contenant cette animation.

## Reproduction locale

Prérequis : Godot standard installé, Python et NumPy. Conserver le pack v0.106 figé utilisé par l’atelier ; ne pas lancer son exécutable directement avec `--script`.

1. Exécuter `export_corrections.gd` dans Godot avec le pack figé et le chemin absolu du script : préparation des contraintes dans `captures/correctives_input.json`.
2. Exécuter `bake_correctives.py` si les données de départ sont à reconstruire. Ce premier calcul demeure un témoin en échec pour les transitions.
3. Exécuter `bake_followed_motion.py`, puis `close_followed_motion.py`. Les données intermédiaires restent dans `captures`; les deux fichiers `periodic_walk*.json` constituent la boucle à contrôler.
4. Exécuter `check_correctives.py --variant periodic`. Exiger son succès avant le rendu. Sans cet argument, le témoin initial doit toujours échouer.
5. Exécuter `render_walk.gd` avec les arguments utilisateur `--periodic --movie`, `--screen 1 --minimized`, et un plafond d’au moins 2 000 images moteur pour laisser finir les 192 captures. Sans `--movie`, douze poses sont exportées.
6. Encoder `captures/periodic_movie/pose_%04d.png` avec FFmpeg à 60 images/s, H.264, 192 images, sans redimensionnement ; décoder ensuite le MP4 pour vérifier son intégrité.

Le retour visuel attendu avant intégration porte encore sur la démarche, le poids, les volumes et les raccords de fourrure. La validation du porteur précède l’extension aux autres unités.
