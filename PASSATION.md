# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 10 novembre 2026 — Claude Code

**Dernière version publiée : v0.168** (commit `291744a`, tag `v0.168`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.168) avec ZIP et `.sha256`, SHA-256 `cb948e16…2a64`). 70 missions jouables : les chapitres 1 à 7 sont complets. Aucun travail de code en cours non commité.

Contenu de la v0.168, à la demande du porteur :

- **Arbres de talents équilibrés.** Un banc de mesure donne la puissance de chaque arbre (PV ennemis maximaux battus, par dichotomie) avec l'armée qu'un joueur de cet arbre constituerait. Les arbres de la Horde se valaient déjà ; ceux de l'Alliance non (Arts arcaniques 43 % et Bastion 69 % de Maîtrise du tir à 51 points). Facteurs `TREE_SCALE` dans `meta_talents_expanded.gd` ([début, fin] par arbre, indexés [faction][arbre]) : Bastion 3,8 / 1,2 ; Arts arcaniques 2,0 / 2,15 ; Voie des maléfices 1,15 / 1,0 ; Démolition 1,0 / 1,4 ; Maîtrise du tir et Fureur de guerre 1,0. Fiche, méthode et résultats : `design/Equilibrage_arbres_talents_v0168.md`. Test : `tests/test_talent_balance.gd` (échelle, règle historique, parité mesurée à 51 points).
- **Compatibilité.** Seules les valeurs des bonus changent (rangs, structure, PV de forteresse et sauvegardes inchangés). Les rapports de version antérieure à 0.168 se rejouent avec les valeurs historiques (`Replay.legacy_talents`, `Model.talent_rules_legacy`). Toute future retouche des effets de talents doit relever ce seuil de version.
- **Chapitre 7 durci.** Trajets raccourcis sur neuf cartes (`volcanic_maps.gd` régénéré, emplacements recalculés), de 34 à 25 unités jusqu'à la finale. Victoires de l'arbre de référence : −8 % Alliance, −16 % Horde. Fiche : `design/Missions_061_070_Volcan.md`.
- **Outil d'essai.** `tools/survey_campaign_sample.gd` accepte `natural_armies = true` : chaque orientation de talents joue l'armée de son arbre (unité de l'arbre achetée à l'ouverture). À utiliser pour comparer des arbres ; les compositions fixes de l'outil favorisent l'archer et la hache. Relevés : `C:/Projet/.tools/survey_volcano_61_70_natural.gd` → `dist/volcano-missions61-70-natural.json`.
- Régression complète : 103 suites, 62 490 contrôles Godot, 17 tests Python. 52 essais Windows ciblés et 87 empreintes de sources réussis.

Points techniques à connaître :

- Un banc de mesure des arbres a été écrit hors dépôt (scratchpad de session) : dichotomie du PV ennemi maximal battu, armées naturelle et doublée, budgets de 10, 20, 35 et 51 points. Sa méthode est décrite dans la fiche des talents ; le refaire plutôt que de régler à l'œil.
- Le chapitre 7 et les cartes des marais ont des emplacements choisis par simulation avec les talents de l'arbre de référence (Maîtrise du tir / Fureur de guerre). Cet arbre n'a pas changé : leurs réglages restent valides.
- L'outil PowerShell de l'agent peut être indisponible : lancer `powershell.exe …` depuis Bash (voir `AGENTS.md`). Ne pas écrire de chemins `\v…` dans un script Python lancé en ligne : écrire un fichier.
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`).

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 8, missions 71–80, avec la nouveauté du biome volcanique. À ne développer qu'après le choix de la nouveauté par le porteur.
- Visuels (Codex) : voir `TODO_VISUELS.md`, en particulier tout l'habillage volcanique.

## Questions ouvertes pour le porteur

- **Nouveauté du chapitre 8** (missions 71–80) : terrain de lave, affixe d'éruption, nouvel attaquant de feu ou autre piste ? À choisir avant de coder.
- **Écart entre factions.** À armées comparables, les talents de l'Alliance sont environ deux fois plus puissants que ceux de la Horde (+136 contre +67,5 à 51 points pour les arbres de référence), et avec l'armée de chaque arbre l'Alliance gagne 97 % des parties du chapitre 7 contre 52 % pour la Horde. Les cartes sont réglées pour que la Horde puisse gagner, donc l'Alliance les écrase. Faut-il aligner les talents de la Horde sur ceux de l'Alliance, ou régler la difficulté par faction ?
- **Unités chères.** Les arbres du mage et du chaman supposent d'acheter cette unité (100 or) à l'ouverture. Si les joueurs achètent d'abord les unités peu chères, ces arbres seront moins rentables et leurs facteurs devraient monter.
- Équilibrage à confirmer en jeu : arbres de talents, chapitre 7, marais.
