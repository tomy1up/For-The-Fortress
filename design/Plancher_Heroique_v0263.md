# Plancher des PV de l'Héroïque (v0.263)

**Statut.** Décisions du porteur du 28 novembre 2026, après la v0.262 :

- **Règle.** Les PV ennemis montent avec la difficulté, mission par mission. L'Héroïque a toujours plus de PV que le Normal, et le Mythique en aura plus que l'Héroïque. Ce sont les bonus qui doivent porter le joueur.
- **Plancher.** L'Héroïque garde au moins les PV du Normal + 5 %. Le porteur l'a choisi parmi trois planchers mesurés (+5, +10 et +20 %).
- **Suite.** Claude Code doit proposer un renfort des bonus, pour ramener le joueur avisé dans la cible de 40 à 70 % de marge.

Le plancher est validé par le porteur ; son effet reste à confirmer en jeu.

## Ce qui change

- Le coefficient de PV d'une mission héroïque vaut au moins 105 % des PV du Normal de la faction. Les coefficients calibrés en v0.262 restent la base ; ceux qui étaient plus bas sont relevés à 105.
- **149 réglages sur 400 sont relevés** : 72 pour l'Alliance et 77 pour la Horde.
  - Le chapitre 10 compte un seul réglage relevé (Alliance).
  - Tous les autres sont aux chapitres 11 à 20.
  - Les 95 réglages qui étaient sous les PV du Normal en font partie.
- Aucune mission héroïque n'a désormais autant ou moins de PV que le Normal.
- Exemple, mission 101 : 256 % en Héroïque pour l'Alliance (Normal : 244 %) au lieu de 207 % ; 260 % pour la Horde (Normal : 248 %) au lieu de 223 %.
- Les chapitres 1 à 9 ne changent pas : leurs coefficients sont déjà bien au-dessus (de 106 à 224 %).

## Effet mesuré

Héroïque complet, joueur avisé, meilleure des 30 compositions, tirages de contrôle 4, 5 et 6 (jamais vus par le calibrage). Fichiers : `design/essais/equilibre_bonus/v262/planchers_heroique.py`, `planchers_456.json`, `planchers.log`.

| Plancher | Marge moyenne aux chapitres 11 à 20 | Missions perdues par toutes les compositions (sur 400) |
| --- | --- | --- |
| Aucun (v0.262) | 51 % (Alliance), 54 % (Horde) | 0 |
| **+5 % (retenu)** | **35 %, 32 %** | **8** |
| +10 % | 24 %, 22 % | 21 |
| +20 % | 9 %, 9 % | 76 |

**Sur les 200 missions avec le plancher retenu :**

| | Alliance | Horde |
| --- | --- | --- |
| Marge moyenne | 42 % (49 % en v0.262) | 40 % (51 %) |
| Réglages dans la cible | 108 sur 200 (151) | 101 sur 200 (143) |
| Sous 40 % | 87 | 92 |
| Missions perdues sur les trois tirages | 3 (151, 161, 171) | 5 (141, 150, 172, 177, 183) |
| Missions perdues sur au moins un tirage | 29 | 51 |

**Par chapitre, à partir du chapitre 10** (réglages relevés, marge moyenne sans plancher puis avec, missions dans la cible avec le plancher, missions perdues sur les trois tirages) :

| Chapitre | Alliance : relevés | sans | avec | dans la cible | perdues | Horde : relevés | sans | avec | dans la cible | perdues |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10 | 1 | 60 % | 60 % | 8 | 0 | 0 | 34 % | 34 % | 2 | 0 |
| 11 | 7 | 54 % | 37 % | 4 | 0 | 7 | 45 % | 29 % | 2 | 0 |
| 12 | 7 | 61 % | 47 % | 5 | 0 | 5 | 57 % | 52 % | 6 | 0 |
| 13 | 7 | 58 % | 39 % | 4 | 0 | 8 | 60 % | 44 % | 7 | 0 |
| 14 | 9 | 44 % | 27 % | 1 | 0 | 10 | 58 % | 20 % | 0 | 0 |
| 15 | 7 | 47 % | 32 % | 3 | 0 | 9 | 54 % | 29 % | 3 | 2 |
| 16 | 5 | 50 % | 40 % | 5 | 1 | 5 | 51 % | 41 % | 4 | 0 |
| 17 | 7 | 48 % | 32 % | 4 | 1 | 10 | 57 % | 33 % | 3 | 0 |
| 18 | 9 | 53 % | 30 % | 3 | 1 | 8 | 55 % | 23 % | 2 | 2 |
| 19 | 9 | 48 % | 33 % | 4 | 0 | 8 | 44 % | 17 % | 1 | 1 |
| 20 | 4 | 47 % | 37 % | 6 | 0 | 7 | 57 % | 35 % | 5 | 0 |

**Ce qu'on en retient :**

- Les chapitres 1 à 10 restent dans la cible.
- Aux chapitres 11 à 20, le joueur avisé passe sous la cible : environ un tiers de marge au lieu de la moitié.
- Huit missions sont perdues par toutes les compositions sur les trois tirages de contrôle. Les plus dures sont aux chapitres 14, 18 et 19 de la Horde.
- C'est l'écart que le renfort des bonus devra combler.

## Mythique

La même règle s'appliquera au lot 6 : chaque mission du Mythique aura plus de PV que la même mission en Héroïque. Dans la course par chapitre, les bonus se gardent d'une mission à l'autre et doivent porter le joueur.

## Technique

- **Catalogue** (`prototype/scripts/campaign_catalogue.gd`) : `HEROIC_MIN_COEFFICIENT := 105`. `heroic_hp_coefficient()` renvoie le plus grand du coefficient calibré et du plancher. `HEROIC_HP_COEFFICIENTS` garde les valeurs de la v0.262.
- **Rapports des versions 0.257 à 0.262** : ils se rejouent sans changement, puisque le rapport garde les PV joués.
- **Tests** (`test_heroic_calibration.gd`) :
  - coefficient = plancher ou coefficient calibré ;
  - PV héroïques strictement supérieurs à ceux du Normal pour les 400 réglages ;
  - 149 réglages relevés.

## Limites

- Les huit missions perdues et la marge d'un tiers aux chapitres 11 à 20 attendent le renfort des bonus.
- Mesure faite avec un joueur avisé ; un joueur qui prend la première offre aura plus de mal.
- Aucun essai en jeu par le porteur.
