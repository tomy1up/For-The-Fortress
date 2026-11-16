# Boutique · Arbalète lourde

Visuel du type 24 (`alliance.heavycrossbow`) approuvé par le porteur le 14 novembre 2026 (`a19a744`). L’arbalétrière naine est à genou, en armure vert patiné, avec une protection d’avant-bras ivoire. Elle porte son arbalète près du corps. La posture basse la distingue de l’Arbalétrier nain. L’arbalète reste portée afin de la distinguer des pièces de siège.

[Comparatif sur le plateau](essais/boutique_guetteurs/Arbalete_lourde_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `arbalete_lourde_v001.png` | `Rect2(0,0,1329,1119)` | `(565,1119)` | 55 px | `(31.5,-19.5)` |

Le portrait, le déblocage, le recrutement et le premier tir ont été vérifiés sur une copie v0.197. Les 95 contrôles d’illustrations passent. Le sprite est fixe et le carreau reprend le rendu de la famille.

Pour l’animation, la naine cale son appui avant, relève légèrement l’arbalète et encaisse le départ du carreau à l’épaule avant de revenir en garde. Accorder le départ visible du carreau avec la pose de lâcher. Le projectile ne doit pas suggérer un effet de zone ou une traversée des ennemis. Le multiplicateur est de ×1,8 contre les lourds et ×0,5 contre les petits.

## Tir à genou et recul

L’arbalétrière cale la crosse, vise et encaisse le recul dans l’épaule. Le genou et la botte avant gardent leur appui. Le carreau quitte le fût, la corde se détend, puis l’arme redescend avant le retour en garde.

[Capture du tir sur le nouveau tracé de la mission 94](essais/gestes_combat/arbalete_lourde/Arbalete_lourde_en_jeu.gif)

Type 24, `defender.alliance.heavycrossbow`. Garde et six inclinaisons de tir (−24°, −12°, 0°, +12°, +24° et +36°), à 28 poses sur 1,12 s par inclinaison. Dernière pose avec carreau à 0,40 s, départ à 0,44 s sur la première pose à fût vide. `lachers.json` donne l’emplacement de la pointe du carreau depuis le pied. Choisir l’inclinaison la plus proche du trajet depuis sa propre pointe parmi les plans qui visent vers l’avant. Retourner ensemble la pose et le repère. Aligner la pointe du carreau affiché en vol sur ce repère et garder le trajet rectiligne jusqu’à l’impact. Si l’ennemi est déjà derrière le repère projeté, jouer l’impact seul. Le type 24 conserve un seul impact et ses multiplicateurs contre les lourds et les petits.

Copie v0.226, mission 94. Six tirs comptés à ×1 et ×2, dont cinq en vol et un à bout portant. Les deux scénarios initiaux utilisent la pose descendante à droite et la pose neutre à gauche. Les autres inclinaisons sont contrôlées sur planche. Les semelles sont identiques et le cadrage est vérifié sur les 168 poses. Position du carreau contrôlée en 17 points par vol et pose figée en pause. Le validateur relève 40 dossiers et zéro problème. Les 181 contrôles de la bibliothèque passent. Le moteur signale encore des objets en mémoire à la fermeture de l’atelier. Le porteur a validé le geste le 16 novembre 2026. Le lot `aa7462b` est prêt à intégrer.
