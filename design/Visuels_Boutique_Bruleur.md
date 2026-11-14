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
