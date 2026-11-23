# Un affixe par biome, étape 2 (v0.245)

**Statut.** Décisions du porteur du 23 novembre 2026 : création des cinq affixes (« Oui, code-les »), rythme (« Oui, ce rythme »), baisses sous la courbe (« Oui, baisse-les »). L'ampleur des effets et les coefficients de PV restent des réglages de prototype à confirmer en partie réelle (MAJ-94 à MAJ-96).

## Les dix affixes

| Biome | Chapitres | Affixe | Rythme | Effet |
| --- | --- | --- | --- | --- |
| Gué | 1-2 (dès la mission 2) | Crue | 4 s toutes les 12 s | Les ennemis avancent 10 % plus vite |
| Ardoises | 3-4 | Vents contraires | Permanent | Les défenseurs attaquent 10 % moins souvent |
| Marais | 5-6 | Vapeurs toxiques | 4 s toutes les 12 s | Les défenseurs infligent 20 % de dégâts en moins |
| Terres volcaniques | 7-8 | Éruptions | 4 s toutes les 12 s | Un défenseur est désactivé |
| Citadelle | 9-10 | Cor d'alarme | Toutes les 15 s | Bouclier de 10 % des PV maximum sur les ennemis présents, sans cumul |
| Désert | 11-12 | Tempête de sable | 4 s toutes les 12 s | Portée des défenseurs réduite de 25 % |
| Mines | 13-14 | Éboulement | 5 s toutes les 12 s | Une entrée est bloquée |
| Îles flottantes | 15-16 | Courants ascendants | Toutes les 15 s | Les ennemis présents bondissent d'une case, jamais sur la forteresse |
| Côtes | 17-18 | Brume marine | 4 s toutes les 12 s | Or par élimination réduit de 30 % |
| Nécropole | 19-20 | Drain d'âmes | 4 s toutes les 12 s | Chaque ennemi éliminé soigne de 10 % de leurs PV maximum les ennemis blessés à moins de 1,5 case, boss exclus |

Les affixes temporisés sont annoncés 3 s avant. Le premier déclenchement a lieu à 12 ou 15 s de combat, puis le compteur se poursuit pendant la vague. La mission 1 reste sans affixe, pour apprendre le jeu.

## Pourquoi ce rythme

La mesure de 3 816 vagues donne une durée de 44 à 71 s (10e à 90e centile). Avec les anciens rythmes de 14 à 22 s, un affixe se déclenchait environ une fois avant la dernière apparition, et la Brume marine manquait 20 % des vagues des Côtes. Le porteur a validé le rythme ci-dessus, pour les nouveaux comme pour les anciens affixes.

## Recalibrage

Méthode : 30 compositions, tirages de bonus 7, 8 et 9, première offre. Pour chaque mission et chaque faction, le coefficient de PV est cherché par dichotomie vers 55 % de meilleure marge (accepté de 47 à 63 %), sans descendre sous la courbe de base. Les missions qu'une politique de référence des suites perd sont ensuite abaissées par pas de 3 points.

| Biome | Alliance | Horde | Réglages dans la cible |
| --- | --- | --- | --- |
| Gué (missions 2-20) | 57,5 % | 63,0 % | 32 / 38 |
| Ardoises | 56,0 % | 62,8 % | 32 / 40 |
| Marais | 52,6 % | 57,4 % | 38 / 40 |
| Terres volcaniques | 54,7 % | 56,8 % | 38 / 40 |
| Citadelle | 54,4 % | 54,1 % | 40 / 40 |
| Désert | 56,4 % | 54,0 % | 39 / 40 |
| Mines | 55,4 % | 54,1 % | 40 / 40 |
| Îles flottantes | 54,7 % | 54,5 % | 40 / 40 |
| Côtes | 53,2 % | 54,0 % | 40 / 40 |
| Nécropole | 54,7 % | 55,3 % | 40 / 40 |

**Résultat : 379 réglages sur 398 dans la cible de 40 à 70 %, aucun en dessous.** Meilleure marge moyenne : 54,9 % (Alliance) et 56,6 % (Horde).

Au-dessus de 70 % : Alliance 2, 3, 16, 23, 33, 105 ; Horde 2, 3, 11, 22, 23, 32, 33, 38, 39, 41, 44, 64, 72. Quelques points de PV de plus y font perdre une politique de référence ou font chuter brutalement la marge (Horde 11 : 97 % à 104, 37 % à 105).

Sous la courbe de base (décisions du porteur, 23 novembre 2026), 27 réglages :

- Alliance à 98 % : 23, 41, 60, 63, 65, 113, 127, 143, 148.
- Alliance à 96 % : 33, 46, 64, 66, 75, 90, 93, 96, 97, 170, 191.
- Alliance à 94 % : 32, 68, 147. Alliance à 92 % : 69.
- Horde à 98 % : 68. Horde à 96 % : 32, 66.

## Limites

- Mesure sur des stratégies fixes avec la première offre de bonus : le ressenti en partie réelle reste à confirmer (O-017).
- Les effets des cinq nouveaux affixes sont dessinés par le code en attendant l'habillage de Codex. Le trait de soin du Drain d'âmes est encore très discret.
- Le Drain d'âmes dépend du regroupement des ennemis : avec l'armée de référence (missions 181 à 200, tirage 7), il soigne au moins une fois dans 101 vagues sur 200 pour l'Alliance et 167 sur 200 pour la Horde.
- Les chapitres pairs recevront encore un attaquant à l'étape 3 pour cinq biomes : leurs missions devront alors être recalibrées.

Données et scripts : `design/essais/equilibre_bonus/v245/`.
