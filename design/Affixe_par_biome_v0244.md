# Un affixe par biome, étape 1 (v0.244)

**Statut.** Décision du porteur du 23 novembre 2026 (MAJ-91 à MAJ-93, `design/Biomes_cumul_2026-10-31.md`). Les valeurs d'affixes et les coefficients de PV sont des réglages de prototype à confirmer en partie réelle.

## Règle

- Chacun des dix biomes a son affixe, actif sur ses deux chapitres.
- Le chapitre pair de chaque biome introduit en plus un nouvel attaquant.
- La mission 1 reste sans affixe, pour apprendre le jeu. L'affixe du Gué s'appliquera dès la mission 2.
- Livraison par étapes : (1) cinq affixes existants étendus, cette version ; (2) cinq affixes à proposer puis créer ; (3) cinq attaquants à proposer puis créer, avec Codex.

| Biome | Chapitres | Affixe | Attaquant du chapitre pair |
| --- | --- | --- | --- |
| Gué | 1-2 | à proposer | Tortue gardienne |
| Ardoises | 3-4 | Vents contraires | à proposer |
| Marais | 5-6 | à proposer | Gueule-de-Vase |
| Terres volcaniques | 7-8 | Éruptions | à proposer |
| Citadelle | 9-10 | à proposer | Garnison |
| Désert | 11-12 | Tempête de sable | à proposer |
| Mines | 13-14 | Éboulement | à proposer |
| Îles flottantes | 15-16 | à proposer | Aigle des cimes |
| Côtes | 17-18 | Brume marine | à proposer |
| Nécropole | 19-20 | à proposer | Revenant |

## Éboulement sur une seule entrée

Les missions 121, 122, 125 et 128 n'ont qu'une entrée. L'éboulement la bloque pendant 7 s : les ennemis prévus attendent la fin du blocage, puis sortent groupés dans le même ordre, espacés de 0,3 s (`rockfall_held_times`). Si le groupe déborde sur un blocage suivant, il attend aussi sa fin. La prévision de vague annonce ces sorties retardées.

## Recalibrage

Méthode : 30 compositions, tirages de bonus 7, 8 et 9, première offre. Pour chaque mission et chaque faction, le coefficient de PV est cherché par dichotomie vers 55 % de meilleure marge (accepté de 47 à 63 %), sans descendre sous la courbe de base. Les missions que l'armée de référence perd sont ensuite abaissées par pas de 3 points. Le porteur a accepté de passer sous la courbe pour huit cas.

| Chapitre | Alliance avant | Alliance après | Horde avant | Horde après |
| --- | --- | --- | --- | --- |
| 3 | 54,4 % | 51,8 % | 77,2 % | 61,5 % |
| 7 | 54,4 % | 49,0 % | 56,8 % | 54,3 % |
| 11 | 62,2 % | 54,1 % | 54,6 % | 54,3 % |
| 13 | 49,5 % | 52,3 % | 52,4 % | 51,4 % |
| 17 | 56,2 % | 54,4 % | 57,4 % | 56,2 % |

« Avant » est la mesure de la v0.236, sans affixe sur ces chapitres. Sans recalibrage, l'affixe faisait tomber le chapitre 7 à 5,7 % (Alliance) et 0,4 % (Horde).

**Résultat : 96 cas sur 100 dans la cible de 40 à 70 %.** Hors cible : Alliance 23 (38 %) et 61 (72 %), Horde 22 (73 %) et 23 (75 %). La marge varie brutalement sur ces missions : l'Alliance passe en 23 de 38 % à 100 % de la courbe à 75 % à 98 %.

Sous la courbe de base (décision du porteur, 23 novembre 2026) : Alliance 63, 64 et 65 à 98 %, 66 à 96 %, 68 à 94 %, 69 à 92 % ; Horde 66 à 96 %, 68 à 98 %.

## Proposition pour l'étape 2 (non validée par le porteur)

Cinq affixes à effet distinct des cinq existants (cadence, désactivation, portée, entrée bloquée, or). Tous sont annoncés 3 s avant et ne dépendent que du temps de combat. Valeurs de départ à confirmer.

| Biome | Affixe proposé | Effet |
| --- | --- | --- |
| Gué (dès la mission 2) | Crue | Toutes les 20 s, pendant 5 s, les ennemis avancent 10 % plus vite |
| Marais | Vapeurs toxiques | Toutes les 16 s, pendant 5 s, les défenseurs infligent 20 % de dégâts en moins |
| Citadelle | Cor d'alarme | Toutes les 20 s, les ennemis présents reçoivent un bouclier de 10 % de leurs PV maximum |
| Îles flottantes | Courants ascendants | Toutes les 20 s, les ennemis présents bondissent d'une case vers la forteresse |
| Nécropole | Drain d'âmes | Toutes les 20 s, pendant 5 s, chaque ennemi éliminé soigne ses voisins proches de 10 % de leurs PV maximum |

## Limites

- Mesure sur des stratégies fixes avec la première offre de bonus : le ressenti en partie réelle reste à confirmer (O-017).
- Les chapitres pairs déjà pourvus d'un affixe ne sont pas recalibrés ici. Quand ils recevront leur nouvel attaquant à l'étape 3, ils devront l'être.

Données et scripts : `design/essais/equilibre_bonus/v244/`.
