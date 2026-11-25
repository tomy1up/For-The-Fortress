# Derniers réglages par renforts de vague (v0.256)

**Statut.** Demande du porteur du 25 novembre 2026 (« Derniers réglages ») : corriger, avec les renforts de vague de la v0.252, les réglages encore au-dessus de la cible que les PV ne pouvaient pas corriger. Quantités, types et vagues : réglages de prototype à confirmer en partie réelle.

## Les cinq réglages

Deux cas, déjà rencontrés en v0.252 :
- **Falaises** : un point de PV de plus fait tomber la marge sous 40 % (Alliance 13 et 40, Horde 43).
- **Limités par l'armée de référence**, devenue avisée en v0.255 (Alliance 132, Horde 34).

Meilleure marge des 30 compositions (première offre, moyenne des tirages 7, 8 et 9), mesurée depuis le catalogue (`mesure256.py`, `renforts_mesures.json`) :

| Faction | Mission | Renfort | Meilleure marge | Tirages 7 / 8 / 9 |
| --- | --- | --- | --- | --- |
| Alliance | 13 | 5 sprinters aux vagues 3, 5 et 7 | 77 % → 62 % | 85 / 40 / 62 |
| Alliance | 40 | 1 élite aux vagues 7 et 9 | 78 % → 63 % | 65 / 50 / 75 |
| Alliance | 132 | 6 sprinters aux vagues 3, 5 et 7 | 88 % → 62 % | 65 / 60 / 62 |
| Horde | 34 | 2 sprinters aux vagues 3, 5 et 7 | 73 % → 57 % | 60 / 50 / 60 |
| Horde | 43 | 1 maraudeur aux vagues 4, 6 et 8 | 72 % → 58 % | 45 / 55 / 75 |

L'armée de référence gagne ces missions dans les 28 suites de campagne. La grille a essayé 15 renforts par réglage, en vérifiant à chaque fois la meilleure marge et la référence avisée sur trois tirages (`grille256.py`, `grille.json`, `choix_retenus.json`, `garde256.py`).

## Sur toute la campagne

**391 réglages sur 398 dans la cible** (386 en v0.255) :

| Cas | Réglages |
| --- | --- |
| Au-dessus de 70 % | missions 2 et 3 des deux factions (prise en main) ; Alliance 33, que la suite des Vents contraires joue avec une autre armée que la référence |
| Juste sous 40 % (39,9 %) | Alliance 67, Horde 40 |

Marge moyenne de la meilleure composition : Alliance 58 %, Horde 52 %. La nouvelle base est `marges_campagne.json`. Au total, 23 réglages ont des renforts : 13 de l'Alliance et 10 de la Horde.

Données et scripts : `design/essais/equilibre_bonus/v256/`.
