# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 9 novembre 2026 — Claude Code

**Dernière version publiée : v0.163** (commit `c4b4f65`, tag `v0.163`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.163) avec ZIP et `.sha256`, SHA-256 `59e788f7…d723`). 50 missions jouables ; le chapitre 5 des marais est complet. Aucun travail de code en cours non commité.

Fait pendant les dernières missions :

- v0.162 : missions 44–45 (commencées par Codex), correction de `test_campaign_guidance.gd`.
- v0.163 : missions 46–50 (`map_definition.gd`, `campaign_catalogue.gd`), PV ennemis jusqu'à 149 %, tests étendus aux missions 41–50 et à la fin du chapitre 5 (`marsh50completed` dans `verify_windows_export.py`). Fiche : `design/Missions_046_050_Marais.md`.
- Essai d'équilibrage : `C:/Projet/.tools/survey_marsh_46_50.gd` → `dist/marsh-missions46-50-survey.json` (1 080 parties).
- Régression complète : 99 suites, 53 647 contrôles Godot, 17 tests Python. 44 essais Windows et 84 empreintes de sources réussis.

Pour Codex : les bassins des missions 46–50 sont des emplacements neutres posés par Claude Code ; voir `TODO_VISUELS.md`.

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 6, missions 51–60, une fois la nouveauté du biome choisie par le porteur.
- Visuels (Codex) : voir `TODO_VISUELS.md`.

## Questions ouvertes pour le porteur

- Nouveauté du chapitre 6 (missions 51–60) : attaquants propres aux marais ou affixe de combat, comme Vents contraires au chapitre 4. À choisir avant de développer ces missions.
- Équilibrage des marais à confirmer en jeu, surtout côté Horde (16 à 42 victoires sur 108 aux missions 46–50 dans les essais automatiques) ; la Nef (49) paraît plus clémente que ses voisines.
