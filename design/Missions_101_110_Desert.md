# Missions 101 à 110 — Chapitre 11, désert et ruines

## Décision du porteur et statut de conception

Le 11 novembre 2026, le porteur retient **désert et ruines** comme sixième biome (chapitres 11 et 12) après avoir constaté que la toundra et glace recoupait les Ardoises. Le chapitre 11 ouvre le biome **sans règle propre** ; la tempête de sable arrive au chapitre 12. Cadre complet : `Cadrage_missions_101_200.md`. Noms, tracés et emplacements sont des propositions de prototype de Claude Code, à confirmer.

## Règles

- Rencontres standard du Gué (les dix vagues de base, sans tortue, sans Noyé, sans Garnison), pas d'affixe.
- PV ennemis `99 + numéro` % (CAMP-015), de **200 % à 209 %** : la borne des PV acceptés passe à 209 %.
- **Gains : 65 PO** à la première victoire (60 PO + 5 PO par chapitre au-delà du dixième, valeur d'essai) et **aucune XP** (CAMP-011 : les points de talent s'arrêtent à la mission 100). Les fiches de mission et le bilan n'affichent plus « XP » quand elle est nulle (`Catalogue.reward_text`).
- Décor `desert`, palette d'essai posée par le code (sable `#B59A67`, faces `#9A8358` et `#7A6845`, dans `assets/decor/decor.json`). Habillage à produire par Codex.

## Cartes

Cartes dans `prototype/scripts/desert_maps.gd`. Les formes reprennent celles des chapitres précédents en plus courtes ; PV de forteresse restants avec l'armée de référence (Alliance / Horde) :

| Mission | Carte | Entrées | Trajets | PV restants A / H |
| --- | --- | --- | --- | --- |
| 101 | Les Premières Dunes | 1 | 48 | 18 / 28 |
| 102 | L'Oasis Asséchée | 1 | 33 | 16 / 29 |
| 103 | Le Canyon Rouge | 2, pression alternée | 32 / 32 | 14 / 28 |
| 104 | Les Colonnes Brisées | 3 | 31 / 28 / 31 | 12 / 13 |
| 105 | La Route des Caravanes | 1 | 43 | 20 / 29 |
| 106 | Le Temple Ensablé | 2, pression alternée | 29 / 29 | 13 / 19 |
| 107 | Le Puits Perdu | 3 | 32 / 29 / 35 | 13 / 23 |
| 108 | Les Obélisques | 2, pression alternée | 32 / 32 | 16 / 28 |
| 109 | La Mer de Sable | 1 | 50 | 14 / 21 |
| 110 | La Nécropole Ancienne | 3 | 29 / 27 / 32 | 12 / 24 |

*Refonte des cartes (v0.226) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

## Méthode de réglage

Même méthode que les chapitres 6 à 10 : simulation avec les talents réellement accumulés (51 points : les cent premières missions donnent tout), 16 jeux d'emplacements et trois ordres d'achat par carte (48 parties par faction), armée de référence (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman), jeu retenu = celui qui maximise les PV restants de la faction la plus faible. Les deux factions gagnent chaque carte.

Constats :

- **Les formes du chapitre 10 étaient trop faciles** : avec 51 points de talent et des PV à 200 %, les cartes reprises telles quelles donnaient 17 à 29 PV de forteresse restants pour les deux factions (aucune perte). Les trajets ont été raccourcis (24 à 32 contre 31 à 38) pour retrouver des marges de 8 à 29 PV.
- **Cartes les plus serrées** : les Colonnes Brisées (104, Horde 8 PV) et la Nécropole Ancienne (110, finale, Alliance 10 PV).
- **Sensibilité des tracés** : comme aux chapitres précédents, de petits changements de forme font varier fortement le nombre de victoires.

## Habillage (Codex)

Désert et ruines : palette de sol, pièces de décor, placements par carte. Identifiants : `dune_first`, `dune_oasis`, `dune_canyon`, `dune_columns`, `dune_caravans`, `dune_temple`, `dune_well`, `dune_obelisks`, `dune_sea`, `dune_necropolis` (décor `desert`). Le format est celui de `design/Format_decor.md`.

## Limites connues

- Tracés, noms, emplacements et gains à confirmer en jeu.
- La difficulté au-delà de 209 % est inconnue : la courbe +1 % par mission sera mesurée chapitre par chapitre (voir le cadrage).
- Aucun son.
