# Loup — mouvement du thorax et du bassin

Date : 2 novembre 2026. **Variante artistique à valider, hors de la version jouable.** Elle conserve le dessin et les appuis de l’étude précédente.

## Problème et reprise

Le lissage de la peau ne suffit pas si le corps est entraîné comme un seul bloc. Le réglage précédent déplaçait principalement les deux attaches à partir du dos ; il ajoutait ensuite aux épaules et au bassin une fraction de la rotation du membre proche. Ce réglage peut donner des réactions du corps qui suivent mal la démarche.

La variante `body_reference` de `../loup_peau_continue/walk_skin.gd` utilise séparément les déplacements des attaches avant et arrière de la référence Quaternius déjà examinée : `FrontUpperLeg.L/R` et `BackLeg.L/R`. Leurs déplacements sont centrés sur la pose moyenne, puis projetés dans le profil du dessin. Le facteur de conversion, environ 324,49 pixels source par unité de référence, est calculé à partir de l’écartement moyen des attaches. Les proportions du dessin au repos restent la base du réglage.

Le thorax et le bassin entraînent leurs racines de membres ; la tête suit l’épaule et la queue suit le bassin. L’inclinaison du tronc découle de la ligne entre les deux attaches proches. La rotation partielle issue des jambes n’est plus ajoutée dans cette variante.

Il s’agit d’une adaptation cinématique pour l’animation. Le choix de projection et les amplitudes restent des **hypothèses artistiques**, non des paramètres approuvés pour le jeu. `body_reference` est désactivé par défaut et n’est utilisé que dans cet atelier.

## Contrôles effectués

| Contrôle | Résultat et limite |
| --- | --- |
| Racines proches des membres / attaches du corps | Écart nul sur 1 025 instants, deux cycles, dans le `Skeleton2D` réel |
| Pieds : différence avec le réglage précédent | Maximum 0,000773 pixel source ; chemins d’appui conservés à la précision native |
| Pieds en appui | Dérive maximale 0,000563 pixel source, 2 395 échantillons d’appui |
| Attache de tête | Erreur maximale 0,000368 pixel source |
| Attache de queue | Écart nul |
| Portée des chaînes articulées | Erreur maximale 0,000031 pixel source |
| Mouvement de l’attache d’épaule | Amplitudes crête à crête : 25,791 pixels source horizontalement, 21,645 verticalement |
| Mouvement de l’attache du bassin | Amplitudes crête à crête : 4,813 pixels source horizontalement, 24,656 verticalement |
| Courbes finales de peau | 128 intervalles cubiques par couche, 1 255 triangles ; aucun intervalle en échec ni non résolu |
| Boucle | Position fermée ; tangentes communes pour les sommets libres. Les ancrages restent linéaires par morceaux |
| Lecture des maillages Godot | 24 672 positions comparées à un évaluateur indépendant ; erreur maximale inférieure à 0,000069 pixel source |

Ces contrôles ne valident pas les pixels de contact sur les routes isométriques ni le naturel ressenti. Les raccords de fourrure et les volumes restent à examiner visuellement.

Le réglage par défaut précédent a été contrôlé à nouveau : ses appuis et sa lecture native restent identiques. Les outils communs acceptent maintenant un dossier de données explicite, ce qui permet de conserver les essais précédents et cette variante séparément.

## Aperçu comparatif

Vidéo locale : `captures/loup_comparaison_corps_2026-11-02.mp4`.

À gauche : la boucle lissée précédente. À droite : les nouvelles attaches. Les deux côtés utilisent le même dessin, la même échelle et les mêmes conditions d’appui. En bas, les loups avancent à l’échelle nominale du plateau ; l’échelle est commune aux deux variantes, sans normalisation individuelle à chaque pose.

Rendu dans Godot 4.7.2 sur l’écran de droite, fenêtre minimisée, sans scène de jeu ni profil joueur. Trois cycles, 192 images à 60 images/s, 1 280 × 800. Les poses 0, 16, 32 et 48 ont été inspectées. Le MP4 a été décodé intégralement pour vérifier ses 192 images et sa durée de 3,20 secondes. Cette inspection de poses ne remplace pas l’appréciation perceptuelle de la vidéo.

`QA_corps_2026-11-02.json` conserve les empreintes des sources, courbes et vidéo. La validation du porteur reste requise avant intégration ou extension aux autres unités. Aucune nouvelle version Windows du jeu n’est annoncée comme contenant cette variante.

## Reproduction

Les scripts communs restent dans `../loup_peau_continue`. Pour les scripts Godot, employer le Godot standard avec `--main-pack` pointant vers le pack v0.106 figé et `--script` vers le chemin absolu du script.

1. Exécuter `check_reference_body.gd` sans fenêtre pour contrôler les attaches du squelette et les appuis.
2. Exécuter `../loup_peau_continue/export_corrections.gd` avec l’argument utilisateur `--body-reference`. Il écrit ici `captures/correctives_input.json` sans remplacer celui de l’étude précédente.
3. Exécuter successivement `bake_correctives.py`, `bake_followed_motion.py`, `close_followed_motion.py`, `smooth_motion.py`, en leur passant à chaque fois `--folder` et le chemin absolu de ce dossier.
4. Exécuter `check_smooth_motion.py --folder <ce dossier>`.
5. Exécuter `check_native_smooth.gd --screen 1 --minimized`, avec les arguments utilisateur `--data-folder <ce dossier>` et un plafond de 300 images moteur.
6. Exécuter `check_smooth_motion.py --native --folder <ce dossier>`.
7. Exécuter `compare_body_motion.gd --screen 1 --minimized`, avec un plafond de 2 000 images moteur. Il vérifie les empreintes des données et de l’interpolateur avant de capturer.
8. Encoder `captures/compare_body_movie/pose_%04d.png` à 60 images/s, 192 images, H.264, sans redimensionnement, puis décoder intégralement le MP4.

Les courbes cubiques finales et rapports sont versionnés. Les données intermédiaires et captures sont locales et se reconstruisent avec cette chaîne. Les scripts communs sans argument gardent leur dossier et leur comportement précédents.
