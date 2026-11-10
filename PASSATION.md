# Passation entre agents

Mettre ce fichier à jour à chaque fin de mission ou changement d'agent (voir `AGENTS.md`, section « Passation entre agents »). Garder seulement l'état courant ; l'historique est dans Git et `design/`. Les tâches artistiques pour Codex sont dans `TODO_VISUELS.md`.

## État au 10 novembre 2026 — Claude Code

**Dernière version publiée : v0.169** (commit `574a8ec`, tag `v0.169`, [préversion GitHub](https://github.com/tomy1up/For-The-Fortress/releases/tag/v0.169) avec ZIP et `.sha256`, SHA-256 `48bd2f12…0a4c`). 70 missions jouables : les chapitres 1 à 7 sont complets. Aucun travail de code en cours non commité.

Trois versions pendant cette mission, toutes sur demande du porteur :

- **v0.168** : chapitre 7 durci (trajets raccourcis) et arbres de talents équilibrés entre eux. Fiche : `design/Equilibrage_arbres_talents_v0168.md`.
- **v0.169** : écart entre factions corrigé. Sans talent, Alliance et Horde se valaient ; tout l'écart venait des talents (Alliance environ deux fois plus puissante). Le porteur a choisi de **baisser l'Alliance** pour la ramener au niveau de la Horde, car les cartes sont déjà réglées pour la Horde. Facteurs `TREE_SCALE` de la v0.169 : Alliance Bastion 2,4 / 0,38, Maîtrise du tir 0,58 / 0,52, Arts arcaniques 1,1 / 1,05 ; Horde inchangée (1,0 / 1,0, 1,15 / 1,0, 1,0 / 1,4). Résultat chapitre 7 avec l'armée de chaque arbre : Alliance 64 %, Horde 57 % de victoires (97 % et 52 % avant) ; les six arbres entre 187 et 235 victoires sur 360.

Points techniques à connaître :

- **Trois jeux de règles de talents** : `RULES_HISTORICAL` (0, avant 0.168), `RULES_V168` (1, tableau `TREE_SCALE_V168`), `RULES_CURRENT` (2, `TREE_SCALE`). `Model.talent_rules` est choisi par `Replay.talent_rules_for(game_version)` pour rejouer chaque rapport avec les valeurs de sa version. Toute future retouche des talents doit conserver l'ancien tableau et ajouter un jeu de règles.
- **Compositions de référence des tests** : Horde « deux haches + chaman » (`[3,3,5]`) ; Alliance « archer, arbalétrier, arbalétrier » (`[0,1,1]`, ancien `[0,1,2]` ne gagnait plus à talents égaux). Chapitre 4 (`test_headwinds.gd`) : compositions et renforts propres à chaque mission pour l'Alliance. Le finale du chapitre 7 a été rallongé (27, 24, 27).
- **Relevés historiques** : `Survey.historical_talents = true` (`tests/survey_shop.gd`) rejoue le relevé validé de la boutique avec les valeurs de talents d'origine.
- **Outil d'essai** : `tools/survey_campaign_sample.gd` accepte `natural_armies = true` (chaque orientation de talents joue l'armée de son arbre). À préférer aux compositions fixes pour comparer des arbres. Banc de mesure des arbres (dichotomie du PV ennemi maximal battu, armées naturelle et doublée) : hors dépôt, méthode décrite dans la fiche des talents.
- Les emplacements des cartes 52–70 sont choisis par simulation avec les talents réels (et la composition de référence de chaque faction) : refaire la simulation en cas de modification, ne pas déplacer à l'œil.
- Régression complète : 103 suites, 62 495 contrôles Godot, 17 tests Python. 52 essais Windows ciblés et 87 empreintes de sources réussis.
- L'outil PowerShell de l'agent peut être indisponible : lancer `powershell.exe …` depuis Bash (voir `AGENTS.md`). Ne pas écrire de chemins `\v…` dans un script Python lancé en ligne : écrire un fichier.
- Tout nouveau fichier d'exécution doit être déclaré dans trois listes d'export (voir `AGENTS.md`).

Fichiers non suivis à laisser tels quels sauf demande : `design/essais/v0109_game_frames/`, `prototype/tools/survey_route_workshops.gd.uid`. `prototype/scripts/enemy_walk_art.gd` apparaît modifié mais son contenu est identique (fins de ligne) : ne pas le committer.

## Prochaines étapes possibles

- Code (Claude Code) : chapitre 8, missions 71–80, avec la nouveauté du biome volcanique. À ne développer qu'après le choix de la nouveauté par le porteur.
- Visuels (Codex) : voir `TODO_VISUELS.md`, en particulier tout l'habillage volcanique.

## Questions ouvertes pour le porteur

- **Nouveauté du chapitre 8** (missions 71–80) : terrain de lave (ennemis plus rapides ou insensibles sur des tronçons), éruptions (emplacement recouvert de cendres), attaquant de feu, ou pluie de cendres ? Recommandation : lave avec ennemis plus rapides.
- **Courbe de difficulté du chapitre 7** : le Pont d'Obsidienne (66) est la carte la plus dure des deux factions (7 et 12 victoires sur 108 avec l'armée de chaque arbre), alors que le Seuil des Cendres, les Coulées Figées et le Cœur du Volcan côté Horde sont presque toujours gagnés. À lisser ?
- **Unités chères** : les arbres du mage et du chaman supposent d'acheter cette unité (100 or) à l'ouverture. Si les joueurs achètent d'abord les unités peu chères, ces arbres seront moins rentables.
- Équilibrage à confirmer en jeu : talents des deux factions, chapitres 4 à 7. Les chapitres 1 à 3 n'ont pas été remesurés avec les talents abaissés de l'Alliance (leurs tests de campagne passent).
