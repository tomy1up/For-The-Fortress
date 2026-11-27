# Cumul des nouveautés de l'Héroïque (v0.259)

**Statut.** Lot 3 du cadrage du 25 novembre 2026 (`Cadrage_Heroique_Mythique_2026-11-25.md`). Les règles et les valeurs ont été validées par le porteur le 26 novembre 2026 (« Tout valider », sur la proposition de Claude Code). Ce sont des réglages de prototype à confirmer en jeu.

## Règles

- **En Héroïque seulement.** Le Normal ne change pas.
- **Chapitres 1 et 2** : aucun rappel, puisqu'aucun biome n'a encore été traversé.
- **Chapitres 3 à 10** : chaque mission rappelle **une** nouveauté d'un biome déjà traversé. Les missions impaires rappellent un ancien attaquant, les missions paires un ancien affixe. Les biomes passés reviennent à tour de rôle.
- **Chapitres 11 à 20** : **deux** rappels par mission, un attaquant et un affixe, venus de deux biomes différents.
- Le rappel est **fixe pour chaque mission**, sans hasard, et jamais le même deux missions de suite.

### Attaquant rappelé

Un groupe s'ajoute aux vagues indiquées, après les ennemis habituels de la vague.

| Biome | Attaquant | Groupe | Vagues |
| --- | --- | --- | --- |
| Gué | Tortue gardienne | 2 | 4, 7 et 10 |
| Ardoises | Bouquetin des crêtes | 4 | 4, 7 et 10 |
| Terres volcaniques | Golem de magma (et ses Braises) | 2 | 4, 7 et 10 |
| Citadelle | Capitaine de garnison | 1 | 7 et 10 |
| Mines | Taupe des galeries | 4 | 4, 7 et 10 |
| Îles flottantes | Aigle des cimes | 8 | 4, 7 et 10 |
| Côtes | Crabe pilleur | 3 | 4, 7 et 10 |

Trois biomes ne rappellent jamais d'attaquant :
- le **Marais** : la Gueule-de-Vase ne régénère que dans l'eau du marais, il ne rappelle donc que son affixe ;
- le **Désert** : le Scorpion n'accélère que dans la tempête de sable, il ne rappelle donc que son affixe ;
- la **Nécropole** : c'est le dernier biome, elle n'est jamais rappelée.

L'espacement dans le groupe reprend celui du biome d'origine. C'est un choix technique de Claude Code : 3 s pour les tortues, 2 s pour les bouquetins, 4 s pour les golems, 1,6 s pour les taupes, 0,6 s pour les aigles et 2,5 s pour les crabes.

### Affixe rappelé

- Il garde les valeurs du premier chapitre de son biome.
- Il est **avancé de 6 s** : pour un affixe toutes les 12 s, il tombe à 6, 18, 30 s, entre deux déclenchements de l'affixe du biome (12, 24, 36 s). Pour un affixe toutes les 15 s (Cor d'alarme, Courants ascendants), il tombe à 9, 24, 39 s.
- Vents contraires, qui est permanent, s'ajoute simplement.
- L'affixe rappelé n'est jamais celui du biome de la mission.

## Dans le jeu

- **Écran de campagne** : en Héroïque, le bloc « Mode infini », propre au Normal, devient « Rappels de l'Héroïque ». Il liste l'attaquant rappelé (biome et vagues) et l'affixe rappelé (biome, décalage de 6 s). Les règles s'affichent au survol.
- **Voir les ennemis** : les attaquants rappelés y figurent.
- **En partie** :
  - la ligne d'affixe sous le titre devient « Affixe du biome · rappel : affixe rappelé », avec les deux règles au survol ;
  - le bandeau d'affixe montre l'effet en cours, puis l'annonce, puis Vents contraires ; l'affixe rappelé y est préfixé « Rappel » ;
  - les avertissements et les effets de chaque affixe sont dessinés comme dans leur biome d'origine. La crue, par exemple, inonde la chaussée du marais.
- La prévision de vague et l'info-bulle du bouton de vague comptent les attaquants rappelés.

## Technique

- `prototype/scripts/heroic_recalls.gd` : table des attaquants (`ATTACKERS`), noms des biomes, `plan(number)` (rotation), `attacker_groups`, `valid_attackers`, `describe`.
- **Catalogue** :
  - `CampaignCatalogue.biome_affix(biome)` ;
  - `recalled_affix(number, difficulty)` et `recalled_attackers(number, difficulty)`, vides en Normal ;
  - `recall_text`, `AFFIX_NAMES`.
- **Combat** (`valley_model.gd`) :
  - deuxième affixe `recalled_affix` (`configure_recalled_affix`) ; validation commune `valid_affix` ;
  - accès par identifiant (`affix_of(id)`) et décalage (`affix_shift(id)`, −6 s pour le rappelé) ;
  - compteur d'impulsions propre au rappelé (`recall_next`) ;
  - attaquants rappelés `recalled_attackers` (`configure_recalled_attackers`), ajoutés aux calendriers par `extra_groups()`.
  - Sans rappel, tous les calculs restent identiques au bit près : les anciennes suites et les anciens rapports passent sans changement.
