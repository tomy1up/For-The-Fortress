# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 9 novembre 2026 — Claude Code

**Dernière version publiée : v0.162** (commit `bc31cad`, tag `v0.162`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.162) avec ZIP et `.sha256`, SHA-256 `2708e952…bb26`). 45 missions jouables. Aucun travail en cours non commité.

Fait pendant cette mission :

- Reprise du projet depuis Codex : `AGENTS.md` (consignes communes, répartition des rôles), `CLAUDE.md`, `TODO_VISUELS.md`, ce fichier.
- Fin de la v0.162 commencée par Codex : missions 44 « Les Chenaux Oubliés » et 45 « Le Cloître Submergé », fiche `design/Missions_044_045_Marais.md`, notes de version, README.
- `test_campaign_guidance.gd` supposait 20 missions et échouait depuis l'ajout de la mission 21 ; il lit désormais le nombre de missions jouables dans le catalogue.
- `test_export_sources.py` lance PowerShell avec `-ExecutionPolicy Bypass`.
- Régression complète : 99 suites, 51 106 contrôles Godot, 17 tests Python. 22 essais Windows et 84 empreintes de sources réussis.

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : missions 46–50 pour terminer la découverte des marais.
- Visuels (Codex) : voir `TODO_VISUELS.md`.

## Questions ouvertes pour le porteur

- Équilibrage des marais à confirmer en jeu, surtout côté Horde (31 victoires sur 108 aux missions 44 et 45 dans les essais automatiques).
- Nouveauté du second chapitre des marais (missions 51–60) : attaquants propres au biome ou affixe, à proposer et faire valider.
