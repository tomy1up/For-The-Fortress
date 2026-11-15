# Orientation par défaut des défenseurs

**Décision du porteur, 15 novembre 2026.** À leur placement et entre les vagues, les défenseurs font face au tronçon de route le plus proche. Pendant la vague, un défenseur sans cible commence dans cette direction. La direction de la cible prend ensuite la priorité pour le geste et le projectile. Le côté du dernier tir reste stable pendant la vague pour éviter les allers-retours entre les attaques.

L’essai prend le point le plus proche de l’emplacement sur chaque segment de chaque route, en coordonnées du plateau. Il choisit la route par distance au sol et l’orientation gauche ou droite par projection à l’écran. Les segments à distance égale conservent l’ordre de la carte. Un point exactement à la verticale ou une route absente garde la direction de repli existante. Le calcul est limité à l’affichage.

[Avant-après à taille native](essais/orientation_defenseurs/Defenseurs_face_a_la_route.png)

| Vérification sur copie v0.216 | E1 | E2 | E3 | E4 | E5 | E6 |
| --- | --- | --- | --- | --- | --- | --- |
| Le Gué, mission 1, une route | Gauche | Droite | Gauche | Droite | Droite | Gauche |
| La Grande Salle, mission 94, trois routes | Droite | Gauche | Gauche | Gauche | Gauche | Droite |

Les six emplacements ont été contrôlés dans les deux factions sur chaque carte, soit 24 cas. En préparation, la direction du dernier tir cède la place à la route. En combat, elle reste prioritaire. La régression de présentation des défenseurs passe avec 63 contrôles. L’essai est local. Claude assure le branchement dans le jeu.
