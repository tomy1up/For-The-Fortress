# Boutique · Catapulte gobeline

Visuel du type 19 (`horde.catapult`) validé par le porteur le 14 novembre 2026 (`9b62adf`). Le bras en bois, la cuillère surélevée et la pierre grise donnent une silhouette distincte du canon sur roues du Bombardier nain. Le servant gobelin à cheveux blancs porte un tablier rouge.

[Comparatif du Sapeur, de la Catapulte et du Bombardier](essais/boutique_guetteurs/Catapulte_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | ---: | --- |
| `catapulte_gobeline_v001.png` | `Rect2(0,0,1503,1008)` | `(758,1008)` | 58 px | `(28.75,-49.0)` |

Le portrait en boutique, le déblocage, le recrutement et le premier tir ont été vérifiés sur une copie v0.197. Les 70 contrôles d’illustrations passent. La pose est fixe et la copie affiche encore une bombe du Sapeur au tir. L’intégration doit associer un rendu de pierre projetée en conservant les règles de dégâts de zone.

## Premier essai animé

La pierre quitte la cuillère à la première image de l’événement de tir, lorsque le jeu commence à la dessiner en vol. Le bras bascule brièvement, cuillère vide, puis revient à la pose chargée. Le servant écarte sa main du bras et les patins gardent la même base d’image. Le retour à la pose chargée est encore abrupt. Les neuf images de la planche réutilisent trois dessins, dont deux cuillères vides.

Les ressources d’essai restent dans `design/essais/gestes_combat/defender.horde.catapult/`. Une copie locale v0.197 les a chargées dans le jeu, avec une pierre provisoire dessinée côté rendu. Le contrôle a couvert un tir à ×1 et un tir à ×2 au Gué, depuis E2, avec une paire d’images identiques pendant l’arrêt de la simulation. Validateur : 24 dossiers, 0 problème. Test de la bibliothèque : 156 contrôles réussis. La fluidité du retour et l’autre orientation restent à vérifier.

[GIF de l’atelier et des captures en jeu](essais/gestes_combat/Catapulte_essai_animation.gif) · [Aperçu fixe](essais/gestes_combat/Catapulte_essai_animation.jpg)

## Deuxième essai · retour de la cuillère

La planche d'étude passe à 20 images sur 0,8 s. La cuillère vide descend après le tir, puis remonte progressivement. La pierre redevient visible au moment du rechargement et la dernière image reprend la pose fixe. Le servant reprend sa prise en fin de mouvement.

Sur une copie v0.197, le premier tir a été capturé dans les deux orientations au Gué, à ×1 et ×2. Dans les quatre cas, le cadrage de la Catapulte est identique sur deux images successives avec simulation arrêtée. Validateur : zéro problème sur 24 dossiers. Test de bibliothèque : 156 contrôles réussis.

[Captures en jeu côte à côte](essais/gestes_combat/Catapulte_retour_v002.gif). Essai soumis à validation visuelle du porteur.

## Tir avec bras sur pivot

La pierre reste dans la cuillère pendant que le servant arme le bras. Le bras pivote d’un bloc, le servant ramène sa main vers lui et ses épaules suivent la détente. La cuillère vide dépasse sa position de garde, revient et se recharge. Les patins et les pieds ont la même position tout au long des 24 poses. La première et la dernière pose reprennent la garde au pixel près.

[Voir les quatre diagonales à taille native et à ×1](essais/gestes_combat/catapulte_gobeline/Catapulte_gobeline_en_jeu.gif) · [Voir deux diagonales à ×2](essais/gestes_combat/catapulte_gobeline/Catapulte_gobeline_x2.gif)

Type 19, `defender.horde.catapult`. Les planches sont dans `design/essais/gestes_combat/catapulte_gobeline/`. Le cycle dure 1,20 s. Le lâcher visuel à 0,50 s correspond à la première cuillère vide. Orienter `pierre.png` depuis le centre indiqué par `lacher.json`, en retournant le décalage horizontal pour un tir à gauche. Le fichier donne aussi les paramètres de l’arc visuel d’essai. Relier le centre de départ à l’impact et retirer une hauteur verticale de `4 × h × progression × (1 − progression)`, avec `h` à 16 px minimum ou 46 % du dénivelé si celui-ci impose davantage. Le rendu de zone se joue à l’arrivée. Les valeurs et le traitement des dégâts restent ceux du modèle.

Essai sur copie v0.220, mission 94. Quatre tirs, aux deux vitesses et des deux côtés, avec deux cibles secondaires enregistrées par tir. L’arc monte dès le départ et rejoint l’impact sur les 17 positions vérifiées. La pose se fige en pause. Validateur à zéro problème sur 35 dossiers et bibliothèque à 176 contrôles réussis.

### Orientation vers la route et la cible

Le porteur a demandé que le châssis vise la route, puis a rejeté l’effet de cisaillement de la première proposition en diagonale. Le châssis des deux vues inclinées a été reconstruit en volume. Ses deux rangées de patins reposent dans le plan du plateau, le bras pivote et la cuillère conserve son volume. Le servant conserve son dessin debout et la vue de profil reprend les deux planches précédentes à l’identique. [Avant et après sur E4](essais/gestes_combat/catapulte_gobeline/Catapulte_gobeline_avant_apres.gif).

Pour la garde, utiliser la direction entre l’emplacement et le point le plus proche sur la route. En combat, utiliser la dernière cible, puis figer le choix de vue et le côté sur la position au moment où le tir est enregistré. Choisir `idle_up` et `attack_up` si la cible au sol est au-dessus à l’écran, `idle_down` et `attack_down` si elle est en dessous. Dans l’essai, le profil est sélectionné pour un écart vertical inférieur à `max(5 px, 0,16 × |écart horizontal|)`. Le signe horizontal donne le côté. La garde prend la vue correspondante à la fin du geste. Le changement de vue se fait directement au changement de direction.

Les deux paires de variantes demandent un branchement dans la bibliothèque. `lacher.json` donne le centre de la pierre pour chaque planche d’attaque. Utiliser le même choix de vue pour le sprite et le point de départ du projectile. Le repère de lâcher est recalculé dans les deux diagonales à partir du centre de la pierre sur la cuillère. L’arc parabolique décrit plus haut correspond à cet essai historique. Pour les planches courantes, appliquer les paramètres ci-dessous.

Vérification sur la mission 94 en v0.220. Quatre diagonales à ×1 et deux à ×2, avec la garde, le changement de diagonale sur E1, la pause et deux cibles secondaires par tir. Les 48 poses diagonales sont cadrées et chaque planche retrouve sa propre garde exactement. Le validateur passe sur 35 dossiers et la bibliothèque passe 176 contrôles. La correction attend l’avis du porteur.

### Sens du coup de bras

Le porteur accueille favorablement le châssis et relève une impression de contresens au lancer à gauche. La reprise sépare le recul de préparation, une courte tenue, puis le mouvement chargé vers la cible. À 0,50 s, la pierre poursuit ce dernier mouvement au moment où la cuillère se vide. Les trois gardes sont identiques à celles du lot précédent.

Dans `lacher.json`, `center_from_foot` donne l’origine par planche et `launch_slope` le rapport entre le mouvement vertical et l’avancée horizontale de la pierre. Partir de cette origine, puis utiliser une courbe quadratique jusqu’à la cible. Le point de contrôle est placé à `flight_control_fraction` (0,44) de l’écart horizontal jusqu’à la cible. Sa composante verticale depuis l’origine vaut la valeur absolue de ce déplacement horizontal multipliée par la pente de la planche. L’effet de zone se joue à l’arrivée.

Sur six tirs en mission 94, vérification de la tangente au départ, de l’avancée horizontale à 16 intervalles et de l’arrivée à l’impact. Les quatre diagonales sont couvertes à ×1 et deux à ×2. Les 72 poses retrouvent exactement leur garde respective. Validateur à zéro problème sur 35 dossiers et 176 contrôles de bibliothèque réussis. [Avant et après sur E4](essais/gestes_combat/catapulte_gobeline/Catapulte_gobeline_sens_du_lancer.gif).
