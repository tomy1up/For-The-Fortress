# Recalibrage des PV d'ennemis avec les 60 bonus — v0.234

**Statut.** Suite du rééquilibrage de la v0.232 (`design/Rebalancage_bonus_v0232.md`), demandée par le porteur le 21 novembre 2026 (« Oui, équilibrer ») après le second lot de bonus de la v0.233 (rareté, relance, 24 rares et épiques). La cible reste celle du porteur (20 novembre 2026, MAJ-69) : **la meilleure composition d'une mission finit avec 40 à 70 % de ses PV de forteresse**. Les coefficients ci-dessous sont des **réglages de prototype à confirmer** en partie réelle (O-028).

## Pourquoi

Mesurée sur 36 000 parties avec les règles de la v0.233, la meilleure marge moyenne était montée à 68,5 % pour l'Alliance et à **85,5 % pour la Horde** (19 missions de nouveau gagnées à 100 %) : plusieurs rares et épiques renforcent surtout les unités à effet de zone et à dégâts sur la durée, majoritaires dans l'armée de base de la Horde.

## Règle (inchangée)

PV ennemis joués = courbe de base de la mission (section 62 du GDD, réduction de la Horde comprise) × coefficient de la mission et de la faction (`REBALANCE_PERCENT`, `prototype/scripts/campaign_catalogue.gd`). Coefficient au moins égal à 100 %. Les rapports des versions antérieures gardent leurs PV enregistrés et se rejouent à l'identique.

## Méthode (changements par rapport à la v0.232)

1. **Trois tirages de bonus au lieu d'un** : pour chaque mission et chaque faction, meilleure marge des 30 compositions de l'étude (trois arbres × dix compositions de base), **moyennée sur les tirages 7, 8 et 9**, avec les règles de la v0.233 (rareté, relance, premier bonus offert). Le tirage pèse beaucoup : la meilleure marge d'une même mission varie de plus de 40 points d'un tirage à l'autre.
2. **Grille affinée** : mesures à 100, 125, 150, 175 et 200 % des PV de base, puis tous les 5 % dans l'intervalle où la marge moyenne franchit 55 % (1 564 couples mission-faction mesurés en plus). Coefficient retenu : interpolation linéaire jusqu'à 55 % de marge.
3. **Garde-fou de la composition de référence** des tests de chapitre (Alliance archer et deux arbalétriers, Horde deux haches et un chaman, choix de bonus de référence) : au moins 25 % de marge, mesurée de 100 à 230 % par pas de 10 (102 coefficients plafonnés).
4. **Ajustement par les suites de campagne** : quinze suites échouaient avec la table brute ; le coefficient de chaque mission perdue a été abaissé de 6 points, en quatre passes, jusqu'à ce que toutes passent (14 coefficients abaissés pour l'Alliance, 52 pour la Horde).
5. **La mission 1 (le Gué) reste à 100 %** dans les deux factions : son rapport garde le format historique, sans PV enregistrés.

Données : `design/essais/equilibre_bonus/calibrage_v233.json` (marges par multiplicateur et tirage), `reference_v233.json` (composition de référence), `rebalance_table.json` (table finale), `parties_v234_{7,8,9}.txt` (vérification). Outil : `prototype/tools/faction_study.gd` (`HPMUL`, `SEED`, `FACTIONS`, `MISSIONS`, `REFONLY`, `POLICY`).

## Table

| | Alliance | Horde |
| --- | --- | --- |
| Coefficient moyen v0.233 | 108,6 % | 115,7 % |
| Coefficient moyen v0.234 | 112,3 % | 122,2 % |
| Médiane, minimum, maximum | 111, 100, 161 % | 120, 100, 183 % |
| Missions à 100 % | 11 | 11 |

## Vérification (21 novembre 2026)

Étude complète avec la nouvelle table : 200 missions × 2 factions × 30 compositions × 3 tirages (7, 8, 9), soit 36 000 parties, règles de la v0.233.

| Mesure | Alliance v0.233 | Alliance v0.234 | Horde v0.233 | Horde v0.234 |
| --- | --- | --- | --- | --- |
| Meilleure marge moyenne | 68,5 % | **56,3 %** | 85,5 % | **69,4 %** |
| Meilleure marge médiane | 68,3 % | 55,0 % | 86,5 % | 67,8 % |
| Missions dans la cible 40-70 % | 109 | **174** | 11 | **108** |
| Missions au-dessus de 70 % | 88 | 19 | 188 | 90 |
| Missions sous 40 % | 3 | 7 | 1 | 2 |
| Missions à 100 % sur les trois tirages | 0 | 0 | 19 | 5 |
| Victoires, toutes compositions confondues | 22,6 % | 16,6 % | 23,8 % | 16,5 % |

Meilleure marge moyenne par chapitre en v0.234 :

| Chapitre | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Alliance | 66 | 52 | 54 | 49 | 55 | 55 | 63 | 48 | 56 | 55 | 62 | 54 | 70 | 53 | 56 | 59 | 56 | 54 | 54 | 54 |
| Horde | 70 | 56 | 78 | 72 | 64 | 59 | 90 | 67 | 60 | 58 | 66 | 71 | 95 | 73 | 64 | 73 | 63 | 71 | 71 | 66 |

- Moyenne par tirage : Alliance 77 %, 34 % et 57 % ; Horde 79 %, 43 % et 86 %. Écart moyen de la meilleure marge entre tirages pour une même mission : 44 points (Alliance) et 46 points (Horde).
- Régression complète : 144 suites sur 144, 197 077 contrôles Godot et 17 tests Python.

## Limites et points à surveiller

- **La Horde reste au-dessus de la cible sur 90 missions**, surtout aux chapitres 7 (90 %) et 13 (95 %). Ce n'est pas un défaut de mesure : 89 de ces 90 missions sont bridées par la règle des tests de chapitre, qui veut que la composition de référence de la Horde (deux haches et un chaman) gagne chaque mission. Elle ne gagnerait plus avec davantage de PV, alors que les meilleures compositions de la Horde finissent encore avec plus de 70 % de marge. Pour rapprocher la Horde de la cible, il faudrait changer cette règle (autre composition de référence, ou cible abaissée pour elle) : décision du porteur (O-028).
- Sept missions de l'Alliance et deux de la Horde passent sous 40 % de marge ; aucune n'est perdue par toutes les compositions sur les trois tirages.
- La mesure repose sur une stratégie d'achat fixe et le choix de la première offre : un joueur qui adapte ses bonus, utilise la relance et achète en boutique fera mieux.
- Le combat d'échantillon des captures (`Main._capture_sample_combat`) joue sur la courbe de base, sans le coefficient.
