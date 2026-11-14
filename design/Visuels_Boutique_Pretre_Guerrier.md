# Boutique · Prêtre guerrier

Visuel fixe du type 32 (`alliance.priest`) validé par le porteur le 14 novembre 2026. Le livre, le tabard ivoire au soleil et la paume levée identifient le Prêtre. Son portrait et son sprite proviennent du générateur d’images intégré, avec le Piquier comme référence de contours et d’aplats.

![Contrôle du visuel et de l’aura en combat](essais/boutique_guetteurs/Pretre_guerrier_aura.jpg)

| PNG | Cadre | Pied | Hauteur | Origine du tir d’essai |
| --- | --- | --- | ---: | --- |
| `pretre_guerrier_v001.png` | `Rect2(0,0,965,1452)` | `(492,1452)` | 58 px | `(-14,-46)` |

Sur la copie v0.199, le Prêtre lance un éclat doré vers une seule cible. Le repère `aura.png` apparaît au pied des défenseurs dont `guardian_aura(slot) > 0`. Au Portail des Ossements, le Prêtre en E1 donne +40 % de dégâts à l’Archer en E4, à portée de son aura de 3,6 cases. Aucun bonus du Prêtre n’est appliqué à l’Archer éloigné en E2 ni au Prêtre lui-même. Portrait, déblocage, recrutement et premier tir vérifiés. Les 111 contrôles d’illustrations et les 41 contrôles du troisième lot de la boutique passent.

Pour l’animation, préparer l’éclat dans la paume et l’expédier d’un mouvement bref de l’avant-bras. Le livre reste calé contre la hanche. Le repère au sol signale la bénédiction passive entre les tirs. La fiche de combat affiche encore « Explosion autour de la cible » avec zéro cible secondaire. Préférer une mention explicite du tir et de la bénédiction de proximité lors de l’intégration.
