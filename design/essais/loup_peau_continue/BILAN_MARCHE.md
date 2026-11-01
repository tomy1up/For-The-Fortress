# Étude d’une marche à peau continue

Date : 1er novembre 2026. Statut : **non validée pour intégration**. Aucun changement de gameplay, de profil joueur ou de version distribuée.

Ce bilan conserve les échecs du premier calcul. Une boucle ultérieure, décrite dans [MARCHE_CONTINUE.md](MARCHE_CONTINUE.md), passe le contrôle des transitions le 2 novembre. Le résultat artistique demeure expérimental.

## Ce qui change

Le tronc et les membres proches partagent le même dessin, les mêmes sommets aux attaches et des influences d’os communes. Les membres éloignés passent derrière. La démarche entraîne aussi les épaules, le bassin, la tête et la queue. La phase suit la distance parcourue : accélérer le déplacement accélère les pas.

Le squelette de marche compte 19 os. La peau expérimentale compte 771 sommets et 1 255 triangles. Les pieds sont pilotés par des objectifs au sol et les articulations sont résolues à partir de ces objectifs. Le test se déroule sur un sol horizontal ; il ne constitue pas une validation des routes isométriques du jeu.

## Référence effectivement examinée

Référence de mouvement : Quaternius, *Ultimate Animated Animals*, `Wolf.gltf`, animation `Walk`, licence CC0. Le cycle a été rendu sur douze poses, puis les positions des os ont été échantillonnées sur 65 instants. `reference_walk.json` conserve les données sélectionnées, la période, l’origine et l’empreinte du fichier source. Le modèle 3D ne devient pas un asset du jeu.

- Source et licence : https://quaternius.com/packs/ultimateanimatedanimals.html
- Précisions de licence : https://quaternius.com/faq.html

Cette adaptation 3D vers le dessin 2D reste une interprétation : les proportions, les phases d’appui et l’amplitude verticale ont été calibrées pour cette étude. Elle ne garantit pas à elle seule une anatomie naturelle. La vidéo YouTube du porteur n’a pas été visionnée.

## Contrôles et résultats

| Contrôle | Résultat | Portée réelle |
| --- | --- | --- |
| Preuve native de flexion à cinq os | Réussie : peau connectée, poids normalisés | Ancienne preuve technique, pas une marche |
| Appuis des quatre extrémités d’os | Réussi sur 1 025 instants, deux cycles ; dérive maximale 0,000611 pixel source | Extrémités des os uniquement ; ne mesure pas les pixels de la patte |
| Peau entraînée seulement par les poids du squelette | **Échec** : triangles inversés sur de nombreuses poses | La pondération automatique seule ne suffit pas |
| Corrections géométriques ARAP | Plis et écrasements subsistent ; la projection de faisabilité enlève les inversions aux 65 poses clés | Ce ne sont pas des corrections dessinées ; les transitions restent en échec |
| Interpolation exacte entre poses | **Échec** : 26 occurrences d’inversion pour la couche proche, 31 pour la couche éloignée | Contrôle analytique du minimum de l’aire sur chaque intervalle, pas seulement quelques images intermédiaires |
| Fermeture du cycle après projection | Écarts de 0,00616 et 0,03349 pixel source | La seconde couche dépasse le seuil numérique de 0,02 ; cela ne permet pas de valider la boucle |
| Vérification visuelle | Douze poses exportées ; poses 0, 3 et 8 inspectées en détail | Pincement encore visible à la hanche ; pas de validation temporelle complète |

Les rapports `controle_appuis_cycle.json`, `controle_marche.json`, `controle_correctifs.json` et `controle_interpolation.json` conservent aussi les échecs. Aucun seuil n’a été abaissé pour les faire passer. Les nombres de triangles inversés du test de peau brute sont des occurrences cumulées sur 128 poses, pas un nombre de triangles uniques. Les occurrences d’interpolation concernent des couples intervalle/triangle ; une face peut apparaître plusieurs fois.

