# Missions 151 à 160 — Chapitre 16, îles flottantes : l'aigle des cimes

## Décision du porteur et statut de conception

Le 12 novembre 2026, le porteur retient **l'aigle des cimes** comme nouveauté du chapitre 16, second chapitre du biome des îles flottantes (CAMP-017). Il avait relevé que le chapitre 14 était déjà un affixe : la nouveauté de ce chapitre revient donc à un **attaquant**, comme aux chapitres 2, 6 et 10. Le principe est validé ; nom, statistiques et composition sont des **réglages de prototype à confirmer** proposés par Claude Code.

## Règle

- **Aigle des cimes** (type 11, neutre, commun aux deux factions, `scripts/eagle_encounters.gd`) : rapide et fragile, 14 PV de base, vitesse 1,5 (le sprinter : 24 PV, vitesse 1,65), −1 PV de forteresse, 4 d'or par élimination. Il arrive en groupes serrés à partir de la vague 3 (jeu de rencontres `sky_eagles`, dérivé de celui du Gué).
- Réglage : avec 30 PV et une vitesse de 1,9, puis 24 PV et 1,6, l'Alliance de référence perdait dès les vagues 5 à 8 ; à 14 PV et 1,5 les deux factions gagnent.
- PV ennemis (courbe ralentie) : 245 % à 249 %. **90 PO** à la première victoire, aucune XP.
- Visuel provisoire : la silhouette du loup (cadre partagé) ; l'illustration et l'animation de l'aigle sont à produire par Codex.

## Cartes

`prototype/scripts/sky_maps.gd`. Formes du chapitre 12 prolongées d'un tronçon supplémentaire (trajets de 39 à 47) pour compenser la hausse des PV. PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 151 | L'Aire des Aigles | 1 | 38 | 245 % | 20 / 29 |
| 152 | Le Nid de Brume | 1 | 49 | 245 % | 20 / 29 |
| 153 | Les Pitons Jumeaux | 2 | 34 | 246 % | 15 / 27 |
| 154 | Les Trois Aires | 3 | 38 | 246 % | 19 / 29 |
| 155 | La Corniche Ventée | 1 | 50 | 247 % | 7 / 27 |
| 156 | Le Col du Ciel | 2 | 40 | 247 % | 20 / 29 |
| 157 | Les Rapaces | 3 | 36 | 248 % | 20 / 28 |
| 158 | Le Perchoir | 2 | 38 | 248 % | 20 / 29 |
| 159 | La Chute d'Azur | 1 | 47 | 249 % | 19 / 29 |
| 160 | Le Trône des Nuées | 3 | 36 | 249 % | 18 / 29 |

*Refonte des cartes (v0.227) : tracés, nombres d'entrées, trajets et PV restants ci-dessus remplacent ceux de la conception d'origine ; la méthode de réglage décrite plus bas (simulation avec talents réels, armée de référence) reste celle d'origine, appliquée à ces nouveaux tracés par `tools/sim_map_candidates.gd` (la mesure retient la composition de référence des tests de chapitre). Tracés et emplacements = propositions de prototype à confirmer en jeu. Voir `design/essais/refonte_cartes/` et le GDD (MAJ-61 à MAJ-64).*

Les marges sont larges presque partout (20 PV = aucune perte) : la mission 155 est la plus serrée (8 PV côté Alliance, 6 côté Horde). L'aigle rend le chapitre plus facile que le 15 sur ces tracés prolongés ; à rééquilibrer si le porteur le souhaite.

## Contrôles

`tests/test_eagle_chapter.gd` (définition de l'aigle, catalogue, cartes, rapports rejouables, récompenses, enchaînement), cas `sky151…sky160` de `verify_windows_export.py`.
