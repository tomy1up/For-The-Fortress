# Finales remesurées : questions O-016 et O-018 closes (24 novembre 2026)

**Statut.** Décision du porteur du 24 novembre 2026 : la question des finales minces de la Horde est close, sans changement de jeu (MAJ-105). Mesures faites sur le jeu 0.251.

## Pourquoi la question était ouverte

O-018 (finales des chapitres 3 et 4 côté Horde) et O-016 (mission 178 à 3 PV côté Horde, chapitres 19 et 20 vers 11 et 12 PV) reposaient sur des mesures de l'armée de référence faites avant le rééquilibrage des v0.232 à v0.236. Ce rééquilibrage a réglé chaque mission sur la cible du porteur : 40 à 70 % de PV de forteresse restants pour la meilleure des 30 compositions (O-028, MAJ-79).

## Meilleure composition : les finales sont dans la cible

Meilleure marge des 30 compositions (trois arbres, dix compositions d'unités de base), moyenne des tirages 7, 8 et 9 (`marges_campagne.json`). Dans la colonne « référence », les PV de forteresse restants de l'armée de référence sont donnés pour les tirages 7, 8 et 9.

| Finale | Horde, meilleure marge | Horde, référence | Alliance, meilleure marge | Alliance, référence |
| --- | --- | --- | --- | --- |
| 10 | 58 % | défaite / 6 / 14 (sur 20) | 49 % | 16 / 3 / 9 (sur 20) |
| 20 | 57 % | 9 / 5 / 15 (sur 20) | 56 % | 14 / 4 / 1 (sur 20) |
| 30 | 58 % | 12 / 6 / 12 (sur 20) | 59 % | 15 / 3 / 6 (sur 20) |
| 40 | 55 % | 15 / défaite / 15 (sur 20) | 50 % | 16 / 2 / 4 (sur 20) |
| 50 | 58 % | 8 / 3 / 6 (sur 22) | 62 % | 11 / défaite / 5 (sur 20) |
| 60 | 42 % | 6 / 5 / 12 (sur 23) | 43 % | 4 / 1 / 4 (sur 20) |
| 70 | 62 % | 7 / défaite / défaite (sur 23) | 52 % | 13 / 7 / 11 (sur 20) |
| 80 | 48 % | 8 / défaite / 5 (sur 25) | 51 % | 14 / défaite / 14 (sur 20) |
| 90 | 49 % | 13 / 3 / 24 (sur 27) | 46 % | 15 / 2 / 6 (sur 20) |
| 100 | 49 % | 16 / défaite / 22 (sur 27) | 42 % | 13 / défaite / 4 (sur 20) |
| 110 | 49 % | 11 / défaite / 11 (sur 29) | 62 % | 14 / 7 / 12 (sur 20) |
| 120 | 48 % | 12 / 1 / 12 (sur 29) | 57 % | 17 / 7 / 9 (sur 20) |
| 130 | 54 % | 28 / défaite / 10 (sur 29) | 70 % | 14 / 14 / 14 (sur 20) |
| 140 | 52 % | 25 / 2 / 14 (sur 29) | 57 % | 14 / 10 / 10 (sur 20) |
| 150 | 48 % | 19 / 3 / 20 (sur 29) | 56 % | 11 / défaite / défaite (sur 20) |
| 160 | 55 % | 17 / 6 / 25 (sur 29) | 58 % | 17 / 2 / 7 (sur 20) |
| 170 | 54 % | 28 / 2 / 14 (sur 29) | 53 % | 16 / 8 / 8 (sur 20) |
| 180 | 52 % | 13 / défaite / 23 (sur 29) | 92 % | 19 / 18 / 18 (sur 20) |
| 190 | 53 % | 18 / défaite / 11 (sur 29) | 48 % | 16 / défaite / 13 (sur 20) |
| 200 | 59 % | 20 / 9 / 22 (sur 29) | 45 % | 14 / défaite / 13 (sur 20) |

- Horde : moyenne 53 % sur les 20 finales, de 42 % à 62 %.
- Alliance : moyenne 55 %, de 42 % à 92 %. La finale 180 de l'Alliance est l'un des 24 réglages au-dessus de la cible.
- La finale 60 est la plus mince dans les deux factions, à la limite basse de la cible.

## Armée de référence : un résultat qui dépend du tirage des bonus

L'armée de référence (`tests/reference_army.gd`) suit une stratégie fixe : mêmes achats et améliorations, et toujours le premier bonus sans contrepartie (`Model.reference_bonus`). Victoires sur 200 missions, dont finales sur 20 :

| Tirage | Horde | Alliance |
| --- | --- | --- |
| 7 | 195 (finales : 19) | 200 (finales : 20) |
| 8 | 85 (finales : 12) | 152 (finales : 14) |
| 9 | 197 (finales : 19) | 170 (finales : 19) |

- Le tirage 8 offre d'abord Écho des ricochets, puis Premier sang. Ces deux bonus aident peu cette armée, et la Horde y perd la majorité des missions. Le tirage 9 pèse au contraire davantage sur l'Alliance.
- Sur les trois tirages, la référence de la Horde gagne 477 missions sur 600, celle de l'Alliance 522.
- Les suites de campagne jouent le tirage 7 avec leur propre répartition des talents : la référence y gagne les 200 missions dans les deux factions. L'outil d'étude répartit les talents autrement, d'où quelques défaites au tirage 7 (Horde : missions 6, 8, 9, 10 et 26).

## Limites

- Mesures par simulation, sans essai en partie réelle. La difficulté ressentie reste à juger en jeu (O-028).
- Une piste reste possible si le porteur la demande : rendre les bonus moins décisifs en début de partie.

## Données et scripts

`design/essais/equilibre_bonus/v251/` : `reference251.py` et `reference_trois_tirages.json` (référence sur 200 missions et trois tirages), `sonde_bonus_tirages.gd` (bonus choisis selon le tirage), `marges_campagne.json` (meilleure marge par mission).
