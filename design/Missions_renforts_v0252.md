# Renforts de vague pour les missions trop faciles (v0.252)

**Statut.** Demande du porteur du 24 novembre 2026 (« attaque ce sujet ») : corriger les réglages encore au-dessus de la cible de 40 à 70 % en retouchant la composition des vagues, puisqu'une hausse de PV ne suffisait pas (`design/Missions_trop_faciles_v0248.md`). Quantités, types et vagues : réglages de prototype à confirmer en partie réelle.

## Pourquoi les PV ne suffisaient pas

Sur ces missions, la meilleure composition est le plus souvent l'armée de référence elle-même, et la partie se joue sur le Seigneur de siège de la vague 10. Il inflige 20 dégâts à la forteresse, soit toute sa vie côté Alliance. Soit il meurt et la forteresse finit avec 80 à 100 % de ses PV, soit il passe et la partie est perdue. Un point de PV ennemi de plus fait passer d'un cas à l'autre.

## Ce qui change

- **Renforts de mission** : pour une mission et une faction, des groupes d'ennemis de base s'ajoutent après ceux de la vague, quatre secondes après le dernier groupe, comme entre deux groupes ordinaires. Ils ajoutent une pression régulière aux vagues 3 à 9, **sans toucher au boss** ni à ses PV.
- Les renforts sont propres à chaque faction, comme les coefficients de PV : une mission peut être renforcée pour l'Alliance et pas pour la Horde.
- Le joueur les voit comme les autres groupes : aperçu de la vague, infobulle du bouton de lancement, préparation de la mission. Ils rapportent leur or habituel.
- Les rapports de partie enregistrent les renforts et se rejouent à l'identique. Un rapport d'avant la v0.252 ne peut pas en porter.
- Code : `CampaignCatalogue.WAVE_REINFORCEMENTS`, `Campaign.groups_for`, `ValleyModel.configure_wave_reinforcements`. Test : `prototype/tests/test_wave_reinforcements.gd`.

## Les dix-huit réglages renforcés

Meilleure marge des 30 compositions (trois arbres, dix compositions d'unités de base), première offre de bonus, moyenne des tirages 7, 8 et 9 ; détail par tirage dans la dernière colonne.

| Faction | Mission | Renfort | Meilleure marge | Tirages 7 / 8 / 9 |
| --- | --- | --- | --- | --- |
| Alliance | 16 | 5 sprinters aux vagues 3, 5 et 7 | 77 % → 65 % | 85 / 50 / 60 |
| Alliance | 23 | 8 sprinters aux vagues 3, 5 et 7 | 75 % → 53 % | 85 / 30 / 45 |
| Alliance | 33 | 1 sprinter aux vagues 3, 5 et 7 | 77 % → 70 % | 90 / 60 / 60 |
| Alliance | 39 | 4 sprinters aux vagues 3, 5 et 7 | 82 % → 53 % | 75 / 35 / 50 |
| Alliance | 72 | 5 sprinters aux vagues 3, 5 et 7 | 82 % → 58 % | 80 / 35 / 60 |
| Alliance | 79 | 7 sprinters aux vagues 3, 5 et 7 | 80 % → 53 % | 80 / 35 / 45 |
| Alliance | 105 | 3 sprinters aux vagues 3, 5 et 7 | 80 % → 55 % | 85 / 25 / 55 |
| Alliance | 173 | 5 sprinters aux vagues 3, 5 et 7 | 73 % → 52 % | 85 / 20 / 50 |
| Alliance | 178 | 3 sprinters aux vagues 3, 5 et 7 | 78 % → 58 % | 95 / 35 / 45 |
| Alliance | 180 | 8 sprinters aux vagues 3, 5 et 7 | 92 % → 62 % | 70 / 55 / 60 |
| Horde | 11 | 2 élites aux vagues 5, 7 et 9 | 97 % → 63 % | 80 / 30 / 80 |
| Horde | 22 | 3 sprinters aux vagues 3, 5 et 7 | 73 % → 68 % | 65 / 50 / 90 |
| Horde | 38 | 7 sprinters aux vagues 3, 5 et 7 | 90 % → 63 % | 60 / 55 / 75 |
| Horde | 41 | 1 maraudeur aux vagues 4, 6 et 8 | 72 % → 58 % | 45 / 65 / 65 |
| Horde | 44 | 10 sprinters aux vagues 3, 5 et 7 | 85 % → 67 % | 65 / 45 / 90 |
| Horde | 79 | 5 sprinters aux vagues 3, 5 et 7 | 81 % → 65 % | 70 / 52 / 74 |
| Horde | 131 | 5 sprinters aux vagues 3, 5 et 7 | 76 % → 68 % | 83 / 55 / 66 |
| Horde | 175 | 5 sprinters aux vagues 3, 5 et 7 | 78 % → 55 % | 62 / 38 / 66 |

L'armée de référence gagne toujours ces missions dans les suites de campagne (28 suites relancées avec le tableau final).

## Sur toute la campagne

**392 réglages sur 398 dans la cible** de 40 à 70 %, aucun en dessous, 6 au-dessus (374, 0 et 24 en v0.251).

## Les six réglages laissés au-dessus de la cible

- **Missions 2 et 3, dans les deux factions** (83 à 93 %). Les tests garantissent qu'une stratégie simple de premier joueur gagne les trois premières missions, avec peu ou pas de talents. Les renforts qui ramènent la marge dans la cible lui font perdre la mission 2. Même trois élites tardives aux vagues 7 et 9 ont cet effet. Ces deux missions restent donc des missions de prise en main.
- **Horde 23 et 39** (75 et 100 %). Tous les renforts qui ramènent la marge sous 70 % font perdre l'armée de référence des suites.

## Méthode

1. Sonde vague par vague des 24 réglages : PV perdus à chaque vague par la meilleure composition et par la référence (`sonde_vagues.gd`).
2. Grille de 34 renforts gradués, essayés sans toucher au catalogue (`REINFORCE` de `tools/faction_study.gd`, `grid252.py`, `ladder252.py`), avec la meilleure marge et la référence sur trois tirages (`grille_renforts.json`).
3. Choix du renfort le plus proche de 55 à 65 %, puis garde dans 28 suites de campagne (`guard252.py`). Quatre passages : la garde a écarté les missions 2 et 3, puis H23 et H39.
4. Remesure finale depuis le catalogue (`measure252.py`, `renforts_mesures.json`) et nouvelle base de la campagne (`marges_campagne.json`).

Données et scripts : `design/essais/equilibre_bonus/v252/`.
