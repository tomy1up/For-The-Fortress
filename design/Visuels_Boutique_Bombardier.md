# Boutique · Bombardier nain

Visuel et nom « Bombardier nain » approuvés par le porteur le 14 novembre 2026. Le personnage est un artilleur à barbe blanche et manteau ocre. Il se tient derrière la bombarde montée sur un affût en bois. La roue et la bouche de la pièce permettent de reconnaître la silhouette à taille réelle.

[Comparaison sur le plateau](essais/boutique_guetteurs/Bombarde_sur_le_plateau.jpg) · [Carte en boutique](essais/boutique_guetteurs/Boutique_Bombarde.jpg)

| Type | Fichier portrait et plateau | Cadre | Pied | Hauteur | Origine du tir |
| --- | --- | --- | --- | ---: | --- |
| 13 | `bombarde_naine_v001.png` | `Rect2(0,0,1313,1001)` | `(654,1001)` | 58 | `(31.25,-39.25)` |

Portrait, déblocage, recrutement et premier tir vérifiés sur une copie v0.197. Le libellé « Bombardier nain » a été vérifié en boutique sur cette copie. Les 50 contrôles d’illustrations passent. Le projectile de cette copie utilise le rendu du mage. Le nouveau rendu du tir, le libellé et l’illustration sont à intégrer par Claude Code. L’identifiant `alliance.bombard` et les données de combat sont conservés.

## Tir, recul et remise en batterie

Le Bombardier se penche vers l’affût pour le caler. Au départ du coup, le canon recule et se cabre. La roue tourne avec le recul et le nain absorbe le mouvement du buste, bottes en appui. La main reste au contact de la poignée. Le canon et le nain regagnent leur position initiale après le tir. Les 20 poses tiennent sur 0,64 s. La première et la dernière image sont identiques à la garde.

[À taille native ×1](essais/gestes_combat/bombardier_nain/Bombardier_tir_x1.gif) · [À taille native ×2](essais/gestes_combat/bombardier_nain/Bombardier_tir_x2.gif) · [Vue agrandie](essais/gestes_combat/bombardier_nain/Bombardier_tir_agrandi.gif)

Dans l’essai, le boulet et le bref éclat apparaissent à 0,160 s, depuis la bouche du canon. Ancrage relatif aux pieds (±30,312 ; −38,905) en pixels de jeu, déclaré par `muzzle`. La tangente de départ monte à 26° par rapport à l’horizontale, puis la trajectoire en cloche rejoint le point d’impact. Les effets temporaires de poudre et de trajectoire sont dessinés dans la copie d’essai. Le délai concerne le rendu du tir et de l’impact. La cadence et les dégâts restent ceux du modèle.

La copie v0.216 vérifie un Bombardier recruté sur la mission 94, en E1 et E2, avec un Capitaine orc comme cible de contrôle. Premier tir dans chaque sens à ×1, ×2 et à temps figé. Le départ suit l’angle du canon à moins d’un degré dans les cas contrôlés. Les 20 poses sont cadrées. Validateur : 30 dossiers, 0 problème. Bibliothèque : 171 contrôles. Le 15 novembre, le porteur juge le rendu satisfaisant. Le lot `4ef598e` est retenu pour intégration. [Planches de garde et de tir](essais/gestes_combat/bombardier_nain/defender.alliance.bombard/).
