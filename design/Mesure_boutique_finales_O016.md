# Mesure O-016 : les unités de boutique et la tenue des missions avancées

**Statut : mesure seule (15 novembre 2026), aucune règle ni valeur modifiée. Les chiffres sont des indications de prototype à confirmer en jeu.**

## Méthode

Outil : `prototype/tools/survey_shop_campaign.gd` (`MISSIONS=100,150,178,190,200`). Pour chaque mission et faction : armée naturelle de chacun des trois arbres de talents, tous les points d'XP gagnés avant la mission dépensés dans cet arbre, deux dispositions d'emplacements, graine 42. La troisième unité est celle de l'armée de base (« base ») ou l'une des alternatives de boutique déjà débloquées à cette mission. Six parties par ligne ; résultat brut dans `design/essais/Mesure_boutique_finales_O016_brut.txt`.

**Limite importante :** cette politique n'achète que trois défenseurs et n'utilise pas les trois autres emplacements, contrairement à un joueur. Les taux de victoire absolus (souvent 0 sur six) ne représentent donc pas la difficulté réelle ; seule la comparaison entre l'unité de base et les alternatives est exploitable.

## Résultats (victoires sur 6 parties, base puis moyenne des alternatives)

| Mission | Faction | Base | Moyenne des alternatives | Alternatives meilleures / moins bonnes |
| --- | --- | --- | --- | --- |
| 100 | Alliance | 3 | 2,9 | 5 / 4 |
| 100 | Horde | 0 | 1,5 | 7 / 0 |
| 150 | Alliance | 0 | 0,1 | 1 / 0 |
| 150 | Horde | 0 | 0,0 | 0 / 0 |
| 178 | Alliance | 2 | 1,7 | 1 / 4 |
| 178 | Horde | 0 | 0,1 | 2 / 0 |
| 190 | Alliance | 0 | 0,7 | 10 / 0 |
| 190 | Horde | 0 | 0,0 | 0 / 0 |
| 200 | Alliance | 2 | 1,5 | 3 / 11 |
| 200 | Horde | 0 | 0,0 | 0 / 0 |

## Lecture

- **Aucune alternative ne brise la progression ni ne l'écrase** : en moyenne les alternatives se situent au niveau de l'unité de base (à la mission 100 de la Horde, elles font mieux, ce qui reflète une armée de base de la Horde faible dans cette politique). Cela confirme la parité mesurée en v0.197 (0,89 à 1,05 de la référence) sur les missions avancées.
- **Côté Alliance**, quelques alternatives ressortent (mission 190 : dix alternatives gagnent là où la base perd ; mission 200 : onze font moins bien que la base), ce qui indique des effets de composition plutôt qu'une supériorité générale.
- **Côté Horde**, la politique à trois unités ne gagne presque jamais après la mission 100 : la mesure ne permet pas de conclure sur les marges de la Horde aux finales (O-016, O-018). Il faudrait une politique à six unités et plusieurs recrutements.

## Suite possible (non engagée)

Étendre l'outil à six défenseurs (renforts de comparaison, déjà gérés par `survey_campaign_sample.gd`) pour mesurer de vraies marges de PV, puis, si besoin, proposer une révision de valeurs au porteur.
