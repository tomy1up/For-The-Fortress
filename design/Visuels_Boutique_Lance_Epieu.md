# Boutique · Lance-épieu orc

Visuel du type 20 (`horde.spearman`) validé par le porteur le 14 novembre 2026. L’orc tient son épieu horizontalement à deux mains, en garde basse. La carrure et l’épaulière rouge à bande écrue le distinguent du piquier et du javelinier.

[Comparatif sur le plateau](essais/boutique_guetteurs/Lance_epieu_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur |
| --- | --- | --- | ---: |
| `lance_epieu_orc_v001.png` | `Rect2(0,0,1424,977)` | `(602,977)` | 51 px |

Portrait, déblocage, recrutement et première attaque vérifiés sur une copie v0.197. Les 75 contrôles d’illustrations passent. La pose est fixe. Le rendu d’attaque de la copie reste celui du lanceur de haches. Le branchement doit prévoir un coup d’épieu à courte portée en gardant les données de combat.

## Estoc à deux mains

L’orc ramène l’épieu près du corps, avance le buste et pousse le manche des deux mains. La ceinture accompagne le mouvement et les semelles gardent le même appui. Les 20 poses de chaque attaque durent 0,80 s et commencent et finissent sur la même garde.

[Voir le coup dans les deux sens à ×1 et ×2](essais/gestes_combat/lance_epieu_orc/Lance_epieu_orc_en_jeu.gif)

Type 20 (`defender.horde.spearman`). Le dossier `design/essais/gestes_combat/lance_epieu_orc/` contient une garde, sept attaques et `contact.json`. Les variantes incluent le geste neutre, deux inclinaisons et quatre adaptations à la distance. Choisir la planche dont la pointe au contact est la plus proche du point d’impact projeté. Les positions de pointe sont relatives au pied. Retourner le signe horizontal pour les attaques à gauche. Les quatre nouveaux noms à reconnaître sont `attack_close`, `attack_far`, `attack_close_up` et `attack_close_down`.

L’épieu est dans les planches. À 0,28 s, dessiner un seul éclair de contact à la pointe de la planche retenue, avec son angle. Les chiffres de combat et l’instant de résolution des dégâts restent ceux du modèle.

Sur une copie v0.223 de la mission 94, contrôle de six coups donnés à gauche et à droite à ×1 et ×2. À ×2, la distance et la hauteur de l’ennemi changent entre deux coups. La capture montre le choix de l’estoc adapté et la pause a été contrôlée. Les 140 poses sont cadrées et les semelles fixes. Le validateur passe sur 35 dossiers et la bibliothèque passe 176 contrôles. La copie de capture signale des ressources encore en mémoire à la fermeture. Le porteur valide le geste du lot `a151adb`.