La dernière préparation réduit les contraintes rigides de 503 à 348 : une trace d’influence de tête ou de queue ne doit pas immobiliser une racine de membre. Une projection géométrique supplémentaire répare les faces inversées sans déplacer les points contraints. Les rapports conservent les valeurs avant et après cette opération. **Son succès aux poses clés ne suffit pas** : le contrôle de transition découvre des inversions entre ces poses et échoue donc volontairement. Ne pas intégrer ce résultat au jeu.

Une première retouche générée de la pose 8/12 et son inspection dans Godot sont conservées dans [POSE_DESSINEE.md](POSE_DESSINEE.md). Elle améliore la hanche mais change les proportions et le cadrage : elle sert de guide artistique, pas de frame enregistrée pour le cycle.

## Conclusion de fabrication

Conserver la peau continue et les appuis. Ne pas étendre ce cycle aux autres unités. La prochaine étape artistique est de reprendre les silhouettes de contact, d’appui, de passage et de retour, puis de **dessiner les corrections d’épaule et de hanche** qui résistent mal à la déformation. Les deux couches doivent aussi être nettoyées pour éviter les recouvrements disgracieux. Le sol doit être recalé sur le dessous des coussinets, et non sur le centre des pieds utilisé par le solveur.

Les corrections automatiques actuelles servent à repérer les poses problématiques. Si leur reprise devient plus coûteuse que le dessin des poses complètes, basculer vers l’image par image pour le loup. Ne pas chercher à résoudre ces défauts en augmentant seulement la cadence.

La validation finale portera sur une boucle animée : quatre pattes attachées visuellement au corps, articulations canines, appuis sans glissement, poids transmis au tronc, volumes stables, continuité de boucle, puis déplacement à taille réelle et à plusieurs vitesses dans une scène isolée. La validation du porteur précède toute intégration.

## Fichiers et reproduction

Les scripts sont autonomes et s’exécutent avec le Godot standard installé. Pour reproduire cet état local, utiliser `--main-pack` avec l’exécutable figé v0.106 et `--script` avec le chemin absolu du script de cette étude. Lancer les contrôles sans fenêtre ; lancer les captures sur l’écran de droite avec `--screen 1 --minimized`. Les commandes ne chargent aucun profil joueur.

1. `check_native.gd` : preuve limitée de connexité et flexion.
2. `check_ground.gd` : contrôle des positions effectives des quatre extrémités d’os.
3. `check_walk.gd` : diagnostic de la peau brute ; retourne actuellement un code d’échec attendu et à conserver.
4. `export_corrections.gd` : export de géométrie et de contraintes dans `captures/correctives_input.json`.
5. `bake_correctives.py` : calcul des géométries avec Python et NumPy ; ne modifie aucun pixel d’image. Le script conserve une triangulation de Delaunay contrainte et stabilise le cycle avant enregistrement.
6. `render_walk.gd`, argument utilisateur `--corrected` : douze poses de diagnostic corrigées, dans le dossier local `captures`. Sans cet argument : peau brute.
7. `check_correctives.py` : contrôle indépendant des images clés, du minimum exact de l’aire pendant chaque interpolation linéaire, des cibles contraintes et de la fermeture. Il retourne actuellement un échec, attendu et à conserver.
8. `compare_drawn_pose.gd` : comparaison fixe dans Godot entre la déformation et le guide dessiné ; ne charge aucun profil.

La méthode ARAP s’appuie sur le principe de préservation locale des formes de [Sorkine et Alexa, 2007](https://igl.ethz.ch/projects/ARAP/arap_web.pdf). Elle ne garantit pas l’absence d’inversion et ne remplace pas le travail artistique.

Les données `correctives_walk*.json` sont des résultats expérimentaux non approuvés. Elles ne sont référencées par aucune scène du prototype. Les images de captures sont des sorties locales de diagnostic, pas des assets validés.
