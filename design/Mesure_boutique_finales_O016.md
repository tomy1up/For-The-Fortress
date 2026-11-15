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


## Seconde mesure : six défenseurs (même jour)

L'outil accepte `SIX=1` : trois renforts de mêmes familles que les deux premières unités sont recrutés aux vagues 3, 5 et 7 si l'or le permet, et améliorés comme les autres. Résultat brut : `design/essais/Mesure_boutique_finales_O016_six_defenseurs_brut.txt`. Victoires sur 6 parties ; PV = PV de forteresse restants (moyenne sur les victoires).

| Mission | Faction | Base (victoires, PV) | Alternatives : victoires moyennes | Meilleures / moins bonnes |
| --- | --- | --- | --- | --- |
| 100 | Alliance | 6, 22,8 | 6,0 | 0 / 0 |
| 100 | Horde | 3, 16,7 | 3,3 | 5 / 2 |
| 150 | Alliance | 3, 13,0 | 2,5 | 1 / 8 |
| 150 | Horde | 1, 8,0 | 0,8 | 5 / 8 |
| 178 | Alliance | 5, 20,0 | 4,0 | 0 / 13 |
| 178 | Horde | 2, 9,5 | 1,6 | 2 / 7 |
| 190 | Alliance | 2, 27,5 | 2,4 | 7 / 0 |
| 190 | Horde | 1, 21,0 | 1,5 | 9 / 0 |
| 200 | Alliance | 5, 11,4 | 3,9 | 0 / 11 |
| 200 | Horde | 1, 7,0 | 0,5 | 0 / 10 |

### Lecture

- **Avec une vraie armée, l'unité de base tient les finales** côté Alliance (5 victoires sur 6 aux missions 178 et 200) : une alternative qui remplace la troisième unité est le plus souvent un peu moins bonne que la base aux missions 150, 178 et 200, ce qui respecte le principe « aucune remplaçante systématiquement supérieure » (CAMP-008). La mission 190 fait exception : sept alternatives de l'Alliance et neuf de la Horde y font mieux que la base, car la base y est faible dans cet échantillon.
- **La Horde est la plus mince** : une victoire sur six à la mission 200 (7 PV restants avec la base) et aucune moyenne d'alternatives au-dessus de 1,6 victoire aux missions 178 à 200. Cela confirme les marges minces déjà notées (O-016, O-018) ; ce n'est pas causé par la boutique.
- Échantillon réduit (6 parties par ligne, une seule graine) : indication, pas démonstration.

## Suite possible (non engagée)

Si le porteur le souhaite, étudier un ajustement de la courbe de difficulté de la Horde aux chapitres 18 à 20 (valeurs à lui soumettre avant tout changement).

## Courbe de la Horde (décision du porteur : « la Horde doit être revue », 15 novembre 2026)

Mesure avec l'armée de base à six défenseurs, huit missions de 150 à 200, PV des ennemis de la Horde multipliés par un facteur d'essai (outil : `HPK_HORDE`, `BASE_ONLY=1`, `SIX=1`). Résultat brut : `design/essais/Mesure_courbe_horde_brut.txt`. Victoires sur 6 parties par mission.

| Mission | 150 | 160 | 170 | 178 | 185 | 190 | 195 | 200 | Total sur 48 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Alliance (référence) | 3 | 5 | 4 | 5 | 5 | 2 | 4 | 5 | 33 |
| Horde, PV ×1,0 | 1 | 2 | 2 | 2 | 4 | 1 | 3 | 1 | 16 |
| Horde, PV ×0,9 | 3 | 2 | 5 | 5 | 5 | 4 | 6 | 1 | 31 |
| Horde, PV ×0,8 | 6 | 5 | 6 | 5 | 6 | 5 | 6 | 5 | 44 |
| Horde, PV ×0,7 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 6 | 48 |

Lecture : à PV égaux, la Horde gagne deux fois moins que l'Alliance aux chapitres 16 à 20. Une réduction d'environ 10 % des PV d'ennemis de la Horde la ramène au niveau de l'Alliance en moyenne (31 contre 33) ; la mission 200 reste mince (1 victoire sur 6 même à ×0,9). Échantillon réduit : indication de prototype, une seule graine.
