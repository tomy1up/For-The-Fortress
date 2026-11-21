# Bonus : rareté, relance et 24 bonus rares et épiques — v0.233

**Statut.** Second lot du catalogue, décidé par le porteur le 21 novembre 2026 (O-027) : trois raretés (commun, rare, épique), environ 70 % de communs, 25 % de rares et 5 % d'épiques, plus de rares en fin de partie ; une relance gratuite par partie qui remplace les trois offres ; 24 bonus rares et épiques « à part, uniques et plus marquants » pour atteindre environ 60 bonus. Le porteur veut poser toute la base maintenant et régler l'équilibre ensuite. **Noms, valeurs, pondérations et effets sont des réglages de prototype à confirmer** (MAJ-70).

## Rareté et tirage

- Les 36 bonus de la v0.232 sont **communs** ; R-37 à R-52 sont **rares** (16) ; R-53 à R-60 sont **épiques** (8). Total : 60 bonus.
- Chaque carte de l'offre tire d'abord sa rareté, puis un bonus de cette rareté (poids égaux), jamais un bonus déjà pris ni une autre carte de l'offre. Si une rareté est épuisée, la carte prend une rareté voisine.
- Pondérations [commun, rare, épique] selon le rang du choix (`Campaign.RARITY_WEIGHTS`) :

| Choix | Après la vague | Commun | Rare | Épique |
| --- | --- | --- | --- | --- |
| 1er | 2 | 80 % | 18 % | 2 % |
| 2e | 4 | 72 % | 24 % | 4 % |
| 3e | 6 | 64 % | 29 % | 7 % |
| 4e | 8 | 56 % | 34 % | 10 % |
| Moyenne | | 68 % | 26 % | 6 % |

- Les cartes rares et épiques portent une étiquette (« Rare » en bleu, « Épique » en violet) et leur nom prend la même couleur (habillage fonctionnel de prototype ; un habillage dessiné éventuel relèvera de Codex).

## Relance

- Une relance gratuite par partie (`REROLLS_PER_RUN = 1`) : le bouton « Relancer les offres · gratuit » remplace les trois offres par trois autres, en évitant les trois offres remplacées. Le tirage suit la rareté du même choix.
- Pas de coût en or : l'or n'est pas illimité, un prix en or ferait concurrence à l'achat d'unités (avis du porteur). D'autres relances pourront plus tard venir d'un bonus, d'un talent ou de la boutique.
- La relance est inscrite au journal de la partie (`bonus_reroll`) et dans le rapport Markdown (« Relance, nouvelles offres »). Les rapports se rejouent avec elle.

## Les 24 nouveaux bonus

| Code | Nom | Rareté | Effet de référence (H) | Mécanisme |
| --- | --- | --- | --- | --- |
| R-37 | Lames runiques | Rare | +20 % à tous les dégâts, +10 % de cadence | Statistiques |
| R-38 | Écho des ricochets | Rare | +2 cibles secondaires, +25 % aux dégâts secondaires (unités à effet de zone) | Statistiques |
| R-39 | Malédiction tenace | Rare | Dégâts sur la durée : 3 échéances au lieu de 2 | Malédictions |
| R-40 | Chausse-trappes | Rare | Chaque ennemi ralenti 2 s à son apparition (vitesse ×0,6) | Apparition |
| R-41 | Réparations | Rare | +2 PV de forteresse à chaque vague gagnée, sans dépasser le maximum | Fin de vague |
| R-42 | Trésor de guerre | Rare | +100 or immédiatement | Immédiat |
| R-43 | Intérêts | Rare | +10 % de l'or possédé à chaque vague gagnée (25 au plus) | Fin de vague |
| R-44 | Promotion | Rare | Défenseurs actuels de niveau 1 → niveau 2, gratuitement | Immédiat |
| R-45 | Exécution | Rare | Un ennemi touché sous 10 % de ses PV est achevé (sauf le boss) | Dégâts |
| R-46 | Tueur de géants | Rare | +40 % contre les ennemis lourds et le boss | Cible |
| R-47 | Herse | Rare | Le premier ennemi qui atteint la forteresse dans chaque vague ne fait aucun dégât | Forteresse |
| R-48 | Tir de couverture | Rare | Longue portée : +1 de portée et +15 % de dégâts | Statistiques |
| R-49 | Rage du désespoir | Rare | +3 % de dégâts par PV de forteresse perdu (+45 % au plus) | Statistiques |
| R-50 | Levée en masse | Rare | −30 % aux achats, améliorations et spécialisations futurs | Prix |
| R-51 | Marque du chasseur | Rare | Tout tir direct marque sa cible 3 s : +10 % de dégâts reçus | Cible |
| R-52 | Prime de guerre | Rare | +2 or par élimination | Or |
| R-53 | Dernier souffle | Épique | Une fois par partie, la forteresse évite une défaite (1 PV puis +10 PV) | Forteresse |
| R-54 | Armée d'élite | Épique | +35 % à tous les dégâts, +20 % de cadence | Statistiques |
| R-55 | Ascension | Épique | Défenseurs actuels de niveau 1 ou 2 → niveau 3, gratuitement | Immédiat |
| R-56 | Frénésie sanguinaire | Épique | +1 % de dégâts par ennemi éliminé dans la partie (+50 % au plus) | Statistiques |
| R-57 | Forteresse imprenable | Épique | +12 PV maximum et soin complet | Immédiat |
| R-58 | Pluie de feu | Épique | +2 cibles secondaires, +0,5 de rayon ou de rebond, +40 % aux dégâts secondaires | Statistiques |
| R-59 | Fortune royale | Épique | +150 or et −20 % aux prix futurs | Immédiat et prix |
| R-60 | Temps suspendu | Épique | Ennemis ralentis 4 s à l'apparition ; ralentissements de vos unités +50 % | Apparition et statistiques |

