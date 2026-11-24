# Missions trop faciles (v0.248)

**Statut.** Décision du porteur du 24 novembre 2026 : appliquer les trois hausses de PV qui rejoignent la cible sans changer de règle (« Les trois hausses »). Les valeurs restent des réglages de prototype à confirmer en partie réelle.

## Ce qui change

| Mission (Horde) | Coefficient de PV | Meilleure marge | Compositions gagnantes sur 30 |
| --- | --- | --- | --- |
| 34 | 124 → 125 | 72 % → 48 % | 4 → 2 |
| 37 | 118 → 119 | 93 % → 70 % | 6 → 5 |
| 64 | 103 → 104 | 75 % → 68 % | 4 → 4 |

Sur toute la campagne, **374 réglages sur 398** sont dans la cible de 40 à 70 %, aucun en dessous et 24 au-dessus (371, 0 et 27 en v0.246). Les marges sont des moyennes sur les tirages 7, 8 et 9 : selon le tirage, la mission 34 va de 35 à 55 %, la 37 de 50 à 90 % et la 64 de 17 à 100 %.

## Pourquoi les 24 autres réglages ne bougent pas

Chaque réglage a été relevé point par point, dans les vraies suites de campagne, tant que l'armée de référence gagnait et que la meilleure marge restait d'au moins 40 %.

- **10 réglages basculent d'un coup.** Le point suivant fait tomber la marge de 73-97 % à 25-38 % : Alliance 16, 23, 72, 79, 105, 173 et 178, Horde 11, 79 et 131.
- **14 réglages sont limités par l'armée de référence**, qui perd après 0 à 2 points de hausse : Alliance 2, 3, 33, 39 et 180, Horde 2, 3, 22, 23, 38, 39, 41, 44 et 175.

Ces réglages gardent leur coefficient : les petites hausses possibles ne les ramènent pas dans la cible.

La marge ne regarde que la meilleure des 30 compositions. Seules les missions 2 et 3 sont largement gagnées (15 à 22 compositions sur 30, dans chaque faction). Sur les autres réglages hors cible, 2 à 10 compositions gagnent.

## Option écartée

Laisser l'armée de référence perdre sur certaines missions aurait permis de durcir surtout les missions 2, 3, 39 et 44. Le porteur ne l'a pas retenue : l'armée de référence reste garantie sur toutes les missions.

## Méthode et données

30 compositions, trois arbres, tirages 7, 8 et 9, première offre de bonus (`prototype/tools/faction_study.gd`). Scripts et mesures : `design/essais/equilibre_bonus/v248/`.
