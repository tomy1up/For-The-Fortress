# Calibrage de l'Héroïque (v0.262)

> **Plancher en v0.263** (décision du porteur, 28 novembre 2026) : l'Héroïque a toujours plus de PV que le Normal, au moins + 5 %. Les 95 réglages sous les PV du Normal, et 54 autres, sont relevés. Voir `Plancher_Heroique_v0263.md`. Cette fiche décrit la v0.262.

**Statut.** Lot 5 du cadrage du 25 novembre 2026 (`Cadrage_Heroique_Mythique_2026-11-25.md`). Le porteur a validé la cible le 27 novembre 2026 (« Oui, calibrer »). La meilleure des 30 compositions, jouée par un joueur avisé, doit finir chaque mission héroïque avec 40 à 70 % de ses PV de forteresse, mission par mission et faction par faction. Les coefficients obtenus sont des réglages de prototype à confirmer en jeu.

## Ce qui change

- Les PV ennemis de l'Héroïque ne sont plus ceux du Normal × 1,3 pour toutes les missions.
- Chaque mission reçoit, pour chaque faction, son propre **coefficient**, appliqué aux PV du Normal de cette faction. Les PV restent bornés de 100 à 800 %.
- Le Normal ne change pas. Champions, rappels, bonus héroïques et récompenses (PO × 1,5, sans XP) non plus.
- Dans le jeu, seul le pourcentage « PV ennemis » affiché pour une mission héroïque change, sur l'écran de campagne et dans l'aperçu de mission.

## Coefficients obtenus

Coefficient moyen par chapitre, en % des PV du Normal de la faction (v0.257 à v0.261 : 130 partout).

| Chapitre | Alliance | Horde |
| --- | --- | --- |
| 1 | 180 (154 à 200) | 210 (188 à 224) |
| 2 | 158 (150 à 166) | 191 (170 à 202) |
| 3 | 148 (141 à 159) | 161 (151 à 175) |
| 4 | 138 (128 à 145) | 152 (141 à 167) |
| 5 | 136 (124 à 147) | 144 (127 à 157) |
| 6 | 131 (121 à 137) | 149 (126 à 163) |
| 7 | 126 (113 à 137) | 134 (121 à 145) |
| 8 | 119 (107 à 135) | 123 (115 à 133) |
| 9 | 118 (106 à 129) | 124 (111 à 134) |
| 10 | 117 (102 à 123) | 127 (105 à 149) |
| 11 | 99 (85 à 115) | 99 (88 à 112) |
| 12 | 102 (96 à 113) | 106 (98 à 119) |
| 13 | 100 (91 à 109) | 100 (87 à 114) |
| 14 | 98 (85 à 107) | 92 (85 à 104) |
| 15 | 100 (91 à 109) | 99 (82 à 114) |
| 16 | 104 (94 à 114) | 104 (93 à 118) |
| 17 | 100 (92 à 112) | 98 (85 à 104) |
| 18 | 98 (91 à 110) | 98 (91 à 109) |
| 19 | 99 (91 à 105) | 98 (90 à 108) |
| 20 | 104 (94 à 111) | 101 (90 à 120) |

**Ce qu'on en retient :**

