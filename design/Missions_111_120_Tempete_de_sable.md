# Missions 111 à 120 — Chapitre 12, la tempête de sable

## Décision du porteur et statut de conception

Le 11 novembre 2026, le porteur valide la **tempête de sable** comme nouveauté du chapitre 12, second chapitre du biome désert et ruines (CAMP-017). Cadre : `Cadrage_missions_101_200.md`. Les valeurs ci-dessous sont des réglages de prototype à confirmer ; noms, tracés et emplacements sont des propositions de Claude Code.

## Règle de l'affixe

`{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25}`

- Toutes les 15 s de combat (15 s, 30 s, 45 s…), une rafale dure 5 s : **la portée de tous les défenseurs baisse de 25 %** (leurs fenêtres de couverture sont recalculées avec la portée réduite). Les autres caractéristiques ne changent pas.
- Une annonce de 3 s précède chaque rafale (de 12 s à 15 s pour la première).
- Le chiffre de l'intervalle suit le temps de combat, pas le temps réel. La règle est déterministe, indépendante du pas de temps (test dédié), enregistrée dans le rapport et rejouable ; un rapport dont l'affixe est retiré ou altéré n'est plus rejouable à l'identique.
- Bornes acceptées par le modèle : intervalle de 10 à 40 s, annonce de 1 à 4 s, durée de 2 à 12 s, réduction de 5 à 60 %, valeurs entières, `durée + annonce + 1 ≤ intervalle`.
- Interface : libellé « Tempête de sable · portée −25 % pendant 5 s toutes les 15 s » avec infobulle, fiche de mission « Nouveau : Tempête de sable · portée réduite », anneau de portée du défenseur sélectionné réduit pendant la rafale.

Effet moyen : un tiers du temps de combat avec un quart de portée en moins.

## Cartes

PV ennemis `99 + numéro` % (de 210 % à 219 %), rencontres standard du Gué, **70 PO** (60 + 5 par chapitre au-delà du dixième) et aucune XP. Cartes dans `prototype/scripts/desert_maps.gd`, décor `desert`.

| Mission | Carte | Entrées | Trajets | PV restants A / H |
| --- | --- | --- | --- | --- |
| 111 | Le Mirage | 1 | 39 | 20 / 29 |
| 112 | La Vallée des Scorpions | 1 | 39 | 18 / 26 |
| 113 | Les Ruines Englouties | 2, pression alternée | 30 / 28 | 9 / 18 |
| 114 | Les Arches de Grès | 2, pression alternée | 34 / 24 | 14 / 14 |
| 115 | La Citerne Perdue | 1 | 45 | 17 / 29 |
| 116 | Le Sphinx Brisé | 2, pression alternée | 35 / 32 | 14 / 22 |
| 117 | Le Col des Vents de Sable | 3 | 33 / 30 / 34 | 7 / 15 |
| 118 | La Salle du Sarcophage | 1 | 50 | 13 / 17 |
| 119 | Le Cratère de Verre | 1 | 43 | 16 / 26 |
| 120 | La Pyramide Ensablée | 3 | 31 / 28 / 32 | 8 / 24 |

*Refonte des cartes (v0.224) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

## Méthode de réglage

Même méthode que les chapitres précédents : simulation avec les talents réels (51 points), 16 jeux d'emplacements et trois ordres d'achat par carte (48 parties par faction) avec la tempête active, armée de référence (Alliance : archer, arbalétrier, arbalétrier ; Horde : deux haches et un chaman), jeu retenu = celui qui maximise les PV restants de la faction la plus faible. Les deux factions gagnent chaque carte.

Constats :

- **La tempête durcit nettement le chapitre** : avec les trajets courts du chapitre 11 (24 à 32), 6 cartes sur 10 n'avaient aucun jeu gagnant pour les deux factions. Les trajets longs (31 à 38, ceux du chapitre 10) rétablissent des marges de 8 à 29 PV.
- **Cartes les plus serrées** : la Pyramide Ensablée (120, finale, Alliance 8 PV), le Col des Vents de Sable (117, Alliance 10 PV), les Arches de Grès (114, 14 / 14).
- **La rafale ne dépend pas de la position** : contrairement aux éruptions, les emplacements peuvent être permutés librement ; l'ordre d'achat des tests est le standard (3, 4, 2).

## Habillage (Codex)

Repère provisoire dans `valley_view.gd::_draw_sandstorm` : liséré sable qui s'épaissit pendant l'annonce, voile translucide et traînées pendant la rafale. Format prêt pour l'habillage de Codex : un effet `effect.sandstorm` dans `assets/animations/effect.sandstorm/` avec une animation `warning` (mode `progress`, progression 0 → 1 pendant l'annonce) et une animation `storm` (mode `time`, boucle pendant la rafale) ; les images sont étirées sur l'emprise du plateau projeté. Voir `Format_animations.md`.

## Limites connues

- Valeurs, tracés, noms et gains à confirmer en jeu. Aucun son.
- La difficulté ressentie à ces PV (210 à 219 %) n'est pas éprouvée en jeu libre.
