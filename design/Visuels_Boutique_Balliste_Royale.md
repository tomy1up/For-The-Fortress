# Boutique · Balliste royale

Visuel fixe du type 38 (`alliance.ballista`) validé par le porteur le 14 novembre 2026. Un ingénieur gnome en lunettes rondes actionne la balliste. La machine repose sur un bâti fixe, porte une plaque bleue à couronne et se reconnaît à son large arc horizontal. Dessin réalisé avec le générateur intégré à partir du comparatif de l’Arbalète lourde pour les contours et les aplats.

![Balliste royale et armes de l’Alliance sur le plateau](essais/boutique_guetteurs/Balliste_royale_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `balliste_royale_v001.png` | `Rect2(0,0,1429,875)` | `(729,875)` | 51 px | `(40,-31)` |

La Balliste touche une cible. Ses dégâts sont multipliés par 1,8 au dernier tiers du trajet et par 0,4 au premier tiers. Sur copie v0.200, un carreau de siège a été testé à la place du carreau de famille. Le portrait, le déblocage sur profil d’essai, le recrutement et le premier tir ont été vérifiés. Les 136 contrôles d’illustrations et les 49 contrôles du quatrième lot passent.

Prévoir un mouvement bref de l’arc et de la corde au départ du carreau, puis une pose vide et un rechargement par le servant. Le carreau reste visible en permanence dans le sprite fixe. Le projectile d’essai et le sprite sont à associer lors de l’intégration.

## Recul et réarmement

Le servant se cale derrière la manivelle, relâche la corde et reprend un carreau. À 0,32 s, le rail est vide et le carreau de siège part depuis le repère de la glissière. Six dessins intermédiaires ajoutés à la demande du porteur dans la mise en tension, le recul et le réarmement. La planche passe de huit à quatorze poses distinctes et de 24 à 36 images sur 0,96 s. La pose de départ est l’image 12 à partir de zéro. Les pieds du châssis restent ancrés au sol. La silhouette est calculée sur les 51 px de la garde. Après le retour du porteur, les deux poses de recul et de corde avancée conservent les verres bleus et montrent une seule corde continue entre les deux extrémités de l’arc.

[Essai en jeu](essais/gestes_combat/balliste_royale/Balliste_royale_en_jeu.gif) · [Planche corrigée](essais/gestes_combat/balliste_royale/Planche_balliste_royale.png)

Le fichier lacher.json donne le départ depuis le pied. Dans l’essai, le repère se retourne avec la pose. Le carreau existant suit un segment direct. Quatre tirs en mission 94 sur copie v0.235, dans les deux sens à ×1 et ×2 et en pause. Essai cadré sur des cibles en visée quasi horizontale. Les multiplicateurs au début, au milieu et à la fin du trajet passent au contrôle. Validateur à zéro problème sur 49 dossiers, 190 contrôles d’animation, 77 des effets et 28 de boutique réussis. Le contrôle de la bibliothèque confirme le passage de l’image 11 à l’image 12 à 0,32 s. La fluidité de la planche enrichie attend l’avis du porteur.

Consignes au générateur intégré. Reprendre l’arc bleu et or, les pieds fixes, la plaque à couronne, les lunettes rondes bleues et la silhouette du servant. Redessiner l’avancée de la corde, le rail vide, le réarmement et le retour en garde. Garder un seul tracé continu pour la corde tendue entre les extrémités.
