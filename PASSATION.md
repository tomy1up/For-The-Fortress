# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 9 novembre 2026 — Claude Code

**Dernière version publiée : v0.164** (commit `900da97`, tag `v0.164`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.164) avec ZIP et `.sha256`, SHA-256 `efaff707…2a43`). 51 missions jouables. Aucun travail de code en cours non commité.

Contenu de la v0.164 : le **Noyé**, nouveauté du chapitre 6 choisie par le porteur (créature des marais qui régénère ses PV dans l'eau), et la mission 51 « Les Eaux Mortes ». Fiche : `design/Mission_051_Eaux_Mortes_Noye.md`.

Points techniques à connaître :

- Le Noyé est l'ennemi de type 9, jeu de rencontres `marsh_drowned` (`scripts/drowned_encounters.gd`). Réglages d'essai : 150 PV de base, vitesse 0,85, régénération `REGEN_PER_SECOND = 0.05` (5 % des PV max par seconde).
- L'eau est un champ facultatif `flooded` d'une carte : tronçons `{route, from, to}` en distance parcourue, réservés aux marais. La régénération est calculée exactement par tronçon (indépendante du pas de temps), dans `valley_model.gd` (`_update_positions`).
- Ancien piège : `configure_wave_set` et `configure_enemy_hp` refusent sans rien dire d'être appelés après `select_faction`. Les configurer avant.
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`). L'oubli de `drowned_encounters.gd` n'a été vu que par la vérification du ZIP.
- Essais d'équilibrage : `C:/Projet/.tools/survey_marsh_51.gd` (et `survey_marsh_51_control.gd`, sans régénération) → `dist/marsh-mission51-*.json`.
- Régression complète : 100 suites, 54 048 contrôles Godot, 17 tests Python. 48 essais Windows et 85 empreintes de sources réussis. Nouvelle suite : `tests/test_drowned.gd`.

Pour Codex : le visuel du Noyé (silhouette provisoire de la tortue) et l'habillage des tronçons inondés (repère bleu provisoire) sont dans `TODO_VISUELS.md`.

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : missions 52–60, qui exploitent le Noyé sur d'autres tracés (plusieurs entrées, eau sur la partie commune).
- Visuels (Codex) : voir `TODO_VISUELS.md`.

## Questions ouvertes pour le porteur

- Confirmer en jeu le principe d'eau retenu (tronçons inondés du chemin) et la force de la régénération (5 % par seconde). Dans les essais automatiques, elle fait passer l'Alliance de 70 à 42 victoires sur 108 et la Horde de 32 à 14.
- Équilibrage des marais à confirmer en jeu, surtout côté Horde.
- Vérification du ZIP : sur cette machine, les captures en fenêtre réduite (`--background`) se bloquent parfois ; relancer sans cette option si besoin.
