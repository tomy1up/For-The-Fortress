# Courbe de difficulté de la campagne (200 missions)

**Statut : outil de contrôle ajouté le 17 novembre 2026 par Claude Code (aucune règle de jeu modifiée).** Mesure sur le jeu 0.230, après la refonte des cartes des chapitres 10 à 20. Les chiffres sont des mesures de simulation, pas un avis de jeu : le porteur juge la difficulté en jouant.

## Méthode

`prototype/tools/difficulty_curve.gd` joue, pour chaque mission et chaque faction, la composition de référence des tests de chapitre (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman ; achats et améliorations scriptés comme dans les tests), avec les talents réels de la mission, les PV d'ennemis, la série de vagues et l'affixe de la mission. Il relève le résultat et les **PV de forteresse restants rapportés aux PV maximaux** (20 plus les bonus de talents de la faction : jusqu'à 29 pour la Horde en fin de campagne). 100 % signifie qu'aucun ennemi n'a touché la forteresse ; 0 %, une défaite. Plus le pourcentage est bas, plus la mission est serrée pour cette composition.

```
FIRST=1 LAST=200 [ORDERS=all] godot --headless --path prototype --script res://tools/difficulty_curve.gd
```

Pour les missions 1 à 90, les chapitres d'origine ont été réglés avec des ordres d'emplacements propres à chaque mission : l'outil essaie les six ordres des emplacements 2, 3 et 4 (`ORDERS=all`) et retient le meilleur. Pour les missions 91 à 200, l'ordre commun 3, 4, 2 des tests de chapitre est utilisé.

**Limite** : une seule composition, la plus simple. Les joueurs disposent de la boutique, de bonus et de choix d'emplacements plus variés ; la courbe indique donc *où la marge est mince pour cette composition*, pas la difficulté ressentie.

## Synthèse par chapitre (PV restants en % des PV maximaux)

| Chapitre | Missions | Moyenne A | Min A | Moyenne H | Min H | Sans perte (A / H) | Marge ≤ 40 % (A / H) | Défaites (A / H) |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- | --- |
| 1 | 1–10 | 100 % | 100 % | 97 % | 85 % | 10 / 8 | 0 / 0 | 0 / 0 |
| 2 | 11–20 | 100 % | 95 % | 94 % | 85 % | 9 / 4 | 0 / 0 | 0 / 0 |
| 3 | 21–30 | 86 % | 65 % | 86 % | 70 % | 2 / 4 | 0 / 0 | 0 / 0 |
| 4 | 31–40 | 45 % | 0 % | 40 % | 0 % | 0 / 1 | 2 / 1 | 2 / 3 |
| 5 | 41–50 | 74 % | 30 % | 83 % | 65 % | 2 / 0 | 1 / 0 | 0 / 0 |
| 6 | 51–60 | 75 % | 40 % | 58 % | 26 % | 0 / 0 | 1 / 3 | 0 / 0 |
| 7 | 61–70 | 74 % | 20 % | 80 % | 30 % | 2 / 3 | 1 / 1 | 0 / 0 |
| 8 | 71–80 | 74 % | 35 % | 57 % | 26 % | 1 / 1 | 1 / 4 | 0 / 0 |
| 9 | 81–90 | 86 % | 75 % | 79 % | 33 % | 2 / 1 | 0 / 1 | 0 / 0 |
| 10 | 91–100 | 68 % | 55 % | 66 % | 44 % | 0 / 0 | 0 / 0 | 0 / 0 |
| 11 | 101–110 | 74 % | 60 % | 83 % | 45 % | 1 / 2 | 0 / 0 | 0 / 0 |
| 12 | 111–120 | 68 % | 35 % | 76 % | 48 % | 1 / 2 | 2 / 0 | 0 / 0 |
| 13 | 121–130 | 78 % | 35 % | 83 % | 45 % | 2 / 2 | 1 / 0 | 0 / 0 |
| 14 | 131–140 | 74 % | 65 % | 82 % | 69 % | 0 / 0 | 0 / 0 | 0 / 0 |
| 15 | 141–150 | 66 % | 35 % | 75 % | 31 % | 1 / 3 | 1 / 1 | 0 / 0 |
| 16 | 151–160 | 89 % | 35 % | 98 % | 93 % | 5 / 7 | 1 / 0 | 0 / 0 |
| 17 | 161–170 | 72 % | 35 % | 100 % | 100 % | 0 / 10 | 1 / 0 | 0 / 0 |
| 18 | 171–180 | 52 % | 30 % | 95 % | 62 % | 0 / 8 | 3 / 0 | 0 / 0 |
| 19 | 181–190 | 73 % | 55 % | 100 % | 100 % | 0 / 10 | 0 / 0 | 0 / 0 |
| 20 | 191–200 | 64 % | 30 % | 95 % | 69 % | 0 / 7 | 1 / 0 | 0 / 0 |

## Missions à surveiller

**Défaites avec la composition de référence** (aucun ordre d'emplacements ne gagne) : 32 (Alliance), 32 (Horde), 39 (Alliance), 39 (Horde), 40 (Horde).

**Marge mince (40 % des PV maximaux restants ou moins)** : 33 (Alliance, 4/20), 36 (Alliance, 5/20), 37 (Horde, 2/20), 41 (Alliance, 6/20), 53 (Horde, 7/23), 55 (Alliance, 8/20), 56 (Horde, 8/23), 60 (Horde, 6/23), 66 (Alliance, 4/20), 66 (Horde, 7/23), 71 (Alliance, 7/20), 71 (Horde, 8/23), 73 (Horde, 7/23), 76 (Horde, 6/23), 78 (Horde, 9/23), 90 (Horde, 9/27), 117 (Alliance, 7/20), 120 (Alliance, 8/20), 127 (Alliance, 7/20), 142 (Horde, 9/29), 147 (Alliance, 7/20), 155 (Alliance, 7/20), 170 (Alliance, 7/20), 174 (Alliance, 6/20), 176 (Alliance, 7/20), 177 (Alliance, 6/20), 194 (Alliance, 6/20).

**Aucune perte** : 111 missions sur 400 (mission × faction). Par chapitre, voir la synthèse ; les chapitres 16 à 20 de la Horde sont presque tous sans perte : chap. 16 : 7/10, chap. 17 : 10/10, chap. 18 : 8/10, chap. 19 : 10/10, chap. 20 : 7/10.

## Constats (à confirmer en jeu ; ce sont des mesures, pas des décisions)

1. **Écart entre les factions en fin de campagne : observation, pas conclusion.** Aux chapitres 16 à 20 (missions 151 à 200), la composition de référence de la Horde ne perd aucun PV sur 42 missions sur 50 ; celle de l'Alliance n'en laisse intactes que 5 sur 50, avec une marge souvent entre 30 et 70 %. L'écart existait avant la refonte des cartes (les anciennes cartes donnaient 29 PV restants sur 29 à la Horde). **Direction du porteur (17 novembre 2026) : il ne doit pas y avoir d'écart énorme entre les deux factions, la puissance doit rester assez similaire ; mais une seule composition par faction est un échantillon trop faible pour conclure.** **L'étude multi-compositions a été menée ensuite : voir `design/Equilibre_factions_fin_campagne_v0232.md` (avantage net de la Horde aux chapitres 11 à 20, quelle que soit la composition, avec les seules unités de base).**

2. **Chapitres 4 et 8 : défaites de la composition de référence.** Les missions 32, 39 et 40 (chapitre 4) n'ont pas de victoire avec cette composition ; les chapitres 4 et 8 sont aussi les plus irréguliers (de 0 à 100 %). Ces chapitres ont été réglés avec des compositions et des évolutions d'unités propres à chaque mission (voir `design/Missions_031_040_*` et `Missions_071_080_*`) : leurs tests de chapitre passent avec ces compositions, ce n'est donc pas un défaut de jeu mais la limite de cet outil, qui ne joue qu'une composition.

3. **Refonte des cartes (chapitres 10 à 20) : marges.** Les nouvelles cartes gardent des marges comparables aux anciennes (voir les fiches `design/Missions_*`) ; les plus serrées pour l'Alliance sont 117, 120, 127, 147, 155, 170, 174, 176, 177 et 194 (6 à 8 PV sur 20), choisies pour rester proches des anciennes valeurs de ces missions. Aucune défaite aux chapitres 10 à 20.

4. **Progression générale.** La marge moyenne de l'Alliance baisse de 100 % (chapitres 1 et 2) à 50-85 % en moyenne (chapitres 10 à 20) en restant irrégulière d'une mission à l'autre (écarts de 30 à 40 points entre voisines), ce qui est voulu par les cartes de formes variées mais se voit sur la courbe.

## Courbe complète

PV restants / PV maximaux, Alliance puis Horde. Pour les missions 1 à 90, entre parenthèses : ordre des emplacements retenu (Alliance / Horde).

| Mission | PV ennemis A | Alliance | Horde | | Mission | PV ennemis A | Alliance | Horde |
| --- | ---: | ---: | ---: | --- | --- | ---: | ---: | ---: |
| 1 | 100 % | 20/20 | 20/20 (423 / 342) | | 101 | 200 % | 18/20 | 28/29 |
| 2 | 101 % | 20/20 | 17/20 (342 / 342) | | 102 | 201 % | 16/20 | 29/29 |
| 3 | 102 % | 20/20 | 20/20 (342 / 342) | | 103 | 202 % | 14/20 | 28/29 |
| 4 | 103 % | 20/20 | 17/20 (432 / 243) | | 104 | 203 % | 12/20 | 13/29 |
| 5 | 104 % | 20/20 | 20/20 (234 / 234) | | 105 | 204 % | 20/20 | 29/29 |
| 6 | 105 % | 20/20 | 20/20 (342 / 234) | | 106 | 205 % | 13/20 | 19/29 |
| 7 | 106 % | 20/20 | 20/20 (342 / 342) | | 107 | 206 % | 13/20 | 23/29 |
| 8 | 107 % | 20/20 | 20/20 (342 / 342) | | 108 | 207 % | 16/20 | 28/29 |
| 9 | 108 % | 20/20 | 20/20 (342 / 243) | | 109 | 208 % | 14/20 | 21/29 |
| 10 | 109 % | 20/20 | 20/20 (342 / 234) | | 110 | 209 % | 12/20 | 24/29 |
| 11 | 110 % | 20/20 | 19/20 (234 / 423) | | 111 | 210 % | 20/20 | 29/29 |
| 12 | 111 % | 20/20 | 20/20 (432 / 432) | | 112 | 211 % | 18/20 | 26/29 |
| 13 | 112 % | 20/20 | 20/20 (342 / 423) | | 113 | 212 % | 9/20 | 18/29 |
| 14 | 113 % | 20/20 | 17/20 (324 / 243) | | 114 | 213 % | 14/20 | 14/29 |
| 15 | 114 % | 19/20 | 17/20 (324 / 234) | | 115 | 214 % | 17/20 | 29/29 |
| 16 | 115 % | 20/20 | 20/20 (342 / 234) | | 116 | 215 % | 14/20 | 22/29 |
| 17 | 116 % | 20/20 | 19/20 (342 / 423) | | 117 | 216 % | 7/20 | 15/29 |
| 18 | 117 % | 20/20 | 20/20 (342 / 342) | | 118 | 217 % | 13/20 | 17/29 |
| 19 | 118 % | 20/20 | 17/20 (432 / 423) | | 119 | 218 % | 16/20 | 26/29 |
| 20 | 119 % | 20/20 | 18/20 (324 / 234) | | 120 | 219 % | 8/20 | 24/29 |
| 21 | 120 % | 20/20 | 20/20 (342 / 234) | | 121 | 220 % | 20/20 | 29/29 |
| 22 | 121 % | 17/20 | 15/20 (342 / 432) | | 122 | 221 % | 16/20 | 25/29 |
| 23 | 122 % | 16/20 | 20/20 (234 / 234) | | 123 | 222 % | 15/20 | 22/29 |
| 24 | 123 % | 20/20 | 20/20 (234 / 234) | | 124 | 223 % | 15/20 | 23/29 |
| 25 | 124 % | 17/20 | 16/20 (342 / 432) | | 125 | 224 % | 20/20 | 29/29 |
| 26 | 125 % | 19/20 | 18/20 (324 / 432) | | 126 | 225 % | 13/20 | 24/29 |
| 27 | 126 % | 16/20 | 14/20 (432 / 342) | | 127 | 226 % | 7/20 | 22/29 |
| 28 | 127 % | 17/20 | 20/20 (342 / 342) | | 128 | 227 % | 14/20 | 13/29 |
| 29 | 128 % | 13/20 | 15/20 (432 / 432) | | 129 | 228 % | 18/20 | 27/29 |
| 30 | 129 % | 17/20 | 15/20 (432 / 342) | | 130 | 229 % | 17/20 | 26/29 |
| 31 | 130 % | 14/20 | 13/20 (234 / 234) | | 131 | 230 % | 16/20 | 27/29 |
| 32 | 131 % | 0/20 | 0/20 (342 / 342) | | 132 | 231 % | 13/20 | 24/29 |
| 33 | 132 % | 4/20 | 12/20 (324 / 432) | | 133 | 232 % | 16/20 | 25/29 |
| 34 | 133 % | 16/20 | 20/20 (432 / 234) | | 134 | 233 % | 15/20 | 25/29 |
| 35 | 134 % | 11/20 | 10/20 (432 / 432) | | 135 | 234 % | 15/20 | 25/29 |
| 36 | 135 % | 5/20 | 14/20 (324 / 342) | | 136 | 235 % | 14/20 | 24/29 |
| 37 | 136 % | 13/20 | 2/20 (432 / 342) | | 137 | 236 % | 16/20 | 22/29 |
| 38 | 137 % | 15/20 | 9/20 (432 / 423) | | 138 | 237 % | 17/20 | 22/29 |
| 39 | 138 % | 0/20 | 0/20 (342 / 342) | | 139 | 238 % | 14/20 | 20/29 |
| 40 | 139 % | 12/20 | 0/20 (342 / 342) | | 140 | 239 % | 13/20 | 25/29 |
| 41 | 140 % | 6/20 | 15/20 (342 / 432) | | 141 | 240 % | 20/20 | 29/29 |
| 42 | 141 % | 17/20 | 17/20 (324 / 234) | | 142 | 240 % | 17/20 | 9/29 |
| 43 | 142 % | 16/20 | 16/20 (342 / 432) | | 143 | 241 % | 14/20 | 23/29 |
| 44 | 143 % | 16/20 | 17/20 (234 / 342) | | 144 | 241 % | 14/20 | 12/29 |
| 45 | 144 % | 20/20 | 18/20 (234 / 342) | | 145 | 242 % | 13/20 | 29/29 |
| 46 | 145 % | 9/20 | 13/20 (342 / 342) | | 146 | 242 % | 13/20 | 24/29 |
| 47 | 146 % | 14/20 | 19/21 (342 / 423) | | 147 | 243 % | 7/20 | 22/29 |
| 48 | 147 % | 20/20 | 19/21 (342 / 432) | | 148 | 243 % | 12/20 | 16/29 |
| 49 | 148 % | 17/20 | 20/22 (324 / 342) | | 149 | 244 % | 13/20 | 25/29 |
| 50 | 149 % | 14/20 | 17/22 (423 / 432) | | 150 | 244 % | 9/20 | 29/29 |
| 51 | 150 % | 18/20 | 16/23 (234 / 243) | | 151 | 245 % | 20/20 | 29/29 |
| 52 | 151 % | 14/20 | 19/23 (423 / 432) | | 152 | 245 % | 20/20 | 29/29 |
| 53 | 152 % | 16/20 | 7/23 (342 / 342) | | 153 | 246 % | 15/20 | 27/29 |
| 54 | 153 % | 15/20 | 19/23 (324 / 342) | | 154 | 246 % | 19/20 | 29/29 |
| 55 | 154 % | 8/20 | 10/23 (432 / 342) | | 155 | 247 % | 7/20 | 27/29 |
| 56 | 155 % | 18/20 | 8/23 (432 / 342) | | 156 | 247 % | 20/20 | 29/29 |
| 57 | 156 % | 18/20 | 16/23 (342 / 243) | | 157 | 248 % | 20/20 | 28/29 |
| 58 | 157 % | 14/20 | 21/23 (342 / 342) | | 158 | 248 % | 20/20 | 29/29 |
| 59 | 158 % | 17/20 | 12/23 (432 / 342) | | 159 | 249 % | 19/20 | 29/29 |
| 60 | 159 % | 12/20 | 6/23 (423 / 342) | | 160 | 249 % | 18/20 | 29/29 |
| 61 | 160 % | 18/20 | 23/23 (342 / 324) | | 161 | 250 % | 18/20 | 29/29 |
| 62 | 161 % | 20/20 | 23/23 (342 / 342) | | 162 | 250 % | 15/20 | 29/29 |
| 63 | 162 % | 17/20 | 21/23 (432 / 342) | | 163 | 251 % | 14/20 | 29/29 |
| 64 | 163 % | 14/20 | 19/23 (342 / 324) | | 164 | 251 % | 11/20 | 29/29 |
| 65 | 164 % | 15/20 | 16/23 (234 / 234) | | 165 | 252 % | 18/20 | 29/29 |
| 66 | 165 % | 4/20 | 7/23 (342 / 342) | | 166 | 252 % | 17/20 | 29/29 |
| 67 | 166 % | 20/20 | 23/23 (342 / 432) | | 167 | 253 % | 14/20 | 29/29 |
| 68 | 167 % | 11/20 | 16/23 (324 / 342) | | 168 | 253 % | 17/20 | 29/29 |
| 69 | 168 % | 13/20 | 17/23 (342 / 342) | | 169 | 254 % | 14/20 | 29/29 |
| 70 | 169 % | 15/20 | 18/23 (342 / 342) | | 170 | 254 % | 7/20 | 29/29 |
| 71 | 170 % | 7/20 | 8/23 (423 / 432) | | 171 | 255 % | 13/20 | 29/29 |
| 72 | 171 % | 20/20 | 23/23 (243 / 243) | | 172 | 255 % | 10/20 | 29/29 |
| 73 | 172 % | 16/20 | 7/23 (432 / 243) | | 173 | 256 % | 13/20 | 25/29 |
| 74 | 173 % | 14/20 | 10/23 (342 / 423) | | 174 | 256 % | 6/20 | 29/29 |
| 75 | 174 % | 18/20 | 17/23 (243 / 423) | | 175 | 257 % | 16/20 | 29/29 |
| 76 | 175 % | 15/20 | 6/23 (423 / 423) | | 176 | 257 % | 7/20 | 29/29 |
| 77 | 176 % | 10/20 | 11/23 (432 / 423) | | 177 | 258 % | 6/20 | 29/29 |
| 78 | 177 % | 16/20 | 9/23 (243 / 423) | | 178 | 258 % | 11/20 | 29/29 |
| 79 | 178 % | 19/20 | 21/23 (342 / 432) | | 179 | 259 % | 10/20 | 29/29 |
| 80 | 179 % | 12/20 | 20/25 (234 / 423) | | 180 | 259 % | 11/20 | 18/29 |
| 81 | 180 % | 15/20 | 22/25 (432 / 342) | | 181 | 260 % | 16/20 | 29/29 |
| 82 | 181 % | 18/20 | 26/27 (342 / 423) | | 182 | 260 % | 16/20 | 29/29 |
| 83 | 182 % | 16/20 | 25/27 (342 / 342) | | 183 | 260 % | 17/20 | 29/29 |
| 84 | 183 % | 16/20 | 11/27 (342 / 342) | | 184 | 260 % | 11/20 | 29/29 |
| 85 | 184 % | 20/20 | 27/27 (342 / 432) | | 185 | 261 % | 18/20 | 29/29 |
| 86 | 185 % | 18/20 | 19/27 (342 / 342) | | 186 | 261 % | 12/20 | 29/29 |
| 87 | 186 % | 16/20 | 25/27 (324 / 342) | | 187 | 261 % | 13/20 | 29/29 |
| 88 | 187 % | 17/20 | 24/27 (243 / 342) | | 188 | 261 % | 17/20 | 29/29 |
| 89 | 188 % | 20/20 | 23/27 (342 / 342) | | 189 | 262 % | 13/20 | 29/29 |
| 90 | 189 % | 16/20 | 9/27 (432 / 342) | | 190 | 262 % | 13/20 | 29/29 |
| 91 | 190 % | 16/20 | 19/27 | | 191 | 262 % | 13/20 | 29/29 |
| 92 | 191 % | 16/20 | 12/27 | | 192 | 262 % | 16/20 | 29/29 |
| 93 | 192 % | 11/20 | 19/27 | | 193 | 263 % | 14/20 | 26/29 |
| 94 | 193 % | 13/20 | 23/27 | | 194 | 263 % | 6/20 | 26/29 |
| 95 | 194 % | 15/20 | 12/27 | | 195 | 263 % | 19/20 | 29/29 |
| 96 | 195 % | 12/20 | 17/27 | | 196 | 263 % | 13/20 | 29/29 |
| 97 | 196 % | 11/20 | 14/27 | | 197 | 264 % | 9/20 | 29/29 |
| 98 | 197 % | 11/20 | 17/27 | | 198 | 264 % | 15/20 | 20/29 |
| 99 | 198 % | 16/20 | 23/27 | | 199 | 264 % | 12/20 | 29/29 |
| 100 | 199 % | 16/20 | 23/27 | | 200 | 264 % | 12/20 | 29/29 |