Règles communes :
- Les pourcentages de dégâts s'additionnent avec ceux des autres bonus (section 27 du GDD) ; les cadences se multiplient.
- Les promotions gratuites (R-44, R-55) ne changent pas l'or payé : la revente reste calculée sur ce qui a été payé.
- Les réductions de prix (R-10, R-11, R-23, R-50, R-59) se multiplient, arrondi supérieur.
- Aucun de ces bonus n'a de contrepartie : la politique de choix de référence des tests et études (`Model.reference_bonus`) peut les choisir.

## Mesure : ce que le second lot change (21 novembre 2026)

Même étude que pour le rééquilibrage de la v0.232 : 200 missions, deux factions, trois arbres, dix compositions d'unités de base, trois tirages de bonus (7, 8, 9), soit 36 000 parties par version ; choix de la première offre, sans relance. Données : `design/essais/equilibre_bonus/parties_v233_{7,8,9}.txt` (v0.232 : `parties_reequilibre*.txt`).

| Mesure | Alliance v0.232 | Alliance v0.233 | Horde v0.232 | Horde v0.233 |
| --- | --- | --- | --- | --- |
| Meilleure marge moyenne | 63,6 % | 68,5 % | 66,3 % | **85,5 %** |
| Missions dans la cible 40-70 % | 119 | 109 | 99 | **11** |
| Missions encore gagnées à 100 % | 0 | 0 | 2 | **19** |
| Victoires, toutes compositions | 17,4 % | 22,6 % | 14,0 % | 23,8 % |

- **Les rares et épiques profitent bien plus à la Horde.** Plusieurs d'entre eux renforcent les unités à effet de zone et à dégâts sur la durée (Écho des ricochets, Pluie de feu, Malédiction tenace), qui composent deux des trois unités de base de la Horde contre une seule pour l'Alliance.
- La meilleure marge varie encore de 28 points en moyenne selon le tirage (37 en v0.232).
- **L'équilibrage reste à faire** (décision du porteur : poser la base d'abord) : revoir les bonus favorables aux unités à effet de zone, ou les coefficients de PV de la Horde, pour revenir à la cible 40-70 %.

## Compatibilité

- Règles portées par `rules_v233` (`valley_model.gd`), lues par `Replay.rules_v233_for(version)` : un rapport de la v0.232 se rejoue avec le tirage uniforme parmi 36 bonus, sans relance ; un rapport plus ancien avec les douze bonus d'origine.
- Outil d'étude : `V232=1` rejoue avec les règles de la v0.232.

## Contrôles

- `tests/test_bonus_rarity.gd` (402 contrôles) : raretés, fréquences de tirage par rang (4 500 cartes par rang, écart toléré de 3 points), anciennes règles, relance (unique, gratuite, journalisée, rejouable), effets des 24 bonus, partie complète avec relance rejouée.
- L'aperçu « Voir les détails » montre l'or gagné, les niveaux promus, les nouveaux prix et la forteresse après le choix.
