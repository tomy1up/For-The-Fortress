# Rééquilibrage des PV d'ennemis — v0.232

**Statut.** Cible décidée par le porteur le 20 novembre 2026 : **la meilleure composition d'une mission doit finir avec 40 à 70 % de ses PV de forteresse** (une victoire sérieuse, plus une réussite à 100 % pour qui connaît les bonnes unités). Les coefficients par mission ci-dessous sont des **réglages de prototype à confirmer** en partie réelle (MAJ-69).

## Pourquoi

L'étude du catalogue élargi (`design/Bonus_catalogue_v0232.md`) a montré que les 36 bonus apportent de la variance mais ne touchent pas le plafond : avec l'ancien comme avec le nouveau système, la meilleure des 30 compositions de l'étude gagnait presque chaque mission avec 100 % de ses PV de forteresse.

## Règle

PV ennemis joués = courbe de base de la mission (section 62 du GDD, réduction de la Horde comprise) × coefficient de rééquilibrage de la mission et de la faction.

- Coefficients : `REBALANCE_PERCENT` dans `prototype/scripts/campaign_catalogue.gd`, un par mission et par faction (Alliance, Horde), entre 100 et 150 %. Fonction : `Catalogue.rebalance_percent(numéro, faction)` ; PV joués : `Catalogue.faction_hp_percent(numéro, faction)`.
- Aucun coefficient sous 100 % : une mission déjà dure n'est pas durcie, mais elle n'est pas non plus allégée.
- La limite de validité des PV d'ennemis passe de 264 % à 400 % (`Model.MAX_ENEMY_HP_PERCENT`). Les rapports des versions antérieures gardent leurs PV enregistrés et restent valides.
- La fiche de mission affiche les PV réellement joués (« PV ennemis : N % »).

## Méthode de calcul

1. **Mesure mission par mission** (`tools/faction_study.gd` avec `HPMUL`, tirage 7) : pour les 200 missions et les deux factions, meilleure marge des 30 compositions (trois arbres × dix compositions d'unités de base) à 100, 110, 120, 135 et 150 % des PV de base. Coefficient retenu : celui qui ramène cette meilleure marge à 55 % (interpolation linéaire). Données : `design/essais/equilibre_bonus/permission_s7.json`.
2. **Garde-fou de la composition de référence** (`REFONLY=1`, `POLICY=ref`) : la composition des tests de chapitre (Alliance archer, arbalétrier, arbalétrier ; Horde deux haches et un chaman), avec le choix de bonus de référence, doit garder au moins 25 % de marge. Le coefficient est plafonné en conséquence (29 missions concernées). Données : `permission_ref.json`.
3. **Ajustement par les tests de campagne** : chaque suite de chapitre joue réellement les missions par le parcours normal (profil, talents, lancement). Sur les missions où elle échouait encore, le coefficient a été abaissé par paliers de 5 à 6 points (missions isolées, puis tout le chapitre de la faction, car les résultats d'un chapitre interagissent). Table finale : `rebalance_table.json`.

## Vérification (20 novembre 2026)

Étude complète avec les PV rééquilibrés : 200 missions × 2 factions × 30 compositions × 3 tirages de bonus (7, 8, 9), soit 36 000 parties. Données : `parties_reequilibre{7,8,9}.txt`.

| Mesure | Alliance | Horde |
| --- | --- | --- |
| Meilleure marge moyenne (moyenne des 3 tirages) | 63,6 % | 66,3 % |
| Meilleure marge médiane | 66 % | 68 % |
| Missions dans la cible 40-70 % | 119 / 200 | 99 / 200 |
| Missions au-dessus de 70 % | 71 | 87 |
| Missions sous 40 % | 10 | 14 |
| Missions encore à 100 % | 0 | 2 |
| Victoires, toutes compositions confondues | 17,4 % | 14,0 % |

Meilleure marge moyenne par chapitre (Alliance / Horde) :

| Chapitre | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Alliance | 73 | 65 | 73 | 61 | 71 | 59 | 72 | 54 | 67 | 54 | 64 | 62 | 74 | 61 | 59 | 60 | 67 | 61 | 61 | 54 |
| Horde | 77 | 73 | 73 | 42 | 66 | 54 | 72 | 66 | 70 | 59 | 72 | 64 | 93 | 63 | 62 | 57 | 70 | 60 | 59 | 73 |

- **Avant le rééquilibrage**, la meilleure composition finissait à 100 % de marge sur presque toutes les missions ; la marge moyenne de toutes les compositions était de 16 à 25 % et le taux de victoire de 29 à 36 % (selon le tirage).
- **Variance** : pour une même mission et une même faction, la meilleure marge varie de 37 points en moyenne d'un tirage de bonus à l'autre (12 points avant). Le choix des bonus pèse désormais nettement sur l'issue.
- **Plus exigeant pour une armée mal choisie** : toutes compositions confondues, le taux de victoire passe à 17 % (Alliance) et 14 % (Horde).
- Régression complète : 143 suites sur 143, 179 190 contrôles Godot et 17 tests Python.

## Limites et points à surveiller

- Le chapitre 13 de la Horde reste au-dessus de la cible (93 %) : ses coefficients ont été abaissés pour que la suite de campagne passe. À reprendre si le porteur le juge trop facile.
- Le chapitre 4 de la Horde est sous la cible (42 %) ; les missions 32 et 40 de la Horde ne sont gagnées par aucune des 30 compositions de l'étude (la composition des tests y gagne). Ces missions étaient déjà dures avant ce lot.
- La mesure repose sur une stratégie d'achat fixe et des choix de bonus simples : un joueur qui adapte sa composition et ses bonus fera mieux. Le jugement en partie réelle reste à faire.
- Le combat d'échantillon des captures (`Main._capture_sample_combat`) joue sur la courbe de base, sans le coefficient : c'est un outil de contrôle, pas le jeu réel.
- Les unités de boutique n'ont pas été incluses dans la calibration : avec elles, la marge peut remonter.
