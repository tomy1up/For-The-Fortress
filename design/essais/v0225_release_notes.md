# Prototype v0.225 — Refonte des cartes, chapitres 13 et 14 (missions 121 à 140)

Suite de la refonte lancée avec le chapitre pilote 12 (v0.224), à la demande du porteur : tracés plus variés et plus complexes au fil des chapitres.

- **Vingt nouvelles cartes** (ids inchangés, géométrie refondue) : serpentins, deux ou trois entrées qui fusionnent en tronc commun, routes qui se croisent puis fusionnent, aller-retour, peigne. Chapitre 13 : 4 cartes à une route, 5 à deux, 1 à trois. Chapitre 14 (éboulements) : 5 cartes à trois routes, 5 à deux.
- **Équilibre calibré par simulation** (`tools/sim_map_candidates.gd`, désormais avec ordre d'emplacements paramétrable) : PV restants de la forteresse proches de ceux des anciennes cartes pour la composition de référence des deux factions. Les anciennes cartes les plus justes (missions 127 et 128) ont un plancher de 8 et 12 PV pour ne pas être reproduites telles quelles.
- **Tests** : `test_mine_chapter.gd` (5 024 contrôles) et `test_rockfall_chapter.gd` (5 746) adaptés ; l'ordre d'emplacements de référence est unifié à 3, 4, 2.
- **Décor** : désactivé sur ces vingt cartes (`DecorArt.REWORKED_MAPS`) ; demande à Codex dans `ECHANGES_CLAUDE_VERS_CODEX.md`.
- **Anciens rapports de partie** : ils ne se rejouent plus sur ces vingt cartes.
- Tracés et emplacements = propositions de prototype à confirmer en jeu.
