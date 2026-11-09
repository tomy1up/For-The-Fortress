# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 10 novembre 2026 — Claude Code

**Dernière version publiée : v0.165** (commit `ed69b00`, tag `v0.165`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.165) avec ZIP et `.sha256`, SHA-256 `78ca12c7…de27`). **60 missions jouables : les chapitres 1 à 6 sont complets.** Aucun travail de code en cours non commité.

Contenu de la v0.165 : missions 52 à 60 (fin du chapitre 6 des marais), neuf tracés où le Noyé régénère dans l'eau. Fiche : `design/Missions_052_060_Marais.md`. Le Noyé et ses règles viennent de la v0.164 (`design/Mission_051_Eaux_Mortes_Noye.md`).

Points techniques à connaître :

- Les cartes 52–60 sont dans `scripts/drowned_maps.gd` (module de données, branché par `Maps.for_id`). Chaque eau est un tronçon `{route, from, to}` défini entre deux sommets du trajet.
- Les emplacements n'ont pas été dessinés à la main : ils ont été choisis par couverture du trajet puis par simulation (16 jeux par carte, trois ordres d'achat), avec les talents **réellement acquis** à chaque mission (26 à 30 points, répartis comme dans les tests). Les emplacements 3, 4 et 2 sont ceux de la stratégie de référence des tests ; les trois autres servent au décor. Les scripts de génération et de simulation ne sont pas dans le dépôt : si une carte est modifiée, refaire cette simulation plutôt que de déplacer des emplacements à l'œil.
- Le placement du décor automatique dépend de l'identifiant de la carte : changer l'identifiant peut supprimer les roseaux ou les ruines que le test exige (La Crue s'appelle `marsh_overflow` pour cette raison).
- `configure_wave_set` et `configure_enemy_hp` refusent sans rien dire d'être appelés après `select_faction`. Dans une simulation, régler aussi `meta_ranks` avant `select_faction` (les PV de forteresse en dépendent).
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`).
- Vérification du ZIP : les captures en fenêtre réduite (`--background`) échouent par aléa sur cette machine ; utiliser la vérification sans cette option.
- Essais d'équilibrage : `C:/Projet/.tools/survey_marsh_52_60.gd` → `dist/marsh-missions52-60-survey.json` (1 944 parties, trois orientations de talents).
- Régression complète : 101 suites, 58 725 contrôles Godot, 17 tests Python. 86 essais Windows et 86 empreintes de sources réussis. Nouvelle suite : `tests/test_drowned_chapter.gd`.

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 7, nouveau biome (missions 61–70). Son ambiance et sa nouveauté sont à choisir avec le porteur avant tout développement.
- Visuels (Codex) : voir `TODO_VISUELS.md` (Noyé, eau, bassins, ruine compacte, animations).

## Questions ouvertes pour le porteur

- **Biome du chapitre 7** : quelle ambiance pour les missions 61–70 ?
- **Courbe de difficulté du chapitre 6** : le Delta des Noyés (55) est le plus dur (20 victoires sur 108 pour l'Alliance, 6 pour la Horde) et le Cœur du Marais (60, finale) est l'un des plus faciles (74 et 33). Faut-il durcir la finale ?
- **Poids des talents** : dans les essais automatiques, l'orientation choisie pèse plus que la carte (Alliance : 288 victoires sur 324 avec Entraînement, 40 avec Étude des arcanes ; Horde : 88 avec Entraînement, 16 avec Rituels). Est-ce voulu, ou faut-il rééquilibrer les arbres ?
- Équilibrage des marais à confirmer en jeu, surtout côté Horde.
