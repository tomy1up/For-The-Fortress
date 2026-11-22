# Joueur avisé sans voyance — mesure pour O-028 (v0.239)

**Statut.** Mesure demandée par le porteur le 22 novembre 2026 (« Oui, mesure-le ») pour éclairer O-028. Elle complète le choix guidé de la v0.236 (`design/Rebalancage_v0236.md`), qui était une borne haute. **Décision du porteur, 22 novembre 2026 : « Garder la cible »** (MAJ-79). La cible reste 40 à 70 % de marge pour la meilleure composition, mesurée avec la première offre (MAJ-69, MAJ-73), sans recalibrage pour le joueur avisé. Les coefficients restent des réglages de prototype à confirmer en jeu.

## Méthode

Le joueur simulé est dans `tools/faction_study.gd`, avec `POLICY=wise`. À chaque choix de bonus, il joue chaque offre jusqu'au bout sur une copie exacte de la partie, comme le choix guidé (`POLICY=look`), mais la copie reçoit **un autre tirage aléatoire** : les offres des choix suivants n'y sont pas celles de la vraie partie. Le hasard du modèle ne sert qu'aux offres de bonus, donc le combat reste exact.

La relance est jugée sur un tirage d'offres fictif. Si elle l'emporte, le joueur relance pour de bon et juge les vraies nouvelles offres de la même façon.

Ce joueur sait exactement ce que chaque bonus apporte à son armée sur la mission en cours, sans connaître les offres à venir. Il reste plus fort qu'un joueur humain, qui estime la valeur d'un bonus sans rejouer la mission en entier.

Échantillon : une mission sur deux (100 missions paires) × 2 factions × 30 compositions × 3 tirages (7, 8, 9), soit 18 000 parties et environ 2 h 15 de calcul sur la v0.238.

## Résultats (missions paires)

| Mesure | Alliance, première offre | Alliance, avisé | Alliance, guidé | Horde, première offre | Horde, avisé | Horde, guidé |
| --- | --- | --- | --- | --- | --- | --- |
| Meilleure marge moyenne | 55,2 % | **84,4 %** | 89,2 % | 57,3 % | **79,6 %** | 90,9 % |
| Missions dans la cible 40-70 % | 95 | **1** | 1 | 88 | **19** | 1 |
| Au-dessus de 70 % | 2 | 99 | 99 | 10 | 81 | 99 |
| Moyenne par tirage (7, 8, 9) | 76, 33, 57 % | 75, 94, 84 % | 88, 93, 86 % | 70, 25, 77 % | 69, 95, 75 % | 83, 95, 94 % |
| Écart moyen entre tirages | 44 points | 24 points | 18 points | 57 points | 36 points | 17 points |
| Missions perdues par les 30 compositions | 0, 6, 1 | 0 | 0 | 1, 24, 0 | 1 (32, tirage 7) | 0 |
| Victoires, toutes compositions | 15,9 % | 34,8 % | 44,1 % | 12,7 % | 19,5 % | 25,3 % |

Moyenne par chapitre, joueur avisé : 81 à 91 % pour l'Alliance ; 71 à 91 % pour la Horde (chapitres 4 et 18 les plus durs, à 72 et 71 %). Missions les plus serrées : Alliance 130 (66 %), 112, 32 et 50 (70 %) ; Horde 32 (48 %), 14 (57 %), 176 (59 %).

## Constats

- **Bien juger l'offre du moment suffit pour l'essentiel du gain.** Le joueur avisé gagne 29 points de marge sur la première offre pour l'Alliance et 22 pour la Horde, contre 34 avec la voyance. Connaître les offres à venir n'ajoute que 5 points (Alliance) à 11 points (Horde).
- **Un joueur qui choisit bien ses bonus termine presque toutes les missions au-dessus de la cible**, vers 80 à 85 % de marge. Avec la cible actuelle, la campagne est réglée pour un joueur qui prend ses bonus au hasard.
- **La Horde dépend davantage du tirage** que l'Alliance (36 points d'écart entre tirages contre 24) et finit 5 points plus bas. La voyance efface cet écart : la Horde a plus souvent besoin d'un bonus précis qui n'est pas proposé.
- Un joueur humain se situe entre la première offre (55 %) et le joueur avisé (80 à 85 %). Seule une partie réelle dira où.

## Ce que cela changerait

Viser 40 à 70 % de marge pour le joueur avisé demanderait de remonter les PV ennemis de presque toutes les missions, puis de refaire tout l'ajustement par les suites de campagne. La référence de chaque faction (`tests/reference_army.gd`), qui doit toujours gagner avec la première offre, bride déjà une partie des missions : il faudrait aussi qu'elle joue en joueur avisé.

Une mesure avisée complète coûte environ 4 h 30 de calcul par passe (200 missions).

## Décision

Le porteur garde la cible actuelle pour le mode normal (22 novembre 2026, réponse à O-028). Aucune mission n'est recalibrée. Piste proposée par Claude Code, non décidée : se servir de cette mesure pour régler les difficultés Héroïque et Mythique (O-014).

Données : `design/essais/equilibre_bonus/parties_v238_wise_{7,8,9}.txt` (joueur avisé), `parties_v236_{7,8,9}.txt` (première offre), `parties_v236_look_{7,8,9}.txt` (choix guidé).
