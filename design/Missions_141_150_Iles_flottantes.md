# Missions 141 à 150 — Chapitre 15, îles flottantes et cité céleste

## Décisions et statut de conception

- **Courbe de PV ralentie (décision du porteur, 12 novembre 2026)** : à 240-249 % de PV avec +1 % par mission, l'Alliance de référence (51 points de talent) ne gagnait plus au-delà d'environ la mission 146 et aucune disposition des emplacements n'y changeait rien. Le porteur retient **+0,5 % par mission à partir de la mission 141** : PV ennemis `239 + (numéro − 139) ÷ 2` (division entière), soit 240 % aux missions 141 et 142, 244 % aux missions 149 et 150 et 269 % à la mission 200. Jusqu'à la mission 140, `99 + numéro` % inchangé. La borne des PV acceptés passe à 244 %.
- **Huitième biome : îles flottantes et cité céleste.** Recommandation de Claude Code sur délégation du porteur (« comme tu le souhaites », 12 novembre 2026) ; **biome confirmé par le porteur le 12 novembre 2026**. La toundra et glace est écartée (elle recoupait les Ardoises).
- Chapitre 15 sans règle propre (CAMP-017) : rencontres standard du Gué, **85 PO** à la première victoire, aucune XP. La nouveauté du chapitre 16 reste à proposer.
- Décor `sky`, palette d'essai (bleu-gris clair) posée par le code, sans pièce de décor : habillage à produire par Codex.

## Cartes

`prototype/scripts/sky_maps.gd`. Tracés repris des formes longues du chapitre 12 (les courts ne laissent aucun jeu gagnant à ce niveau de PV). PV de forteresse restants avec l'armée de référence (Alliance / Horde), talents réels à 51 points :

| Mission | Carte | Entrées | Trajet principal | PV ennemis | PV restants A / H |
| --- | --- | --- | --- | --- | --- |
| 141 | Le Ponton des Nuées | 1 | 34 | 240 % | 20 / 29 |
| 142 | Le Pont de Brume | 1 | 35 | 240 % | 13 / 12 |
| 143 | La Porte des Nuages | 2 | 38 | 241 % | 13 / 12 |
| 144 | Les Flèches d'Azur | 3 | 36 | 241 % | 14 / 13 |
| 145 | Les Jardins Suspendus | 1 | 31 | 242 % | 12 / 21 |
| 146 | Le Belvédère | 2 | 35 | 242 % | 13 / 17 |
| 147 | Les Courants Ascendants | 3 | 35 | 243 % | 7 / 21 |
| 148 | Le Dôme Céleste | 2 | 38 | 243 % | 11 / 18 |
| 149 | L'Île Effondrée | 1 | 32 | 244 % | 12 / 25 |
| 150 | La Citadelle des Cimes | 3 | 33 | 244 % | 9 / 24 |

Les marges sont plus minces que celles du chapitre 14 (la plus fine : mission 147, 7 PV côté Alliance). Si la boutique ne compense pas la hausse de PV, la courbe devra être revue (O-016).

## Contrôles

`tests/test_sky_chapter.gd` (cartes, rapports rejouables, récompenses, enchaînement), cas `sky141…sky150` de `verify_windows_export.py`.
