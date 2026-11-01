# Loup — corps animé et pattes conservées

**Retour suivant du porteur :** corps jugé bien meilleur, mais raccords des pattes toujours trop dissociés. Cette animation complète n’est donc pas validée. Une [étude de peau continue](../loup_peau_continue/README.md) reprend la construction des jonctions avant de produire un nouveau cycle.

## Retour du porteur et statut

Le porteur juge les pattes du précédent essai « parfaites », mais le corps trop fixe : impression de tube porté par des pattes. **Les pattes sont validées ; cette nouvelle animation du corps reste une proposition à valider.** Aucune extension aux autres unités, ni remplacement du rendu du jeu publié, avant ce retour.

Référence fournie par le porteur : https://www.youtube.com/watch?v=mCsCiLTRe9c. Le visionnage n’a pas pu être réalisé : récupération web en échec puis contrôle du navigateur arrêté automatiquement faute de vérification de l’URL. Ce travail répond à la description explicite du porteur ; il ne prétend pas reproduire une analyse de cette vidéo.

## Voir la proposition

Ouvrir `Voir_essai_corps_loup.cmd` : écran de droite, atelier sans profil joueur. Le bouton **Corps fixe / animé** permet de comparer instantanément avec les mêmes appuis ; vitesses ×0,5 / ×1 / ×2, pause et taille du jeu / zoom ×5 sont disponibles. Échap ferme l’atelier.

La vidéo `Loup_corps_essai.mp4` dure vingt secondes :

| Temps | Vue |
| --- | --- |
| 0–5 s | Nouveau corps animé, vitesse normale, agrandi ×5 |
| 5–10 s | Corps fixe pour comparaison, mêmes trajectoires des pattes |
| 10–15 s | Corps animé, vitesse doublée, agrandi ×5 |
| 15–20 s | Corps animé à taille du plateau, vitesse normale |

La capture contrôlée comporte 1 200 images à 60 ips ; elle ne mesure pas les performances en partie. Le lanceur utilise le moteur Godot et le paquet v0.106 existants. Aucun accès au profil joueur, aucun gain enregistré.

## Changement essayé

- Épaules et bassin se déplacent en décalage avec les phases d’appui ; le dos se déforme entre eux.
- Le haut des membres suit les mêmes points du corps, tandis que les pattes conservent leurs trajectoires résolues par le précédent essai.
- La tête pivote légèrement au niveau du cou avec un retard de phase. Le visage reste rigide ; la transition se fait à la jonction du cou.
- La queue accompagne le bassin, avec un retard croissant jusqu’à son extrémité.
- Tout dépend de la distance parcourue : arrêt et variation de vitesse s’appliquent à l’ensemble du mouvement.

Le PNG reste inchangé et partagé avec l’essai des appuis. Seul le maillage de rendu est animé. Les amplitudes, décalages et mouvements restent des réglages d’essai. Les deux orientations miroir et le comportement aux virages doivent toujours être jugés visuellement.

## Contrôles

`test_contacts.gd` compare les références de toutes les pattes, en appui **et en retour**, à celles du rendu précédemment approuvé, pour 16 décalages de cycle sur tout le trajet. Il mesure aussi la dérive des appuis après résolution de l’articulation. Résultats dans `controle_appuis.json`.

`test_body_skin.gd` contrôle le raccord du cycle, la rigidité du visage, le mouvement relatif épaules/bassin et les triangles du maillage sur 48 phases : aucune inversion ou dilatation excessive selon les seuils internes de l’atelier. Résultats dans `controle_corps.json`. Ces contrôles ne prouvent pas une animation naturelle.

Inspection des poses agrandies réalisée ; contrôles de pause, vitesse, zoom, comparaison du corps et redémarrage effectués. Le prochain contrôle artistique porte sur le poids, la continuité du mouvement et le caractère vivant de l’ensemble. L’intégration aux combats avec de nombreux ennemis, les performances, impacts et malédictions ne sont pas validés par cet atelier à un seul loup.
