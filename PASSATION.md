# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 10 novembre 2026 — Claude Code

**Dernière version publiée : v0.167** (commit `7c2d780`, tag `v0.167`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.167) avec ZIP et `.sha256`, SHA-256 `4a4846a4…4625`). **70 missions jouables : les chapitres 1 à 7 sont complets.** Aucun travail de code en cours non commité.

Deux versions pendant cette mission :

- **v0.166** : finale du chapitre 6 (Cœur du Marais, mission 60) durcie à la demande du porteur. L'eau couvre la jonction jusqu'à la forteresse (24 unités sur 29). Essais : Alliance 74 → 53 victoires sur 108, Horde 33 → 16. Comparaison des longueurs d'eau dans `design/Missions_052_060_Marais.md`. Un jeu de rencontres propre à la finale serait le levier suivant (décision du porteur).
- **v0.167** : chapitre 7, biome des **terres volcaniques et cendres** (choix du porteur, 10 novembre 2026). Missions 61–70, dix cartes sans règle propre ; la nouveauté du biome est prévue au **chapitre 8** (CAMP-017). Fiche : `design/Missions_061_070_Volcan.md`.

Points techniques à connaître :

- Cartes volcaniques : `scripts/volcanic_maps.gd` (module de données branché par `Maps.for_id`, décor `volcanic` accepté par `validation_error`). Rencontres standard (pas de `wave_set_id`), PV ennemis `99 + numéro` %, borne portée à 169 %.
- Les repères de couleur du décor `volcanic` sont neutres (sol `3d3837`, faces `4a403d` / `352e2d` dans `valley_view.gd`, aperçu dans `campaign_screen.gd`) ; pas de décor automatique : `scenery_for` ne traite que les ardoises, les marais et le chapitre 1.
- Emplacements non dessinés à la main : choisis par couverture du trajet puis par simulation (16 jeux par carte, trois ordres d'achat) avec les talents **réels** de la mission (30 à 35 points). Les outils de génération et de simulation sont hors dépôt (scratchpad de session). Pour modifier une carte, refaire cette simulation au lieu de déplacer des emplacements à l'œil. Les emplacements 3, 4 et 2 sont ceux de la stratégie de référence des tests.
- Les chapitres de test suivent un modèle : `tests/test_drowned_chapter.gd` (52–60) et `tests/test_volcanic_chapter.gd` (61–70). Un nouveau chapitre doit aussi mettre à jour les tests « contenu à venir » (`test_campaign_preview`, `test_mission_scout`, `test_campaign_states`, `test_chapter_one`, `test_campaign_progress`, `test_campaign_sample`) et `verify_windows_export.py` (cas `volcano<N>`, `volcano70completed`).
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`).
- Régression complète : 102 suites, 62 195 contrôles Godot, 17 tests Python. 68 essais Windows et 87 empreintes de sources réussis. Essais d'équilibrage : `C:/Projet/.tools/survey_volcano_61_70.gd` → `dist/volcano-missions61-70-survey.json` (2 160 parties).
- L'outil PowerShell de l'agent peut être indisponible : lancer `powershell.exe …` depuis Bash (voir `AGENTS.md`).
- Piège shell : un chemin de fichier `\v…` écrit dans un script Python via heredoc devient un caractère de tabulation verticale ; écrire les scripts dans un fichier plutôt qu'en ligne.

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 8, missions 71–80, avec la nouveauté du biome volcanique. À ne développer qu'après le choix de la nouveauté par le porteur.
- Visuels (Codex) : voir `TODO_VISUELS.md`, en particulier tout l'habillage volcanique (sol, décor, palette).

## Questions ouvertes pour le porteur

- **Nouveauté du chapitre 8** (missions 71–80) : attaquant de feu, terrain de lave (tronçons sur le chemin), affixe de combat ou autre piste ? À proposer et valider avant de coder.
- **Difficulté du chapitre 7** : nettement plus facile que le chapitre 6 (Alliance de 41 à 90 victoires sur 108, Horde de 15 à 62) et sa finale est dans la moyenne (76 / 46). Faut-il la durcir, comme celle du chapitre 6 ?
- **Poids des talents** : l'orientation pèse plus que la carte (Alliance : 357 victoires sur 360 avec Entraînement, 90 avec Étude des arcanes). Est-ce voulu, ou faut-il rééquilibrer les arbres ?
- Équilibrage à confirmer en jeu, surtout côté Horde.
