# Boutique · Lanceur double troll

Visuel fixe du type 27 (`horde.doublethrower`) validé par le porteur le 14 novembre 2026. La lanceuse se distingue par sa silhouette élancée, sa mèche blanche et ses deux petites haches à hauteur différente. Le comparatif place les trois trolls au même emplacement E2.

![Comparatif sur le plateau](essais/boutique_guetteurs/Lanceur_double_troll_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `lanceur_double_troll_v001.png` | `Rect2(0,0,905,1128)` | `(462,1128)` | 57 px | `(18,-37)` |

Sur une copie v0.198, le portrait, le déblocage sur profil d’essai, le recrutement et le premier tir ont été vérifiés. Les 106 contrôles d’illustrations passent. Le projectile actuel reprend la hache de famille.

Pour l’animation, alterner les bras d’un tir au suivant. L’autre hache reste en main pendant le geste. Le jeu enregistre un seul tir par attaque, avec un bonus de dégâts sur un ennemi blessé. Les origines alternées et le raccord de chaque lâcher restent à produire.

Dessin réalisé avec le générateur intégré. Direction artistique : troll adulte élancée, deux petites haches en croissant, aplats ombrés aux contours nets et silhouette lisible à 57 px.

## Deux bras alternés

La lanceuse remonte le bras de la hache basse en travers du buste. Au tir suivant, elle arme le bras de la hache haute près de l’épaule. La main du lancer s’ouvre et continue son mouvement. L’autre hache reste tenue pendant tout le geste. La garde revient entre les tirs et les appuis restent stables.

[Deux tirs par vue sur la mission 94 à taille réelle](essais/gestes_combat/lanceur_double_troll/Lanceur_double_troll_en_jeu.gif)

Type 27, `defender.horde.doublethrower`. Le [lot d’essai](essais/gestes_combat/lanceur_double_troll/) fournit la garde et six planches de 23 poses sur 0,92 s, soit trois inclinaisons par bras. Le bras de la hache basse utilise `attack`, `attack_up` et `attack_down`. Le bras de la hache haute utilise `attack_close`, `attack_close_up` et `attack_close_down`. Ces noms correspondent aux bras, indépendamment de la distance. Départ à 0,48 s, sur la première pose à main ouverte. Reprendre le centre et l’angle de la dernière pose tenue dans `lachers.json`. Le fichier indique aussi le dessin et le pivot de chaque hache ainsi que l’échelle commune.

L’essai alterne par défenseur à chaque tir enregistré, en commençant par la hache basse. Le bras sélectionné reste associé au tir pour choisir la pose et le projectile. D’après le repère de chaque inclinaison du bras sélectionné, choisir la pose la plus proche du trajet vers l’impact. Retourner ensemble la planche, le point et l’angle. Faire tourner la hache correspondante le long du trajet rectiligne. À bout portant, si l’impact est déjà derrière le point de lâcher projeté, jouer l’impact seul. Conserver un projectile par attaque et le bonus contre les cibles blessées.

Copie v0.226 et mission 94 refondue. Huit tirs, deux par côté et par vitesse à ×1 et ×2. Les deux bras ont été vérifiés dans les deux sens à +24°. Les quatre autres planches ont été contrôlées hors combat. Pause, 17 points par trajet, alternance et absence de projectile secondaire vérifiés. Les 138 poses restent cadrées et les semelles, la première et la dernière pose correspondent à la garde. Le validateur relève 43 dossiers et zéro problème. Les 184 contrôles de la bibliothèque et les 77 contrôles des effets d’unités passent. Retour favorable du porteur le 17 novembre 2026 (« ok pas mal »). Lot `b779d4d` prêt à intégrer.