- **Affichage** (`valley_view.gd`) : chaque affixe actif est dessiné (`_draw_biome_affix_for`) ; bandeau par affixe (`affix_banner_for`) ; couleur des impulsions selon l'affixe qui les produit.
- **Rapport** : champs `recalled_affix` et `recalled_attackers`, refusés au rejeu avant la v0.259 (« Rappels invalides. »).
- **Captures** : avec `--capture-difficulty=1`, une variante de mission (`dune101`, `marsh44play`…) ouvre désormais cette mission dans l'onglet de la difficulté. Les missions précédentes et les 100 premières du Normal sont réussies dans le profil isolé des aperçus.
- **Outil d'étude** (`tools/faction_study.gd`) :
  - `HEROIC=1` : Héroïque complet, rappels compris ;
  - `HEROIC=champ` : PV et champions, comme la mesure de la v0.258 ;
  - `HEROIC=hp` : PV seuls.
- **Tests** : `prototype/tests/test_heroic_recalls.gd`. Il vérifie la rotation des 200 missions, le catalogue, le modèle, le décalage, le bandeau et l'écran de campagne. Il joue et rejoue les 180 missions héroïques des chapitres 3 à 20, à petits et grands pas pour sept d'entre elles.

## Mesure : effet sur la difficulté de l'Héroïque

Meilleure des 30 compositions, 40 missions (une sur cinq), tirages 7, 8 et 9, 51 points de talent. Marge = PV de forteresse restants en fin de mission. Fichiers : `design/essais/equilibre_bonus/v259/`.

Les colonnes « Champions » reprennent la mesure de la v0.258 (PV × 1,3 et champions, sans rappel). Les colonnes « cumul » ajoutent les rappels de la v0.259. Les deux premières colonnes de mesure prennent toujours la première offre de bonus. Les deux dernières jouent en joueur avisé : bonus choisis d'après leur valeur mesurée, avec relance (`POLICY=refwise`).

**Alliance** (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Champions (v0.258) | Champions et cumul (v0.259) | Idem, joueur avisé (v0.258) | Idem, joueur avisé (v0.259) |
| --- | --- | --- | --- | --- |
| 1 | 93 % | 93 % | 99 % | 99 % |
| 2 | 85 % | 85 % | 94 % | 94 % |
| 3 | 77 % | 72 % | 90 % | 90 % |
| 4 | 61 % | 44 % | 78 % | 64 % |
| 5 | 39 % | 18 % | 73 % | 39 % |
| 6 | 29 % | 25 % | 57 % | 46 % |
| 7 | 11 % | 11 % | 12 % | 25 % |
| 8 | 0 % | 0 % | 5 % | 0 % |
| 9 | 0 % | 0 % | 0 % | 0 % |
| 10 | 0 % | 0 % | 5 % | 0 % |
| 11 à 15 | 0 % | 0 % | 1 % | 0 % |
| 16 à 20 | 0 % | 0 % | 0 % | 0 % |

**Horde** (marge moyenne des missions mesurées, en % des PV de forteresse) :

| Chapitre | Champions (v0.258) | Champions et cumul (v0.259) | Idem, joueur avisé (v0.258) | Idem, joueur avisé (v0.259) |
| --- | --- | --- | --- | --- |
| 1 | 100 % | 100 % | 100 % | 100 % |
| 2 | 95 % | 95 % | 100 % | 100 % |
| 3 | 91 % | 87 % | 98 % | 95 % |
| 4 | 90 % | 85 % | 99 % | 98 % |
| 5 | 61 % | 25 % | 92 % | 69 % |
| 6 | 69 % | 59 % | 94 % | 87 % |
| 7 | 51 % | 29 % | 81 % | 71 % |
| 8 | 25 % | 11 % | 62 % | 50 % |
| 9 | 2 % | 0 % | 45 % | 22 % |
| 10 | 13 % | 3 % | 42 % | 29 % |
| 11 à 15 | 0 % | 0 % | 5 % | 0 % |
| 16 à 20 | 0 % | 0 % | 1 % | 0 % |

**Ce qu'on en retient :**
- **Le cumul coûte en moyenne 10 points de marge à l'Alliance et 15 à la Horde**, sur les missions qui restaient gagnables (première offre). Il pèse surtout aux chapitres 4 à 7, jusqu'à 40 à 60 points sur une mission isolée.
- Missions perdues par toutes les compositions, sur 40 : 28 pour l'Alliance (27 en v0.258) et 23 pour la Horde (22). En joueur avisé : 27 (23) et 19 (15).
- À partir du chapitre 11, l'Héroïque reste perdu partout, avec ou sans cumul : la hausse uniforme de 30 % des PV en est la cause (fiche des champions, `Champions_mutants_v0258.md`).
- Le calibrage mission par mission (lot 5) devra tenir compte des rappels de chaque mission, et des bonus héroïques (lot 4) s'ils sont faits avant.

## Limites

- **L'Héroïque n'est toujours pas calibré** : le calibrage mission par mission reste le lot 5.
- Les règles et les tailles de groupe n'ont pas été essayées en jeu par le porteur : elles restent à confirmer.
- Quand l'annonce d'un affixe tombe pendant l'effet de l'autre, le bandeau montre l'effet en cours. L'annonce reste visible sur le plateau (liseré, emplacement ou entrée signalés).
- Les visuels des affixes et des attaquants ont été dessinés pour leur biome d'origine. Ils apparaissent maintenant sur d'autres décors, comme l'éruption dans le désert. Codex pourra juger s'il faut les adapter.
