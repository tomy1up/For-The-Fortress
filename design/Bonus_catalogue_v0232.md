# Catalogue de bonus élargi — v0.232

**Statut.** Premier lot du catalogue élargi demandé par le porteur le 17 novembre 2026 (MAJ-67, O-027) : 24 nouveaux bonus (R-13 à R-36) s'ajoutent aux douze bonus approuvés (R-01 à R-12), soit 36 bonus. Le rythme des choix passe de trois choix (après les vagues 3, 6 et 9) à quatre choix (après les vagues 2, 4, 6 et 8). **Noms, valeurs et rythme sont des réglages de prototype à confirmer** (MAJ-68). La rareté et la relance forment le second lot.

## Familles

| Famille | Bonus | Intention |
| --- | --- | --- |
| Rôle | R-13 Salves rapprochées, R-14 Coups de maître, R-15 Tir de barrage, R-16 Sortilèges durables, R-17 Vue dégagée, R-18 Mêlée acharnée, R-19 Soutien efficace | Récompenser une armée orientée vers un rôle (unités rapides, lentes, de groupe, à malédiction, de longue ou courte portée, de soutien) |
| Contrepartie | R-20 Pari risqué, R-21 Cadence effrénée, R-22 Tir tendu, R-23 Marché noir, R-24 Forteresse blindée, R-25 Élite sacrifiée | Un gain fort payé par une perte : choisir selon sa situation |
| Situation et synergie | R-26 Formation serrée, R-27 Francs-tireurs, R-28 Armée variée, R-29 Dernier rempart, R-30 Embuscade, R-31 Premier sang, R-32 Coup de grâce, R-33 Moral montant, R-34 Chasseurs de rapides, R-35 Briseurs de hordes, R-36 Prime de butin | Récompenser une disposition, une diversité, un moment de la route ou un type d'ennemi |

Le texte de chaque bonus est dans le GDD (section 26) et dans `prototype/scripts/campaign_data.gd` (`BONUSES`).

## Règles de calcul

- **Rôles lus sur les valeurs de base** de chaque unité (`ROSTER`), pas sur une liste figée : rapide = intervalle d'attaque ≤ 1,3 s ; lent = intervalle ≥ 2,4 s ; longue portée = portée de base ≥ 4,5 ; courte portée = portée de base ≤ 3,6 ; effet de groupe = plafond de victimes secondaires > 0 ; dégâts sur la durée = malédiction ; soutien = aura, marque, ralentissement, pillage ou charge volatile. Une unité de boutique entre dans un rôle selon ses propres valeurs.
- Les pourcentages de dégâts s'additionnent avec ceux du catalogue d'origine (section 27 du GDD), sans multiplication successive.
- R-20 et R-24 modifient immédiatement les PV de forteresse ; R-20 ne descend jamais sous 1 PV.
- R-23 : prix d'achat réduits de 25 %, améliorations et spécialisations augmentées de 15 %, arrondi supérieur.
- R-36 : or de chaque élimination × 1,25, arrondi à l'or le plus proche.
- Chaque bonus a un bénéficiaire potentiel dans les deux factions (contrôlé par `tests/test_bonus_catalogue.gd`).
- **Choix de référence** des tests et des études (`Model.reference_bonus`) : la première offre sans contrepartie (R-20 à R-25 écartés quand une autre offre existe).

## Compatibilité des anciens rapports

Les règles de la v0.232 sont portées par `rules_v232` (`valley_model.gd`). Un rapport d'une version antérieure se rejoue avec l'ancien tirage (douze bonus, choix après les vagues 3, 6 et 9) : `Replay.rules_v232_for(version)`. Les tests historiques qui dépendent d'un tirage précis épinglent l'ancien catalogue.

## Mesure : ce que les bonus changent (étude du 20 novembre 2026)

Étude `tools/faction_study.gd` : 20 missions (5, 15, …, 195), deux factions, trois arbres, dix compositions d'unités de base, soit 1 200 parties par configuration. Données : `design/essais/equilibre_bonus/parties_*.txt`.

| Configuration | Victoires (toutes compositions) | Marge moyenne de PV de forteresse |
| --- | --- | --- |
| Ancien système (12 bonus, 3 choix) | 27,4 % | 16,7 % |
| Nouveau système, tirage 7 | 28,7 % | 16,1 % |
| Nouveau système, tirage 8 | 35,8 % | 24,5 % |
| Nouveau système, tirage 9 | 29,3 % | 18,7 % |
| Nouveau système, choix sans contrepartie | 42,8 % | 30,9 % |

- **Variance** : pour une même partie (mission, faction, arbre, composition), la marge varie en moyenne de 12 points selon le tirage des bonus (jusqu'à 100 points).
- **Puissance** : un choix au hasard ajoute peu en moyenne ; un choix réfléchi (sans contrepartie) ajoute environ 15 points de victoires.
- **Plafond inchangé** : avec l'ancien comme avec le nouveau système, la meilleure composition de presque chaque mission finissait à 100 % de marge. Le catalogue seul ne répondait donc pas à l'observation du porteur (une réussite à 100 % pour qui connaît les bonnes unités) : d'où le rééquilibrage des PV d'ennemis (`design/Rebalancage_bonus_v0232.md`).

## Limites

- L'étude joue une stratégie d'achat et d'amélioration fixe et choisit la première offre de bonus (ou la première sans contrepartie) : elle ne joue pas comme un joueur qui adapte sa composition aux bonus proposés.
- Aucun bonus n'a encore été jugé en partie réelle par le porteur.
