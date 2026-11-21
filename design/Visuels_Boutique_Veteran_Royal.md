# Boutique · Vétéran royal

Proposition masculine retenue pour le type 40 (`alliance.veteran`) après retour favorable du porteur le 14 novembre 2026. Les cheveux gris, l’armure rayée, le chevron doré et la cape de campagne marquent son expérience. Sa posture droite et son arbalète courte se distinguent du Piquier et de l’Arbalétrier nain au même emplacement. Dessin réalisé avec le générateur intégré, avec le Piquier comme référence pour les aplats et les contours.

![Vétéran royal comparé aux défenseurs de l’Alliance](essais/boutique_guetteurs/Veteran_royal_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du carreau d’essai |
| --- | --- | --- | ---: | --- |
| `veteran_royal_v001.png` | `Rect2(0,0,1022,1496)` | `(460,1496)` | 59 px | `(20.5,-34.75)` |

Sur une copie v0.201, le portrait, le déblocage sur profil d’essai, le recrutement et le premier tir ont été vérifiés. Le carreau de famille part de l’arbalète courte. Les 161 contrôles d’illustrations et les 49 contrôles du quatrième lot passent. Le rôle existant lui donne +16 % de dégâts par vague survivée depuis son achat, jusqu’à +90 %.

Pour l’animation, le Vétéran relève l’arbalète, stabilise son appui avant et laisse la corde partir. Faire disparaître le carreau du sprite à cet instant. L’animation du tir et du rechargement reste à réaliser.

## Tir et réarmement

Le Vétéran relève son arbalète, vise puis absorbe le recul avant de réarmer. Le carreau quitte le sprite à 0,36 s, image 18 à partir de zéro. Douze dessins distincts sur 48 images et 0,96 s. La silhouette reste à 66 px et les semelles restent calées. Une pièce bleue près de l’arrière de la glissière reste visible après le départ du carreau. La retouche ciblée de ce détail a été refusée par le filtre de génération de l’outil.

[Essai en jeu](essais/gestes_combat/veteran_royal/Veteran_royal_en_jeu.gif) · [Planche des douze poses](essais/gestes_combat/veteran_royal/Planche_veteran_royal.png)

Le fichier lacher.json donne le repère sur la glissière. Il suit le retournement du sprite. Le carreau de famille suit un trajet rectiligne. Six tirs contrôlés en mission 94 sur copie v0.235, visées presque horizontales à gauche et à droite, à ×1 et ×2 avec pause. Le bonus par vague et le plafond de +90 % passent au contrôle. Validateur à zéro problème sur 49 dossiers, 190 contrôles d’animation, 77 des effets d’unités et 28 de boutique réussis. Le banc termine avec son marqueur de réussite, puis Godot signale une ressource encore chargée à la fermeture. Avis du porteur attendu.

Consignes au générateur intégré. Garder les cheveux gris, le visage marqué, la cape bordeaux, le chevron et les appuis. Dessiner le lever de l’arbalète courte, la prise de visée, le départ, le retour du bras et la recharge. Conserver la continuité des deux bras et une main d’appui sous l’arbalète.
