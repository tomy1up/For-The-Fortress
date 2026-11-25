# Bonus faibles et trop forts rééquilibrés (v0.254)

**Statut.** Décision du porteur du 24 novembre 2026 : « Tout valider » sur les dix changements proposés, pour que le tirage des bonus pèse moins. Valeurs et recalage : réglages de prototype à confirmer en partie réelle.

## Les dix changements

Chiffres : PV de forteresse restants en moyenne quand le bonus est pris au premier choix par l'armée de référence (Alliance / Horde ; 40 missions, tirages 7, 8 et 9). Pour comparer, Armes affûtées, un commun ordinaire, donne 51 / 33.

| Bonus | Avant | Depuis la v0.254 | Mesure avant → après |
| --- | --- | --- | --- |
| Lames runiques (rare) | +20 % dégâts, +10 % cadence | +12 % dégâts, +6 % cadence | 92 / 86 → 80 / 57 |
| Exercice de tir (R-02) | +12 % cadence | +8 % cadence | 76 / 60 → 63 / 42 |
| Cadence effrénée | +25 % cadence, −0,5 portée | +15 % cadence, −0,5 portée | 83 / 70 → 63 / 36 |
| Pari risqué | +30 % dégâts, −4 PV | +20 % dégâts, −4 PV | 79 / 70 → 62 / 47 |
| Chausse-trappes (rare) | ralenti 2 s à l'apparition | ralenti 3 s au premier tir direct reçu | 20 / 7 → 28 / 32 |
| Temps suspendu (épique) | ralenti 4 s à l'apparition, ralentissements +50 % | ralenti 8 s au premier tir direct reçu, ralentissements +50 % | 21 / 9 → 29 / 51 |
| Malédiction tenace (rare) | 3 échéances au lieu de 2 | 3 échéances et +100 % aux dégâts sur la durée | Horde 7 → 28 |
| Marché noir | achats −25 %, améliorations +15 % | achats −25 %, améliorations +5 % | 41 / 17 → 46 / 25 |
| Forteresse blindée | +8 PV, −10 % dégâts | +8 PV, −5 % dégâts | 22 / 3 → 35 / 9 |
| Élite sacrifiée | niveaux 3-4 +30 %, niveaux 1-2 −10 % | niveaux 3-4 +30 %, niveaux 1-2 −5 % | 17 / 3 → 28 / 7 |

- **Ralentissement au premier tir reçu.** À l'apparition, les ennemis sont loin des tours : le ralentissement servait à peine. Désormais, chaque ennemi est ralenti une seule fois, quand il reçoit son premier tir direct. Les éclats, rebonds et dégâts sur la durée ne déclenchent rien.
- **Les trois bonus à contrepartie** (Pari risqué, Forteresse blindée, Élite sacrifiée) restent faibles au tout premier choix : ce sont des bonus de fin de partie.
- **Les valeurs mesurées avant le choix** viennent d'essais temporaires (`premesure_bonus.py`, `premesure_bonus.json`, `premesure_bonus_crans.json`). D'autres crans ont été essayés, par exemple Lames runiques +10 % / +5 % ou Temps suspendu 10 s.
- **Code** : `ValleyModel.rules_v254`, `_trap_on_first_hit`, `CALTROPS_HIT_SECONDS`, `STASIS_HIT_SECONDS`, `_market_upgrade_factor`. Les rapports d'avant la v0.254 gardent les anciennes valeurs (`Replay.rules_v254_for`). Test : `prototype/tests/test_bonus_values_v254.gd`.

## Effets mesurés

**Écart de valeur entre bonus** (bonus imposé au premier choix) : il s'est nettement resserré. Pour les communs de l'Alliance, il allait de 13 à 83 % de PV restants ; il va maintenant d'environ 28 à 63 %. Pour la Horde, il passe de 2-70 % à environ 7-47 %.

**Poids du tirage pour l'armée de référence** (premier choix naturel, 40 missions, tirages 7 à 16 ; `poids_tirage.txt`) :

| | Victoires | PV moyens | Écart moyen entre tirages d'une mission |
| --- | --- | --- | --- |
| Alliance, v0.253 → v0.254 | 92 → 92 % | 62 → 60 % | 81 → 78 points |
| Horde, v0.253 → v0.254 | 79 → 79 % | 44 → 43 % | 79 → 77 points |

Le gain est faible : les épiques et les rares les plus forts (Ascension, Armée d'élite, Fortune royale, Frénésie sanguinaire, Trésor de guerre) font encore la différence quand ils sortent. De plus, la stratégie de référence n'utilise pas la relance.

## Recalage de la campagne

Les bonus forts baissés étaient souvent pris par la stratégie de mesure, qui prend la première offre. Résultat : la marge moyenne passe de 63 à 58 % (Alliance) et de 57 à 50 % (Horde) ; 30 réglages tombent sous 40 % et 19 dépassent 70 % (`marges_avant_recalage.json`).

1. **Recherche dans les deux sens** (`recherche254.py`, `recherche.json`) : coefficient de PV ramenant la meilleure marge entre 40 et 70 %, avec la plus petite variation. 41 coefficients changent.
   - Restent hors cible : les falaises Alliance 13 et 40, Alliance 67 et Horde 40 juste sous 40 % au cran le plus proche, et Horde 43, laissée à 72 % plutôt qu'à 37 %.
   - Alliance 33 garde son coefficient : la hausse fait perdre l'armée de référence.
2. **Garde de l'armée de référence** (`recherche_garde254.py`, `recherche_garde.json`). Sur le tirage des suites, la référence prend Exercice de tir au premier choix. À +8 %, elle perdait 23 missions, surtout de la Horde aux chapitres 3 à 5. Leurs coefficients ont été baissés de 1 à 10 points, au plus haut niveau qui la fait regagner : Horde 33 de 112 à 102, Horde 39 de 115 à 106.
Au total, **62 coefficients changent** par rapport à la v0.253 : 12 hausses, 50 baisses (surtout côté Horde).

3. **Missions sous la courbe de base** (92 à 99 %, décision du porteur du 23 novembre 2026) : la liste suit les coefficients.
   - Ajouts : Alliance 84 ; Horde 22, 23, 25, 60, 84 et 91.

## Sur toute la campagne

**379 réglages sur 398 dans la cible**, 2 juste sous 40 % (Alliance 67, Horde 40), 17 au-dessus (386, 0 et 12 en v0.253) :
- Alliance : 2, 3, 13, 33, 40, 132 ;
- Horde : 2, 3, 25, 28, 33, 34, 39, 43, 46, 81, 88.

La plupart des nouveaux réglages au-dessus de la cible sont ceux dont les PV ont dû baisser pour que l'armée de référence gagne ; la Horde 33 monte à 100 %. Marge moyenne de la meilleure composition : Alliance 58 %, Horde 53 %. La nouvelle base est `marges_campagne.json`.

## Limites et suites possibles

- La garde de l'armée de référence dépend d'un seul tirage, où elle reçoit Exercice de tir dès le premier choix. Toute baisse de ce bonus la fragilise mission par mission.
- Pour réduire encore le poids du tirage, il faudrait toucher aux épiques et aux rares les plus forts, ou apprendre la relance à la stratégie de référence.

Données et scripts : `design/essais/equilibre_bonus/v254/`.
