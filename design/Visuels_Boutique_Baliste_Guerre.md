# Boutique · Baliste de guerre

Proposition du type 43 (`horde.warballista`) bien accueillie par le porteur le 14 novembre 2026. Le servant squelette reprend le crâne d’ivoire, les yeux ambrés et les tons prune de l’infanterie morte-vivante. Le bâti bas en bois sombre et la toile bordeaux distinguent la pièce de la Balliste royale et de la Catapulte. Dessin réalisé avec le générateur intégré à partir du Garde noir pour le servant et de la Balliste royale pour les aplats et le cadrage.

![Comparaison des pièces de siège sur le plateau](essais/boutique_guetteurs/Baliste_guerre_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du carreau d’essai |
| --- | --- | --- | ---: | --- |
| `baliste_guerre_v001.png` | `Rect2(0,0,1583,820)` | `(791,820)` | 44 px | `(41.25,-27.5)` |

Copie v0.201 : portrait, déblocage sur profil d’essai, recrutement et premier tir vérifiés. 171 contrôles d’illustrations et 49 contrôles du quatrième lot passent. L’essai représente un carreau de siège sur une seule cible. Le catalogue applique ×1,8 au dernier tiers du trajet et ×0,4 au premier tiers.

Pour l’animation, prévoir un recul bref, une pose vide après le départ et un rechargement par le servant. Le carreau reste visible dans le sprite fixe.

## Tir et réarmement

Le cycle part d’un dessin fixe du bâti et du servant. L’avant-bras s’anime localement, une seule corde se détend puis revient en tension. Le rail est vide sur l’image 20 à partir de zéro, à 0,32 s. Un nouveau carreau revient sur la glissière pendant le réarmement. L’animation compte 60 images sur 0,96 s, dont 59 distinctes. La garde mesure 44 px. Trois zones couvrant le crâne, les bottes et le bas du châssis sont identiques sur toutes les images.

[Essai en jeu](essais/gestes_combat/baliste_guerre/Baliste_guerre_en_jeu.gif) · [Images clés](essais/gestes_combat/baliste_guerre/Planche_baliste_guerre.png)

Le carreau de siège existant part en ligne droite sur l’essai. Le repère de lacher.json suit le retournement. Quatre tirs contrôlés en mission 94 sur copie v0.236, en visée quasi horizontale à gauche et à droite, à ×1 et ×2 avec pause. Le contrôle vérifie la transition entre les images 19 et 20 autour de 0,32 s ainsi que les multiplicateurs selon la progression de la cible. Validateur à zéro problème sur 56 dossiers, 197 contrôles d’animation, 77 des effets et 93 de boutique réussis. L’essai attend l’avis du porteur.

Consignes au générateur intégré. Reprendre le bâti bas, la toile bordeaux et le servant squelette aux yeux ambrés. Fournir un dessin de base au rail vide, avec appuis et mains calés. L’assemblage ajoute les mouvements locaux autour d’un châssis fixe.
