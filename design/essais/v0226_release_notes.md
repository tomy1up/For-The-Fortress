# Prototype v0.226 — Refonte des cartes, chapitres 10 et 11 (missions 91 à 110)

Suite de la refonte des cartes (v0.224 chapitre 12, v0.225 chapitres 13 et 14), à la demande du porteur : tracés plus variés et plus complexes au fil des chapitres.

- **Vingt nouvelles cartes** (ids inchangés) : serpentins, peigne, aller-retour, deux ou trois entrées qui fusionnent en tronc commun. Les nombres de routes restent ceux des anciennes cartes (chapitre 10 : 4 cartes à une route, 3 à deux, 3 à trois ; chapitre 11 : idem). Complexité volontairement plus modérée que le chapitre 12, pour que la progression reste régulière jusqu'au chapitre 20.
- **Équilibre calibré par simulation** (`tools/sim_map_candidates.gd`) : PV restants de la forteresse proches de ceux des anciennes cartes pour la composition de référence des deux factions.
- **Tests** : `test_garrison_chapter.gd` (4 474 contrôles) et `test_desert_chapter.gd` (4 714) adaptés aux nouvelles longueurs.
- **Décor** : désactivé sur ces vingt cartes (`DecorArt.REWORKED_MAPS`) ; demande à Codex. La mission 94 (`garrison_hall`) change de tracé : les essais de gestes de Codex qui s'appuient sur elle sont concernés.
- **Anciens rapports de partie** : ils ne se rejouent plus sur ces vingt cartes.
- Tracés et emplacements = propositions de prototype à confirmer en jeu.
