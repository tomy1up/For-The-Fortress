# Boutique · Hache en chaîne

Visuel fixe du type 26 (`horde.chainaxe`) accueilli favorablement par le porteur le 14 novembre 2026. Le troll a une silhouette compacte, une épaulière haute, une écharpe rouge et une hache à deux lobes portée bas. Comparé au Lanceur de haches et au Javelinier sur le même emplacement, il se distingue par son armure et le contour de son arme.

![Comparaison sur le plateau](essais/boutique_guetteurs/Hache_en_chaine_comparatif.jpg)

| Ressource | Cadre | Pied | Hauteur | Origine d’essai |
| --- | --- | --- | ---: | --- |
| `hache_en_chaine_v001.png` | `Rect2(0,0,1182,1205)` | `(462,1205)` | 58 px | `(21,-18)` |

Le portrait en boutique, le déblocage, le recrutement et le premier tir ont été contrôlés sur une copie v0.198 avec un profil d’essai. Les 101 contrôles d’illustrations passent sur cette copie. Elle utilise la hache de la famille en vol. Le dessin fixe conserve l’arme en main.

Pour le futur geste, partir de la hache basse, pivoter le buste puis prolonger l’arc du bras jusqu’au lâcher. Le projectile de la planche devra reprendre les deux lobes du dessin et suivre les cibles enregistrées par le jeu pour visualiser les rebonds. Le nom « en chaîne » désigne les ricochets du catalogue. L’essai actuel couvre le premier tir. Le raccord au lâcher et le rendu des rebonds successifs restent à produire et à vérifier.

Dessin créé avec le générateur intégré en prenant le Lanceur de haches comme référence de style. Consigne artistique : troll en armure sombre, hache courte à lame argentée tenue à la hanche, contours nets, aplats ombrés et silhouette lisible à 58 px.

## Lancer de la hache et ricochets

Le troll remonte la hache depuis la hanche en tournant le buste. L’épaule lance le mouvement, puis le bras projette la hache et poursuit son geste main ouverte. Les bottes restent calées. La hache à deux lobes conserve le même dessin en main, en vol et au fil des rebonds.

[Capture du combat à taille réelle sur la mission 94](essais/gestes_combat/hache_en_chaine/Hache_en_chaine_en_jeu.gif)

Type 26, `defender.horde.chainaxe`. Le lot `essais/gestes_combat/hache_en_chaine/` contient la garde, cinq inclinaisons (−12°, 0°, +12°, +24°, +36°) et `hache_double.png`. Chaque planche de tir compte 24 poses sur 0,96 s. La hache reste en main jusqu’à la pose de 0,48 s. Le vol commence à 0,52 s sur la première pose à main ouverte. `lachers.json` donne le centre et l’angle de la dernière hache tenue pour chaque inclinaison, ainsi que le pivot et l’échelle du projectile. Choisir l’inclinaison depuis son propre point de départ et retourner ensemble le repère, l’angle et la planche.

L’essai rend le premier trajet rectiligne en 0,12 s, puis chaque ricochet en 0,068 s avec une légère remontée de 3 px. La même texture suit les points d’impact dans l’ordre de `shot.secondary`. L’éclat apparaît à l’arrivée de la hache sur chaque point. À bout portant, déclencher le premier impact au lâcher si le point est déjà derrière le repère à l’écran, puis jouer les rebonds. Le modèle conserve les valeurs et l’instant de résolution des dégâts du type 26.

Sur la copie v0.226, mission 94 refondue, dix tirs sur les deux côtés à ×1 et ×2 et contrôle de la pause. Trois ricochets et leurs dégâts vérifiés sur le premier tir de chacun des quatre scénarios. La capture montre +24° à droite et +12° à gauche. Les autres angles ont été vérifiés sur planche. Les 120 poses restent cadrées avec les mêmes semelles et une garde identique en début et fin de planche. Le validateur relève 42 dossiers et zéro problème. Les 183 contrôles de la bibliothèque passent. Le porteur a validé le geste le 17 novembre 2026. Le lot `f0b6867` est prêt à intégrer.
