# Un attaquant par chapitre pair, étape 3 (v0.246)

**Statut.** Décisions du porteur du 23 novembre 2026 : les cinq unités et leurs capacités (« ça me paraît tout bon », puis « Coureur de tempête » pour le Scorpion), et trois baisses sous la courbe (« Oui, baisse-les »). Les statistiques, les compositions de vagues et les coefficients de PV restent des réglages de prototype à confirmer en partie réelle (MAJ-98 et MAJ-99).

## Les cinq attaquants

Tous sont neutres, identiques dans les deux factions, et n'apparaissent que dans leur chapitre.

| Biome | Chapitre | Attaquant | PV | Vitesse | Forteresse | Or | Capacité | Dès la vague |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ardoises | 4 | Bouquetin des crêtes | 70 | 0,9 | −2 | 6 | Sous 50 % de ses PV, charge une fois, 70 % plus vite pendant 2 s | 3 |
| Volcan | 8 | Golem de magma | 150 | 0,6 | −2 | 8 | À sa mort, éclate en deux Braises | 4 |
| Volcan | 8 | Braise | 15 | 1,4 | −1 | 1 | Créée par l'éclatement, n'éclate pas | 4 |
| Désert | 12 | Scorpion des dunes | 90 | 0,85 | −2 | 6 | Deux fois plus rapide pendant la Tempête de sable | 3 |
| Mines | 14 | Taupe des galeries | 60 | 1 | −1 | 5 | Une case sur trois sous terre, intouchable | 3 |
| Côtes | 18 | Crabe pilleur | 100 | 0,8 | −1 | 8 | Vole 20 or en atteignant la forteresse | 4 |

Le porteur a écarté la carapace d'abord proposée pour le Scorpion : elle était trop complexe à mettre en avant et à expliquer.

## Précisions de règle

- **Taupe** : sur chaque tranche de trois cases, deux en surface puis une sous terre. Elle n'y est ni visée, ni touchée par une explosion ou un rebond. Les dégâts sur la durée déjà posés continuent. La dernière case avant la forteresse est toujours en surface.
- **Golem** : les Braises repartent de sa position, sur sa route, et comptent dans les ennemis de la vague.
- **Crabe** : le trésor ne devient jamais négatif. La Herse (R-47), qui annule le premier passage de la vague, empêche aussi le vol.
- **Scorpion** : un scorpion apparu pendant une rafale court aussi jusqu'à la fin de celle-ci.

## Recalibrage

Méthode : 30 compositions, tirages de bonus 7, 8 et 9, première offre, vers 55 % de meilleure marge (accepté de 47 à 63 %), sans descendre sous la courbe de base. Les missions qu'une armée de référence perd sont ensuite abaissées par pas de 3 points.

| Chapitre | Alliance | Horde | Réglages dans la cible |
| --- | --- | --- | --- |
| 4 Ardoises | 61,5 % | 70,5 % | 14 / 20 |
| 8 Volcan | 59,4 % | 59,3 % | 17 / 20 |
| 12 Désert | 54,1 % | 57,2 % | 20 / 20 |
| 14 Mines | 54,2 % | 57,7 % | 19 / 20 |
| 18 Côtes | 61,3 % | 58,2 % | 16 / 20 |

**Résultat : 86 réglages sur 100 dans la cible de 40 à 70 %, aucun en dessous. Sur toute la campagne : 371 sur 398, et 27 au-dessus de 70 %.**

Au-dessus de 70 % sur ces chapitres : Alliance 33, 39, 72, 79, 173, 178, 180 ; Horde 34, 37, 38, 39, 79, 131, 175. Quelques points de PV de plus y font perdre une armée de référence ou font chuter brutalement la marge. Les missions 37, 38 et 39 de la Horde sont les plus faciles (90 à 100 %).

Sous la courbe de base (décisions du porteur, 23 novembre 2026), 26 réglages :

- Alliance à 98 % : 23, 41, 60, 63, 65, 127, 143, 148. À 97 % : 75.
- Alliance à 96 % : 46, 64, 66, 90, 93, 96, 97, 113, 170, 191.
- Alliance à 94 % : 68, 147, 180. À 92 % : 69, 118.
- Horde à 98 % : 68. À 96 % : 66.

## Limites

- Mesure sur des stratégies fixes avec la première offre de bonus : le ressenti en partie réelle reste à confirmer (O-017, O-029).
- Les six silhouettes sont provisoires : des visuels existants teintés, en attendant les dessins de Codex.

Données et scripts : `design/essais/equilibre_bonus/v246/`.