- **Chapitres 1 à 10 :** l'Héroïque monte nettement au-dessus du Normal, de 1,8 à 2,1 fois ses PV au chapitre 1, puis environ 1,2 fois au chapitre 10. Le joueur y arrive avec ses 51 points de talent, alors que le Normal de ces chapitres se joue avec bien moins.
- **Chapitres 11 à 20 :** les PV restent proches de ceux du Normal (de 82 à 120 %). Les talents y sont les mêmes qu'en Normal. Deux rappels par mission et les champions pèsent plus que les deux bonus héroïques.
- **95 réglages sur 400 ont moins de PV que le Normal** (44 de l'Alliance, 51 de la Horde), tous aux chapitres 11 à 20. La difficulté de l'Héroïque y vient alors des champions et des rappels, pas des PV. Comme convenu, aucun plancher n'a été imposé ; le porteur peut en demander un.
- Le passage du chapitre 10 au chapitre 11 est marqué (de 117 à 99 % côté Alliance) : c'est là que commencent les deux rappels par mission.

## Méthode

- **Mesure.** Héroïque complet (PV, champions, rappels, bonus héroïques avec second choix), 51 points de talent. On garde la meilleure des 30 compositions, jouées par le joueur avisé des mesures (`POLICY=refwise` : bonus choisis d'après leur note, relance des offres faibles). La marge est le pourcentage des PV de forteresse restants.
- **Recherche par encadrement**, réglage par réglage (200 missions × 2 factions) :
  - phase 1 sur le tirage 7 ;
  - phase 2 sur la moyenne des tirages 7, 8 et 9, en partant du coefficient de la phase 1.
- **Coefficients** essayés de 30 à 320 %. Le premier essai part de la marge mesurée en v0.261.
- **Volume.** Environ 4 650 études de 30 compositions, réparties sur 14 processus en parallèle.
- **Outils.**
  - `prototype/tools/faction_study.gd` : variable `HEROIC_COEF`, qui impose un coefficient ;
  - script `design/essais/equilibre_bonus/v262/calibrage_heroique.py`, état `etat_calibrage.json`, journal `calibrage.log`.

## Résultat sur les tirages du calibrage (7, 8 et 9)

| | Alliance | Horde |
| --- | --- | --- |
| Réglages dans la cible (40 à 70 %) | 192 sur 200 | 194 sur 200 |
| Sous 40 % | 4 | 2 |
| Au-dessus de 70 % | 4 | 4 |
| Marge moyenne | 56 % | 58 % |
| Missions perdues sur les trois tirages | 0 | 0 |

**Quatorze réglages restent hors cible, de 32 à 80 % de marge.** Ce sont des falaises : un point de coefficient de plus fait passer la meilleure composition de plus de 70 % à moins de 40 %, parce qu'une vague devient soudain trop forte. Par exemple, Alliance mission 112 : 95 % de marge à 95, 35 % à 96. Les PV seuls ne peuvent pas les corriger ; on garde le coefficient le plus proche de 55 %.

En v0.261, aux PV × 1,3, le joueur avisé finissait avec 31 % de marge moyenne (Alliance) et 41 % (Horde), et perdait toutes les compositions dans 20 et 12 des 40 missions mesurées.

## Contrôle sur d'autres tirages (4, 5 et 6)

Mêmes règles, mêmes coefficients (ceux du catalogue), mais trois tirages que le calibrage n'a jamais vus. Fichiers : `controle_heroique.py`, `controle_tirages_456.json`.

| | Alliance | Horde |
| --- | --- | --- |
| Réglages dans la cible (40 à 70 %) | 151 sur 200 | 143 sur 200 |
| Sous 40 % | 40 | 44 |
| Au-dessus de 70 % | 9 | 13 |
| Entre 30 et 80 % | 193 | 184 |
| Marge moyenne | 49 % | 51 % |
| Missions perdues sur les trois tirages | 0 | 0 |
| Missions perdues sur au moins un tirage | 4 | 15 |
| Dans la cible en moyenne sur les six tirages (4 à 9) | 178 | 178 |

Marge moyenne par chapitre : tirages du calibrage (7, 8 et 9), puis tirages de contrôle (4, 5 et 6), et nombre de missions du chapitre dans la cible au contrôle.

| Chapitre | Alliance, calibrage | Alliance, contrôle | Alliance, dans la cible | Horde, calibrage | Horde, contrôle | Horde, dans la cible |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 49 % | 42 % | 5 | 61 % | 43 % | 7 |
| 2 | 57 % | 42 % | 4 | 54 % | 46 % | 7 |
| 3 | 59 % | 54 % | 6 | 64 % | 56 % | 9 |
| 4 | 60 % | 47 % | 7 | 61 % | 49 % | 5 |
| 5 | 60 % | 52 % | 9 | 62 % | 56 % | 10 |
| 6 | 57 % | 46 % | 8 | 56 % | 47 % | 7 |
| 7 | 56 % | 43 % | 6 | 61 % | 56 % | 8 |
| 8 | 57 % | 49 % | 9 | 58 % | 50 % | 8 |
| 9 | 53 % | 44 % | 7 | 56 % | 41 % | 5 |
| 10 | 58 % | 60 % | 8 | 60 % | 34 % | 2 |
| 11 | 58 % | 54 % | 10 | 56 % | 45 % | 5 |
| 12 | 49 % | 61 % | 7 | 57 % | 57 % | 8 |
| 13 | 57 % | 58 % | 9 | 57 % | 60 % | 9 |
| 14 | 54 % | 44 % | 5 | 61 % | 58 % | 9 |
| 15 | 53 % | 47 % | 9 | 58 % | 54 % | 8 |
| 16 | 51 % | 50 % | 8 | 54 % | 51 % | 7 |
| 17 | 56 % | 48 % | 9 | 60 % | 57 % | 6 |
| 18 | 54 % | 53 % | 10 | 56 % | 55 % | 9 |
| 19 | 59 % | 48 % | 7 | 55 % | 44 % | 5 |
| 20 | 59 % | 47 % | 8 | 63 % | 57 % | 9 |

**Ce qu'on en retient :**
- Sur des tirages neufs, la marge moyenne reste dans la cible, un peu sous son milieu de 55 % (49 % et 51 %). Elle est environ 7 points plus basse que sur les tirages du calibrage. C'est l'effet attendu d'un choix fait sur trois tirages seulement : on garde le coefficient qui tombe bien sur ces trois-là.
- La marge d'une même mission varie en moyenne de 10 à 11 points d'un groupe de trois tirages à l'autre. Une partie des réglages sort donc de la cible au contrôle (surtout sous 40 %) sans être mal calibrée. 377 réglages sur 400 restent entre 30 et 80 %.
- Aucune mission n'est perdue par toutes les compositions sur les trois tirages de contrôle. En v0.261, aux PV × 1,3, toutes les compositions perdaient 20 des 40 missions mesurées pour l'Alliance et 12 pour la Horde.
- Les chapitres les plus serrés au contrôle sont le chapitre 10 de la Horde (34 %) et les chapitres 1 et 2 de l'Alliance (42 %).

## Technique

- **Catalogue** (`prototype/scripts/campaign_catalogue.gd`) :
  - `HEROIC_HP_COEFFICIENTS`, deux rangées de 200 coefficients (Alliance, Horde) ;
  - `heroic_hp_coefficient(mission, faction)`, qui renvoie 100 hors campagne ;
  - `faction_hp_percent(mission, faction, HEROIC)` = PV du Normal × coefficient, borné de 100 à 800 ;
  - `HEROIC_HP_PERCENT` (130) reste pour mémoire.
- **Rapports des versions 0.257 à 0.261** : ils se rejouent sans changement, puisque le rapport garde les PV ennemis joués.
- **Tests** :
  - `test_heroic_calibration.gd` (nouveau) contrôle la forme de la table, les bornes, la formule, le Normal inchangé, et l'affichage et le lancement de la mission héroïque 101 dans les deux factions ;
  - `test_difficulties.gd` suit la nouvelle formule.

## Limites

- Le porteur n'a pas encore essayé ces coefficients en jeu.
- Le calibrage vise un joueur avisé ; un joueur qui prend la première offre aura plus de mal.
- Les quatorze falaises demanderaient d'autres réglages que les PV (renforts, rythme des vagues), comme en Normal en v0.256.
- 51 points de talent sont supposés : le joueur qui ouvre l'Héroïque a fini les 100 premières missions du Normal, mais n'a pas forcément réparti ses points dans le meilleur arbre.
