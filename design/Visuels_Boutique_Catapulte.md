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
