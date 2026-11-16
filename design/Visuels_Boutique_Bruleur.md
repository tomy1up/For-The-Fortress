# Boutique · Brûleur de cendres

Visuel du type 21 (`horde.cinderburner`) approuvé par le porteur le 14 novembre 2026. La posture basse, le manteau d’obsidienne et le brasero tenu à deux mains distinguent l’unité du Chaman orc et du Pyromancien humain.

[Comparatif des lanceurs de sorts sur le plateau](essais/boutique_guetteurs/Bruleur_comparatif.jpg)

| Portrait et plateau | Cadre | Pied | Hauteur | Origine visuelle du tir |
| --- | --- | --- | ---: | --- |
| `bruleur_cendres_v001.png` | `Rect2(0,0,1176,1246)` | `(420,1246)` | 58 px | `(28.75,-17.5)` |

## Animation d’attaque proposée

1. Les pieds restent ancrés. Les épaules et les coudes ramènent légèrement le brasero vers le corps. Le bol suit la poignée avec un léger retard.
2. Le buste et les deux bras poussent la poignée en avant. Le brasero bascule et une braise magique sort au niveau de la grille à la fin du geste. Les deux mains restent sur la poignée.
3. Le bol revient sous la poignée et le corps retrouve sa garde. À l’impact, la cible reçoit un rappel visuel discret de la brûlure pendant ses dégâts périodiques.

Ce mouvement est une proposition pour la future animation. Synchroniser le départ visible de la braise avec le geste et la direction du sprite. Contrôler la lecture à taille réelle, à ×1 et ×2. Le rôle de l’unité repose sur la brûlure prolongée avec un impact initial faible. L’animation et le projectile réutilisent les événements actuels du combat.

Portrait, déblocage, recrutement et premier tir vérifiés sur une copie v0.197, avec 80 contrôles d’illustrations réussis. Le sprite est fixe et le tir de cette copie affiche encore le projectile du Chaman orc.

## Poussée du brasero

Le Brûleur ramène le brasero vers lui, engage le buste et pousse la poignée à deux mains. Le bol et ses chaînes suivent avec un léger retard, puis reviennent en garde. Les semelles restent fixes dans les 60 poses, et chaque planche rejoint exactement le dessin de garde.

[Voir la poussée et la brûlure à taille réelle](essais/gestes_combat/bruleur_cendres/Bruleur_de_cendres_en_jeu.gif)

Type 21 (`defender.horde.cinderburner`). L’essai fournit la garde et trois inclinaisons d’attaque. Chaque planche dure 0,84 s, avec le départ de la braise à 0,336 s. `lachers.json` fournit le point de grille selon la planche sélectionnée. Utiliser la petite braise déjà dessinée par le moteur et l’impact ambré. Le trait violet du chaman doit être désactivé pour ce type. Si la cible tombe derrière la grille en projection horizontale, le rendu joue l’impact et la brûlure en omettant le vol. Le statut visible commence à l’arrivée de la braise, avec la synchronisation de brûlure déjà en place.

Essai sur la mission 94, copie v0.223. Quatre séquences de première attaque et deux déclenchements suivants contrôlés, des deux côtés à ×1 et ×2. À ×2, l’un des ennemis passe derrière la grille entre deux attaques, ce qui couvre le cas sans vol. L’apparition des flammes à l’impact, les dégâts périodiques existants et la pause ont été vérifiés. Validateur à zéro problème sur 36 dossiers et 177 contrôles de bibliothèque réussis. Le lot attend l’avis du porteur.
