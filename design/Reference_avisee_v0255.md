# Armée de référence en joueur avisé (v0.255)

**Statut.** Décisions du porteur du 25 novembre 2026 :
- « Joueur avisé d'abord » ;
- puis « Garantie des tests seulement » : l'armée de référence des suites de campagne choisit ses bonus comme un joueur avisé. **La cible de difficulté ne change pas** : 40 à 70 % de marge pour la meilleure des 30 compositions, mesurée avec la première offre (MAJ-79).

Les notes des bonus et les coefficients recalés sont des réglages de prototype à confirmer en partie réelle.

## Pourquoi

L'armée de référence doit gagner chaque mission dans les suites de campagne : c'est la garantie de difficulté du projet. Jusqu'ici, elle prenait toujours la première carte sans contrepartie et ne relançait jamais. Son résultat dépendait donc du tirage, parce que les suites jouent toutes le même. Sur ce tirage, elle reçoit Exercice de tir dès le premier choix : quand ce bonus est passé de +12 à +8 % en v0.254, elle a perdu 23 missions, et leurs PV ont dû baisser.

## La règle

- `tests/reference_army.gd`, `choose_bonus` : à chaque choix, la référence prend la carte la **mieux notée pour sa faction**. Si la meilleure carte proposée est sous la médiane des notes (50 pour l'Alliance, 30 pour la Horde) et qu'une relance reste, elle **relance une fois** puis prend la meilleure carte des nouvelles offres.
- **Notes** (`BONUS_VALUES`) : PV de forteresse restants (en %) quand le bonus est imposé au premier choix de l'armée de référence (40 missions, tirages 7, 8 et 9, règles v0.254 ; `valeur_bonus.txt`, `notes_bonus.json`). C'est un jugement moyen, comme celui d'un joueur qui connaît ses bonus, sans rejouer la mission.
- **Où elle s'applique** : les 18 suites qui jouent l'armée de référence ; au chapitre 3, la Horde seulement ; au chapitre 4 (Vents contraires), seulement quand la composition jouée est celle de la référence. Ailleurs, et pour la stratégie de premier joueur des missions 1 à 3, le choix simple d'avant reste en place.
  - Appliquées à d'autres compositions, ces notes trompent le choix : l'archer, l'arbalétrier et le mage de l'Alliance du chapitre 3 perdaient les missions 21, 23 et 24.
- Les contrôles de budget de deux suites comptent maintenant l'or donné par Trésor de guerre et Fortune royale, que le choix avisé peut retenir.
- Le jeu ne change pas de règle. Seuls les coefficients de PV ci-dessous changent.
- Tests : `prototype/tests/test_reference_wise.gd`. Outil : `POLICY=refwise` dans `tools/faction_study.gd`.

## Une garantie qui ne dépend presque plus du tirage

Victoires de l'armée de référence sur les 200 missions (outil d'étude, coefficients de la v0.255 ; `reference_premiere_offre.json`, `reference_avisee.json`) :

| | Tirage 7 | Tirage 8 | Tirage 9 |
| --- | --- | --- | --- |
| Alliance, première offre | 198 | 146 | 193 |
| Alliance, joueur avisé | 200 | 194 | 193 |
| Horde, première offre | 177 | 89 | 195 |
| Horde, joueur avisé | 198 | 198 | 193 |

## Missions resserrées

Les 23 coefficients baissés par la garde de la v0.254 ont été remontés vers leur valeur d'avant cette garde, qui était dans la cible. L'armée de référence avisée devait toujours gagner dans les 28 suites de campagne (`resserrage255.py`, dossier `resserrage/`).
- **20 retrouvent leur valeur** : Horde 21, 22, 23, 25, 28, 39, 46, 47, 49, 50, 81, 84, 88, 91, 120, 141, 145, 149, 162 et 177.
- **Horde 33** : remontée de 102 à 111 (la cible était 112).
- **Horde 34 et Alliance 132** : restent à 122 et 111, car un point de plus fait perdre la référence.
- 21 coefficients changent en tout, tous côté Horde. Les Horde 22, 23, 25, 84 et 91 repassent à 100 ou plus et sortent de la liste des missions sous la courbe.

## Sur toute la campagne

**386 réglages sur 398 dans la cible** (379 en v0.254), 2 juste sous 40 %, 10 au-dessus :

| Cas | Réglages |
| --- | --- |
| Prise en main | missions 2 et 3 des deux factions |
| Falaises (un point de plus fait tomber la marge sous 40 %) | Alliance 13, 40 ; Horde 43 |
| Stratégie propre au chapitre 4 | Alliance 33 |
| Limités par la référence | Alliance 132, Horde 34 |
| Juste sous 40 % | Alliance 67, Horde 40 |

Marge moyenne de la meilleure composition : Alliance 58 %, Horde 52 %. La nouvelle base est `marges_campagne.json`.

## Limites

- Les notes valent pour la composition de référence de chaque faction ; elles ne jugent pas une autre armée.
- Le joueur avisé ne connaît pas la mission en cours ; il reste moins fort que le « joueur avisé » de la v0.238, qui rejoue chaque offre, mais il est assez rapide pour les suites de test.

Données et scripts : `design/essais/equilibre_bonus/v255/`.
