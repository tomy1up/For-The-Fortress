# Prototype v0.260 — Héroïque : les bonus héroïques

Lot 4 du cadrage des difficultés. Liste, valeurs et règle d'apparition validées par le porteur le 27 novembre 2026 ; réglages de prototype à confirmer en jeu.

## Ce qui change

- En **Héroïque**, aux choix des **vagues 4 et 8**, la troisième carte est un **bonus héroïque** : au plus deux par mission. Les choix des vagues 2 et 6 ne changent pas.
- **Quinze bonus héroïques**, débloqués au fil de la campagne (deux au chapitre 1, puis un par chapitre jusqu'au 14) : Chasseur de champions, Prime des champions, Forge ardente, Sceau des anciens, Hiver éternel, Charges en chaîne, Héros du rempart, Doctrine unique, Supériorité numérique, Perce-armures, Muraille vivante, Pacte de sang, Arsenal royal, Fléau, Dernier carré.
- Seuls les bonus utiles à votre armée sont proposés (par exemple, le Sceau des anciens seulement s'il y a des rappels). La relance en tire un autre.
- Les cartes héroïques ont leur rareté, « Héroïque », en ambre.
- Le Normal ne change pas.

**Attention :** l'Héroïque n'est toujours pas calibré (lot 5). Mesurés, ces bonus valent en moyenne un bon bonus rare, moins que les épiques : voir la fiche.

Fiche : `design/Bonus_heroiques_v0260.md`.

## Contrôles

- Régression complète : 154 suites sur 154, 247 677 contrôles Godot, 17 tests Python (nouvelle suite `test_heroic_bonuses.gd`, 629 contrôles). Ensuite, `test_bonus_preview.gd` a été renforcé (aperçu de tous les bonus cumulés contre les quatre familles lourdes, Chasseur de champions mis à part) et relancé seul : 54 184 contrôles.
- Les offres du Normal et des anciens rapports sont inchangées : les tirages ordinaires ne voient jamais les bonus héroïques.
- Paquet Windows vérifié : 1 050 cas et 672 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées, depuis les sources et le jeu exporté : offres avec une carte héroïque (Héros du rempart, Pacte de sang), rareté « Héroïque » en ambre et aperçu des défenseurs concernés.
- Notes des bonus héroïques et mesure de l'Héroïque : voir la fiche.
