# Prototype v0.227 — Refonte des cartes, chapitres 15 à 20 (missions 141 à 200)

Fin de la refonte des cartes demandée par le porteur (chapitre 12 en v0.224, 13-14 en v0.225, 10-11 en v0.226).

- **Soixante nouvelles cartes** (ids inchangés) : chapitres 15 et 16 (îles flottantes), 17 et 18 (côte, brume marine), 19 et 20 (nécropole, revenants). Serpentins, peignes, aller-retour, deux ou trois entrées qui fusionnent, routes qui se croisent puis fusionnent. Les nombres de routes restent ceux des anciennes cartes, sauf la mission 174 (deux routes au lieu de trois).
- **Équilibre calibré par simulation** : PV restants proches de ceux des anciennes cartes pour la composition de référence des deux factions ; sur quelques cartes serrées (170, 174, 177, 194) l'Alliance garde 6 à 7 PV, contre 3 à 14 auparavant. Ordre d'emplacements de référence : 3, 4, 2 (inchangé).
- **Tests** : tables des chapitres adaptées (`test_sky_chapter`, `test_eagle_chapter`, `test_coast_chapter`, `test_seamist_chapter`, `test_necro_chapter`, `test_revenant_chapter`).
- **Décor** : désactivé sur ces soixante cartes (`DecorArt.REWORKED_MAPS`) ; demande à Codex.
- **Anciens rapports de partie** : ils ne se rejouent plus sur ces cartes.
- **Trois gestes de Codex intégrés** (validés par le porteur) : **Arbalète lourde** (type 24, lot `aa7462b`, carreau à 0,44 s, impact seul si la cible est derrière la pointe) ; **Fronde elfe** (type 25, lot `a683912`, galet à 0,40 s) ; **Hache en chaîne** (type 26, lot `f0b6867`, hache à 0,52 s, ricochets de 0,068 s dans l'ordre de `shot.secondary`, éclat à l'arrivée de la hache). Rendu seulement. Limite : à bout portant la hache n'est pas dessinée en vol, mais le premier impact garde l'instant d'arrivée normal.
- Tracés et emplacements = propositions de prototype à confirmer en jeu.
