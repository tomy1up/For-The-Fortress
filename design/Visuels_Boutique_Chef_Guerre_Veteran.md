# Boutique · Chef de guerre vétéran

Visuel fixe du type 45 (`horde.warveteran`), accueilli favorablement par le porteur le 14 novembre 2026. La barbe blanche tressée, le manteau bordeaux et la fourrure asymétrique dessinent une silhouette de vétéran. L’illustration a été générée à partir du comparatif du Lanceur de masse, utilisé comme référence pour les contours, les aplats et les proportions. La hache courte et la posture droite distinguent les deux orcs.

![Comparaison au Gué à l’emplacement E2](essais/boutique_guetteurs/Chef_guerre_veteran_comparatif.jpg)

| PNG | Cadre | Pied | Hauteur | Départ du lancer |
| --- | --- | --- | ---: | --- |
| `chef_guerre_veteran_v001.png` | `Rect2(0, 0, 925, 1149)` | `(520, 1149)` | 57 px | `(-22, -40)` |

L’unité lance une hache sur une cible. Elle gagne 16 % de dégâts par vague survécue depuis son achat, jusqu’à 90 %. Sur une copie v0.202, essai du déblocage après 180 missions, de l’achat, de la sélection, du recrutement et du premier tir avec la hache de famille. Le bonus au recrutement est nul. Les 186 contrôles d’illustrations et les 49 contrôles du quatrième lot passent.

Le sprite est fixe. Au prochain passage sur l’animation, faire accompagner le lancer par l’épaule et ouvrir la main au départ de la hache. Le panneau de combat de la copie d’essai affiche « Rebond : 0 × 0 max. ». Préférer une indication du bonus acquis au fil des vagues.

## Lancer de la hache

Le Chef de guerre lève la hache directement depuis sa garde. Le temps pris par l’abaissement initial est redistribué au passage de la main au-dessus du front. Après la poussée, la main se replie plus progressivement vers la ceinture. La reprise de la hache et sa remontée vers la garde passent par des positions intermédiaires. Les 28 premières images, jusqu’à la poussée main ouverte, sont identiques au lot fff2f7c. Le lot reprend les dessins précédents et utilise des intermédiaires calculés avec [RIFE](https://github.com/nihui/rife-ncnn-vulkan) puis corrigés aux passages sensibles. Quatre poses supplémentaires répartissent les principaux écarts du retour entre le repli du coude, la reprise à la ceinture et la remontée en garde. La planche comporte 64 images dont 63 distinctes, sur 64/60 s. Les cellules passent à 128 × 166 px par recadrage des marges transparentes, avec un ancrage compensé pour conserver l’échelle et la position du sprite. Le lâcher reste à 0,40 s, au passage des index 23 à 24.

[Essai en jeu, GIF à cadence fixe](essais/gestes_combat/chef_guerre_veteran/Chef_guerre_veteran_en_jeu.gif) · [Vidéo à 60 ips](essais/gestes_combat/chef_guerre_veteran/Chef_guerre_veteran_60ips.mp4) · [Planche de contrôle du geste](essais/gestes_combat/chef_guerre_veteran/Planche_chef_guerre_veteran.png)

La hache courte à manche bordeaux commence tournée selon la pose de lâcher, puis fait un tour sur un segment rectiligne. Le repère et la texture suivent le retournement. Les réglages correspondent à lacher.json. À bout portant, jouer l’impact seul si la cible est derrière la main. Six tirs en mission 94 sur copie v0.238, dans les deux sens à ×1 et ×2 avec pause. Pour le bonus des vagues, le contrôle vérifie le départ à zéro, le premier palier et le plafond de +90 %. Validateur à zéro problème sur 60 dossiers, 201 contrôles d’animation, 77 des effets d’unités et 135 de boutique réussis. Le porteur a validé le lot 2199f08 pour cette version le 22 novembre 2026.

Les trois intermédiaires ont été préparés avec le générateur d’images intégré à partir des poses de l’essai. Consigne utilisée pour les dessins du passage au-dessus de la tête. Conserver la silhouette et l’armure de l’orc en trois quarts, garder les deux bottes au sol et suivre avec la main fermée la progression du manche au-dessus du front avant de tendre le bras.
