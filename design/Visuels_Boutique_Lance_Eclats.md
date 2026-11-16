# Boutique · Lance-éclats gobelin

Visuel du type 18 (`horde.shardthrower`) validé par le porteur le 14 novembre 2026. La chevelure noire, le manteau prune et l’éclat de cristal violet tenu en l’air distinguent le Lance-éclats du Sapeur et du Grenadier sur le plateau.

[Comparatif des trois gobelins](essais/boutique_guetteurs/Lance_eclats_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | ---: | --- |
| `lance_eclats_gobelin_v001.png` | `Rect2(0,0,1026,1111)` | `(560,1111)` | 53 px | `(-22.0,-43.0)` |

Portrait, déblocage, recrutement et premier tir vérifiés sur copie v0.197. Les 65 contrôles d’illustrations passent. Le sprite est fixe et la copie utilise encore le projectile de sa famille. À l’intégration, afficher un éclat de cristal en conservant les règles et les valeurs de combat.

## Lancer du cristal

Essai sur une copie de la v0.219, soumis à l’avis du porteur. Le geste part du poignet et de l’épaule. Les bottes restent en appui et le retour à la garde reprend exactement son dessin. La main tient l’éclat jusqu’à la neuvième pose (indice 8), puis l’ouvre pendant le suivi du geste.

[Voir les lancers en jeu, à taille native](essais/gestes_combat/lance_eclats_gobelin/Lance_eclats_jeu.gif)

Les six planches de `defender.horde.shardthrower` sont dans [le dossier d’essai](essais/gestes_combat/lance_eclats_gobelin/). Chaque attaque a 16 poses sur 0,20 s. Le lâcher à 0,1125 s coïncide avec la première pose à main vide. `lachers.json` fournit le repère de pointe depuis le pied pour −36°, −12°, 0°, +12° et +36°, ainsi que l’ancrage et l’échelle de `eclat.png`. Pour le type 18, relier la pointe du cristal à l’impact par une droite et orienter le sprite dans cet axe durant tout le vol. Choisir la planche qui minimise l’écart angulaire entre son axe et cette droite, en recalculant l’origine pour chaque angle candidat. Le jeu doit reconnaître les deux variantes à 36°.

Vérification sur la mission 94, emplacement E1 à droite (+36°) et E2 à gauche (0°). Trois départs à ×1 et cinq à ×2 sur chaque emplacement. La position du cristal a été comparée à 17 points de la droite pour chacun de ces tirs. L’image reste fixe en pause pendant le geste. Les cinq planches ont été contrôlées pour le cadrage et le retour à la garde. Le validateur a vérifié 33 dossiers sans problème et la régression a passé 174 contrôles. La copie de test émet un avertissement de nettoyage de ressources à la fermeture. Le branchement du projectile et du délai concerne le rendu. Les règles et chiffres de combat restent ceux du jeu.

[Comparatif avant et après, à droite et à ×1](essais/gestes_combat/lance_eclats_gobelin/Lance_eclats_virage_avant_apres.gif). Dans le tir rapproché signalé, l’ancienne courbe finissait à 85°. Le cristal corrigé suit un angle constant de 45° de la main à l’impact.
