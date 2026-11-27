# Prototype v0.261 — Héroïque : bonus héroïques renforcés

Renforcement validé par le porteur le 27 novembre 2026, après la mesure de la v0.260. Réglages de prototype à confirmer en jeu.

## Ce qui change

- En **Héroïque**, aux vagues 4 et 8, le choix ordinaire est suivi d'un **second choix entre deux bonus héroïques**. Une partie héroïque compte jusqu'à **six bonus** : quatre ordinaires et deux héroïques. Auparavant, la carte héroïque remplaçait une carte ordinaire.
- **Treize bonus héroïques renforcés** : Chasseur de champions +100 %, Prime des champions +50 or, Sceau des anciens (rappelés −60 % de PV et +15 % de dégâts), Hiver éternel −30 %, Charges en chaîne 40 % et rayon 1,5, Doctrine unique +80 %, Supériorité numérique +15 % par défenseur, Perce-armures +50 % contre les lourds, Muraille vivante 5 arrivées, Pacte de sang +100 %, Arsenal royal −60 %, Fléau +100 %, Dernier carré +150 % au-delà de 75 %. Forge ardente et Héros du rempart ne changent pas.
- « Bonus acquis » compte jusqu'à six bonus en Héroïque ; le récapitulatif les affiche sur deux rangées.
- Le Normal ne change pas.

**Attention :** l'Héroïque n'est toujours pas calibré (lot 5).

Fiche : `design/Bonus_heroiques_v0261.md`.

## Contrôles

- Régression complète : 154 suites sur 154, 264 299 contrôles Godot, 17 tests Python (`test_heroic_bonuses.gd` réécrit, 1 267 contrôles ; `test_bonus_panel_cache.gd` passe à six emplacements de cartes).
- Les rapports de la v0.260 se rejouent avec leur règle (carte de remplacement), leurs valeurs et leurs textes ; le Normal est inchangé.
- Paquet Windows vérifié : 1 050 cas et 672 contrôles de sources, sur un bureau caché (aucune fenêtre sur l'écran du porteur).
- Captures inspectées, depuis les sources et le jeu exporté : second choix héroïque (deux cartes, titre « Choisissez un bonus héroïque ») et récapitulatif à six bonus sur deux rangées. Une première capture a révélé un retour à la ligne en trop dans neuf effets de cartes héroïques et une portée trop proche du bouton ; les deux sont corrigés.
- Notes des bonus renforcés et mesure de l'Héroïque : voir la fiche.
