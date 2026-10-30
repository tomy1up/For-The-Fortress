# Comparaison des trois missions du prototype

Jeu 0.92 ; 2 592 simulations de politiques fixes, sans profil joueur ni changement d’équilibrage.

**Ce tableau ne mesure pas le taux de victoire des joueurs.** Les mêmes décisions mécaniques sont répétées sur six triplets d’emplacements, quatre compositions, trois moments de tentative d’amélioration et trois graines de tirage. Les compositions, branches et choix de bonus couverts ne représentent pas toutes les stratégies possibles.

## Sans talent persistant

| Faction | Mission | Victoires / cas | Politiques gagnantes sur les 3 graines | Politiques au résultat variable | Défaites par vague atteinte |
| --- | --- | --- | --- | --- | --- |
| Alliance | 1 | 190 / 216 | 59 / 72 | 9 / 72 | vague 7 : 12, vague 8 : 3, vague 9 : 11 |
| Alliance | 2 | 168 / 216 | 45 / 72 | 20 / 72 | vague 4 : 7, vague 5 : 5, vague 6 : 5, vague 7 : 11, vague 8 : 15, vague 9 : 5 |
| Alliance | 3 | 212 / 216 | 68 / 72 | 4 / 72 | vague 8 : 4 |
| Horde | 1 | 164 / 216 | 50 / 72 | 9 / 72 | vague 4 : 9, vague 5 : 7, vague 6 : 14, vague 7 : 8, vague 8 : 10, vague 9 : 4 |
| Horde | 2 | 77 / 216 | 17 / 72 | 14 / 72 | vague 4 : 46, vague 5 : 17, vague 6 : 49, vague 7 : 19, vague 8 : 7, vague 10 : 1 |
| Horde | 3 | 106 / 216 | 30 / 72 | 12 / 72 | vague 3 : 18, vague 4 : 26, vague 5 : 17, vague 6 : 14, vague 7 : 16, vague 8 : 13, vague 9 : 6 |

Les différences entre missions combinent changement de tracé, positions et PV. Elles ne permettent pas d’attribuer à la seule hausse de 1 % les victoires ou défaites. Un résultat variable montre la sensibilité de cette politique aux trois tirages testés, sans mesurer la probabilité de victoire humaine.

## Premier point en mission 3

Les trois choix de premier talent sont évalués séparément : un seul point investi à la fois, tel qu’obtenable après les deux premières victoires. Chaque essai est comparé à la même faction, au même placement, à la même composition, à la même tentative d’amélioration et à la même graine sans talent.

| Faction | Premier talent | Victoires / cas | Défaite devenue victoire | Victoire devenue défaite |
| --- | --- | --- | --- | --- |
| Alliance | Remparts renforcés | 212 / 216 | 0 | 0 |
| Alliance | Entraînement | 216 / 216 | 4 | 0 |
| Alliance | Étude des arcanes | 212 / 216 | 0 | 0 |
| Horde | Entraînement | 134 / 216 | 28 | 0 |
| Horde | Rituels | 111 / 216 | 5 | 0 |
| Horde | Explosifs | 129 / 216 | 23 | 0 |

## Lecture des résultats

Des politiques sans talent gagnent les trois missions dans les deux factions. Pour l’Alliance, la troisième carte est plus favorable que la deuxième aux politiques testées, malgré ses PV ennemis supérieurs. Il faut comparer la couverture et les compositions, et pas seulement ajuster les PV.

Le premier point peut changer certains résultats sans annuler l’intérêt du placement et des unités. Ces relevés n’autorisent pas à conclure qu’un arbre est globalement supérieur : seuls trois talents d’entrée à un rang sont évalués, avec quatre compositions et une politique de bonus imposée. Les talents majeurs et les builds avancés ne sont pas couverts.

La plupart des défaites couvertes surviennent avant la vague finale. Le niveau de pression du boss reste à confronter à des parties humaines ; sa survie ou sa mort dans ces stratégies n’est pas une validation de ses sensations de combat.

## Compositions et emplacements

| Composition | Alliance dans l’ordre de recrutement | Horde dans l’ordre de recrutement |
| --- | --- | --- |
| A | Archer, arbalétrier, mage | Lanceur de haches, sapeur, chaman |
| B | Archer, mage, arbalétrier | Lanceur de haches, chaman, sapeur |
| C | Deux arbalétriers, puis archer | Deux sapeurs, puis lanceur de haches |
| D | Deux archers, puis mage | Deux lanceurs de haches, puis chaman |

Triplets testés, dans l’ordre des recrutements : E1/E2/E3, E2/E3/E5, E2/E4/E5, E1/E3/E5, E3/E5/E6 et E3/E4/E6. Les identifiants d’emplacements restent les mêmes, mais leurs positions dépendent de la carte. Les autres emplacements ne sont pas utilisés par ces politiques.

## Politique et limites

Deux recrues au départ ; tentative d’amélioration de la première aux vagues 1, 2 ou 3 ; troisième recrue à partir de la vague 4 ; améliorations à partir de la vague 5, branche A ; premier bonus proposé. Aucun revenu ajouté, aucune opération forcée. Un seul point, facultatif, est simulé uniquement en mission 3.

Une demande d’amélioration refusée faute d’or n’est pas forcée ; aucune ressource ne s’ajoute au budget du jeu. Les branches A et le premier bonus proposé sont choisis par cette politique : elle n’adapte pas ses achats à la vague, ne vend pas, n’utilise que trois emplacements et peut gaspiller de l’or ou du potentiel. Une défaite ne prouve donc pas qu’une carte est impossible.

Le contrôle rapide de douze scénarios compare aussi de petits et grands pas de simulation et rejoue les rapports complets. Le grand relevé contrôle le budget et le résultat terminal de chaque cas, mais ne rejoue pas 2 592 rapports. Les sources de réalisation sont identifiées par leurs empreintes ; aucun profil joueur, sauvegarde, achat en boutique ou économie de campagne n’est simulé.

## Suite du travail

Comparer ces situations aux essais humains, en relevant les placements, bonus et choix de talents. Prioriser les difficultés de compréhension avant toute modification de statistiques. Le barème de PV, les talents et les cartes restent des réglages de prototype ; aucune hausse générale de puissance ni nouvelle règle n’est déduite de cet audit.

## Reproduire

Lancer Godot 4.7.2 en mode headless avec le projet `prototype`, le script `res://tools/survey_campaign_sample.gd`, puis `-- --output=<nouveau fichier JSON hors du profil joueur>`. Ajouter `--smoke` pour les douze cas avec rejeu, et `--small-steps` pour les vérifier à pas de 0,05 seconde. Le relevé complet conserve trois graines : 7, 42 et 2026.

Exécuter ensuite `prototype/tools/analyse_campaign_sample.py <rapport.json> --markdown <nouvelle synthèse.md> --summary <nouvelle synthèse.json>`. Les sorties doivent être nouvelles. Ces outils de conception ne sont pas nécessaires pour lancer le jeu Windows.

[Données complètes](essais/v092_comparaison_missions.json), [synthèse chiffrée](essais/v092_synthese_missions.json), [vérifications](essais/v092_verification_comparaison_missions.json).
